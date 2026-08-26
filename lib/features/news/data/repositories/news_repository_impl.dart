import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/errors.dart';
import '../../domain/entities/news_response_entities.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_local_datasource/news_local_datasource.dart';
import '../datasources/news_remote_datasource/news_remote_datasource.dart';

@Injectable(as: NewsRepository)
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDatasource remoteDatasource;
  final NewsLocalDatasource localDatasource;

  NewsRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Errors, NewsResponseEntity>> getNews(String sourceId, {int page = 1}) async {
    var either = await remoteDatasource.getNews(sourceId, page: page);

    return either.fold(
      (error) async {
        try {
          final cachedNews = await localDatasource.getCachedNews(sourceId);
          if (cachedNews != null) {
            return Right(cachedNews);
          }
        } catch (_) {
          //نتجاهل أي خطأ ثانوي (زي فشل التخزين المؤقت) وما نخليهوش يوقف التطبيق أو يأثر على تجربة المستخدم الأساسية.

        }
        return Left(error);
      },
      (responseModel) async {

        if (page == 1) {
          try {
            await localDatasource.cacheNews(sourceId, responseModel);
          } catch (_) {
          }
        }
        return Right(responseModel);
      },
    );
  }
}
