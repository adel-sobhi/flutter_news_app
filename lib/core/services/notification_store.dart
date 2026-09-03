import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/notifications/domain/entities/notification_entity.dart';

class NotificationStore {
  static const String _databaseName = 'notifications.db';
  static const String _tableName = 'notifications';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            url TEXT,
            imageUrl TEXT,
            sourceId TEXT,
            categoryId TEXT,
            author TEXT,
            publishedAt TEXT,
            description TEXT,
            content TEXT,
            isRead INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final columns = await db.rawQuery('PRAGMA table_info($_tableName)');
          final columnNames = columns.map((c) => c['name'] as String).toSet();
          if (!columnNames.contains('sourceId')) {
            await db
                .execute('ALTER TABLE $_tableName ADD COLUMN sourceId TEXT');
          }
          if (!columnNames.contains('categoryId')) {
            await db
                .execute('ALTER TABLE $_tableName ADD COLUMN categoryId TEXT');
          }
        }
        if (oldVersion < 3) {
          final columns = await db.rawQuery('PRAGMA table_info($_tableName)');
          final columnNames = columns.map((c) => c['name'] as String).toSet();
          for (final column in [
            'author',
            'publishedAt',
            'description',
            'content'
          ]) {
            if (!columnNames.contains(column)) {
              await db
                  .execute('ALTER TABLE $_tableName ADD COLUMN $column TEXT');
            }
          }
        }
      },
    );
  }

  Future<List<NotificationEntity>> getNotifications() async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );

    final notifications = rows
        .map((row) => NotificationEntity.fromJson({
              ...row,
              'isRead': (row['isRead'] as int) == 1,
            }))
        .toList();

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((item) => !item.isRead).length;
  }

  Future<void> addNotification(NotificationEntity notification) async {
    final db = await database;
    final existing = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [notification.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return;
    }

    await db.insert(
      _tableName,
      {
        'id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'url': notification.url,
        'imageUrl': notification.imageUrl,
        'sourceId': notification.sourceId,
        'categoryId': notification.categoryId,
        'author': notification.author,
        'publishedAt': notification.publishedAt,
        'description': notification.description,
        'content': notification.content,
        'isRead': notification.isRead ? 1 : 0,
        'createdAt': notification.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markAsRead(String id) async {
    final db = await database;
    await db.update(
      _tableName,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteReadNotifications() async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'isRead = ?',
      whereArgs: [1],
    );
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
