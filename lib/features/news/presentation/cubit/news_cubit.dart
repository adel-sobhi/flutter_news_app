import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_news_use_case.dart';
import 'news_state.dart';

@injectable
class NewsCubit extends Cubit<NewsState> {
  final GetNewsUseCase getNewsUseCase;

  NewsCubit(this.getNewsUseCase) : super(NewsInitial());

  String? currentSourceId;
  int currentPage = 1;
  int totalResults = 0;

  void getNews(String sourceId) async {
    currentSourceId = sourceId;
    currentPage = 1;
    totalResults = 0;
    emit(NewsLoading());

    var result = await getNewsUseCase(sourceId, page: currentPage);

    result.fold(
      (error) => emit(NewsError(errorMessage: error)),
      (data) {
        final articles = data.articles ?? [];
        totalResults = data.totalResults?.toInt() ?? articles.length;

        emit(NewsSuccess(
          articles: articles,
          hasReachedMax: data.isFromCache || articles.isEmpty || articles.length >= totalResults,
          isLoadingMore: false,
          isOffline: data.isFromCache,
        ));
      },
    );
  }


  Future<void> fetchNextPage() async {
    final state = this.state;
    if (state is! NewsSuccess) return;
    if (state.hasReachedMax || state.isLoadingMore || state.isOffline) return;
    final sourceId = currentSourceId;
    if (sourceId == null) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = currentPage + 1;
    final result = await getNewsUseCase(sourceId, page: nextPage);

    result.fold(
      (error) {
        emit(state.copyWith(isLoadingMore: false));
      },
      (newsEntity) {
        final newArticles = newsEntity.articles ?? [];
        currentPage = nextPage;
        final combinedArticles = [...state.articles, ...newArticles];

        emit(NewsSuccess(
          articles: combinedArticles,
          hasReachedMax: newArticles.isEmpty || combinedArticles.length >= totalResults,
          isLoadingMore: false,
          isOffline: false,
        ));
      },
    );
  }


}
