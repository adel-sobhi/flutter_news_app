import 'package:flutter/material.dart';

import '../../../../core/services/app_navigation.dart';
import '../../../../core/services/notification_store.dart';
import '../../../../core/utils/app_color.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationStore _notificationStore = NotificationStore();

  Future<List<NotificationEntity>> _loadNotifications() async {
    return _notificationStore.getNotifications();
  }

  Future<void> _openNotification(NotificationEntity notification) async {
    if (!notification.isRead) {
      await _notificationStore.markAsRead(notification.id);
      if (mounted) {
        setState(() {});
      }
    }

    if (notification.url != null && notification.url!.isNotEmpty) {
      AppNavigation.goToArticle(
        notification.title,
        notification.body,
        notification.url,
        notification.imageUrl,
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: FutureBuilder<List<NotificationEntity>>(
        future: _loadNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? <NotificationEntity>[];
          final unreadCount =
              notifications.where((item) => !item.isRead).length;

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.background,
                child: Text(
                  '$unreadCount unread',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: notifications.length,
                  padding: const EdgeInsets.all(12),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      onTap: () => _openNotification(notification),
                      tileColor: notification.isRead
                          ? Colors.white
                          : AppColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: notification.isRead
                            ? Colors.grey.shade200
                            : AppColors.primary,
                        child: Icon(
                          notification.isRead
                              ? Icons.mark_email_read_outlined
                              : Icons.notifications_active_rounded,
                          color: notification.isRead
                              ? AppColors.textPrimary
                              : Colors.white,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: notification.isRead
                          ? const Icon(Icons.check_circle_outline,
                              color: Colors.green)
                          : const Icon(Icons.circle,
                              color: AppColors.primary, size: 12),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
