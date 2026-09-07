import 'dart:convert';

import 'package:flutter/material.dart';

import '../../features/news/domain/entities/news_response_entities.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/news/presentation/widgets/article_details_sheet.dart';
import 'notification_store.dart';

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final Set<String> handledNotificationKeys = <String>{};

  static String notificationKeyFromPayload(Map<String, dynamic> decoded) {
    final id = decoded['id']?.toString();
    if (id != null && id.isNotEmpty) return 'id:$id';

    final url = decoded['url']?.toString();
    if (url != null && url.isNotEmpty) return 'url:$url';

    final title = decoded['title']?.toString() ?? 'notification';
    final body = decoded['body']?.toString() ?? '';
    return 'fallback:${title}_$body';
  }

  static void goToArticle(
    String? title,
    String? body,
    String? url,
    String? imageUrl, {
    String? sourceId,
    String? categoryId,
    String? author,
    String? publishedAt,
    String? description,
    String? content,
    String? notificationId,
  }) {
    if (title == null && body == null && (url == null || url.isEmpty)) {
      return;
    }

    void openArticle() {
      final context = navigatorKey.currentContext;
      if (context == null) {
        Future.delayed(const Duration(milliseconds: 250), openArticle);
        return;
      }

      if ((sourceId ?? '').isNotEmpty || (categoryId ?? '').isNotEmpty) {
        if (notificationId != null && notificationId.isNotEmpty) {
          try {
            final store = NotificationStore();
            store.markAsRead(notificationId);
          } catch (_) {}
        }

        final route = MaterialPageRoute(
          builder: (_) => NewsPage(
            categoryId: categoryId ?? 'general',
            initialSourceId: sourceId,
            initialArticleUrl: url,
            initialTitle: title ?? body,
            initialBody: body ?? title,
            initialImageUrl: imageUrl,
            initialAuthor: author,
            initialPublishedAt: publishedAt,
            initialDescription: description,
            initialContent: content,
          ),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final nav = navigatorKey.currentState;
          if (nav == null || !nav.mounted) return;
          nav.push(route);
        });
        return;
      }

      final article = NewsEntity(
        title: title ?? body ?? 'News',
        description: description ?? body ?? title ?? 'News details',
        url: url,
        urlToImage: imageUrl,
        publishedAt: publishedAt ?? DateTime.now().toIso8601String(),
        content: content ?? body ?? title ?? 'News details',
        author: author,
      );

      ArticleDetailsSheet.show(context, article);
    }

    openArticle();
  }

  static void handleNotificationPayload(String? payload) async {
    if (payload == null || payload.isEmpty) {
      return;
    }

    final dedupeKey = payload.trim();
    final fallbackKey = Uri.tryParse(dedupeKey)?.toString() ?? dedupeKey;
    if (handledNotificationKeys.contains(fallbackKey)) {
      return;
    }
    handledNotificationKeys.add(fallbackKey);

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final key = notificationKeyFromPayload(decoded);
        if (handledNotificationKeys.contains(key)) {
          return;
        }
        handledNotificationKeys.add(key);

        final notificationId = decoded['id']?.toString();
        final url = decoded['url']?.toString();
        final store = NotificationStore();

        ///نتاكد ان الاشعار متفتحش قبل كده
        final alreadyHandled =
            await store.hasBeenHandled(notificationId, url: url);
        if (alreadyHandled) {
          return;
        }
        await store.markAsHandled(notificationId, url: url);

        final sourceValue = decoded['source'];
        final sourceId = decoded['sourceId']?.toString() ??
            decoded['source_id']?.toString() ??
            (sourceValue is Map
                ? (sourceValue['id']?.toString() ??
                    sourceValue['sourceId']?.toString() ??
                    sourceValue['source_id']?.toString())
                : null);
        final categoryValue = decoded['category'];
        final categoryId = decoded['categoryId']?.toString() ??
            decoded['category_id']?.toString() ??
            (categoryValue is Map
                ? (categoryValue['id']?.toString() ??
                    categoryValue['categoryId']?.toString() ??
                    categoryValue['category_id']?.toString())
                : null);

        goToArticle(
          decoded['title']?.toString(),
          decoded['body']?.toString(),
          url,
          decoded['imageUrl']?.toString(),
          sourceId: sourceId,
          categoryId: categoryId,
          author: decoded['author']?.toString(),
          publishedAt: decoded['publishedAt']?.toString(),
          description: decoded['description']?.toString(),
          content: decoded['content']?.toString(),
          notificationId: notificationId,
        );
        return;
      }
    } catch (_) {
    }

    final uri = Uri.tryParse(payload);
    if (uri != null && uri.hasScheme) {
      final url = uri.toString();
      final store = NotificationStore();
      final alreadyHandled = await store.hasBeenHandled(null, url: url);
      if (alreadyHandled) {
        return;
      }
      await store.markAsHandled(null, url: url);
      goToArticle('News', 'Open article', url, null);
    }
  }
}
