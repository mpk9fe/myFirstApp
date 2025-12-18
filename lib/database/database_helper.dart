import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_entry.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_storage_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static WebStorageHelper? _webStorage;

  DatabaseHelper._init() {
    if (kIsWeb) {
      _webStorage = WebStorageHelper();
    }
  }

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Use WebStorageHelper on web');
    }
    if (_database != null) return _database!;
    try {
      _database = await _initDB('calorie_tracker.db');
      return _database!;
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Web uses SharedPreferences storage instead
      throw UnsupportedError('SQLite not supported on web, use WebStorageHelper');
    }
    
    // For mobile platforms
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE food_entries (
        id $idType,
        name $textType,
        calories $intType,
        dateTime $textType
      )
    ''');
  }

  Future<int> insertFoodEntry(FoodEntry entry) async {
    try {
      if (kIsWeb) {
        return await _webStorage!.insertFoodEntry(entry);
      }
      final db = await database;
      final result = await db.insert('food_entries', entry.toMap());
      print('Inserted food entry: ${entry.name}, ID: $result');
      return result;
    } catch (e) {
      print('Error inserting food entry: $e');
      rethrow;
    }
  }

  Future<List<FoodEntry>> getAllFoodEntries() async {
    try {
      if (kIsWeb) {
        return await _webStorage!.getAllFoodEntries();
      }
      final db = await database;
      final result = await db.query('food_entries', orderBy: 'dateTime DESC');
      print('Retrieved ${result.length} food entries');
      return result.map((map) => FoodEntry.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all food entries: $e');
      return [];
    }
  }

  Future<List<FoodEntry>> getFoodEntriesByDate(DateTime date) async {
    if (kIsWeb) {
      final allEntries = await _webStorage!.getAllFoodEntries();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      return allEntries.where((entry) {
        return entry.dateTime.isAfter(startOfDay) && entry.dateTime.isBefore(endOfDay);
      }).toList();
    }
    
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'food_entries',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'dateTime DESC',
    );

    return result.map((map) => FoodEntry.fromMap(map)).toList();
  }

  Future<List<FoodEntry>> getFoodEntriesInRange(
      DateTime start, DateTime end) async {
    if (kIsWeb) {
      final allEntries = await _webStorage!.getAllFoodEntries();
      return allEntries.where((entry) {
        return entry.dateTime.isAfter(start) && entry.dateTime.isBefore(end);
      }).toList();
    }
    
    final db = await database;
    final result = await db.query(
      'food_entries',
      where: 'dateTime >= ? AND dateTime < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dateTime DESC',
    );

    return result.map((map) => FoodEntry.fromMap(map)).toList();
  }

  Future<int> updateFoodEntry(FoodEntry entry) async {
    if (kIsWeb) {
      // Not implemented for web - would need to load all, update one, save all
      return 0;
    }
    final db = await database;
    return await db.update(
      'food_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteFoodEntry(int id) async {
    if (kIsWeb) {
      await _webStorage!.deleteFoodEntry(id);
      return 1;
    }
    final db = await database;
    return await db.delete(
      'food_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOldEntries(int daysToKeep) async {
    if (kIsWeb) {
      await _webStorage!.deleteOldEntries(daysToKeep);
      return 1;
    }
    final db = await database;
    final cutoffDate =
        DateTime.now().subtract(Duration(days: daysToKeep)).toIso8601String();

    return await db.delete(
      'food_entries',
      where: 'dateTime < ?',
      whereArgs: [cutoffDate],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
