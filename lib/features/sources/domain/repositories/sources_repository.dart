import '../../../../core/errors/errors.dart';
import '../entities/sources_response_entities.dart';
import 'package:dartz/dartz.dart';

abstract class SourcesRepository {
  Future<Either<Errors,SourcesResponseEntity>>getSources(String categoryId);
}