import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../../domain/entities/news_response_entities.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsEntity article;

  const NewsDetailPage({super.key, required this.article});

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return '';

    final difference = DateTime.now().difference(parsed);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return 'Over a week';
  }

  @override
  Widget build(BuildContext context) {
    final content = article.content?.isNotEmpty == true
        ? article.content!
        : (article.description ?? 'No additional content available.');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Article details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if ((article.urlToImage ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 18),
            Text(
              article.title ?? 'Untitled',
              style: AppStyles.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if ((article.author ?? '').isNotEmpty)
                  Expanded(
                    child: Text(
                      article.author!,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodyMediumBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                if ((article.source?.name ?? '').isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '· ${article.source!.name}',
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              formatDate(article.publishedAt),
              style:
                  AppStyles.dateText.copyWith(color: AppColors.textLightHint),
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: AppStyles.bodyMedium.copyWith(
                height: 1.7,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 28),
            if ((article.url ?? '').isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(article.url!);
                  if (uri == null ||
                      !await launchUrl(uri,
                          mode: LaunchMode.externalApplication)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Could not open the article.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('Open full article'),
              ),
          ],
        ),
      ),
    );
  }
}
