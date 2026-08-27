import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../features/authentication/data/models/login_response_model.dart';
import '../../features/authentication/data/models/register_response_model.dart';
import '../../features/news/data/models/news_response_model.dart';
import '../../features/sources/data/models/sources_response_model.dart';
import '../errors/exceptions.dart';
import 'api_constants.dart';
import 'end_points.dart';

@singleton
class ApiManager {
  static const Duration timeoutDuration = Duration(seconds: 15);

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    Uri url = Uri.https(ApiConstants.authBaseUrl, EndPoints.loginApi);

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'expiresInMins': 30,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponseModel.fromJson(json);
      }

      if (response.statusCode == 400 || response.statusCode == 401) {

        throw ServerException('Invalid username or password');
      }
      throw ServerException();
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Connection timed out, please check your internet');
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    }
  }

  Future<RegisterResponseModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    Uri url = Uri.https(ApiConstants.authBaseUrl, EndPoints.registerApi);

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
              'username': username,
              'password': password,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RegisterResponseModel.fromJson(json);

      }
      throw ServerException();
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Connection timed out, please check your internet');
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    }
  }

  Future<SourcesResponseModel> getSources(String categoryId) async {
    Uri url = Uri.https(
      ApiConstants.baseUrl,
      EndPoints.sourceApi,
      {
        'apiKey': ApiConstants.apiKey,
        'category': categoryId,
      },
    );

    try {
      final response = await http.get(url).timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SourcesResponseModel.fromJson(json);
      }
      throw ServerException();
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Connection timed out, please check your internet');
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    }
  }

  Future<NewsResponseModel> getNewsBySourceId(
      String sourceId, {
        int page = 1,
        int pageSize = ApiConstants.pageSize,
      }) async {
    Uri url = Uri.https(
      ApiConstants.baseUrl,
      EndPoints.newsApi,
      {
        'apiKey': ApiConstants.apiKey,
        'sources': sourceId,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    try {
      final response = await http.get(url).timeout(timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return NewsResponseModel.fromJson(json);
      }

      throw ServerException();
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Connection timed out, please check your internet');
    } on FormatException {
      throw ServerException('Received an invalid response from the server');
    }
  }


}