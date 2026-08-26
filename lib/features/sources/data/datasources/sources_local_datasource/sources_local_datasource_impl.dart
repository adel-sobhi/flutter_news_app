import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/sources_response_model.dart';
import 'sources_local_datasource.dart';

@Injectable(as: SourcesLocalDatasource)
class SourcesLocalDatasourceImpl implements SourcesLocalDatasource {
  static const String dbName = 'sources_cache.db';
  static const String table = 'cached_sources';

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
            category_id TEXT PRIMARY KEY,
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
  Future<void> cacheSources(String categoryId, SourcesResponseModel response) async {
    final db = await sureInitialized;
    await db.insert(
      table,
      {
        'category_id': categoryId,
        'response_json': jsonEncode(response.toJson()),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<SourcesResponseModel?> getCachedSources(String categoryId) async {
    final db = await sureInitialized;
    final rows = await db.query(
      table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final jsonString = rows.first['response_json'] as String;
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final model = SourcesResponseModel.fromJson(decoded);
    model.isFromCache = true;
    return model;
  }
}
