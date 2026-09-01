import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/errors.dart';
import '../../models/login_response_model.dart';
import '../../models/register_response_model.dart';
import 'auth_remote_datasource.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // final ApiManager apiManager;
  // AuthRemoteDataSourceImpl({required this.apiManager});
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl(
      {required this.firebaseAuth, required this.firestore});

  @override
  Future<Either<Errors, LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc =
          await firestore.collection('users').doc(credential.user?.uid).get();

      final username = userDoc.data()?['username'];

      return Right(LoginResponseModel(
        id: credential.user?.uid.hashCode,
        email: credential.user?.email,
        username: username,
        accessToken: await credential.user?.getIdToken(),
      ));
    } on FirebaseAuthException catch (e) {
      return Left(ServerError(errorMessage: e.message ?? 'Login failed'));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Errors, RegisterResponseModel>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection('users').doc(credential.user?.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Right(RegisterResponseModel(
        id: credential.user?.uid.hashCode,
        firstName: firstName,
        lastName: lastName,
        email: credential.user?.email,
        username: username,
      ));
    } on FirebaseAuthException catch (e) {
      return Left(ServerError(errorMessage: e.message ?? 'Register failed'));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }

// @override
// Future<Either<Errors, LoginResponseModel>> login({
//   required String username,
//   required String password,
// }) async {
//   try {
//     final response = await apiManager.login(username: username, password: password);
//     return Right(response);
//   } on NetworkException catch (e) {
//     return Left(NetworkError(errorMessage: e.message));
//   } on ServerException catch (e) {
//     return Left(ServerError(errorMessage: e.message));
//   } catch (e) {
//     return Left(Errors(errorMessage: 'An unexpected error occurred'));
//   }
// }

// @override
// Future<Either<Errors, RegisterResponseModel>> register({
//   required String firstName,
//   required String lastName,
//   required String email,
//   required String username,
//   required String password,
// }) async {
//   try {
//     final response = await apiManager.register(
//       firstName: firstName,
//       lastName: lastName,
//       email: email,
//       username: username,
//       password: password,
//     );
//     return Right(response);
//   } on NetworkException catch (e) {
//     return Left(NetworkError(errorMessage: e.message));
//   } on ServerException catch (e) {
//     return Left(ServerError(errorMessage: e.message));
//   } catch (e) {
//     return Left(Errors(errorMessage: 'An unexpected error occurred'));
//   }
// }
}
