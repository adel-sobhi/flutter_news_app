abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException(
      [super.message = 'No internet connection, please check your network']);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error, please try again later']);
}