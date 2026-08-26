import '../../domain/entities/login_response_entities.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthCheckingStatus extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final LoginResponseEntity user;
  LoginSuccess(this.user);
}

class RegisterSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
