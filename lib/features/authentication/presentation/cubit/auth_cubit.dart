import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/check_auth_status_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit(
      this.loginUseCase,
      this.registerUseCase,
      this.checkAuthStatusUseCase,
      this.logoutUseCase,
      ) : super(AuthInitial());


  Future<void> checkAuthStatus() async {
    emit(AuthCheckingStatus());
    final isLoggedIn = await checkAuthStatusUseCase();
    emit(isLoggedIn ? AuthAuthenticated() : AuthUnauthenticated());
  }

  Future<void> login({required String username, required String password}) async {
    emit(AuthLoading());
    debugPrint(' [Login] Sending request for username: "$username"...');

    final result = await loginUseCase(username: username, password: password);

    result.fold(
          (error) {
        debugPrint(' [Login] Failed: ${error.errorMessage}');
        emit(AuthError(error.errorMessage));
      },
          (user) {
        debugPrint(' [Login] Success: welcome "${user.username}" (id: ${user.id})');
        emit(LoginSuccess(user));
      },
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());
    debugPrint('[Register] Sending request for username: "$username"...');

    final result = await registerUseCase(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: password,
    );

    result.fold(
          (error) {
        debugPrint(' [Register] Failed: ${error.errorMessage}');
        emit(AuthError(error.errorMessage));
      },
          (user) {
        debugPrint(' [Register] Success: created user "${user.username}" (id: ${user.id})');
        emit(RegisterSuccess());
      },
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }
}