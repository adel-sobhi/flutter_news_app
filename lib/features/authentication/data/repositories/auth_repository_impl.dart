import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/errors.dart';
import '../../domain/entities/login_response_entities.dart';
import '../../domain/entities/register_response_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource/auth_remote_datasource.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Errors, LoginResponseEntity>> login({
    required String email,
    required String password,
  }) async {
    final either =
        await remoteDataSource.login(email: email, password: password);

    return either.fold(
      (error) async => Left(error),
      (response) async {
        if (response.accessToken != null) {
          await localDataSource.cacheToken(response.accessToken!);
        }
        return Right(response);
      },
    );
  }

  @override
  Future<Either<Errors, RegisterResponseEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    final either = await remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: password,
    );

    return either.fold(
          (error) async => Left(error),
          (response) async => Right(response),
    );
  }
  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getCachedToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() {
    return localDataSource.clearToken();
  }
}
