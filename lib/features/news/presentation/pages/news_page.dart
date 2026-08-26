import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_color.dart';
import '../../../sources/presentation/cubit/sources_cubit.dart';
import '../../../sources/presentation/cubit/sources_state.dart';
import '../cubit/news_cubit.dart';
import '../widgets/news_list_section.dart';
import '../../../sources/presentation/pages/source_horizontal_list.dart';


class NewsPage extends StatefulWidget {
  final String categoryId;

  const NewsPage({super.key, this.categoryId = 'general'});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String? selectedSourceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SourcesCubit>().getSources(widget.categoryId);
    });
  }

  void selectSource(int index, String sourceId) {
    context.read<SourcesCubit>().changeTabIndex(index);
    if (selectedSourceId != sourceId) {
      setState(() => selectedSourceId = sourceId);
      context.read<NewsCubit>().getNews(sourceId);
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
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (sourcesState is SourcesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sourcesState.errorMessage.errorMessage,
                      style: const TextStyle(color: AppColors.error, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.read<SourcesCubit>().getSources(widget.categoryId),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
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
                selectSource(0, sourcesList[sourcesState.selectedIndex].id ?? '');
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
                      : NewsListSection(sourceId: selectedSourceId!),
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