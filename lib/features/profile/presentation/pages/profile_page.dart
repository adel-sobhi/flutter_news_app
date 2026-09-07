import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../authentication/presentation/widgets/auth_text_field.dart';
import '../../domain/entities/profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  bool justSavedProfile = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();

    super.dispose();
  }

  void populateFieldsIfEmpty(ProfileEntity profile) {
    if (firstNameController.text.trim().isEmpty) {
      firstNameController.text = profile.firstName ?? '';
    }
    if (lastNameController.text.trim().isEmpty) {
      lastNameController.text = profile.lastName ?? '';
    }
    if (usernameController.text.trim().isEmpty) {
      usernameController.text = profile.username ?? '';
    }
  }

  void save() {
    if (formKey.currentState!.validate()) {
      justSavedProfile = true;
      context.read<ProfileCubit>().updateTextFields(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            username: usernameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'My Profile',
          style: AppStyles.appBarTitle.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: AppStyles.snackBarText),
                  backgroundColor: AppColors.error,
                ),
              );
              justSavedProfile = false;
            } else if (state is ProfileLoaded && justSavedProfile) {
              justSavedProfile = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Profile saved successfully',
                    style: AppStyles.snackBarText,
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
          builder: (context, state) {
            final lastLoadedProfile = extractLastProfile(context);
            final fallbackProfile = lastLoadedProfile ?? ProfileEntity();

            if (state is ProfileInitial || state is ProfileLoading) {
              populateFieldsIfEmpty(fallbackProfile);
              return buildProfileContent(
                profile: fallbackProfile,
                uploadProgress: null,
                isUpdating: false,
              );
            }

            ProfileEntity? profile;
            int? uploadProgress;

            if (state is ProfileLoaded) {
              profile = state.profile;
            } else if (state is ProfileImageUploading) {
              uploadProgress = state.progress;
            }

            profile ??= lastLoadedProfile ?? fallbackProfile;
            populateFieldsIfEmpty(profile);

            return buildProfileContent(
              profile: profile,
              uploadProgress: uploadProgress,
              isUpdating: state is ProfileUpdating,
            );
          },
        ),
      ),
    );
  }

  Widget buildProfileContent({
    required ProfileEntity profile,
    required int? uploadProgress,
    required bool isUpdating,
  }) {
    final isUploading = uploadProgress != null;
    final currentUploadProgress = uploadProgress ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: GestureDetector(
                      onTap: isUploading
                          ? null
                          : () =>
                              context.read<ProfileCubit>().pickAndUpdateImage(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                AppColors.iconDefault.withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (profile.image != null &&
                                  profile.image!.isNotEmpty)
                                Image.memory(
                                  base64Decode(profile.image!),
                                  fit: BoxFit.cover,
                                )
                              else if (!isUploading)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 42,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Add photo',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  color: AppColors.iconDefault
                                      .withValues(alpha: 0.12),
                                ),
                              if (isUploading)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.upload,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'File Upload',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 140,
                                          child: LinearProgressIndicator(
                                            value: (currentUploadProgress / 100)
                                                .clamp(0.0, 1.0),
                                            minHeight: 6,
                                            backgroundColor: Colors.white24,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                              AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '$currentUploadProgress%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isUploading) const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if ((profile.email ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  profile.email!,
                  style: AppStyles.snackBarText.copyWith(
                    color: AppColors.iconDefault,
                  ),
                ),
              ),
            AuthTextField(
              controller: firstNameController,
              hint: 'First name',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: lastNameController,
              hint: 'Last name',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: usernameController,
              hint: 'Username',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Save Changes',
              isLoading: isUpdating,
              onPressed: save,
            ),
          ],
        ),
      ),
    );
  }

  ProfileEntity? extractLastProfile(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) return state.profile;
    return null;
  }
}
