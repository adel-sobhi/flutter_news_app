import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
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
  String? pickedImageBase64;

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

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await loginUseCase(email: email, password: password);

    result.fold(
          (error) {
        emit(AuthError(error.errorMessage));
      },
          (user) {
        emit(LoginSuccess(user));
      },
    );
  }

  Future<void> pickAndCompressImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    emit(ProfileImageCompressing(progress: 10));
    await Future.delayed(const Duration(milliseconds: 150));
    emit(ProfileImageCompressing(progress: 35));

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      picked.path,
      minWidth: 300,
      minHeight: 300,
      quality: 60,
    );

    if (compressedBytes != null) {
      emit(ProfileImageCompressing(progress: 75));
      pickedImageBase64 = base64Encode(compressedBytes);
      emit(ProfileImagePicked(pickedImageBase64!));
    } else {
      emit(AuthError('Failed to compress image.'));
    }
  }

  void clearPickedImage() {
    pickedImageBase64 = null;
    emit(AuthInitial());
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: password,
      image: pickedImageBase64,
    );

    result.fold(
          (error) {
        emit(AuthError(error.errorMessage));
      },
          (user) {
        emit(RegisterSuccess());
      },
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }
}