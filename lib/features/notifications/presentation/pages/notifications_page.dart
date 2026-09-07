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
  final NotificationStore notificationStore = NotificationStore();
  final Set<String> expandedIds = <String>{};

  Future<List<NotificationEntity>> loadNotifications() async {
    return notificationStore.getNotifications();
  }

  Future<void> markAsReadOnly(NotificationEntity notification) async {
    if (!notification.isRead) {
      await notificationStore.markAsRead(notification.id);
      try {
        await FcmService().updateBadgeCount();
      } catch (_) {}
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> toggleExpanded(
      NotificationEntity notification, bool isExpanded) async {
    if (isExpanded) {
      expandedIds.add(notification.id);
      await markAsReadOnly(notification);
    } else {
      expandedIds.remove(notification.id);
    }
  }

  Future<void> openFullArticle(NotificationEntity notification) async {
    await markAsReadOnly(notification);

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

  Future<void> deleteReadNotifications() async {
    await notificationStore.deleteReadNotifications();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: AppColors.textPrimary,
        actions: [
          FutureBuilder<List<NotificationEntity>>(
            future: loadNotifications(),
            builder: (context, snapshot) {
              final notifications = snapshot.data ?? <NotificationEntity>[];
              if (!notifications.any((item) => item.isRead)) {
                return SizedBox.shrink();
              }

              return IconButton(
                onPressed: deleteReadNotifications,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationEntity>>(
        future: loadNotifications(),
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final isExpanded = expandedIds.contains(notification.id);

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
                              onExpansionChanged: (value) async {
                                if (value &&
                                    notification.url != null &&
                                    notification.url!.isNotEmpty) {
                                  await openFullArticle(notification);
                                }
                                await toggleExpanded(notification, value);
                              },
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
                                notification.title,
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
                                if ((notification.author ?? '').isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'By ${notification.author}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                if ((notification.publishedAt ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        notification.publishedAt!,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    notification.description ??
                                        notification.body,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if ((notification.content ?? '')
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      notification.content!,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        height: 1.55,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                if (notification.url != null &&
                                    notification.url!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          openFullArticle(notification),
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
