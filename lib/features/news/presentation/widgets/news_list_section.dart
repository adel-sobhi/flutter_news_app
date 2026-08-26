import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import 'news_item_card.dart';

class NewsListSection extends StatefulWidget {
  final String sourceId;

  const NewsListSection({required this.sourceId});

  @override
  State<NewsListSection> createState() => _NewsListSectionState();
}

class _NewsListSectionState extends State<NewsListSection> {
  final ScrollController scrollController = ScrollController();

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
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is NewsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.textLightHint),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage.errorMessage,
                    style: const TextStyle(color: AppColors.error, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => context.read<NewsCubit>().getNews(widget.sourceId),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is NewsSuccess) {
          final articles = state.articles;

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
