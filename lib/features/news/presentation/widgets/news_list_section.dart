import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../sources/domain/entities/sources_response_entities.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../domain/entities/news_response_entities.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import 'article_details_sheet.dart';
import 'error_retry_view.dart';
import 'news_item_card.dart';

class NewsListSection extends StatefulWidget {
  final String sourceId;
  final String? initialTitle;
  final String? initialBody;
  final String? initialImageUrl;
  final String? initialAuthor;
  final String? initialPublishedAt;
  final String? initialDescription;
  final String? initialContent;

  const NewsListSection({
    super.key,
    required this.sourceId,
    this.initialTitle,
    this.initialBody,
    this.initialImageUrl,
    this.initialAuthor,
    this.initialPublishedAt,
    this.initialDescription,
    this.initialContent,
  });

  @override
  NewsListSectionState createState() => NewsListSectionState();
}

class NewsListSectionState extends State<NewsListSection> {
  final ScrollController scrollController = ScrollController();
  String? _pendingArticleUrl;

  /// Request the list to open the article with [url]. If articles are not loaded yet,
  /// the URL will be stored and opened once loading finishes.
  bool _urlsMatch(String? a, String b) {
    if (a == null || a.isEmpty) return false;
    try {
      final ua = Uri.parse(a);
      final ub = Uri.parse(b);
      // Match by scheme, host and path to avoid differences in query params/order
      return ua.scheme == ub.scheme && ua.host == ub.host && ua.path == ub.path;
    } catch (_) {
      return a == b || a.contains(b) || b.contains(a);
    }
  }

  Future<void> openArticleByUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    _pendingArticleUrl = url;

