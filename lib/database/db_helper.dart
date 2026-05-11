import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/shift.dart';
import '../models/schedule.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shiftflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        hourlyRate REAL NOT NULL,
        overtimeRate REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        shiftId INTEGER NOT NULL,
        note TEXT,
        isLeave INTEGER DEFAULT 0,
        leaveType TEXT
      )
    ''');

    // 插入默认班次
    await db.insert('shifts', {
      'name': '早班',
      'startTime': '08:00',
      'endTime': '17:00',
      'colorValue': 0xFF2196F3,
      'hourlyRate': 20.0,
      'overtimeRate': 30.0,
    });
    await db.insert('shifts', {
      'name': '中班',
      'startTime': '14:00',
      'endTime': '22:00',
      'colorValue': 0xFFFF9800,
      'hourlyRate': 20.0,
      'overtimeRate': 30.0,
    });
    await db.insert('shifts', {
      'name': '晚班',
      'startTime': '22:00',
      'endTime': '08:00',
      'colorValue': 0xFF4CAF50,
      'hourlyRate': 25.0,
      'overtimeRate': 37.5,
    });
    await db.insert('shifts', {
      'name': '休息日',
      'startTime': '00:00',
      'endTime': '00:00',
      'colorValue': 0xFF9E9E9E,
      'hourlyRate': 0.0,
      'overtimeRate': 0.0,
    });
  }

  // ===== Shift =====
  Future<int> insertShift(Shift shift) async {
    final db = await database;
    return await db.insert('shifts', shift.toMap());
  }

  Future<List<Shift>> getAllShifts() async {
    final db = await database;
    final maps = await db.query('shifts', orderBy: 'id ASC');
    return maps.map((e) => Shift.fromMap(e)).toList();
  }

  Future<int> updateShift(Shift shift) async {
    final db = await database;
    return await db.update('shifts', shift.toMap(), where: 'id = ?', whereArgs: [shift.id]);
  }

  Future<int> deleteShift(int id) async {
    final db = await database;
    return await db.delete('shifts', where: 'id = ?', whereArgs: [id]);
  }

  Future<Shift?> getShiftById(int id) async {
    final db = await database;
    final maps = await db.query('shifts', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Shift.fromMap(maps.first);
  }

  // ===== Schedule =====
  Future<int> insertSchedule(Schedule schedule) async {
    final db = await database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<List<Schedule>> getSchedulesByMonth(int year, int month) async {
    final db = await database;
    final start = '$year-${month.toString().padLeft(2, '0')}-01';
    final end = '$year-${month.toString().padLeft(2, '0')}-31';
    final maps = await db.query(
      'schedules',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date ASC',
    );
    return maps.map((e) => Schedule.fromMap(e)).toList();
  }

  Future<List<Schedule>> getSchedulesByDateRange(String start, String end) async {
    final db = await database;
    final maps = await db.query(
      'schedules',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date ASC',
    );
    return maps.map((e) => Schedule.fromMap(e)).toList();
  }

  Future<Schedule?> getScheduleByDate(String date) async {
    final db = await database;
    final maps = await db.query('schedules', where: 'date = ?', whereArgs: [date], limit: 1);
    if (maps.isEmpty) return null;
    return Schedule.fromMap(maps.first);
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await database;
    return await db.update('schedules', schedule.toMap(), where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
