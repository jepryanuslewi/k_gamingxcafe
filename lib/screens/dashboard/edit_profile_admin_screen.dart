import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _usernameController.text = user?.username ?? '';
  }

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
        backgroundColor: const Color(0xff141c2f),
        title: const Text("Admin Profile"),
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

                // USERNAME
                _card(
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

                const SizedBox(height: 20),

                // PASSWORD
                _card(
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
                          () => _showConfirmPassword = !_showConfirmPassword,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
