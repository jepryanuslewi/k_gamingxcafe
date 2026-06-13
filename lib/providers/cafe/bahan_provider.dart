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

  // 2. Getter
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
      bool success = await DatabaseService.instance.stokKeluar(
        bahanId: bahanId,
        jumlah: jumlah,
        username: username,
        namaShift: namaShift,
        keterangan: keterangan,
      );

      if (success) {
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

 // FUNGSI STOK KELUAR
  Future<bool> stokMasuk({
    required int bahanId,
    required double jumlah,
    required String username,
    required String namaShift,
    String keterangan = "",
  }) async {
    try {
      bool success = await DatabaseService.instance.stokMasuk(
        bahanId: bahanId,
        jumlah: jumlah,
        username: username,
        namaShift: namaShift,
        keterangan: keterangan,
      );
      if (success) {
        await fetchBahan();
        await fetchRiwayatMasuk();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Error tambahStokMasuk: $e");
      return false;
    }
  }

  // Fungsi Tambah Bahan
  Future<void> addBahan(Bahan bahan, String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      Bahan bahanBaruTanpaStok = Bahan(
        nama: bahan.nama,
        kategori: bahan.kategori,
        satuan: bahan.satuan,
        isiPerQty: bahan.isiPerQty,
        stokSaatIni: 0, 
      );

      final int newId = await DatabaseService.instance.tambahBahan(
        bahanBaruTanpaStok,
      );

      await DatabaseService.instance.stokMasuk(
        bahanId: newId,
        jumlah: bahan.stokSaatIni, 
        username: username,
        namaShift: '-Admin-',
        keterangan: "Stok awal bahan baru",
      );

      await fetchBahan();
      await fetchRiwayatMasuk();
    } catch (e) {
      debugPrint("Error addBahan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Update Bahan
  Future<void> updateBahan(Bahan bahanBaru, {required String username}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final bahanLama = _listBahan.firstWhere((b) => b.id == bahanBaru.id);
      double selisih = bahanBaru.stokSaatIni - bahanLama.stokSaatIni;

      
      Bahan dataUpdateTanpaStok = Bahan(
        id: bahanBaru.id,
        nama: bahanBaru.nama,
        kategori: bahanBaru.kategori,
        satuan: bahanBaru.satuan,
        isiPerQty: bahanBaru.isiPerQty,
        stokSaatIni: bahanLama.stokSaatIni, 
      );
     
      await DatabaseService.instance.updateBahan(dataUpdateTanpaStok);

      if (selisih != 0) {
        if (selisih > 0) {
          await DatabaseService.instance.stokMasuk(
            bahanId: bahanBaru.id!,
            jumlah: selisih,
            username: username,
            namaShift: '-Admin-',
            keterangan: "Penyesuaian (Update)",
          );
        } else {
          await DatabaseService.instance.stokKeluar(
            bahanId: bahanBaru.id!,
            jumlah: selisih.abs(),
            username: username,
            namaShift: '-Admin-',
            keterangan: "Penyesuaian (Update)",
          );
        }
      }

      await fetchBahan();
      await fetchRiwayatMasuk();
    } catch (e) {
      debugPrint("Error updateBahan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Hapus Bahan
  Future<void> deleteBahan(int id) async {
    try {
      await DatabaseService.instance.deleteBahan(id);
      await fetchBahan();
    } catch (e) {
      debugPrint("Error deleteBahan: $e");
    }
  }
}
