import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() {
    return repository.isLoggedIn();
  }
}
