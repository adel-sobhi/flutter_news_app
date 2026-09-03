import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  const NewsListSection({super.key, required this.sourceId});

  @override
  NewsListSectionState createState() => NewsListSectionState();
}

class NewsListSectionState extends State<NewsListSection> {
  final ScrollController scrollController = ScrollController();
  String? _pendingArticleUrl;

  /// Request the list to open the article with [url]. If articles are not loaded yet,
  /// the URL will be stored and opened once loading finishes.
  void openArticleByUrl(String? url) {
    if (url == null || url.isEmpty) return;
    _pendingArticleUrl = url;

    // Try immediately if data already available
    final state = context.read<NewsCubit>().state;
    if (state is NewsSuccess) {
      NewsEntity? found;
      for (final a in state.articles) {
        if ((a.url ?? '') == url) {
          found = a;
          break;
        }
      }
      if (found != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ArticleDetailsSheet.show(context, found!);
        });
        _pendingArticleUrl = null;
      }
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
            final found = articles.firstWhere(
              (a) => (a.url ?? '') == pendingUrl,
              orElse: () => NewsEntity(),
            );
            if ((found.url ?? '').isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ArticleDetailsSheet.show(context, found);
              });
              _pendingArticleUrl = null;
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