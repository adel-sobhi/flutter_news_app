import '../../models/news_response_model.dart';


abstract class NewsLocalDatasource {
  Future<void> cacheNews(String sourceId, NewsResponseModel response);

  Future<NewsResponseModel?> getCachedNews(String sourceId);
}
