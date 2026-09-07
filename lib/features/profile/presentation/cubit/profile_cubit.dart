import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileCubit(this.getProfileUseCase, this.updateProfileUseCase)
      : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await getProfileUseCase();
    result.fold(
      (error) => emit(ProfileError(error.errorMessage)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateTextFields({
    String? firstName,
    String? lastName,
    String? username,
  }) async {
    emit(ProfileUpdating());
    final result = await updateProfileUseCase(
      firstName: firstName,
      lastName: lastName,
      username: username,
    );
    result.fold(
      (error) => emit(ProfileError(error.errorMessage)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> pickAndUpdateImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    emit(ProfileImageUploading(10));
    await Future.delayed(const Duration(milliseconds: 150));
    emit(ProfileImageUploading(30));

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      picked.path,
      minWidth: 300,
      minHeight: 300,
      quality: 60,
    );

    if (compressedBytes == null) {
      emit(ProfileError('Failed to process image'));
      return;
    }

    emit(ProfileImageUploading(60));
    final base64Image = base64Encode(compressedBytes);

    emit(ProfileImageUploading(90));
    final result = await updateProfileUseCase(image: base64Image);

    result.fold(
      (error) => emit(ProfileError(error.errorMessage)),
      (profile) {
        emit(ProfileImageUploading(100));
        emit(ProfileLoaded(profile));
      },
    );
  }
}
