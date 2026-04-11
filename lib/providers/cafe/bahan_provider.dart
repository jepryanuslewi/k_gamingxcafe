import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class BahanProvider extends ChangeNotifier {
  List<Bahan> _listBahan = [];
  bool _isLoading = false;

  List<Bahan> get listBahan => _listBahan;
  bool get isLoading => _isLoading;

  // Mendapatkan semua data bahan
  Future<void> fetchBahan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseService.instance.getBahanSemua();
      _listBahan = data.map((item) => Bahan.fromMap(item)).toList();
    } catch (e) {
      print("Error Fetch Bahan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> stokMasuk({
    required int bahanId,
    required double jumlah,
    required String username,
    required String namaShift,
    String keterangan = "",
  }) async {
    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      // 1. Update stok_saat_ini di tabel bahan
      await txn.rawUpdate(
        'UPDATE bahan SET stok_saat_ini = stok_saat_ini + ? WHERE id = ?',
        [jumlah, bahanId],
      );

      // 2. Insert ke riwayat_bahan
      await txn.insert('riwayat_bahan', {
        'bahan_id': bahanId,
        'jumlah': jumlah,
        'tipe': 'masuk',
        'username': username,
        'nama_shift': namaShift,
        'waktu': DateTime.now().toIso8601String(),
      });
    });

    // Refresh list bahan setelah update
    await fetchBahan();
  }

  // Fungsi Tambah Bahan
  Future<void> addBahan(Bahan bahan) async {
    await DatabaseService.instance.tambahBahan(bahan);
    await fetchBahan(); // Refresh list otomatis
  }

  Future<void> updateBahan(Bahan bahan) async {
    await DatabaseService.instance.updateBahan(
      bahan,
    ); // Pastikan DB Service juga punya fungsi update
    await fetchBahan();
  }

  // Fungsi Hapus Bahan
  Future<void> deleteBahan(int id) async {
    await DatabaseService.instance.deleteBahan(id);
    await fetchBahan();
  }
}
