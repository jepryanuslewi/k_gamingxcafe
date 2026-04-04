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
