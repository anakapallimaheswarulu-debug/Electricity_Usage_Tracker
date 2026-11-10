import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/electricity_reading.dart';

class DatabaseService {
  static final DatabaseService instance =
      DatabaseService._internal();

  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'electricity_usage.db',
    );

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        previous_reading REAL NOT NULL,
        current_reading REAL NOT NULL,
        units REAL NOT NULL,
        bill_amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        tariff REAL NOT NULL
      )
    ''');

    await db.insert(
      'settings',
      {
        'id': 1,
        'tariff': 7.0,
      },
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE settings (
          id INTEGER PRIMARY KEY,
          tariff REAL NOT NULL
        )
      ''');

      await db.insert(
        'settings',
        {
          'id': 1,
          'tariff': 7.0,
        },
      );
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE readings
        ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0
      ''');
    }
  }

  Future<int> insertReading(
    ElectricityReading reading,
  ) async {
    final db = await database;

    return await db.insert(
      'readings',
      reading.toMap(),
    );
  }

  Future<List<ElectricityReading>> getReadings(
  int userId,
) async {
  final db = await database;

  final result = await db.query(
    'readings',
    where: 'user_id = ?',
    whereArgs: [userId],
    orderBy: 'id DESC',
  );

  return result
      .map(
        (map) => ElectricityReading.fromMap(map),
      )
      .toList();
}

  Future<int> deleteReading(int id) async {
    final db = await database;

    return await db.delete(
      'readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllReadings() async {
    final db = await database;

    return await db.delete('readings');
  }

  Future<double> getTariff() async {
    final db = await database;

    final result = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return 7.0;
    }

    return (result.first['tariff'] as num).toDouble();
  }

  Future<void> updateTariff(double tariff) async {
    final db = await database;

    await db.insert(
      'settings',
      {
        'id': 1,
        'tariff': tariff,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}