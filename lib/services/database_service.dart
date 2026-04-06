import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/models/cafe/menu_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  static const _dbName = 'rental_ps.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        /// USERS
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          role TEXT,
          created_at TEXT
        )
        ''');

        /// SHIFTS
        await db.execute('''
        CREATE TABLE shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          shift_name TEXT,
          start_time TEXT NOT NULL,
          end_time TEXT,
          created_at TEXT,
          FOREIGN KEY(user_id) REFERENCES users(id)
        )
        ''');

        /// DEFAULT USERS
        await db.insert('users', {
          'username': 'admin',
          'password': '123',
          'role': 'admin',
          'created_at': DateTime.now().toIso8601String(),
        });

        await db.insert('users', {
          'username': 'pegawai1',
          'password': '1234',
          'role': 'staff',
          'created_at': DateTime.now().toIso8601String(),
        });
        await db.insert('users', {
          'username': 'pegawai2',
          'password': '1234',
          'role': 'staff',
          'created_at': DateTime.now().toIso8601String(),
        });

        /// PS UNITS ====================================================================
        await db.execute('''
          CREATE TABLE ps_units(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL, 
            price_per_hour INTEGER NOT NULL,
            status TEXT DEFAULT 'Available',
            customer_name TEXT,
            duration_seconds INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE packages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price INTEGER NOT NULL,
            duration_hours INTEGER NOT NULL,
            description TEXT
          )
        ''');

        /// TABEL JADWAL =======================================
        await db.execute('''
          CREATE TABLE jadwal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            unit_id INTEGER,           
            shift_id INTEGER NOT NULL,  
            customer_name TEXT,        
            customer_phone TEXT,        
            category TEXT,            
            package_name TEXT,         
            start_time TEXT NOT NULL,  
            duration_hours INTEGER NOT NULL,
            end_time TEXT NOT NULL,     
            total_price INTEGER NOT NULL,
            status TEXT, -- booking/walkin 
            created_at TEXT,
            status_completed TEXT DEFAULT 'active',
            FOREIGN KEY(unit_id) REFERENCES ps_units(id),
            FOREIGN KEY(shift_id) REFERENCES shifts(id)
          )
        ''');

        // Database Khusus CAFE==============================================================
        await db.execute('''
        CREATE TABLE menu (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          harga INTEGER NOT NULL,
          stok INTEGER NOT NULL DEFAULT 0,
          kategori TEXT                   -- Makanan / Minuman
        )
        ''');

        /// TRANSAKSI CAFE
        await db.execute('''
        CREATE TABLE cafe_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shift_id INTEGER NOT NULL,
          product_id INTEGER,               -- ✅ nullable, jika produk dihapus tetap aman
          nama_produk TEXT NOT NULL,        -- ✅ snapshot nama saat transaksi
          jumlah INTEGER NOT NULL,
          harga_satuan INTEGER NOT NULL,    -- ✅ snapshot harga saat transaksi
          total_harga INTEGER NOT NULL,
          created_at TEXT,
          status TEXT DEFAULT 'active',
          FOREIGN KEY(shift_id) REFERENCES shifts(id),
          FOREIGN KEY(product_id) REFERENCES menu(id)
        )
      ''');

        /// LOG STOK (RIWAYAT MASUK/KELUAR)
        await db.execute('''
        CREATE TABLE log_stok (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_menu TEXT NOT NULL,
          kategori TEXT NOT NULL,
          jumlah REAL NOT NULL,
          tipe TEXT NOT NULL DEFAULT 'keluar', -- masuk (restock) / keluar (terjual)
          username TEXT NOT NULL,
          nama_shift TEXT NOT NULL,
          waktu TEXT NOT NULL
        )
        ''');

        /// BAHAN BAKU
        await db.execute('''
        CREATE TABLE bahan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          kategori TEXT NOT NULL,
          satuan TEXT NOT NULL,               -- ✅ gram / ml / pcs / liter / kg
          stok_saat_ini REAL NOT NULL DEFAULT 0 -- ✅ REAL agar bisa desimal (misal 0.5 kg)
        )
      ''');

        /// RIWAYAT BAHAN BAKU
        await db.execute('''
        CREATE TABLE riwayat_bahan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bahan_id INTEGER NOT NULL,
          jumlah REAL NOT NULL,               -- ✅ REAL agar bisa desimal
          tipe TEXT NOT NULL DEFAULT 'masuk',
          username TEXT NOT NULL,
          nama_shift TEXT NOT NULL,
          waktu TEXT NOT NULL,
          FOREIGN KEY(bahan_id) REFERENCES bahan(id)
        )
      ''');

        /// RESEP PRODUK
        await db.execute('''
        CREATE TABLE resep_menu (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER NOT NULL,
          bahan_id INTEGER NOT NULL,
          jumlah_pakai REAL NOT NULL,
          -- Tambahkan ON DELETE CASCADE di sini
          FOREIGN KEY(product_id) REFERENCES menu(id) ON DELETE CASCADE,
          FOREIGN KEY(bahan_id) REFERENCES bahan(id) ON DELETE CASCADE
        )
      ''');
      },
    );
  }

  // fungi untuk stok masuk dan keluar
  Future<List<Map<String, dynamic>>> getBahanSemua() async {
    final db = await instance.database;
    return await db.query('bahan', orderBy: 'nama ASC');
  }

  Future<int> tambahBahan(Bahan bahan) async {
    final db = await instance.database;
    return await db.insert('bahan', bahan.toMap());
  }

  // Fungsi untuk Update Bahan Baku
  Future<int> updateBahan(Bahan bahan) async {
    final db = await instance.database;
    return await db.update(
      'bahan_baku', // Pastikan nama tabel sesuai dengan yang Anda buat di onCreate
      bahan.toMap(),
      where: 'id = ?',
      whereArgs: [bahan.id],
    );
  }

  // Fungsi untuk Delete Bahan Baku
  Future<int> deleteBahan(int id) async {
    final db = await instance.database;
    return await db.delete('bahan_baku', where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi pengurangan stok bahan secara otomatis saat produk terjual
  Future<void> kurangiStokBahanOtomatis(int productId, int qtyPesanan) async {
    final db = await instance.database;

    // Cari di resep_menu
    final List<Map<String, dynamic>> resep = await db.query(
      'resep_menu',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    for (var item in resep) {
      int bahanId = item['bahan_id'];
      double totalPotong =
          (item['jumlah_pakai'] as num).toDouble() * qtyPesanan;

      await db.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE bahan SET stok_saat_ini = stok_saat_ini - ? WHERE id = ?',
          [totalPotong, bahanId],
        );

        await txn.insert('riwayat_bahan', {
          'bahan_id': bahanId,
          'jumlah': totalPotong,
          'tipe': 'keluar',
          'username': 'System',
          'nama_shift': 'Auto-Cut',
          'waktu': DateTime.now().toIso8601String(),
        });
      });
    }
  }

  Future<void> addMenuWithResep(
    MenuModel menu,
    List<Map<String, dynamic>> resep,
  ) async {
    final db = await database;

    await db.transaction((txn) async {
      // Simpan menu
      int productId = await txn.insert('menu', menu.toMap());

      // Simpan resep
      for (var item in resep) {
        if (item['bahan_id'] != null) {
          // Ambil text dari controller
          final controller = item['jumlah'] as TextEditingController;
          double qty = double.tryParse(controller.text) ?? 0.0;

          if (qty > 0) {
            await txn.insert('resep_menu', {
              'product_id': productId,
              'bahan_id': item['bahan_id'],
              'jumlah_pakai': qty,
            });
          }
        }
      }
    });
  }

  // Fungsi Untuk Kelola Menu Cafe
  Future<int> createMenu(MenuModel menu) async {
    final db = await instance.database;
    return await db.insert('menu', menu.toMap());
  }

  Future<List<MenuModel>> readAllMenu() async {
    final db = await instance.database;
    // Pastikan nama tabel adalah 'menu'
    final result = await db.query('menu', orderBy: 'nama ASC');
    return result.map((json) => MenuModel.fromMap(json)).toList();
  }

  Future<void> updateMenuWithResep(
    MenuModel menu,
    List<Map<String, dynamic>> resep,
  ) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 1. Update info utama menu
      await txn.update(
        'menu',
        menu.toMap(),
        where: 'id = ?',
        whereArgs: [menu.id],
      );

      await txn.delete(
        'resep_menu',
        where: 'product_id = ?',
        whereArgs: [menu.id],
      );

      // 3. Masukkan resep baru hasil editan
      for (var item in resep) {
        if (item['bahan_id'] != null) {
          final controller = item['jumlah'] as TextEditingController;
          double qty = double.tryParse(controller.text) ?? 0.0;

          if (qty > 0) {
            await txn.insert('resep_menu', {
              'product_id': menu.id,
              'bahan_id': item['bahan_id'],
              'jumlah_pakai': qty,
            });
          }
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> getResepByProductId(int productId) async {
    final db = await instance.database;
    return await db.query(
      'resep_menu',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteMenu(int id) async {
    final db = await instance.database;
    // Menghapus menu otomatis akan menghapus resep jika Anda menggunakan ON DELETE CASCADE,
    // Jika tidak, sebaiknya hapus resepnya dulu secara manual atau tambahkan CASCADE di create table.
    return await db.delete('menu', where: 'id = ?', whereArgs: [id]);
  }

  /// --- UNTUK LAPORAN JADWAL --------------------------------------------------------------------------------------------------

  // 1. Ambil daftar karyawan secara dinamis
  Future<List<String>> getAllStaffNames() async {
    try {
      final db = await instance.database;

      final List<Map<String, dynamic>> result = await db.query(
        'users',
        columns: ['username'],
        // Filter hanya untuk role staff
        where: 'role = ?',
        whereArgs: ['staff'],
        orderBy: 'username ASC',
      );

      List<String> names = result
          .map((row) => row['username'].toString())
          .toList();

      // Tetap kembalikan "Semua" di awal list untuk kebutuhan filter laporan
      return ["Semua", ...names];
    } catch (e) {
      print("Error ambil karyawan staff: $e");
      return ["Semua"];
    }
  }

  Future<List<Map<String, dynamic>>> getJadwalLaporan({
    DateTime? tglAwal,
    DateTime? tglAkhir,
    String? subKategori,
    String? namaKaryawan,
    String? kategori,
  }) async {
    try {
      final db = await instance.database;
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [];

      // 1. Filter Tanggal
      if (tglAwal != null && tglAkhir != null) {
        String start = DateFormat('yyyy-MM-dd').format(tglAwal.toLocal());
        String end = DateFormat('yyyy-MM-dd').format(tglAkhir.toLocal());
        whereClauses.add("j.created_at BETWEEN ? AND ?");
        whereArgs.addAll([start, end]);
      }

      // 2. Filter Sub Kategori (Walk-In / Booking)
      if (subKategori != null && subKategori != "Semua") {
        // ✅ Konversi nilai UI ke nilai DB
        final statusDB = subKategori.toLowerCase() == "booking"
            ? "booking"
            : "walkin";
        whereClauses.add("j.status = ?");
        whereArgs.add(statusDB);
      }

      // 3. Filter Nama Staff
      if (namaKaryawan != null && namaKaryawan != "Semua") {
        whereClauses.add("u.username = ?");
        whereArgs.add(namaKaryawan);
      }

      String whereString = whereClauses.isNotEmpty
          ? "WHERE ${whereClauses.join(' AND ')}"
          : "";

      return await db.rawQuery('''
      SELECT 
        j.customer_name,
        s.shift_name, 
        u.username AS operator,
        j.created_at, 
        j.package_name,
        j.duration_hours, 
        j.total_price,
        j.status,
        j.start_time,
        J.end_time,
        COALESCE(j.status_completed, 'active') AS status_completed,
        p.name AS unit_name
      FROM jadwal j
      INNER JOIN shifts s ON j.shift_id = s.id
      INNER JOIN users u ON s.user_id = u.id
      LEFT JOIN ps_units p ON j.unit_id = p.id
      $whereString
      ORDER BY j.created_at DESC
    ''', whereArgs);
    } catch (e) {
      print("Error Query Laporan: $e");
      return [];
    }
  }
}
