import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_state.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'memory_grid.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            level INTEGER NOT NULL,
            moves INTEGER NOT NULL,
            score INTEGER NOT NULL,
            date TEXT NOT NULL,
            timeInSeconds INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveProgress(GameState state) async {
    final db = await database;
    await db.insert(
      'user_progress',
      state.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GameState>> getLastSevenDaysProgress() async {
    final db = await database;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'date > ?',
      whereArgs: [sevenDaysAgo.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => GameState.fromMap(maps[i]));
  }

  Future<int> getBestScore(int level) async {
    final db = await database;
    final result = await db.query(
      'user_progress',
      columns: ['MAX(score) as maxScore'],
      where: 'level = ?',
      whereArgs: [level],
    );

    return result.first['maxScore'] as int? ?? 0;
  }
}
