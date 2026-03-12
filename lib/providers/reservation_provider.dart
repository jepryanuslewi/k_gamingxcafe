import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import '../models/ps_unit_model.dart';
import '../models/reservation_model.dart';

class ReservationProvider with ChangeNotifier {
  List<PsUnitModel> _availableUnits = [];
  List<PsUnitModel> get availableUnits => _availableUnits;

  // Mencari unit berdasarkan tipe untuk dropdown
  Future<void> getUnitsByType(String type) async {
    final db = await DatabaseService.instance.database;
    final res = await db.query(
      'ps_units',
      where: 'type = ? AND status = ?',
      whereArgs: [type, 'available'],
    );

    _availableUnits = res.map((e) => PsUnitModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> saveBooking(ReservationModel res) async {
    final db = await DatabaseService.instance.database;
    await db.insert('reservations', res.toMap());
    // Update status unit di tabel ps_units
    await db.update(
      'ps_units',
      {'status': 'occupied'},
      where: 'id = ?',
      whereArgs: [res.unitId],
    );
    notifyListeners();
  }
}
