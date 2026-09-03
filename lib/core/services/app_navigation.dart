import 'dart:convert';

import 'package:flutter/material.dart';

import '../../features/news/domain/entities/news_response_entities.dart';
import '../../features/news/presentation/widgets/article_details_sheet.dart';

class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void goToArticle(String? title, String? body, String? url, String? imageUrl) {
    if (title == null && body == null && (url == null || url.isEmpty)) {
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final article = NewsEntity(
      title: title ?? body ?? 'News',
      description: body ?? title ?? 'News details',
      url: url,
      urlToImage: imageUrl,
      publishedAt: DateTime.now().toIso8601String(),
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
        goToArticle(
          decoded['title']?.toString(),
          decoded['body']?.toString(),
          decoded['url']?.toString(),
          decoded['imageUrl']?.toString(),
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
