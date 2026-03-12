import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class ShiftProvider with ChangeNotifier {
  int? _activeShiftId;
  String? _activeShiftName;

  int? get activeShiftId => _activeShiftId;
  String? get activeShiftName => _activeShiftName;

  // Cek apakah ada shift yang belum ditutup (end_time is NULL)
  Future<bool> checkActiveShift(int userId) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shifts',
      where: 'user_id = ? AND end_time IS NULL',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      _activeShiftId = maps.first['id'];
      _activeShiftName = maps.first['shift_name'];
      notifyListeners();
      return true; // Ada shift aktif
    }
    return false; // Tidak ada shift aktif
  }

  // Mulai shift baru
  Future<void> startShift(int userId, String shiftName) async {
    final db = await DatabaseService.instance.database;
    final id = await db.insert('shifts', {
      'user_id': userId,
      'shift_name': shiftName,
      'start_time': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
    _activeShiftId = id;
    _activeShiftName = shiftName;
    notifyListeners();
  }
}
