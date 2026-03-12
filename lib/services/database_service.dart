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

        /// PS UNITS
        await db.execute('''
        CREATE TABLE ps_units(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          type TEXT,
          price_per_hour INTEGER,
          status TEXT,
          customer_name TEXT,
          start_time INTEGER,
          duration_seconds INTEGER
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

        /// RESERVATIONS / BOOKING
        await db.execute('''
        CREATE TABLE reservations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          unit_id INTEGER NOT NULL,
          shift_id INTEGER NOT NULL,
          customer_name TEXT NOT NULL,
          start_time TEXT NOT NULL,
          duration_hours INTEGER NOT NULL,
          end_time TEXT NOT NULL,
          total_price INTEGER NOT NULL,
          status TEXT DEFAULT 'booked',
          created_at TEXT,
          FOREIGN KEY(unit_id) REFERENCES ps_units(id),
          FOREIGN KEY(shift_id) REFERENCES shifts(id)
        )
        ''');
      },
    );
  }
}
