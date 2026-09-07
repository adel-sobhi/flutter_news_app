import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/errors.dart';
import '../../models/profile_model.dart';
import 'profile_remote_datasource.dart';

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl(
      {required this.firebaseAuth, required this.firestore});

  @override
  Future<Either<Errors, ProfileModel>> getProfile() async {
    try {
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(Errors(errorMessage: 'User not authenticated'));
      }

      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return Left(Errors(errorMessage: 'User data not found'));
      }

      final data = {
        ...doc.data()!,
        'email': firebaseAuth.currentUser?.email,
      };

      return Right(ProfileModel.fromFirestore(data));
    } on FirebaseException catch (e) {
      return Left(
          ServerError(errorMessage: e.message ?? 'Failed to fetch data'));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Errors, ProfileModel>> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? image,
  }) async {
    try {
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return Left(Errors(errorMessage: 'User not authenticated'));
      }

      final updates = <String, dynamic>{};
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (username != null) updates['username'] = username;
      if (image != null) updates['image'] = image;

      await firestore.collection('users').doc(uid).update(updates);

      final doc = await firestore.collection('users').doc(uid).get();
      final data = {
        ...doc.data()!,
        'email': firebaseAuth.currentUser?.email,
      };

      return Right(ProfileModel.fromFirestore(data));
    } on FirebaseException catch (e) {
      return Left(
          ServerError(errorMessage: e.message ?? 'Failed to update data'));
    } catch (e) {
      return Left(Errors(errorMessage: 'An unexpected error occurred'));
    }
  }
}
