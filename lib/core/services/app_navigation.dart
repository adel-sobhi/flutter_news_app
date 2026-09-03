import 'dart:convert';

import 'package:flutter/material.dart';

import '../../features/news/domain/entities/news_response_entities.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/news/presentation/widgets/article_details_sheet.dart';
import 'notification_store.dart';

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // If we know the target source/category, open the real news page and let it resolve the
    // article from the same API data that the user is already viewing.
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

  static void handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final sourceId =
            decoded['sourceId']?.toString() ?? decoded['source_id']?.toString();
        final categoryId = decoded['categoryId']?.toString() ??
            decoded['category_id']?.toString();

        goToArticle(
          decoded['title']?.toString(),
          decoded['body']?.toString(),
          decoded['url']?.toString(),
          decoded['imageUrl']?.toString(),
          sourceId: sourceId,
          categoryId: categoryId,
          author: decoded['author']?.toString(),
          publishedAt: decoded['publishedAt']?.toString(),
          description: decoded['description']?.toString(),
          content: decoded['content']?.toString(),
          notificationId: decoded['id']?.toString(),
        );
        return;
      }
    } catch (_) {
      // ignore and fallback to browser if payload is plain URL
    }

    final uri = Uri.tryParse(payload);
    if (uri != null && uri.hasScheme) {
      goToArticle('News', 'Open article', uri.toString(), null);
    }
  }
}
