import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // AKSI
  // ─────────────────────────────────────────────
  Future<void> _simpanUsername() async {
    final authProvider = context.read<AuthProvider>();
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      _showSnackbar('Username tidak boleh kosong', isError: true);
      return;
    }

    if (newUsername == authProvider.user?.username) {
      _showSnackbar('Username sama dengan sebelumnya', isError: true);
      return;
    }

    setState(() => _isLoadingUsername = true);

    final error = await authProvider.updateUsername(newUsername);

    if (!mounted) return;
    setState(() => _isLoadingUsername = false);

    if (error != null) {
      _showSnackbar(error, isError: true);
    } else {
      _showSnackbar('Username berhasil diubah');
    }
  }

  Future<void> _simpanPassword() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return;

    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;

    if (newPw.isEmpty || confirmPw.isEmpty) {
      _showSnackbar('Semua kolom password harus diisi', isError: true);
      return;
    }
    if (newPw.length < 4) {
      _showSnackbar('Password minimal 4 karakter', isError: true);
      return;
    }
    if (newPw != confirmPw) {
      _showSnackbar('Konfirmasi password tidak cocok', isError: true);
      return;
    }

    setState(() => _isLoadingPassword = true);

    final error = await DatabaseService.instance.updatePassword(
      userId: userId,
      newPassword: newPw,
    );

    if (!mounted) return;
    setState(() => _isLoadingPassword = false);

    if (error != null) {
      _showSnackbar(error, isError: true);
    } else {
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showSnackbar('Password berhasil diubah');
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.redAccent
            : Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (_usernameController.text != (user?.username ?? '')) {
      _usernameController.text = user?.username ?? '';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141C2F),
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E0C6)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white10, height: 1),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100, // 🔥 batas maksimal lebar tablet
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── KIRI ─────────────────────────
                  Expanded(
                    child: Column(
                      children: [
                        _buildProfileInfo(user),
                        const SizedBox(height: 20),

                        _buildCard(
                          title: 'Ubah Username',
                          icon: Icons.person_outline,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _usernameController,
                                label: 'Username Baru',
                                hint: 'Masukkan username baru',
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 16),
                              _buildButton(
                                label: 'SIMPAN USERNAME',
                                isLoading: _isLoadingUsername,
                                onPressed: _simpanUsername,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // ── KANAN ────────────────────────
                  Expanded(
                    child: _buildCard(
                      title: 'Ubah Password',
                      icon: Icons.lock_outline,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _newPasswordController,
                            label: 'Password Baru',
                            hint: 'Minimal 4 karakter',
                            icon: Icons.lock_reset,
                            isPassword: true,
                            showPassword: _showNewPassword,
                            onToggleVisibility: () => setState(
                              () => _showNewPassword = !_showNewPassword,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Konfirmasi Password',
                            hint: 'Ulangi password baru',
                            icon: Icons.lock_reset,
                            isPassword: true,
                            showPassword: _showConfirmPassword,
                            onToggleVisibility: () => setState(
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildButton(
                            label: 'SIMPAN PASSWORD',
                            isLoading: _isLoadingPassword,
                            onPressed: _simpanPassword,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGET PEMBANTU
  // ─────────────────────────────────────────────

  Widget _buildProfileInfo(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E0C6).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin, size: 56, color: Color(0xFF00E0C6)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.username ?? '-',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E0C6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00E0C6),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  (user?.role ?? '-').toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00E0C6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00E0C6), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 28),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !showPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white30),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF00E0C6), size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white38,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(11, 55, 50, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0B1220),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
