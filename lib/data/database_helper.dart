import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Konstruktor internal privat
  DatabaseHelper._internal();

  // Instance tunggal (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  // Biarkan factory tetap ada sebagai cadangan
  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tangan_kebaikan.db');
    return await openDatabase(
      path,
      version: 2, // <-- GANTI DARI 1 MENJADI 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // <-- TAMBAHKAN INI
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Hapus tabel lama yang skemanya cacat/tertinggal
      await db.execute("DROP TABLE IF EXISTS donations");
      await db.execute("DROP TABLE IF EXISTS volunteers");
      // Buat ulang tabel baru dengan skema paling update yang ada di _onCreate
      await _onCreate(db, newVersion);
    }
  }

  Future _onCreate(Database db, int version) async {
    // Tabel Donasi (Uang / Barang)
    await db.execute('''
      CREATE TABLE donations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT, -- 'UANG' atau 'BARANG'
        target TEXT,
        amount REAL,
        itemQuantity INTEGER,
        itemName TEXT,
        date TEXT
      )
    ''');

    // Tabel Volunteer
    await db.execute('''
      CREATE TABLE volunteers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        campaignName TEXT,
        phoneNumber TEXT,
        status TEXT
      )
    ''');
  }

  // --- 6 OPERASI CRUD ---

  // 1. Create Donation
  Future<int> insertDonation(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('donations', row);
  }

  // 2. Read Donations
  Future<List<Map<String, dynamic>>> getDonations() async {
    Database db = await database;
    return await db.query('donations', orderBy: 'id DESC');
  }

  // 3. Delete Donation
  Future<int> deleteDonation(int id) async {
    Database db = await database;
    return await db.delete('donations', where: 'id = ?', whereArgs: [id]);
  }

  // 4. Create Volunteer
  Future<int> insertVolunteer(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('volunteers', row);
  }

  // 5. Read Volunteers
  Future<List<Map<String, dynamic>>> getVolunteers() async {
    Database db = await database;
    return await db.query('volunteers', orderBy: 'id DESC');
  }

  // 6. Update Volunteer Status
  Future<int> updateVolunteerStatus(int id, String status) async {
    Database db = await database;
    return await db.update(
      'volunteers',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- TAMBAHAN OPERASI UPDATE & DELETE ---

  // Update Data Donasi
  Future<int> updateDonation(int id, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update('donations', row, where: 'id = ?', whereArgs: [id]);
  }

  // Update Data Relawan (Misal untuk ubah status dari Pending ke Aktif)
  // Pastikan ini ada di file database_helper.dart
  Future<int> updateVolunteer(int id, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update(
      'volunteers',
      row,
      where: 'id = ?',
      whereArgs: [id], // Pastikan ID ini dikirim dengan benar
    );
  }

  // Delete Data Relawan
  Future<int> deleteVolunteer(int id) async {
    Database db = await database;
    return await db.delete('volunteers', where: 'id = ?', whereArgs: [id]);
  }
}
