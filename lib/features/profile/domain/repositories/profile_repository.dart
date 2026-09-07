import 'package:dartz/dartz.dart';

import '../../../../core/errors/errors.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Errors, ProfileEntity>> getProfile({bool forceRemote = false});

  Future<Either<Errors, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? image,
  });
}
