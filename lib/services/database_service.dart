import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ocr_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ocr_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ocr_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        original_text TEXT,
        edited_text TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await _onCreate(db, newVersion);
    }
  }

  Future<int> insertRecord(OcrRecord record) async {
    final db = await database;
    return await db.insert(
      'ocr_records',
      record.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OcrRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ocr_records',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => OcrRecord.fromMap(map)).toList();
  }

  Future<OcrRecord?> getRecordById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ocr_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return OcrRecord.fromMap(maps.first);
  }

  Future<int> updateRecord(OcrRecord record) async {
    final db = await database;
    return await db.update(
      'ocr_records',
      record.toMap()..['updated_at'] = DateTime.now().toIso8601String(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'ocr_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllRecords() async {
    final db = await database;
    return await db.delete('ocr_records');
  }

  Future<List<OcrRecord>> searchRecords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ocr_records',
      where: 'original_text LIKE ? OR edited_text LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => OcrRecord.fromMap(map)).toList();
  }
}
