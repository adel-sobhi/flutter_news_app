import '../../../../core/errors/errors.dart';
import '../../domain/entities/news_response_entities.dart';

abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsError extends NewsState {
  final Errors errorMessage;
  NewsError({required this.errorMessage});
}

class NewsSuccess extends NewsState {
  final List<NewsEntity> articles;

  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isOffline;

  NewsSuccess({
    required this.articles,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isOffline = false,
  });

  NewsSuccess copyWith({
    List<NewsEntity>? articles,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isOffline,
  }) {
    return NewsSuccess(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
