import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/errors.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Errors, ProfileEntity>> call({bool forceRemote = false}) {
    return repository.getProfile(forceRemote: forceRemote);
  }
}
