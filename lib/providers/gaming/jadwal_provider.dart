import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/gaming/jadwal_model.dart';
import 'package:k_gamingxcafe/models/gaming/package_model.dart';
import 'package:k_gamingxcafe/models/gaming/ps_unit_model.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class JadwalProvider with ChangeNotifier {
  List<PsUnitModel> _allUnits = [];
  List<JadwalModel> _filteredJadwal = [];
  List<PackageModel> _allPackages = [];

  List<PsUnitModel> get allUnits => _allUnits;
  List<JadwalModel> get filteredJadwal => _filteredJadwal;
  List<PackageModel> get allPackages => _allPackages;

  Future<void> loadAllPackages() async {
    try {
      final db = await DatabaseService.instance.database;
      final res = await db.query('packages');
      _allPackages = res.map((e) => PackageModel.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading packages: $e");
      _allPackages = [];
      notifyListeners();
    }
  }

  Future<void> loadAllUnits() async {
    final db = await DatabaseService.instance.database;
    final res = await db.query('ps_units');
    _allUnits = res.map((e) => PsUnitModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> loadJadwalByView(String viewType) async {
    final db = await DatabaseService.instance.database;
    final statusFilter = viewType == "WALK IN" ? 'walkin' : 'booking';

    final res = await db.query(
      'jadwal',
      where: 'status = ? AND status_completed = ?',
      whereArgs: [statusFilter, 'active'],
    );

    _filteredJadwal = res.map((e) => JadwalModel.fromMap(e)).toList();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  //  TAMBAH JADWAL
  //  Jika kategori Event → otomatis potong stok bahan dari paket
  // ─────────────────────────────────────────────────────────────
  Future<void> addJadwal(
    JadwalModel jadwal, {
    bool isPaketEvent = false, // ← flag dari screen
    String? shiftName, // ← untuk dicatat di riwayat_bahan
  }) async {
    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      // 1. Insert jadwal
      await txn.insert('jadwal', jadwal.toMap());

      // 2. Update status unit PS (jika bukan event)
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

    // 3. Potong stok bahan jika ini order Event
    if (isPaketEvent && jadwal.packageName != null) {
      await potongStokBahanDariPaket(
        packageName: jadwal.packageName!,
        shiftName: 'Auto-Cut (Sales)',
      );
    }

    await loadAllUnits();
    notifyListeners();
  }

  Future<void> potongStokBahanDariPaket({
    required String packageName,
    required String shiftName,
  }) async {
    try {
      final db = await DatabaseService.instance.database;

      // 1. Cari package_id dari nama paket
      final pkgResult = await db.query(
        'packages',
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [packageName],
        limit: 1,
      );
      if (pkgResult.isEmpty) {
        debugPrint('⚠️ Paket "$packageName" tidak ditemukan di database');
        return;
      }
      final packageId = pkgResult.first['id'] as int;

      // 2. Ambil semua menu dalam paket beserta qty-nya
      final menuDalamPaket = await db.query(
        'package_menus',
        where: 'package_id = ?',
        whereArgs: [packageId],
      );

      if (menuDalamPaket.isEmpty) {
        debugPrint('⚠️ Paket "$packageName" tidak memiliki menu');
        return;
      }

      // 3. Proses tiap menu → ambil resep → potong stok bahan
      for (final item in menuDalamPaket) {
        final menuId = item['menu_id'] as int;
        final qtyMenu = (item['qty'] as int?) ?? 1;

        final resep = await db.query(
          'resep_menu',
          where: 'product_id = ?',
          whereArgs: [menuId],
        );

        for (final r in resep) {
          final bahanId = r['bahan_id'] as int;
          final jumlahPakai = (r['jumlah_pakai'] as num).toDouble();
          final totalPotong = jumlahPakai * qtyMenu;

          // Kurangi stok bahan
          await db.rawUpdate(
            'UPDATE bahan SET stok_saat_ini = stok_saat_ini - ? WHERE id = ?',
            [totalPotong, bahanId],
          );

          // Catat ke riwayat_bahan
          await db.insert('riwayat_bahan', {
            'bahan_id': bahanId,
            'jumlah': totalPotong,
            'tipe': 'keluar',
            'username': 'System',
            'nama_shift': shiftName,
            'keterangan': 'Auto-Cut Event: $packageName',
            'waktu': DateTime.now().toIso8601String(),
          });
        } 
      }

      debugPrint('✅ Stok bahan berhasil dipotong untuk paket: $packageName');
    } catch (e) {
      debugPrint('❌ Error potong stok bahan event: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  HAPUS JADWAL — tandai deleted, data tetap ada di laporan
  // ─────────────────────────────────────────────────────────────
  Future<void> deleteJadwal(int jadwalId, int? unitId) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'jadwal',
        {'status_completed': 'deleted'},
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

  // ─────────────────────────────────────────────────────────────
  //  SELESAIKAN JADWAL — tandai done
  // ─────────────────────────────────────────────────────────────
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
