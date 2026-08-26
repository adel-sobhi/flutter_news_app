import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/errors.dart';
import '../entities/news_response_entities.dart';
import '../repositories/news_repository.dart';

@injectable
class GetNewsUseCase {
  final NewsRepository repository;
  GetNewsUseCase(this.repository);

    Future<Either<Errors, NewsResponseEntity>>call(String sourceId, {int page = 1}){
    return repository.getNews(sourceId, page: page) ;

  }

}
