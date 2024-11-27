import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "FoodOrderingDB.db";
  static final _databaseVersion = 1;

  static final tableFoodItems = 'food_items';
  static final tableOrderPlans = 'order_plans';

  static final columnId = 'id';
  static final columnName = 'name';
  static final columnCost = 'cost';
  static final columnDate = 'date';
  static final columnTargetCost = 'target_cost';
  static final columnSelectedItems = 'selected_items';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFoodItems (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnCost REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrderPlans (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDate TEXT NOT NULL,
        $columnTargetCost REAL NOT NULL,
        $columnSelectedItems TEXT NOT NULL
      )
    ''');

    await db.insert(tableFoodItems, {'name': 'Pizza', 'cost': 10.5});
    await db.insert(tableFoodItems, {'name': 'Burger', 'cost': 7.5});
    await db.insert(tableFoodItems, {'name': 'Pasta', 'cost': 8.0});
    await db.insert(tableFoodItems, {'name': 'Salad', 'cost': 5.0});
  }

  Future<int> insertFoodItem(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableFoodItems, row);
  }

  Future<List<Map<String, dynamic>>> queryAllFoodItems() async {
    Database db = await database;
    return await db.query(tableFoodItems);
  }

  Future<int> updateFoodItem(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnId];
    return await db.update(tableFoodItems, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteFoodItem(int id) async {
    Database db = await database;
    return await db.delete(tableFoodItems, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> insertOrderPlan(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableOrderPlans, row);
  }

  Future<List<Map<String, dynamic>>> queryOrderPlan(String date) async {
    Database db = await database;
    return await db.query(tableOrderPlans, where: '$columnDate = ?', whereArgs: [date]);
  }
}
