import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/screens/dashboard/backup_service.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:provider/provider.dart';

class EditProfileAdminScreen extends StatefulWidget {
  const EditProfileAdminScreen({super.key});

  @override
  State<EditProfileAdminScreen> createState() => _EditProfileAdminScreenState();
}

class _EditProfileAdminScreenState extends State<EditProfileAdminScreen> {
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoadingUsername = false;
  bool _isLoadingPassword = false;

  List<FileSystemEntity> _backupFiles = [];
  bool _isLoadingBackup = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _usernameController.text = user?.username ?? '';
    _loadBackupList();
  }

  // ─── Backup Methods ────────────────────────────────────────────
  Future<void> _loadBackupList() async {
    try {
      final files = await BackupService.getBackupList();
      if (mounted) {
        setState(() => _backupFiles = files);
      }
    } catch (e) {
      debugPrint('Error load backup list: $e');
    }
  }

  Future<void> _doBackup() async {
    setState(() => _isLoadingBackup = true);
    final result = await BackupService.backupToLocal();
    setState(() => _isLoadingBackup = false);

    _showBackupSnackbar(result);
    if (result.isSuccess) await _loadBackupList();
  }

  Future<void> _doRestoreFromPicker() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff141c2f),
        title: const Text(
          'Restore dari File',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Anda akan memilih file backup (.db) dari penyimpanan.\n\n'
          '⚠️ Data saat ini akan diganti!\n'
          'Pastikan sudah backup data terbaru.\n\n'
          'Lanjutkan?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Color(0xFF00E0C6),
            ),
            child: const Text(
              'Pilih File',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoadingBackup = true);

    final result = await BackupService.restoreFromPicker(
      onBeforeRestore: () async {
        final db = await DatabaseService.instance.database;
        await db.close();
        DatabaseService.resetDatabase();
      },
    );

    setState(() => _isLoadingBackup = false);
    _showBackupSnackbar(result);
  }

  Future<void> _doRestore(String filePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff141c2f),
        title: const Text(
          'Konfirmasi Restore',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Data saat ini akan diganti dengan data backup.\n'
          'Pastikan Anda sudah backup data terbaru!\n\n'
          'Lanjutkan?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(226, 19, 136, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoadingBackup = true);

    final result = await BackupService.restoreFromFile(
      filePath,
      onBeforeRestore: () async {
        final db = await DatabaseService.instance.database;
        await db.close();
        DatabaseService.resetDatabase();
      },
    );

    setState(() => _isLoadingBackup = false);
    _showBackupSnackbar(result);
  }

  void _showBackupSnackbar(BackupResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatFileName(String path) {
    final name = path.split('/').last.replaceAll('.db', '');
    final parts = name.split('_');
    if (parts.length < 5) return name;

    final dateStr = parts[3];
    final timeStr = parts[4];

    try {
      final date = DateFormat('yyyyMMdd').parse(dateStr);
      final formattedDate = DateFormat('dd MMM yyyy', 'id').format(date);
      final time =
          '${timeStr.substring(0, 2)}:${timeStr.substring(2, 4)}:${timeStr.substring(4)}';
      return '$formattedDate  $time';
    } catch (_) {
      return name;
    }
  }

  // ─── Profile Methods ───────────────────────────────────────────
  Future<void> _simpanUsername() async {
    final authProvider = context.read<AuthProvider>();
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      _snack("Username tidak boleh kosong", true);
      return;
    }

    setState(() => _isLoadingUsername = true);
    final error = await authProvider.updateUsername(newUsername);
    setState(() => _isLoadingUsername = false);

    _snack(error ?? "Username berhasil diubah", error != null);
  }

  Future<void> _simpanPassword() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;

    if (newPw != confirmPw) {
      _snack("Password tidak cocok", true);
      return;
    }

    setState(() => _isLoadingPassword = true);
    final error = await DatabaseService.instance.updatePassword(
      userId: userId,
      newPassword: newPw,
    );
    setState(() => _isLoadingPassword = false);

    if (error == null) {
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }

    _snack(error ?? "Password berhasil diubah", error != null);
  }

  void _snack(String msg, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(
        backgroundColor: const Color(0xff0b1220),
        title: const Text(
          "Admin Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                _profileHeader(user),
                const SizedBox(height: 25),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // USERNAME
                    Expanded(
                      child: _card(
                        "Ubah Username",
                        Icons.person,
                        Column(
                          children: [
                            _input(_usernameController, "Username"),
                            const SizedBox(height: 15),
                            _button(
                              "SIMPAN USERNAME",
                              _isLoadingUsername,
                              _simpanUsername,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // PASSWORD
                    Expanded(
                      child: _card(
                        "Ubah Password",
                        Icons.lock,
                        Column(
                          children: [
                            _input(
                              _newPasswordController,
                              "Password Baru",
                              isPassword: true,
                              show: _showNewPassword,
                              toggle: () => setState(
                                () => _showNewPassword = !_showNewPassword,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _input(
                              _confirmPasswordController,
                              "Konfirmasi Password",
                              isPassword: true,
                              show: _showConfirmPassword,
                              toggle: () => setState(
                                () => _showConfirmPassword =
                                    !_showConfirmPassword,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _button(
                              "SIMPAN PASSWORD",
                              _isLoadingPassword,
                              _simpanPassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // BACKUP & RESTORE
                _card(
                  "Backup & Restore Database",
                  Icons.backup,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── 2 Tombol Utama ───────────────────────
                      _isLoadingBackup
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Row(
                              children: [
                                // Tombol Backup
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _doBackup,
                                    icon: const Icon(
                                      Icons.backup_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Backup',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromRGBO(
                                        226,
                                        19,
                                        136,
                                        1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Tombol Restore dari file picker
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _doRestoreFromPicker,
                                    icon: const Icon(
                                      Icons.folder_open_outlined,
                                      color: Color(0xFF00E0C6),
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Restore',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF00E0C6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: 6),
                      const Text(
                        '📁 Backup disimpan di: Download/KGamingBackup/',
                        style: TextStyle(fontSize: 11, color: Colors.white38),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(color: Colors.white12, height: 32),

                      // ─── Riwayat Backup ───────────────────────
                      const Text(
                        'Riwayat Backup',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _backupFiles.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Belum ada backup tersimpan',
                                style: TextStyle(color: Colors.white38),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _backupFiles.length,
                              separatorBuilder: (_, __) => const Divider(
                                color: Colors.white12,
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final file = _backupFiles[index];
                                final label = _formatFileName(file.path);

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.storage,
                                    color: Color.fromRGBO(226, 19, 136, 1),
                                  ),
                                  title: Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: index == 0
                                      ? const Text(
                                          'Terbaru',
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 11,
                                          ),
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Tombol restore dari list
                                      IconButton(
                                        icon: const Icon(
                                          Icons.restore,
                                          color: Color.fromRGBO(
                                            226,
                                            19,
                                            136,
                                            1,
                                          ),
                                        ),
                                        tooltip: 'Restore file ini',
                                        onPressed: () => _doRestore(file.path),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Widgets ───────────────────────────────────────────────────
  Widget _profileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff141c2f),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 50,
            color: Color(0xFF00E0C6),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.username ?? "-",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                (user?.role ?? "-").toUpperCase(),
                style: const TextStyle(color: Colors.cyanAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(String title, IconData icon, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff141c2f),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String hint, {
    bool isPassword = false,
    bool show = false,
    VoidCallback? toggle,
  }) {
    return TextField(
      controller: c,
      obscureText: isPassword && !show,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  show ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                ),
                onPressed: toggle,
              )
            : null,
        filled: true,
        fillColor: const Color(0xff1c273d),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _button(String text, bool loading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff00e0c6),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(text, style: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
