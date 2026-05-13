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

  // --- Logic tetap sama ---
  Future<void> _loadBackupList() async {
    try {
      final files = await BackupService.getBackupList();
      if (mounted) setState(() => _backupFiles = files);
    } catch (e) {
      debugPrint('Error load backup list: $e');
    }
  }

  Future<void> _doBackup() async {
    setState(() => _isLoadingBackup = true);
    final result = await BackupService.backupToLocal();
    setState(() => _isLoadingBackup = false);
    _snack(result.message, !result.isSuccess);
    if (result.isSuccess) await _loadBackupList();
  }

  Future<void> _doRestoreFromPicker() async {
    final confirm = await _showConfirmDialog("Restore dari File");
    if (confirm != true) return;
    setState(() => _isLoadingBackup = true);
    final result = await BackupService.restoreFromPicker(
      onBeforeRestore: _resetDb,
    );
    setState(() => _isLoadingBackup = false);
    _snack(result.message, !result.isSuccess);
  }

  Future<void> _doRestore(String filePath) async {
    final confirm = await _showConfirmDialog("Konfirmasi Restore");
    if (confirm != true) return;
    setState(() => _isLoadingBackup = true);
    final result = await BackupService.restoreFromFile(
      filePath,
      onBeforeRestore: _resetDb,
    );
    setState(() => _isLoadingBackup = false);
    _snack(result.message, !result.isSuccess);
  }

  Future<void> _resetDb() async {
    final db = await DatabaseService.instance.database;
    await db.close();
    DatabaseService.resetDatabase();
  }

  void _snack(String msg, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  String _formatFileName(String path) {
    final name = path.split('/').last.replaceAll('.db', '');
    final parts = name.split('_');
    if (parts.length < 5) return name;
    try {
      final date = DateFormat('yyyyMMdd').parse(parts[3]);
      return "${DateFormat('dd MMM yyyy', 'id').format(date)} ${parts[4].substring(0, 2)}:${parts[4].substring(2, 4)}";
    } catch (_) {
      return name;
    }
  }

  Future<void> _simpanUsername() async {
    setState(() => _isLoadingUsername = true);
    final error = await context.read<AuthProvider>().updateUsername(
      _usernameController.text.trim(),
    );
    setState(() => _isLoadingUsername = false);
    _snack(error ?? "Username diubah", error != null);
  }

  Future<void> _simpanPassword() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;
    setState(() => _isLoadingPassword = true);
    final error = await DatabaseService.instance.updatePassword(
      userId: userId,
      newPassword: _newPasswordController.text,
    );
    setState(() => _isLoadingPassword = false);
    _snack(error ?? "Password diubah", error != null);
  }

  Future<bool?> _showConfirmDialog(String title) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff141c2f),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text(
          "Data akan diganti. Lanjutkan?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffe21388),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI Layout (No Scroll, Fixed Height) ---

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Admin Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: Column(
          children: [
            _profileHeader(user),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Menyamakan tinggi kolom kiri & kanan
                children: [
                  // KOLOM KIRI
                  Expanded(
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(Icons.person, "Ubah Username"),
                          const SizedBox(height: 8),
                          _input(_usernameController, "Username"),
                          const SizedBox(height: 8),
                          _button(
                            "SIMPAN USERNAME",
                            _isLoadingUsername,
                            _simpanUsername,
                          ),
                          const Spacer(), // Memberi jarak fleksibel antar section
                          _sectionTitle(Icons.lock, "Ubah Password"),
                          const SizedBox(height: 8),
                          _input(
                            _newPasswordController,
                            "Password Baru",
                            isPassword: true,
                            show: _showNewPassword,
                            toggle: () => setState(
                              () => _showNewPassword = !_showNewPassword,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _input(
                            _confirmPasswordController,
                            "Konfirmasi Password",
                            isPassword: true,
                            show: _showConfirmPassword,
                            toggle: () => setState(
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _button(
                            "SIMPAN PASSWORD",
                            _isLoadingPassword,
                            _simpanPassword,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // KOLOM KANAN
                  Expanded(
                    child: _card(
                      child: Column(
                        children: [
                          _sectionTitle(
                            Icons.cloud_upload,
                            "Backup & Restore Database",
                            center: true,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _actionBtn(
                                  "Backup",
                                  Icons.cloud_upload,
                                  const Color(0xffe21388),
                                  _doBackup,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _actionBtn(
                                  "Restore",
                                  Icons.folder,
                                  Colors.transparent,
                                  _doRestoreFromPicker,
                                  isOutline: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Divider(color: Colors.white12),
                          const Text(
                            "Riwayat Backup",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child:
                                _backupHistoryList(), // ListView akan mengisi sisa tinggi yang tersedia
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff141c2f),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, size: 30, color: Color(0xFF00E0C6)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.username ?? "admin",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                (user?.role ?? "ADMIN").toUpperCase(),
                style: const TextStyle(color: Color(0xFF00E0C6), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff141c2f),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title, {bool center = false}) {
    return Row(
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00E0C6), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _input(
    TextEditingController c,
    String hint, {
    bool isPassword = false,
    bool? show,
    VoidCallback? toggle,
  }) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: c,
        obscureText: isPassword && !(show ?? false),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xff0b1220),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    show! ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onPressed: toggle,
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF00E0C6)),
          ),
        ),
      ),
    );
  }

  Widget _button(String text, bool loading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff00e0c6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
      ),
    );
  }

  Widget _actionBtn(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isOutline = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: isOutline ? Border.all(color: Colors.orangeAccent) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isOutline ? Colors.orangeAccent : Colors.white,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: isOutline ? Colors.orangeAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backupHistoryList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0b1220).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: _backupFiles.isEmpty
          ? const Center(
              child: Text(
                "Kosong",
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(5),
              itemCount: _backupFiles.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final file = _backupFiles[index];
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    _formatFileName(file.path),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color(0xffe21388),
                      size: 18,
                    ),
                    onPressed: () => _doRestore(file.path),
                  ),
                );
              },
            ),
    );
  }
}
