import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/gaming/jadwal_model.dart';
import 'package:k_gamingxcafe/models/gaming/package_model.dart';
import 'package:k_gamingxcafe/models/gaming/ps_unit_model.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class JadwalProvider with ChangeNotifier {
  List<PsUnitModel> _allUnits = [];
  List<JadwalModel> _filteredJadwal = [];

  // 1. TAMBAHKAN VARIABLE UNTUK PACKAGES
  List<PackageModel> _allPackages = [];

  List<PsUnitModel> get allUnits => _allUnits;
  List<JadwalModel> get filteredJadwal => _filteredJadwal;

  // 2. TAMBAHKAN GETTER AGAR BISA DIAKSES OLEH SCREEN
  List<PackageModel> get allPackages => _allPackages;

  // 3. TAMBAHKAN FUNGSI LOAD DATA DARI DATABASE
  Future<void> loadAllPackages() async {
    try {
      final db = await DatabaseService.instance.database;
      // 'packages' adalah nama tabel di database Anda
      final res = await db.query('packages');

      _allPackages = res.map((e) => PackageModel.fromMap(e)).toList();
      notifyListeners(); // Beritahu UI bahwa data sudah siap
    } catch (e) {
      print("Error loading packages: $e");
      _allPackages = [];
      notifyListeners();
    }
  }

  // Fungsi load unit (sudah ada sebelumnya)
  Future<void> loadAllUnits() async {
    final db = await DatabaseService.instance.database;
    final res = await db.query('ps_units');
    print("DEBUG: Jumlah unit di DB = ${res.length}");
    print("DEBUG: Data Unit = $res");
    _allUnits = res.map((e) => PsUnitModel.fromMap(e)).toList();

    notifyListeners();
  }

  Future<void> loadJadwalByView(String viewType) async {
    final db = await DatabaseService.instance.database;
    final statusFilter = viewType == "WALK IN" ? 'walkin' : 'booking';

    // ✅ Hanya tampilkan yang belum selesai/dihapus
    final res = await db.query(
      'jadwal',
      where: 'status = ? AND status_completed = ?',
      whereArgs: [statusFilter, 'active'],
    );

    _filteredJadwal = res.map((e) => JadwalModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addJadwal(JadwalModel jadwal) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.insert('jadwal', jadwal.toMap());
      if (jadwal.unitId != null) {
        await txn.update(
          'ps_units',
          {
            'status': 'occupied',
            'customer_name': jadwal.customerName ?? "Guest",
          },
          where: 'id = ?',
          whereArgs: [jadwal.unitId],
        );
      }
    });
    await loadAllUnits();
    notifyListeners();
  }

  // Hapus — tandai deleted, data tetap ada di laporan
  Future<void> deleteJadwal(int jadwalId, int? unitId) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'jadwal',
        {'status_completed': 'deleted'}, // ✅ hanya update status_completed
        where: 'id = ?',
        whereArgs: [jadwalId],
      );
      if (unitId != null) {
        await txn.update(
          'ps_units',
          {'status': 'idle'},
          where: 'id = ?',
          whereArgs: [unitId],
        );
      }
    });
  }

  // Selesaikan — tandai done
  Future<void> completeJadwal(int jadwalId, int? unitId) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'jadwal',
        {'status_completed': 'done'}, 
        where: 'id = ?',
        whereArgs: [jadwalId],
      );
      if (unitId != null) {
        await txn.update(
          'ps_units',
          {'status': 'idle'},
          where: 'id = ?',
          whereArgs: [unitId],
        );
      }
    });
  }
}
