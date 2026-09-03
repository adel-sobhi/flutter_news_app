import 'package:flutter/material.dart';

import '../../../../core/services/app_navigation.dart';
import '../../../../core/services/fcm_service.dart';
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
  final Set<String> _expandedIds = <String>{};

  Future<List<NotificationEntity>> _loadNotifications() async {
    return _notificationStore.getNotifications();
  }

  Future<void> _markAsReadOnly(NotificationEntity notification) async {
    if (!notification.isRead) {
      await _notificationStore.markAsRead(notification.id);
      // update badge count after marking as read
      try {
        await FcmService().updateBadgeCount();
      } catch (_) {}
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _toggleExpanded(
      NotificationEntity notification, bool isExpanded) async {
    if (isExpanded) {
      _expandedIds.add(notification.id);
      await _markAsReadOnly(notification);
    } else {
      _expandedIds.remove(notification.id);
    }
  }

  Future<void> _openFullArticle(NotificationEntity notification) async {
    await _markAsReadOnly(notification);

    AppNavigation.goToArticle(
      notification.title,
      notification.body,
      notification.url,
      notification.imageUrl,
      sourceId: notification.sourceId,
      categoryId: notification.categoryId,
      author: notification.author,
      publishedAt: notification.publishedAt,
      description: notification.description,
      content: notification.content,
      notificationId: notification.id,
    );
  }

  Future<void> _deleteReadNotifications() async {
    await _notificationStore.deleteReadNotifications();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          FutureBuilder<List<NotificationEntity>>(
            future: _loadNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? <NotificationEntity>[];
              if (!notifications.any((item) => item.isRead)) {
                return SizedBox.shrink();
              }

              return IconButton(
                onPressed: _deleteReadNotifications,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: 'Delete all read notifications',
              );
            },
          ),
        ],
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
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                    final isExpanded = _expandedIds.contains(notification.id);

                    return Container(
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? Colors.white
                              : AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notification.isRead
                                ? Colors.grey.shade200
                                : AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              tilePadding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              childrenPadding:
                                  const EdgeInsets.fromLTRB(14, 0, 14, 14),
                              onExpansionChanged: (value) =>
                                  _toggleExpanded(notification, value),
                              initiallyExpanded: isExpanded,
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
                                notification.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                              ),
                              trailing:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    notification.body,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (notification.url != null &&
                                    notification.url!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          _openFullArticle(notification),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                      ),
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'View Article',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ));
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
