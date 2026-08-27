import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/api/api_manager.dart';
import '../../../../../core/errors/errors.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/news_response_model.dart';
import 'news_remote_datasource.dart';

@Injectable(as: NewsRemoteDatasource)
class NewsRemoteDatasourceImpl implements NewsRemoteDatasource {
  final ApiManager apiManager;

  NewsRemoteDatasourceImpl({required this.apiManager});

  @override
  Future<Either<Errors, NewsResponseModel>> getNews(
    String sourceId, {
    int page = 1,
  }) async {
    try {
      final response = await apiManager.getNewsBySourceId(sourceId, page: page);

      if (response.status == 'ok') {
        return Right(response);
      }
      return Left(ServerError(errorMessage: 'Server error, please try again later'));
    } on NetworkException catch (e) {
      return Left(NetworkError(errorMessage: e.message));
    } on ServerException catch (e) {
      return Left(ServerError(errorMessage: e.message));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }
}
