import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'auth_local_datasource.dart';

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String tokenKey = 'auth_token';
  static const String dbName = 'user_profile_cache.db';
  static const String table = 'user_profile';

  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  Database? database;

  Future<Database> get db async {
    database ??= await initDb();
    return database!;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY,
            firstName TEXT,
            lastName TEXT,
            email TEXT,
            username TEXT,
            image TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<void> cacheToken(String token) async {
    await storage.write(key: tokenKey, value: token);
  }

  @override
  Future<String?> getCachedToken() async {
    return await storage.read(key: tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await storage.delete(key: tokenKey);
  }

  @override
  Future<void> cacheUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? image,
  }) async {
    final db = await this.db;
    await db.insert(
      table,
      {
        'id': 1,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
        'image': image,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final db = await this.db;
    final rows =
        await db.query(table, where: 'id = ?', whereArgs: [1], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  @override
  Future<void> clearUserProfile() async {
    final db = await this.db;
    await db.delete(table);
  }
}