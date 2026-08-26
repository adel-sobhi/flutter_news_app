abstract class AppException implements Exception {
  final String message;
  AppException(this.message);


}

class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection, please check your network'])
      : super(message);
}

class ServerException extends AppException {
  ServerException([String message = 'Server error, please try again later'])
      : super(message);
}