    // Try immediately if data already available
    final state = context.read<NewsCubit>().state;
    if (state is NewsSuccess) {
      NewsEntity? found;
      final articles = state.articles;
      final idx = articles.indexWhere((a) => _urlsMatch(a.url, url));
      if (idx != -1) {
        found = articles[idx];
      } else {
        // Not found locally — try Firestore fallback
        try {
          final doc = await FirebaseFirestore.instance
              .collection('latest_articles')
              .doc(widget.sourceId)
              .get();
          if (doc.exists) {
            final data = doc.data();
            if (data != null) {
              final sourceMap = data['source'] as Map<String, dynamic>?;
              final sourceEntity = sourceMap != null
                  ? SourcesEntity(
                      id: sourceMap['id']?.toString(),
                      name: sourceMap['name']?.toString())
                  : null;

              final candidateUrl = data['url']?.toString();
              if (candidateUrl != null && _urlsMatch(candidateUrl, url)) {
                found = NewsEntity(
                  title: data['title']?.toString(),
                  description: data['description']?.toString(),
                  url: candidateUrl,
                  urlToImage: data['urlToImage']?.toString(),
                  publishedAt: data['publishedAt']?.toString(),
                  author: data['author']?.toString(),
                  source: sourceEntity,
                  content: data['content']?.toString(),
                );
              }
            }
          }
        } catch (_) {
          // ignore firestore read failures
        }
      }

      if (found != null) {
        // Scroll the list so the target item becomes visible (approximate by index)
        if (scrollController.hasClients) {
          final itemHeightEstimate = 160.0; // estimated card height
          final maxScroll = scrollController.position.maxScrollExtent;
          final targetIndex = idx != -1 ? idx : 0;
          final target =
              (targetIndex * itemHeightEstimate).clamp(0.0, maxScroll);
          scrollController.animateTo(target,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ArticleDetailsSheet.show(context, found!);
        });
        _pendingArticleUrl = null;
        return;
      }

      // Final fallback: never open another news card if we failed to match the exact URL.
      final fallback = NewsEntity(
        title: widget.initialTitle ?? 'News',
        description: widget.initialDescription ??
            widget.initialBody ??
            widget.initialTitle ??
            'News details',
        url: url,
        urlToImage: widget.initialImageUrl,
        publishedAt:
            widget.initialPublishedAt ?? DateTime.now().toIso8601String(),
        content: widget.initialContent ??
            widget.initialBody ??
            widget.initialTitle ??
            'News details',
        author: widget.initialAuthor,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ArticleDetailsSheet.show(context, fallback);
      });
      _pendingArticleUrl = null;
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _tryShowFromFirestore(String pendingUrl) async {
    if ((_pendingArticleUrl ?? '').isEmpty ||
        _pendingArticleUrl != pendingUrl) {
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('latest_articles')
          .doc(widget.sourceId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final candidateUrl = data['url']?.toString();
          if (candidateUrl != null && _urlsMatch(candidateUrl, pendingUrl)) {
            final sourceMap = data['source'] as Map<String, dynamic>?;
            final sourceEntity = sourceMap != null
                ? SourcesEntity(
                    id: sourceMap['id']?.toString(),
                    name: sourceMap['name']?.toString())
                : null;

            final found = NewsEntity(
              title: data['title']?.toString(),
              description: data['description']?.toString(),
              url: candidateUrl,
              urlToImage: data['urlToImage']?.toString(),
              publishedAt: data['publishedAt']?.toString(),
              author: data['author']?.toString(),
              source: sourceEntity,
              content: data['content']?.toString(),
            );

            if (scrollController.hasClients) {
              final maxScroll = scrollController.position.maxScrollExtent;
              final target = (0.0).clamp(0.0, maxScroll);
              scrollController.animateTo(target,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut);
            }

            if (!mounted) return;
            ArticleDetailsSheet.show(context, found);
            _pendingArticleUrl = null;
            return;
          }
        }
      }

      final fallback = NewsEntity(
        title: widget.initialTitle ?? 'News',
        description: widget.initialDescription ??
            widget.initialBody ??
            widget.initialTitle ??
            'News details',
        url: pendingUrl,
        urlToImage: widget.initialImageUrl,
        publishedAt:
            widget.initialPublishedAt ?? DateTime.now().toIso8601String(),
        content: widget.initialContent ??
            widget.initialBody ??
            widget.initialTitle ??
            'News details',
        author: widget.initialAuthor,
      );

      if (!mounted) return;
      ArticleDetailsSheet.show(context, fallback);
      _pendingArticleUrl = null;
    } catch (_) {
      final fallback = NewsEntity(
        title: widget.initialTitle ?? 'News',
        description: widget.initialDescription ??
            widget.initialBody ??
            widget.initialTitle ??
            'News details',
        url: pendingUrl,
        urlToImage: widget.initialImageUrl,
        publishedAt:
            widget.initialPublishedAt ?? DateTime.now().toIso8601String(),
        content: widget.initialContent ??
            widget.initialBody ??
            widget.initialTitle ??
            'News details',
        author: widget.initialAuthor,
      );

      if (!mounted) return;
      ArticleDetailsSheet.show(context, fallback);
      _pendingArticleUrl = null;
    }
  }

  void onScroll() {
    if (!scrollController.hasClients) return;

    const loadMoreOffset = 200.0;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (currentScroll >= maxScroll - loadMoreOffset) {
      context.read<NewsCubit>().fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading || state is NewsInitial) {
          return const AppLoadingIndicator();
        }

        if (state is NewsError) {
          return ErrorRetryView(
            icon: Icons.wifi_off_rounded,
            message: state.errorMessage.errorMessage,
            onRetry: () => context.read<NewsCubit>().getNews(widget.sourceId),
          );
        }

        if (state is NewsSuccess) {
          final articles = state.articles;

          // If a pending URL was requested earlier, try to open it now
          if ((_pendingArticleUrl ?? '').isNotEmpty) {
            final pendingUrl = _pendingArticleUrl!;
            final idx =
                articles.indexWhere((a) => _urlsMatch(a.url, pendingUrl));
            if (idx != -1) {
              final found = articles[idx];

              // Scroll approximate position before showing details
              if (scrollController.hasClients) {
                final itemHeightEstimate = 160.0;
                final maxScroll = scrollController.position.maxScrollExtent;
                final target = (idx * itemHeightEstimate).clamp(0.0, maxScroll);
                scrollController.animateTo(target,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut);
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                ArticleDetailsSheet.show(context, found);
              });
              _pendingArticleUrl = null;
            } else {
              // Try Firestore fallback if not found locally (run after frame)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _tryShowFromFirestore(pendingUrl);
              });
            }
          }

          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.newspaper_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This channel has no news',
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  color: AppColors.imagePlaceholderBg,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'You are offline — please connect to the internet',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context.read<NewsCubit>().getNews(widget.sourceId),
                  child: ListView.builder(
                    key: PageStorageKey<String>(widget.sourceId),
                    controller: scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: articles.length + (state.hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index >= articles.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      return NewsItemCard(article: articles[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}