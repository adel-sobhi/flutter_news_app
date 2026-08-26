import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/errors.dart';
import '../entities/register_response_entities.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Errors, RegisterResponseEntity>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) {
    return repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: password,
    );
  }
}
