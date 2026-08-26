import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/errors.dart';
import '../../domain/entities/sources_response_entities.dart';
import '../../domain/repositories/sources_repository.dart';
import '../datasources/sources_local_datasource/sources_local_datasource.dart';
import '../datasources/sources_remote_datasource/sources_remote_datasource.dart';


@Injectable(as: SourcesRepository)
class SourcesRepositoryImpl implements SourcesRepository {
  final SourcesRemoteDatasource remoteDatasource;
  final SourcesLocalDatasource localDatasource;

  SourcesRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Errors, SourcesResponseEntity>> getSources(String categoryId) async {
    var either = await remoteDatasource.getSources(categoryId);

    return either.fold(
      (error) async {

        try {
          final cachedSources = await localDatasource.getCachedSources(categoryId);
          if (cachedSources != null) {
            return Right(cachedSources);
          }
        } catch (_) {
        }
        return Left(error);
      },
      (responseModel) async {

        try {
          await localDatasource.cacheSources(categoryId, responseModel);
        } catch (_) {}
        return Right(responseModel);
      },
    );
  }
}
