import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
