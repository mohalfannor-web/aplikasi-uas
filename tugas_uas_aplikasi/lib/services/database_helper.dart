import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studymate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel tugas
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        course TEXT NOT NULL,
        deadline INTEGER NOT NULL,
        description TEXT,
        priority TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabel jadwal
    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        course TEXT NOT NULL,
        day TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        room TEXT NOT NULL
      )
    ''');
  }

  // ===== TASK CRUD =====

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      _taskToMap(task),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      _taskToMap(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'deadline ASC');
    return maps.map((m) => _taskFromMap(m)).toList();
  }

  Future<void> deleteAllTasks() async {
    final db = await database;
    await db.delete('tasks');
  }

  Map<String, dynamic> _taskToMap(Task task) => {
    'id': task.id,
    'title': task.title,
    'course': task.course,
    'deadline': task.deadline.millisecondsSinceEpoch,
    'description': task.description,
    'priority': task.priority,
    'isDone': task.isDone ? 1 : 0,
  };

  Task _taskFromMap(Map<String, dynamic> m) => Task(
    id: m['id'] as String,
    title: m['title'] as String,
    course: m['course'] as String,
    deadline: DateTime.fromMillisecondsSinceEpoch(m['deadline'] as int),
    description: m['description'] as String?,
    priority: m['priority'] as String,
    isDone: (m['isDone'] as int) == 1,
  );

  // ===== JADWAL CRUD =====

  Future<void> insertJadwal(Jadwal jadwal) async {
    final db = await database;
    await db.insert(
      'schedules',
      _jadwalToMap(jadwal),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteJadwal(String id) async {
    final db = await database;
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Jadwal>> getAllJadwal() async {
    final db = await database;
    final maps = await db.query('schedules');
    return maps.map((m) => _jadwalFromMap(m)).toList();
  }

  Future<void> deleteAllJadwal() async {
    final db = await database;
    await db.delete('schedules');
  }

  Map<String, dynamic> _jadwalToMap(Jadwal j) => {
    'id': j.id,
    'course': j.course,
    'day': j.day,
    'startTime': j.startTime,
    'endTime': j.endTime,
    'room': j.room,
  };

  Jadwal _jadwalFromMap(Map<String, dynamic> m) => Jadwal(
    id: m['id'] as String,
    course: m['course'] as String,
    day: m['day'] as String,
    startTime: m['startTime'] as String,
    endTime: m['endTime'] as String,
    room: m['room'] as String,
  );

  // ===== PROFILE (SharedPreferences) =====

  static const _keyName = 'profile_name';
  static const _keyUsername = 'profile_username';
  static const _keyImagePath = 'profile_image_path';

  Future<void> saveProfile({
    required String name,
    required String username,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyUsername, username);
    if (imagePath != null) {
      await prefs.setString(_keyImagePath, imagePath);
    } else {
      await prefs.remove(_keyImagePath);
    }
  }

  Future<Map<String, String?>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? 'Mahasiswa',
      'username': prefs.getString(_keyUsername) ?? 'mahasiswa@email.com',
      'imagePath': prefs.getString(_keyImagePath),
    };
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyImagePath);
  }

  Future<void> clearAll() async {
    await deleteAllTasks();
    await deleteAllJadwal();
    await clearProfile();
  }
}
