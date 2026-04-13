import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/menu_model.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class MenuProvider extends ChangeNotifier {
  List<MenuModel> _listMenu = [];
  bool _isLoading = false;

  List<MenuModel> get listMenu => _listMenu;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _riwayatTransaksi = [];
  List<Map<String, dynamic>> get riwayatTransaksi => _riwayatTransaksi;

  // Fungsi untuk mengambil data dari DB
  Future<void> fetchRiwayatTransaksi() async {
    final db = DatabaseService.instance;
    final data = await (await db.database).query(
      'cafe_transactions',
      orderBy: 'created_at DESC',
    );
    _riwayatTransaksi = data;
    notifyListeners();
  }

  Future<void> fetchMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseService.instance.readAllMenu();
      _listMenu = data;
    } catch (e) {
      print("Error fetch menu: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Simpan transaksi
  Future<bool> simpanTransaksi(
    List<Map<String, dynamic>> items,
    num total,
    String shiftName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Filter item valid
      final validItems = items
          .where((item) => item['selectedProduk'] != null && item['qty'] > 0)
          .toList();

      if (validItems.isEmpty) return false;

      // Jalankan service database
      await DatabaseService.instance.createTransaksi(
        total,
        validItems,
        shiftName,
      );
      await fetchRiwayatTransaksi();
      await fetchMenu();
      return true;
    } catch (e) {
      debugPrint("Error simpan transaksi: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GANTI ATAU TAMBAHKAN FUNGSI INI
  Future<void> addMenuWithResep(
    MenuModel menu,
    List<Map<String, dynamic>> resep,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Memanggil fungsi transaksi di DatabaseService
      await DatabaseService.instance.addMenuWithResep(menu, resep);
      await fetchMenu(); // Refresh otomatis setelah simpan
    } catch (e) {
      print("Error simpan menu dan resep: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMenuLengkap(
    MenuModel menu,
    List<Map<String, dynamic>> resep,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseService.instance.updateMenuWithResep(menu, resep);
      await fetchMenu(); // Refresh list
    } catch (e) {
      print("Error update lengkap: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMenu(int id) async {
    await DatabaseService.instance.deleteMenu(id);
    await fetchMenu();
  }
}
