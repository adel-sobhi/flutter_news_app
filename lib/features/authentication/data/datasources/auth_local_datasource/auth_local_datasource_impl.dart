// import 'package:injectable/injectable.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'auth_local_datasource.dart';


import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'auth_local_datasource.dart';

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String tokenKey = 'auth_token';

  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> cacheToken(String token) async {
    await storage.write(
      key: tokenKey,
      value: token,
    );
  }

  @override
  Future<String?> getCachedToken() async {
    return await storage.read(
      key: tokenKey,
    );
  }

  @override
  Future<void> clearToken() async {
    await storage.delete(
      key: tokenKey,
    );
  }
}





















// @Injectable(as: AuthLocalDataSource)
// class AuthLocalDataSourceImpl implements AuthLocalDataSource {
//   static const String dbName = 'auth_cache.db';
//   static const String table = 'user_auth';
//
//   Database? database;
//
//   Future<Database> initDb() async {
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, dbName);
//
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute('''
//           CREATE TABLE $table (
//             id INTEGER PRIMARY KEY,
//             token TEXT NOT NULL
//           )
//         ''');
//       },
//     );
//   }
//
//   Future<Database> get sureInitialized async {
//     database ??= await initDb();
//     return database!;
//   }
//
//   @override
//   Future<void> cacheToken(String token) async {
//     final db = await sureInitialized;
//     await db.delete(table);
//     await db.insert(table, {'id': 1, 'token': token});
//   }
//
//   @override
//   Future<String?> getCachedToken() async {
//     final db = await sureInitialized;
//     final rows = await db.query(table, limit: 1);
//     if (rows.isEmpty) return null;
//     return rows.first['token'] as String?;
//   }
//
//   @override
//   Future<void> clearToken() async {
//     final db = await sureInitialized;
//     await db.delete(table);
//   }
// }
