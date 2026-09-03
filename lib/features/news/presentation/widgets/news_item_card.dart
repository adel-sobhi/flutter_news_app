import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../../domain/entities/news_response_entities.dart';
import 'article_details_sheet.dart';

class NewsItemCard extends StatelessWidget {
  final NewsEntity article;

  const NewsItemCard({super.key, required this.article});

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return '';

    final difference = DateTime.now().difference(parsed);
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'Over a week';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = article.title ?? 'Untitled';
    final description = article.description ?? '';
    final imageUrl = article.urlToImage;

    final author = article.author ?? 'Unknown Author';
    final date = formatDate(article.publishedAt);

    return GestureDetector(
      onTap: () => showArticleDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.imagePlaceholderBg,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            imagePlaceholder(),
                      )
                    : imagePlaceholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (author.isNotEmpty)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 16),
                        if (date.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 14, color: AppColors.textLightHint),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: AppStyles.itemDateText
                                    .copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imagePlaceholder() {
    return Container(
      color: AppColors.imagePlaceholderBg,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined,
            size: 40, color: AppColors.textLightHint),
      ),
    );
  }

  void showArticleDetails(BuildContext context) {
    ArticleDetailsSheet.show(context, article);
  }
}
