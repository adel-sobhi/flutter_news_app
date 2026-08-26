import 'package:dartz/dartz.dart';

import '../../../../../core/errors/errors.dart';
import '../../models/login_response_model.dart';
import '../../models/register_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Errors, LoginResponseModel>> login({
    required String username,
    required String password,
  });

  Future<Either<Errors, RegisterResponseModel>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  });
}
