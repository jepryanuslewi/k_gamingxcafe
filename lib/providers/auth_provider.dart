import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  Future<bool> login(String username, String password) async {
    final db = await DatabaseService.instance.database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (res.isNotEmpty) {
      _user = UserModel.fromMap(res.first);
      notifyListeners();
      return true;
    }
    return false;
  }
}
