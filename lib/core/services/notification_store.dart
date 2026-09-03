import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/notifications/domain/entities/notification_entity.dart';

class NotificationStore {
  static const String databaseName = 'notifications.db';
  static const String tableName = 'notifications';

  static Database? _database;
  static final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  Stream<int> get unreadCountStream => _unreadCountController.stream;

  void notifyUnreadCountChanged() {
    getUnreadCount().then((count) => _unreadCountController.add(count));
  }

  Future<Database> get database async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
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
    );
  }

  Future<List<NotificationEntity>> getNotifications() async {
    final db = await database;
    final rows = await db.query(
      tableName,
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
      tableName,
      where: 'id = ?',
      whereArgs: [notification.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return;
    }

    await db.insert(
      tableName,
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
    notifyUnreadCountChanged();
  }

  Future<void> markAsRead(String id) async {
    final db = await database;
    await db.update(
      tableName,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyUnreadCountChanged();
  }

  Future<void> deleteReadNotifications() async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'isRead = ?',
      whereArgs: [1],
    );
    notifyUnreadCountChanged();
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete(tableName);
    notifyUnreadCountChanged();
  }
}
