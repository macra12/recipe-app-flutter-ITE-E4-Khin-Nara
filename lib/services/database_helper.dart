import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
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
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        name TEXT,
        imageUrl TEXT,
        category TEXT
      )
    ''');
  }

  Future<void> insertFavorite(Meal meal) async {
    final db = await instance.database;
    await db.insert('favorites', {
      'id': meal.id,
      'name': meal.name,
      'imageUrl': meal.imageUrl,
      'category': meal.category,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteFavorite(String id) async {
    final db = await instance.database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await instance.database;
    return await db.query('favorites');
  }
}