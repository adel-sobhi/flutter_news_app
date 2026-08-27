import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:notes_app/features/sources/data/datasources/sources_remote_datasource/sources_remote_datasource.dart';
import 'package:notes_app/features/sources/data/models/sources_response_model.dart';

import '../../../../../core/api/api_manager.dart';
import '../../../../../core/errors/errors.dart';
import '../../../../../core/errors/exceptions.dart';

@Injectable(as: SourcesRemoteDatasource)
class SourcesRemoteDatasourceImpl implements SourcesRemoteDatasource {
  final ApiManager apiManager;

  SourcesRemoteDatasourceImpl({required this.apiManager});

  @override
  Future<Either<Errors, SourcesResponseModel>> getSources(String categoryId) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return Left(NetworkError(errorMessage: 'No internet connection, please check your network'));
      }

      final response = await apiManager.getSources(categoryId);

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
