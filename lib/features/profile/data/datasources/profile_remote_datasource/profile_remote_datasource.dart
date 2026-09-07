import 'package:dartz/dartz.dart';

import '../../../../../core/errors/errors.dart';
import '../../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<Either<Errors, ProfileModel>> getProfile();

  Future<Either<Errors, ProfileModel>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? image,
  });
}
