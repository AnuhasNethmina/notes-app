import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLite {
  static final SQLite _instance = SQLite._internal();
  factory SQLite() => _instance;

  SQLite._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(
      join(await getDatabasesPath(), filePath),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert(
      'notes',
      note,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  Future<void> updateNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
