import 'package:dartz/dartz.dart';
import '../../../../../core/errors/errors.dart';
import '../../../../sources/data/models/sources_response_model.dart';
import '../../models/news_response_model.dart';

abstract class NewsRemoteDatasource {
  Future<Either<Errors, NewsResponseModel>> getNews(String sourceId, {int page});
}