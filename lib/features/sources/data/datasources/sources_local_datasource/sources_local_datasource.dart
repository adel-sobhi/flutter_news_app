import '../../models/sources_response_model.dart';

abstract class SourcesLocalDatasource {
  Future<void> cacheSources(String categoryId, SourcesResponseModel response);
  Future<SourcesResponseModel?> getCachedSources(String categoryId);
}
