import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'blog.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE articles (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)',
        );
      },
    );
  }

  Future<int> addArticle(String title, String content) async {
    final db = await database;
    return await db.insert('articles', {'title': title, 'content': content});
  }

  Future<List<Map<String, dynamic>>> getAllArticles() async {
    final db = await database;
    return await db.query('articles');
  }

  Future<Map<String, dynamic>?> getArticleById(int id) async {
    final db = await database;
    final results =
        await db.query('articles', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
