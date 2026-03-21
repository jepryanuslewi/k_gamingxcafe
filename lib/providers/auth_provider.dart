import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  int? _currentShiftId; // Variabel penampung shift yang sedang aktif

  UserModel? get user => _user;
  int? get currentShiftId =>
      _currentShiftId; // Getter untuk dipakai di screen lain

  // 1. Fungsi Login (Sudah OK, tetap simpan userId)
  Future<bool> login(String username, String password) async {
    final db = await DatabaseService.instance.database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (res.isNotEmpty) {
      _user = UserModel.fromMap(res.first);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _user!.id!);
      notifyListeners();
      return true;
    }
    return false;
  }

  // 2. FUNGSI BARU: Set Shift ID setelah pegawai memilih shift (Pagi/Malam)
  Future<void> setShift(int shiftId) async {
    _currentShiftId = shiftId;

    // Simpan ke SharedPreferences supaya kalau aplikasi restart, shift tidak hilang
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeShiftId', shiftId);

    notifyListeners();
  }

  // 3. Update CheckLoginStatus agar juga mengambil shift yang tersimpan
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedUserId = prefs.getInt('userId');
    final int? savedShiftId = prefs.getInt('activeShiftId');

    if (savedUserId != null) {
      final db = await DatabaseService.instance.database;
      final res = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [savedUserId],
      );

      if (res.isNotEmpty) {
        _user = UserModel.fromMap(res.first);
        _currentShiftId = savedShiftId; // Ambil shift yang tersimpan (jika ada)
        notifyListeners();
      }
    }
  }

  // 4. Logout (Hapus semua data)
  Future<void> logout() async {
    _user = null;
    _currentShiftId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('activeShiftId'); // Hapus shift saat logout

    notifyListeners();
  }
}
