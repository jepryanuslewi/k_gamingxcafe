import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:k_gamingxcafe/widgets/search_widget.dart';
import 'package:k_gamingxcafe/models/user_model.dart';
// Import DatabaseHelper Anda, contoh:
// import 'package:k_gamingxcafe/database/db_helper.dart';

class DahboardPegawai extends StatefulWidget {
  const DahboardPegawai({super.key});

  @override
  State<DahboardPegawai> createState() => _DahboardPegawaiState();
}

class _DahboardPegawaiState extends State<DahboardPegawai> {
  List<UserModel> _allUsers = [];
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshUserList(); // Ambil data saat pertama kali buka
  }

  // 1. FUNGSI UNTUK MENAMBAH USER KE DATABASE ASLI
  Future<void> _addUser(String username, String password, String role) async {
    try {
      // Mengambil instance database dari DatabaseService kamu
      final db = await DatabaseService.instance.database;

      await db.insert('users', {
        'username': username,
        'password': password,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Refresh list agar user baru langsung muncul di tabel
      _refreshUserList();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User $username berhasil didaftarkan!")),
        );
      }
    } catch (e) {
      print("Error adding user: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menambah user. Username mungkin sudah ada."),
          ),
        );
      }
    }
  }

  // 2. FUNGSI UNTUK MENAMPILKAN DIALOG FORM REGISTRASI
  void _showAddUserDialog() {
    final TextEditingController userController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    String selectedRole = 'staff'; // Default role
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color.fromRGBO(20, 28, 47, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Registrasi Pegawai Baru",
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: userController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Username",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.person, color: Color(0xffe21388)),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Username tidak boleh kosong" : null,
                ),
                TextFormField(
                  controller: passController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.lock, color: Color(0xffe21388)),
                  ),
                  validator: (v) =>
                      v!.length < 3 ? "Password minimal 3 karakter" : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color.fromRGBO(20, 28, 47, 1),
                  value: selectedRole,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Role Akses",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  items: ['admin', 'staff']
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addUser(
                    userController.text,
                    passController.text,
                    selectedRole,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Simpan Akun",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI UTAMA: Mengambil data dari Tabel 'users' asli dari DatabaseService
  Future<void> _refreshUserList() async {
    setState(() => _isLoading = true);

    try {
      // Memanggil instance database dari DatabaseService Anda
      final db = await DatabaseService.instance.database;

      // Mengambil data dari tabel 'users' diurutkan berdasarkan ID terbaru
      final List<Map<String, dynamic>> userMaps = await db.query(
        'users',
        orderBy: 'id DESC',
      );

      setState(() {
        // Mengonversi List Map menjadi List UserModel
        _allUsers = userMaps.map((map) => UserModel.fromMap(map)).toList();
        _isLoading = false;
      });

      // Debugging untuk memastikan data terbaca (Opsional)
      print("Data user berhasil dimuat: ${_allUsers.length} orang");
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => _isLoading = false);

      // Memberi notifikasi jika terjadi error database
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat database: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan input di Search Bar
    final filteredUsers = _allUsers.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.username.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(10, 15, 28, 1),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          height: 550,
          width: 760,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(20, 28, 47, 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              // Search Bar terintegrasi
              SearchWidget(
                text: "Cari Pegawai...",

                onChanged: (value) {
                  setState(() {
                    _searchQuery =
                        value; // Ini yang akan memfilter list secara otomatis
                  });
                },
              ),

              const SizedBox(height: 20),
              _buildTableHeader(),
              const SizedBox(height: 10),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffe21388),
                        ),
                      )
                    : _buildUserList(filteredUsers),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Database Pegawai",
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
              onPressed: _refreshUserList, // Tombol refresh manual
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _showAddUserDialog, // TERHUBUNG KE FUNGSI REGISTRASI
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              label: const Text(
                "Registrasi Baru",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "ID",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "USERNAME",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "ROLE",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "AKSI",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada data ditemukan",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "#${user.id}",
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  user.username,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  user.role.toUpperCase(),
                  style: TextStyle(
                    color: user.role == 'admin'
                        ? Colors.pinkAccent
                        : Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.amber,
                  size: 20,
                ),
                onPressed: () => _showEditUserDialog(user),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _deleteUser(
                  user.id!,
                  user.username,
                ), // TERHUBUNG KE FUNGSI DELETE
              ),
            ],
          ),
        );
      },
    );
  }

  // FUNGSI UNTUK UPDATE DATA USER
  Future<void> _updateUser(int id, String username, String role) async {
    try {
      final db = await DatabaseService.instance.database;
      await db.update(
        'users',
        {'username': username, 'role': role},
        where: 'id = ?',
        whereArgs: [id],
      );
      _refreshUserList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data pegawai berhasil diperbarui")),
        );
      }
    } catch (e) {
      print("Error update user: $e");
    }
  }

  // FUNGSI UNTUK HAPUS USER
  Future<void> _deleteUser(int id, String username) async {
    // Tampilkan konfirmasi sebelum hapus
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color.fromRGBO(20, 28, 47, 1),
            title: const Text(
              "Konfirmasi Hapus",
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              "Apakah Anda yakin ingin menghapus $username?",
              style: const TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        final db = await DatabaseService.instance.database;
        await db.delete('users', where: 'id = ?', whereArgs: [id]);
        _refreshUserList();
      } catch (e) {
        print("Error delete user: $e");
      }
    }
  }

  void _showEditUserDialog(UserModel user) {
    final TextEditingController userController = TextEditingController(
      text: user.username,
    );
    String selectedRole = user.role;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color.fromRGBO(20, 28, 47, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Edit Data Pegawai",
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: userController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Username",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.person, color: Color(0xffe21388)),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Username tidak boleh kosong" : null,
                ),

                DropdownButtonFormField<String>(
                  dropdownColor: const Color.fromRGBO(20, 28, 47, 1),
                  value: selectedRole,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Role Akses",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  items: ['admin', 'staff']
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setModalState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _updateUser(user.id!, userController.text, selectedRole);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Simpan Perubahan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
