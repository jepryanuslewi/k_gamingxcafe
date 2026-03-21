import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:k_gamingxcafe/repository/shift_repository.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class ShiftProvider extends ChangeNotifier {
  final _repo = ShiftRepository();
  Map<String, dynamic>? activeShift;

  // Getter untuk memudahkan akses
  String? get activeShiftName => activeShift?['shift_name'];

  Future<void> startShift(int userId, String shiftName) async {
    final shiftId = await _repo.startShift(userId, shiftName);

    activeShift = {'id': shiftId, 'user_id': userId, 'shift_name': shiftName};

    // SIMPAN DATA SHIFT KE MEMORI FISIK
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_shift_id', shiftId);
    await prefs.setString('active_shift_name', shiftName);

    notifyListeners();
  }

  // FUNGSI BARU: Memuat ulang shift yang sedang berjalan saat aplikasi dibuka
  Future<void> loadActiveShift() async {
    final prefs = await SharedPreferences.getInstance();
    final int? shiftId = prefs.getInt('active_shift_id');
    final String? shiftName = prefs.getString('active_shift_name');

    if (shiftId != null && shiftName != null) {
      activeShift = {'id': shiftId, 'shift_name': shiftName};
      notifyListeners();
    }
  }

  Future<void> stopShift() async {
    if (activeShift != null) {
      final db = await DatabaseService.instance.database;
      await db.update(
        'shifts',
        {'end_time': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [activeShift!['id']],
      );

      // HAPUS DATA SHIFT DARI MEMORI FISIK
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_shift_id');
      await prefs.remove('active_shift_name');

      activeShift = null;
      notifyListeners();
    }
  }
}
