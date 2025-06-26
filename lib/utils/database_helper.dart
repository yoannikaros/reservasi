import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'reservasi.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN email TEXT;');
        }
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // 1. USERS: Login & role
    await db.execute('''
      CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          role TEXT DEFAULT 'admin',
          email TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 2. CUSTOMERS: Data pelanggan
    await db.execute('''
      CREATE TABLE customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT,
          address TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 3. VENUES: Tempat yang disewakan
    await db.execute('''
      CREATE TABLE venues (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          location TEXT,
          capacity INTEGER,
          price_per_hour REAL NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 4. BOOKINGS: Reservasi tempat
    await db.execute('''
      CREATE TABLE bookings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER NOT NULL,
          venue_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          total_price REAL,
          status TEXT DEFAULT 'reserved',
          is_paid INTEGER DEFAULT 0,
          notes TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (customer_id) REFERENCES customers(id),
          FOREIGN KEY (venue_id) REFERENCES venues(id)
      )
    ''');

    // 5. PAYMENTS: Pembayaran untuk booking
    await db.execute('''
      CREATE TABLE payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          booking_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          method TEXT,
          payment_date TEXT NOT NULL,
          note TEXT,
          FOREIGN KEY (booking_id) REFERENCES bookings(id)
      )
    ''');

    // 6. TRANSACTIONS: Transaksi umum (operasional)
    await db.execute('''
      CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          category TEXT,
          amount REAL NOT NULL,
          description TEXT,
          transaction_date TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 7. SAVINGS: Tabungan usaha
    await db.execute('''
      CREATE TABLE savings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          description TEXT,
          date TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 8. SETTINGS: Nama usaha + header/footer nota
    await db.execute('''
      CREATE TABLE settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_name TEXT,
          note_header TEXT,
          note_footer TEXT,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
    });

    // Insert default settings
    await db.insert('settings', {
      'business_name': 'Reservasi Tempat Usaha',
      'note_header': 'Terima kasih telah menggunakan layanan kami',
      'note_footer': 'Hubungi kami untuk informasi lebih lanjut',
    });
  }

  // Tambahkan fungsi untuk update username
  Future<int> updateUsername(int userId, String newUsername) async {
    final db = await database;
    return await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Tambahkan fungsi untuk update password
  Future<int> updatePassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
