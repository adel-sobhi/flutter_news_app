import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/errors.dart';
import '../entities/sources_response_entities.dart';
import '../repositories/sources_repository.dart';

@injectable
class GetSourcesUseCase {
  final SourcesRepository repository;
  GetSourcesUseCase(this.repository);

  Future<Either<Errors, SourcesResponseEntity>>call(String categoryId){
    return repository.getSources(categoryId)   ;

  }

}
