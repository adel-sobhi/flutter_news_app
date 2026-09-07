import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/errors.dart';
import '../../../authentication/data/datasources/auth_local_datasource/auth_local_datasource.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource/profile_remote_datasource.dart';
import '../models/profile_model.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Errors, ProfileEntity>> getProfile(
      {bool forceRemote = false}) async {
    if (!forceRemote) {
      final cached = await localDataSource.getCachedUserProfile();
      if (cached != null) {
        return Right(ProfileModel.fromMap(cached));
      }
    }

    final either = await remoteDataSource.getProfile();
    return either.fold(
      (error) async => Left(error),
      (profile) async {
        await localDataSource.cacheUserProfile(
          firstName: profile.firstName,
          lastName: profile.lastName,
          email: profile.email,
          username: profile.username,
          image: profile.image,
        );
        return Right(profile);
      },
    );
  }

  @override
  Future<Either<Errors, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? image,
  }) async {
    final either = await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      username: username,
      image: image,
    );

    return either.fold(
      (error) async => Left(error),
      (profile) async {
        await localDataSource.cacheUserProfile(
          firstName: profile.firstName,
          lastName: profile.lastName,
          email: profile.email,
          username: profile.username,
          image: profile.image,
        );
        return Right(profile);
      },
    );
  }
}
