import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  int? _currentShiftId;

  UserModel? get user => _user;
  int? get currentShiftId => _currentShiftId;

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

  Future<void> setShift(int shiftId) async {
    _currentShiftId = shiftId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeShiftId', shiftId);

    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedUserId = prefs.getInt('userId');
    final int? savedShiftId = prefs.getInt('activeShiftId');

    if (savedUserId != null) {
      final userData = await DatabaseService.instance.getUserById(savedUserId);

      if (userData != null) {
        _user = UserModel.fromMap(userData);
        _currentShiftId = savedShiftId;
        notifyListeners();
      }
    }
  }

  Future<String?> updateUsername(String newUsername) async {
    if (_user == null) return "User tidak ditemukan";

    final error = await DatabaseService.instance.updateUsername(
      userId: _user!.id!,
      newUsername: newUsername,
    );

    if (error == null) {
      final updatedUser = await DatabaseService.instance.getUserById(
        _user!.id!,
      );

      if (updatedUser != null) {
        _user = UserModel.fromMap(updatedUser);
        notifyListeners();
      }
    }

    return error;
  }

  Future<String?> updatePassword(String newPassword) async {
    if (_user == null) return "User tidak ditemukan";

    final error = await DatabaseService.instance.updatePassword(
      userId: _user!.id!,
      newPassword: newPassword,
    );

    return error;
  }

  Future<void> logout() async {
    _user = null;
    _currentShiftId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('activeShiftId');

    notifyListeners();
  }
}
