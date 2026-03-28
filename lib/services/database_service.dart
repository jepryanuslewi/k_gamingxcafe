import 'package:intl/intl.dart';
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
            FOREIGN KEY(unit_id) REFERENCES ps_units(id),
            FOREIGN KEY(shift_id) REFERENCES shifts(id)
          )
        ''');

        // Database Khusus CAFE==============================================================
        /// PRODUCTS (CAFE STOK)
        await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price INTEGER NOT NULL,
          stock INTEGER NOT NULL,
          category TEXT -- Makanan / Minuman
        )
        ''');

        /// CAFE TRANSACTIONS
        await db.execute('''
        CREATE TABLE cafe_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shift_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          total_price INTEGER NOT NULL,
          created_at TEXT,
          FOREIGN KEY(shift_id) REFERENCES shifts(id),
          FOREIGN KEY(product_id) REFERENCES products(id)
        )
        ''');

        // Di dalam onCreate DatabaseService, tambahkan:
        await db.execute('''
        CREATE TABLE stock_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_name TEXT NOT NULL,
          category TEXT NOT NULL,
          qty INTEGER NOT NULL,
          username TEXT NOT NULL,
          shift_name TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');

        /// 1. TABEL BAHAN (STOK MENTAH)
        await db.execute('''
          CREATE TABLE bahan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL, 
            current_qty INTEGER NOT NULL DEFAULT 0
          )
        ''');

        /// 2. TABEL RIWAYAT BAHAN (LOG INPUT)
        await db.execute('''
          CREATE TABLE riwayat_bahan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bahan_id INTEGER NOT NULL,
            qty_added INTEGER NOT NULL,
            username TEXT NOT NULL,
            shift_name TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY(bahan_id) REFERENCES bahan(id) -- SUDAH DIPERBAIKI
          )
        ''');

        /// 3. TABEL DETAIL BAHAN (RESEP/RECIPE)
        await db.execute('''
          CREATE TABLE detail_bahan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            bahan_id INTEGER NOT NULL,
            usage_qty INTEGER NOT NULL,
            FOREIGN KEY(product_id) REFERENCES products(id),
            FOREIGN KEY(bahan_id) REFERENCES bahan(id) -- SUDAH DIPERBAIKI
          )
        ''');
      },
    );
  }

  /// --- UNTUK LAPORAN --------------------------------------------------------------------------------------------------

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
    String? kategori, // ✅ tambah parameter kategori
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
