import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/errors.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Errors, ProfileEntity>> call({
    String? firstName,
    String? lastName,
    String? username,
    String? image,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      username: username,
      image: image,
    );
  }
}
