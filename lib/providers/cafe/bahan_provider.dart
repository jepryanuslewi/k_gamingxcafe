import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/models/cafe/riwayat_bahan_model.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class BahanProvider extends ChangeNotifier {
  // 1. Deklarasi Variabel Private
  List<Bahan> _listBahan = [];
  List<RiwayatBahanModel> _listRiwayat = [];
  List<RiwayatBahanModel> _listRiwayatKeluar = [];
  bool _isLoading = false;

  // 2. Getter (Cukup Tulis Satu Kali Saja)
  List<Bahan> get listBahan => _listBahan;
  List<RiwayatBahanModel> get listRiwayat => _listRiwayat;
  List<RiwayatBahanModel> get listRiwayatKeluar => _listRiwayatKeluar;
  bool get isLoading => _isLoading;

  // Mendapatkan semua data bahan
  Future<void> fetchBahan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseService.instance.getBahanSemua();
      _listBahan = data.map((item) => Bahan.fromMap(item)).toList();
    } catch (e) {
      debugPrint("Error Fetch Bahan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mendapatkan data riwayat
  Future<void> fetchRiwayatMasuk() async {
    try {
      final data = await DatabaseService.instance.getRiwayatMasuk();
      _listRiwayat = data.map((e) => RiwayatBahanModel.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error Fetch Riwayat: $e");
    }
  }

  Future<void> fetchRiwayatKeluar() async {
    final data = await DatabaseService.instance.getRiwayatKeluar();
    _listRiwayatKeluar = data.map((e) => RiwayatBahanModel.fromMap(e)).toList();
    notifyListeners();
  }

  // FUNGSI STOK KELUAR
  Future<bool> stokKeluar({
    required int bahanId,
    required double jumlah,
    required String username,
    required String namaShift,
    String keterangan = "",
  }) async {
    try {
      // Eksekusi di DatabaseService
      bool success = await DatabaseService.instance.stokKeluar(
        bahanId: bahanId,
        jumlah: jumlah,
        username: username,
        namaShift: namaShift,
        keterangan: keterangan,
      );

      if (success) {
        // Refresh semua data agar sinkron
        await fetchBahan();
        await fetchRiwayatKeluar();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error Provider stokKeluar: $e");
      return false;
    }
  }

  Future<bool> stokMasuk({
    required int bahanId,
    required double jumlah,
    required String username,
    required String namaShift,
    String keterangan = "",
  }) async {
    try {
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
          'keterangan': keterangan, // Tambahkan keterangan jika kolomnya ada
        });
      });

      // Refresh data agar UI terupdate otomatis
      await fetchBahan();
      await fetchRiwayatMasuk();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error tambahStokMasuk: $e");
      return false;
    }
  }

  // Fungsi Tambah Bahan
  Future<void> addBahan(Bahan bahan) async {
    await DatabaseService.instance.tambahBahan(bahan);
    await fetchBahan();
  }

  // Fungsi Update Bahan
  Future<void> updateBahan(Bahan bahan) async {
    await DatabaseService.instance.updateBahan(bahan);
    await fetchBahan();
  }

  // Fungsi Hapus Bahan
  Future<void> deleteBahan(int id) async {
    await DatabaseService.instance.deleteBahan(id);
    await fetchBahan();
  }
}
