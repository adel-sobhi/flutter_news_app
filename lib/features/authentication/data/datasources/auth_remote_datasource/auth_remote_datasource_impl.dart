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

      final data = userDoc.data();

      return Right(LoginResponseModel(
        id: credential.user?.uid.hashCode,
        email: credential.user?.email,
        username: data?['username'],
        firstName: data?['firstName'],
        lastName: data?['lastName'],
        image: data?['image'],
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
    String? image,
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
        'image': image,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Right(RegisterResponseModel(
        id: credential.user?.uid.hashCode,
        firstName: firstName,
        lastName: lastName,
        email: credential.user?.email,
        username: username,
        image: image,
      ));
    } on FirebaseAuthException catch (e) {
      return Left(ServerError(errorMessage: e.message ?? 'Register failed'));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }
}