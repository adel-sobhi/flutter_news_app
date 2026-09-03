import 'dart:convert';

import 'package:flutter/material.dart';

import '../../features/news/domain/entities/news_response_entities.dart';
import '../../features/news/presentation/widgets/article_details_sheet.dart';
import '../../features/news/presentation/pages/news_page.dart';

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void goToArticle(
    String? title,
    String? body,
    String? url,
    String? imageUrl, {
    String? sourceId,
    String? categoryId,
  }) {
    if (title == null && body == null && (url == null || url.isEmpty)) {
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // If we know the target source/category, open the real news page and let it resolve the
    // article from the same API data that the user is already viewing.
    if ((sourceId ?? '').isNotEmpty || (categoryId ?? '').isNotEmpty) {
      final route = MaterialPageRoute(
        builder: (_) => NewsPage(
          categoryId: categoryId ?? 'general',
          initialSourceId: sourceId,
          initialArticleUrl: url,
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
      description: body ?? title ?? 'News details',
      url: url,
      urlToImage: imageUrl,
      publishedAt: DateTime.now().toIso8601String(),
      content: body ?? title,
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
