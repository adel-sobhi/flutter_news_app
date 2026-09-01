import 'package:dartz/dartz.dart';

import '../../../../core/errors/errors.dart';
import '../entities/login_response_entities.dart';
import '../entities/register_response_entities.dart';

abstract class AuthRepository {
  Future<Either<Errors, LoginResponseEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Errors, RegisterResponseEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  });

  Future<bool> isLoggedIn();

  Future<void> logout();
}
