import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/api/api_manager.dart';
import '../../../../../core/errors/errors.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/login_response_model.dart';
import '../../models/register_response_model.dart';
import 'auth_remote_datasource.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiManager apiManager;

  AuthRemoteDataSourceImpl({required this.apiManager});

  @override
  Future<Either<Errors, LoginResponseModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiManager.login(username: username, password: password);
      return Right(response);
    } on NetworkException catch (e) {
      return Left(NetworkError(errorMessage: e.message));
    } on ServerException catch (e) {
      return Left(ServerError(errorMessage: e.message));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Errors, RegisterResponseModel>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiManager.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        password: password,
      );
      return Right(response);
    } on NetworkException catch (e) {
      return Left(NetworkError(errorMessage: e.message));
    } on ServerException catch (e) {
      return Left(ServerError(errorMessage: e.message));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }
}
