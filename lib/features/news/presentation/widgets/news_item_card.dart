import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../../domain/entities/news_response_entities.dart';

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
                        errorWidget: (context, url, error) => imagePlaceholder(),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  if (article.urlToImage != null &&
                      article.urlToImage!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const SizedBox(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    article.title ?? '',
                    style: AppStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if ((article.author ?? '').isNotEmpty)
                        Flexible(
                          child: Text(
                            article.author!,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bodyMediumBold.copyWith(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if ((article.source?.name ?? '').isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '· ${article.source!.name}',
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(article.publishedAt),
                    style: AppStyles.dateText
                        .copyWith(fontSize: 11, color: AppColors.textLightHint),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    (article.content?.isNotEmpty ?? false)
                        ? article.content!
                        : (article.description ??
                            'No additional content available.'),
                    style: AppStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if ((article.url ?? '').isNotEmpty)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final String? rawUrl = article.url;
                        if (rawUrl != null && rawUrl.isNotEmpty) {
                          final Uri url = Uri.parse(rawUrl);
                          try {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch this link'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: const Text('View Full Article',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
