import 'package:dartz/dartz.dart';
import '../../../../../core/errors/errors.dart';
import '../../models/sources_response_model.dart';

abstract class SourcesRemoteDatasource {
  Future<Either<Errors, SourcesResponseModel>> getSources(String categoryId);
}