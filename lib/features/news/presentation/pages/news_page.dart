import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../sources/presentation/cubit/sources_cubit.dart';
import '../../../sources/presentation/cubit/sources_state.dart';
import '../../../sources/presentation/pages/source_horizontal_list.dart';
import '../cubit/news_cubit.dart';
import '../widgets/error_retry_view.dart';
import '../widgets/news_list_section.dart';


class NewsPage extends StatefulWidget {
  final String categoryId;
  final String? initialArticleUrl;
  final String? initialSourceId;
  final String? initialTitle;
  final String? initialBody;
  final String? initialImageUrl;
  final String? initialAuthor;
  final String? initialPublishedAt;
  final String? initialDescription;
  final String? initialContent;

  const NewsPage({
    super.key,
    this.categoryId = 'general',
    this.initialArticleUrl,
    this.initialSourceId,
    this.initialTitle,
    this.initialBody,
    this.initialImageUrl,
    this.initialAuthor,
    this.initialPublishedAt,
    this.initialDescription,
    this.initialContent,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String? selectedSourceId;

  final GlobalKey<NewsListSectionState> _newsListKey =
      GlobalKey<NewsListSectionState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SourcesCubit>().getSources(widget.categoryId);
    });
  }

  void selectSource(int index, String sourceId) {
    context.read<SourcesCubit>().changeTabIndex(index);
    if (selectedSourceId != sourceId) {
      setState(() => selectedSourceId = sourceId);
      context.read<NewsCubit>().getNews(sourceId);
    }

    if (widget.initialArticleUrl != null &&
        widget.initialArticleUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _newsListKey.currentState?.openArticleByUrl(widget.initialArticleUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,size: 20),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.categoryId} News',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<SourcesCubit, SourcesState>(
        builder: (context, sourcesState) {
          if (sourcesState is SourcesLoading) {
            return const AppLoadingIndicator();
          }

          if (sourcesState is SourcesError) {
            return ErrorRetryView(
              message: sourcesState.errorMessage.errorMessage,
              onRetry: () =>
                  context.read<SourcesCubit>().getSources(widget.categoryId),
            );
          }

          if (sourcesState is SourcesSuccess) {
            final sourcesList = sourcesState.sourcesResponse.sources ?? [];


            if (sourcesList.isEmpty) {
              return const Center(
                child: Text(
                  'No Sources Available',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            if (selectedSourceId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                final targetId = widget.initialSourceId != null &&
                        sourcesList.any((source) =>
                            (source.id ?? '') == widget.initialSourceId)
                    ? widget.initialSourceId!
                    : sourcesList[sourcesState.selectedIndex].id ?? '';

                final targetIndex = sourcesList.indexWhere(
                  (source) => (source.id ?? '') == targetId,
                );

                if (targetIndex >= 0) {
                  selectSource(targetIndex, targetId);
                } else if (sourcesList.isNotEmpty) {
                  selectSource(0, sourcesList[0].id ?? '');
                }
              });
            }

            // If this was opened from a notification, open the exact matching article after the
            // source list is ready.
            if (widget.initialArticleUrl != null &&
                widget.initialArticleUrl!.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _newsListKey.currentState
                    ?.openArticleByUrl(widget.initialArticleUrl);
              });
            }
            return Column(
              children: [
                SourceHorizontalList(
                  sources: sourcesList,
                  selectedIndex: sourcesState.selectedIndex,
                  onSourceTap: (index) => selectSource(index, sourcesList[index].id ?? ''),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: selectedSourceId == null
                      ? const SizedBox()
                      : NewsListSection(
                          key: _newsListKey,
                          sourceId: selectedSourceId!,
                          initialTitle: widget.initialTitle,
                          initialBody: widget.initialBody,
                          initialImageUrl: widget.initialImageUrl,
                          initialAuthor: widget.initialAuthor,
                          initialPublishedAt: widget.initialPublishedAt,
                          initialDescription: widget.initialDescription,
                          initialContent: widget.initialContent,
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}