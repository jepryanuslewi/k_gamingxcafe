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
          shift_name TEXT,
          product_id INTEGER,              
          nama_produk TEXT NOT NULL,        
          jumlah INTEGER NOT NULL,
          harga_satuan INTEGER NOT NULL,    
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
          keterangan TEXT, 
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

  // Fungsi stok masuk — update stok_saat_ini + insert riwayat_bahan
  Future<bool> stokMasuk({
    required int bahanId,
    required double jumlah,
    required String username,
    required String namaShift,
    String? keterangan, // Tambahkan ini jika di UI ada input deskripsi
  }) async {
    try {
      final db = await instance.database;

      // Gunakan return di depan db.transaction untuk memastikan hasil transaksi tertangkap
      await db.transaction((txn) async {
        // 1. Update stok_saat_ini di tabel bahan
        int updateCount = await txn.rawUpdate(
          'UPDATE bahan SET stok_saat_ini = stok_saat_ini + ? WHERE id = ?',
          [jumlah, bahanId],
        );

        // Opsional: Cek apakah ID bahan benar-benar ada
        if (updateCount == 0) {
          throw Exception("Bahan dengan ID $bahanId tidak ditemukan");
        }

        // 2. Insert ke riwayat_bahan
        await txn.insert('riwayat_bahan', {
          'bahan_id': bahanId,
          'jumlah': jumlah,
          'tipe': 'masuk',
          'username': username,
          'nama_shift': namaShift,
          'keterangan': keterangan ?? '', // Masukkan deskripsi jika ada
          'waktu': DateTime.now().toIso8601String(),
        });
      });

      // Jika sampai di sini tanpa error, kembalikan true
      return true;
    } catch (e) {
      // Jika ada error (DB penuh, kolom salah, dll), cetak error dan kembalikan false
      debugPrint("Database Error: $e");
      return false;
    }
  }

  // 1. Fungsi Stok Keluar
  Future<bool> stokKeluar({
    required int bahanId,
    required double jumlah,
    required String username,
    required String namaShift,
    String? keterangan,
  }) async {
    try {
      final db = await instance.database;

      await db.transaction((txn) async {
        // Perhatikan tanda MINUS (-) untuk mengurangi stok
        int updateCount = await txn.rawUpdate(
          'UPDATE bahan SET stok_saat_ini = stok_saat_ini - ? WHERE id = ?',
          [jumlah, bahanId],
        );

        if (updateCount == 0) {
          throw Exception("Bahan tidak ditemukan");
        }

        // Insert ke riwayat dengan tipe 'keluar'
        await txn.insert('riwayat_bahan', {
          'bahan_id': bahanId,
          'jumlah': jumlah,
          'tipe': 'keluar', // Tipe dibedakan di sini
          'username': username,
          'nama_shift': namaShift,
          'keterangan': keterangan ?? '',
          'waktu': DateTime.now().toIso8601String(),
        });
      });
      return true;
    } catch (e) {
      debugPrint("Database Error (Stok Keluar): $e");
      return false;
    }
  }

  // 2. Fungsi Ambil Riwayat Keluar
  Future<List<Map<String, dynamic>>> getRiwayatKeluar() async {
    final db = await instance.database;
    // Join dengan tabel bahan agar kita bisa dapat nama_bahan
    return await db.rawQuery('''
    SELECT riwayat_bahan.*, bahan.nama as nama_bahan, bahan.kategori 
    FROM riwayat_bahan 
    JOIN bahan ON riwayat_bahan.bahan_id = bahan.id
    WHERE riwayat_bahan.tipe = 'keluar'
    ORDER BY riwayat_bahan.waktu DESC
  ''');
  }

  // Ambil riwayat stok masuk dengan JOIN ke tabel bahan
  Future<List<Map<String, dynamic>>> getRiwayatMasuk() async {
    final db = await instance.database;
    return await db.rawQuery('''
    SELECT 
      r.id,
      b.nama       AS nama_bahan,
      b.kategori,
      b.satuan,
      r.jumlah,
      r.username,
      r.nama_shift,
      r.waktu
    FROM riwayat_bahan r
    JOIN bahan b ON r.bahan_id = b.id
    WHERE r.tipe = 'masuk'
    ORDER BY r.waktu DESC
  ''');
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
      'bahan', // Pastikan nama tabel sesuai dengan yang Anda buat di onCreate
      bahan.toMap(),
      where: 'id = ?',
      whereArgs: [bahan.id],
    );
  }

  // Fungsi untuk Delete Bahan Baku
  Future<int> deleteBahan(int id) async {
    final db = await instance.database;
    return await db.delete('bahan', where: 'id = ?', whereArgs: [id]);
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
    return await db.delete('menu', where: 'id = ?', whereArgs: [id]);
  }

  // Tambahkan di dalam class DatabaseService

  Future<void> createTransaksi(
    num total,
    List<Map<String, dynamic>> items,
    String shiftName,
  ) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 1. Loop setiap item yang dibeli
      for (var item in items) {
        final MenuModel p = item['selectedProduk'];
        final int qty = item['qty'];

        // 2. Simpan ke tabel cafe_transactions
        // Catatan: Saya set shift_id default ke 1 atau sesuaikan dengan sistem shift kamu
        await txn.insert('cafe_transactions', {
          'shift_id': 1,
          'shift_name': shiftName,
          'product_id': p.id,
          'nama_produk': p.nama,
          'jumlah': qty,
          'harga_satuan': p.harga,
          'total_harga': (p.harga) * qty,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'active',
        });

        // 3. Panggil fungsi pengurangan stok bahan baku otomatis
        // Karena kita di dalam transaksi, kita panggil logic-nya secara berurutan
        await _kurangiStokBahanInternal(txn, p.id!, qty);
      }
    });
  }

  // Fungsi pembantu untuk mengurangi stok di dalam transaksi yang sama
  Future<void> _kurangiStokBahanInternal(
    dynamic txn,
    int productId,
    int qtyPesanan,
  ) async {
    // Cari resep untuk produk ini
    final List<Map<String, dynamic>> resep = await txn.query(
      'resep_menu',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    for (var item in resep) {
      int bahanId = item['bahan_id'];
      double totalPotong =
          (item['jumlah_pakai'] as num).toDouble() * qtyPesanan;

      // Update stok bahan baku
      await txn.rawUpdate(
        'UPDATE bahan SET stok_saat_ini = stok_saat_ini - ? WHERE id = ?',
        [totalPotong, bahanId],
      );

      // Catat ke riwayat bahan baku
      await txn.insert('riwayat_bahan', {
        'bahan_id': bahanId,
        'jumlah': totalPotong,
        'tipe': 'keluar',
        'username': 'System',
        'nama_shift': 'Auto-Cut (Sales)',
        'waktu': DateTime.now().toIso8601String(),
      });
    }
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

  // Filter Laporan
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
        whereClauses.add("DATE(j.created_at) BETWEEN ? AND ?");
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

  // Untuk kategori "Stock" (dari tabel riwayat_bahan)
  Future<List<Map<String, dynamic>>> getStockLaporan({
    DateTime? tglAwal,
    DateTime? tglAkhir,
    String? subKategori, // Masuk / Keluar / Semua
    String? namaKaryawan,
  }) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (tglAwal != null && tglAkhir != null) {
      String start = DateFormat('yyyy-MM-dd').format(tglAwal);
      String end = DateFormat('yyyy-MM-dd').format(tglAkhir);
      whereClauses.add("DATE(rb.waktu) BETWEEN ? AND ?");
      whereArgs.addAll([start, end]);
    }

    if (subKategori != null && subKategori != "Semua") {
      final tipeDB = subKategori.toLowerCase(); // "masuk" atau "keluar"
      whereClauses.add("rb.tipe = ?");
      whereArgs.add(tipeDB);
    }

    if (namaKaryawan != null && namaKaryawan != "Semua") {
      whereClauses.add("rb.username = ?");
      whereArgs.add(namaKaryawan);
    }

    String whereString = whereClauses.isNotEmpty
        ? "WHERE ${whereClauses.join(' AND ')}"
        : "";

    return await db.rawQuery('''
    SELECT 
      b.nama AS nama_bahan,
      b.kategori,
      b.satuan,
      rb.jumlah,
      rb.tipe,
      rb.username,
      rb.nama_shift,
      rb.waktu,
      rb.keterangan
    FROM riwayat_bahan rb
    JOIN bahan b ON rb.bahan_id = b.id
    $whereString
    ORDER BY rb.waktu DESC
  ''', whereArgs);
  }

  // Untuk kategori "Transaksi" (dari tabel cafe_transactions)
  Future<List<Map<String, dynamic>>> getTransaksiLaporan({
    DateTime? tglAwal,
    DateTime? tglAkhir,
    String? subKategori, // Makanan / Minuman / Semua
    String? namaKaryawan,
  }) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (tglAwal != null && tglAkhir != null) {
      String start = DateFormat('yyyy-MM-dd').format(tglAwal);
      String end = DateFormat('yyyy-MM-dd').format(tglAkhir);
      whereClauses.add("DATE(ct.created_at) BETWEEN ? AND ?");
      whereArgs.addAll([start, end]);
    }

    if (subKategori != null && subKategori != "Semua") {
      // Join ke tabel menu untuk ambil kategori produk
      whereClauses.add("m.kategori = ?");
      whereArgs.add(subKategori); // "Makanan" atau "Minuman"
    }

    if (namaKaryawan != null && namaKaryawan != "Semua") {
      whereClauses.add("u.username = ?");
      whereArgs.add(namaKaryawan);
    }

    String whereString = whereClauses.isNotEmpty
        ? "WHERE ${whereClauses.join(' AND ')}"
        : "";

    return await db.rawQuery('''
    SELECT 
      ct.nama_produk,
      ct.jumlah,
      ct.harga_satuan,
      ct.total_harga,
      ct.created_at,
      ct.shift_name,
      m.kategori,
      u.username AS operator
    FROM cafe_transactions ct
    LEFT JOIN menu m ON ct.product_id = m.id
    INNER JOIN shifts s ON ct.shift_id = s.id
    INNER JOIN users u ON s.user_id = u.id
    $whereString
    AND ct.status = 'active'
    ORDER BY ct.created_at DESC
  ''', whereArgs);
  }

  // Untuk Laporan Pendapatan
  // Tambahkan di dalam class DatabaseService

  // Total pendapatan Gaming hari ini (dari tabel jadwal)
  Future<int> getTotalGamingHariIni() async {
    final db = await instance.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await db.rawQuery(
      '''
    SELECT COALESCE(SUM(total_price), 0) AS total
    FROM jadwal
    WHERE DATE(created_at) = ?
    AND status_completed = 'done'
  ''',
      [today],
    );
    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  // Total pendapatan Cafe hari ini (dari tabel cafe_transactions)
  Future<int> getTotalCafeHariIni() async {
    final db = await instance.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await db.rawQuery(
      '''
    SELECT COALESCE(SUM(total_harga), 0) AS total
    FROM cafe_transactions
    WHERE DATE(created_at) = ?
    AND status = 'active'
  ''',
      [today],
    );
    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  // Total gabungan Gaming + Cafe hari ini
  Future<int> getTotalGabunganHariIni() async {
    final gaming = await getTotalGamingHariIni();
    final cafe = await getTotalCafeHariIni();
    return gaming + cafe;
  }

  // edit username password untuk pegawai ==================================================
  // ── Ambil user by ID ────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ── Update username ─────────────────────────────────────────────
  // Return null jika sukses, return pesan error jika gagal
  Future<String?> updateUsername({
    required int userId,
    required String newUsername,
  }) async {
    try {
      final db = await instance.database;

      // Cek apakah username sudah dipakai user lain
      final existing = await db.query(
        'users',
        where: 'username = ? AND id != ?',
        whereArgs: [newUsername, userId],
        limit: 1,
      );
      if (existing.isNotEmpty) return 'Username sudah digunakan';

      await db.update(
        'users',
        {'username': newUsername},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return null; // sukses
    } catch (e) {
      debugPrint('updateUsername Error: $e');
      return 'Gagal mengubah username';
    }
  }

  // ── Update password (langsung tanpa verifikasi password lama) ───
  // Return null jika sukses, return pesan error jika gagal
  Future<String?> updatePassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      final db = await instance.database;
      await db.update(
        'users',
        {'password': newPassword},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return null; // sukses
    } catch (e) {
      debugPrint('updatePassword Error: $e');
      return 'Gagal mengubah password';
    }
  }
}
