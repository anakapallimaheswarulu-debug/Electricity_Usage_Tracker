import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('electricity_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Readings table
    await db.execute('''
      CREATE TABLE readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        previous_reading REAL NOT NULL,
        current_reading REAL NOT NULL,
        units REAL NOT NULL,
        tariff REAL NOT NULL,
        estimated_bill REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // =========================================================
  // USER METHODS
  // =========================================================

  // Insert a new user
  Future<int> insertUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await instance.database;

    return await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  // Check whether an email already exists
  Future<bool> emailExists(String email) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // Login user
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(
    String email,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // Update user name
  Future<int> updateUserName({
    required int id,
    required String name,
  }) async {
    final db = await instance.database;

    return await db.update(
      'users',
      {
        'name': name,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update user email
  Future<int> updateUserEmail({
    required int id,
    required String email,
  }) async {
    final db = await instance.database;

    return await db.update(
      'users',
      {
        'email': email,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update user password
  Future<int> updateUserPassword({
    required int id,
    required String password,
  }) async {
    final db = await instance.database;

    return await db.update(
      'users',
      {
        'password': password,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // DATABASE MANAGEMENT
  // =========================================================

  Future<void> close() async {
    final db = await instance.database;
    await db.close();

    _database = null;
  }
}