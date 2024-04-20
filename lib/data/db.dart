import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  // static const List<String> ageStages = [
  //   'year_11',
  //   'year_12',
  //   'year_13',
  //   'year_14',
  //   'year_15',
  //   'public',
  // ];
  static const List<String> races = [
    'free_50m',
    'free_100m',
    'free_200m',
    'free_400m',
    'free_800m',
    'free_1500m',
    'breast_50m',
    'breast_100m',
    'breast_200m',
    'back_50m',
    'back_100m',
    'back_200m',
    'butterfly_50m',
    'butterfly_100m',
    'butterfly_200m',
    'medley_200m',
    'medley_400m',
  ];

  static const List<String> weekDays = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];
  static Database? _db;

  String myDatabase = "swimming_database.db";
  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, myDatabase);
    Database myDb = await openDatabase(path, onCreate: _onCreate, version: 1, onUpgrade: onUpgrade);
    return myDb;
  }
  onUpgrade(Database db, int oldVersion, int newVersion) async{
    if (kDebugMode) {
      print("onUpgrade ========================");
    }
  }

  _onCreate(Database db, int version) async {
    // Table of swimmer
    await db.execute('''
    CREATE TABLE swimmer(
       "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
       "name" TEXT NOT NULL, 
       "age" TEXT NOT NULL, 
       "gender" TEXT NOT NULL,
       "monday" TEXT,
       "tuesday" TEXT,
       "wednesday" TEXT,
       "thursday" TEXT,
       "friday" TEXT,
       "saturday" TEXT,
       "sunday" TEXT
       )
    ''');
    if (kDebugMode) {
      print("Create DATABASE AND SWIMMER TABLE ==========================");
    }
    // Table of championships
    await db.execute('''
    CREATE TABLE champ(
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
        "name" TEXT, 
        "start" TEXT, 
        "end" TEXT
    )
    ''');
    if (kDebugMode) {
      print("CHAMPIONSHIPS TABLES ==========================");
    }
    // Table of week days
    await createWeekDayTables(db);
    if (kDebugMode) {
      print("WEEKDAYS TABLES ==========================");
    }
    // Table of races
    await createRacesTables(db);
    if (kDebugMode) {
      print("RACES TABLES ==========================");
    }
  }
  getAllTableNames() async {
    try {
      // Wait for the database to be opened
      Database? db = await this.db;

      // Query the sqlite_master table to retrieve table names
      List<Map<String, dynamic>> tables = await db!.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);

      // Extract table names from the query result
      List<String> tableNames = tables.map((table) => table['name'] as String).toList();

      return tableNames;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching table names: $e');
      }
      rethrow;
    }
  }
  deleteTable(String tableName) async {
    try {
      // Wait for the database to be opened
      Database? db = await this.db;

      // Execute the DROP TABLE statement
      await db!.execute('DROP TABLE IF EXISTS $tableName');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting table: $e');
      }
      rethrow;
    }
  }
  readData(String sql) async{
    Database? myDb = await db;
    List<Map> response = await myDb!.rawQuery(sql);
    return response;
  }
  insertData(String sql) async{
    Database? myDb = await db;
    int response = await myDb!.rawInsert(sql);
    return response;
  }
  updateData(String sql) async{
    Database? myDb = await db;
    int response = await myDb!.rawUpdate(sql);
    return response;
  }
  deleteData(String sql) async{
    Database? myDb = await db;
    int response = await myDb!.rawDelete(sql);
    return response;
  }
  deleteMyDatabase() async{
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, myDatabase);
    await deleteDatabase(path);
    if (kDebugMode) {
      print("delete database ====================================");
    }
  }
}
createWeekDayTables(Database db) {
  for (String day in SqlDb.weekDays) {
    db.execute('''
    CREATE TABLE $day(
       "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
       "swimmerName" TEXT, 
       "time" TEXT, 
       "come" TEXT, 
       FOREIGN KEY(swimmerName) REFERENCES swimmer(name)
    )
    ''');
  }
}
createRacesTables(Database db) {
  for (String race in SqlDb.races) {
    db.execute('''
    CREATE TABLE $race(
       "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
       "swimmerName" TEXT, 
       "gender" TEXT, 
       "ageStage" TEXT, 
       "date" TEXT, 
       "time" TEXT, 
       "score" TEXT, 
       "champName" TXT, 
       FOREIGN KEY(swimmerName) REFERENCES swimmer(name), 
       FOREIGN KEY(champName) REFERENCES champ(name)
    )
    ''');
  }
}

