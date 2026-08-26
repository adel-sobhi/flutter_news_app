import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/news_response_model.dart';
import 'news_local_datasource.dart';

@Injectable(as: NewsLocalDatasource)
class NewsLocalDatasourceImpl implements NewsLocalDatasource {
  static const String dbName = 'news_cache.db';
  static const String table = 'cached_news';

  Database? database;

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $table (
            source_id TEXT PRIMARY KEY,
            response_json TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<Database> get sureInitialized async {
    database ??= await initDb();
    return database!;
  }

  @override
  Future<void> cacheNews(String sourceId, NewsResponseModel response) async {
    final db = await sureInitialized;
    await db.insert(
      table,
      {
        'source_id': sourceId,
        'response_json': jsonEncode(response.toJson()),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<NewsResponseModel?> getCachedNews(String sourceId) async {
    final db = await sureInitialized;
    final rows = await db.query(
      table,
      where: 'source_id = ?',
      whereArgs: [sourceId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final jsonString = rows.first['response_json'] as String;
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final model = NewsResponseModel.fromJson(decoded);
    model.isFromCache = true;
    return model;
  }
}
