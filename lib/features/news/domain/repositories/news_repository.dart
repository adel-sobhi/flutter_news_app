import '../../../../core/errors/errors.dart';
import '../entities/news_response_entities.dart';
import 'package:dartz/dartz.dart';

abstract class NewsRepository {
  Future<Either<Errors,NewsResponseEntity>>getNews(String sourceId, {int page});
}