import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CafeProvider with ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> get products => _products;

  Future<void> loadProducts() async {
    final db = await DatabaseService.instance.database;
    _products = await db.query('products');
    notifyListeners();
  }

  Future<void> sellProduct(int productId, int qty, int shiftId) async {
    final db = await DatabaseService.instance.database;

    await db.transaction((txn) async {
      // 1. Ambil data produk untuk hitung harga
      List<Map> p = await txn.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );
      int price = p.first['price'];
      int currentStock = p.first['stock'];

      // 2. Simpan Transaksi
      await txn.insert('cafe_transactions', {
        'shift_id': shiftId,
        'product_id': productId,
        'quantity': qty,
        'total_price': price * qty,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 3. Kurangi Stok
      await txn.update(
        'products',
        {'stock': currentStock - qty},
        where: 'id = ?',
        whereArgs: [productId],
      );
    });

    await loadProducts();
  }

  // add product ke stock
  Future<void> addProduct(Map<String, dynamic> data) async {
    final db = await DatabaseService.instance.database;

    // Masukkan data (name, price, stock, category) ke tabel products
    await db.insert('products', data);

    // Refresh data list agar UI terupdate otomatis
    await loadProducts();
  }

  // Tambahkan di CafeProvider
  Future<void> addStockLog(Map<String, dynamic> logData) async {
    final db = await DatabaseService.instance.database;

    await db.insert('stock_logs', {
      'product_name': logData['name'],
      'category': logData['category'],
      'qty': logData['qty'],
      'username': logData['username'],
      'shift_name': logData['shift'],
      'timestamp': DateTime.now().toIso8601String(), // Mencatat jam otomatis
    });

    // Jika ini juga menambah stok di tabel products, tambahkan logika update di sini
    notifyListeners();
  }
}
