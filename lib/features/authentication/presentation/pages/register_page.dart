import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void clearSelectedImage() {
    if (!mounted) return;
    context.read<AuthCubit>().clearPickedImage();
  }

  void goBack() {
    clearSelectedImage();
    Navigator.of(context).pop();
  }

  void submit() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            email: emailController.text.trim(),
            username: usernameController.text.trim(),
            password: passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (_, __) => clearSelectedImage(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              onPressed: goBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            title: Text('Create Account', style: AppStyles.appBarTitle),
            centerTitle: true,
          ),
          body: SafeArea(
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is RegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account created.',
                    style: AppStyles.snackBarText.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
                  clearSelectedImage();
                  Navigator.of(context).pop();
                } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: AppStyles.snackBarText),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      Center(
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final base64Image =
                                context.read<AuthCubit>().pickedImageBase64;
                            final isCompressing =
                                state is ProfileImageCompressing;
                            final progress = isCompressing ? state.progress : 0;

                            return SizedBox(
                              width: double.infinity,
                              height: 220,
                              child: GestureDetector(
                                onTap: isCompressing
                                    ? null
                                    : () => context
                                        .read<AuthCubit>()
                                        .pickAndCompressImage(),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.iconDefault
                                          .withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: base64Image != null
                                        ? Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.memory(
                                                base64Decode(base64Image),
                                                fit: BoxFit.cover,
                                              ),
                                              if (isCompressing)
                                                Container(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.25),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .upload_file_rounded,
                                                          color: Colors.white,
                                                          size: 36,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        const Text(
                                                          'File Upload',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        SizedBox(
                                                          width: 140,
                                                          child:
                                                              LinearProgressIndicator(
                                                            value: (progress /
                                                                    100)
                                                                .clamp(
                                                                    0.0, 1.0),
                                                            minHeight: 6,
                                                            backgroundColor:
                                                                Colors.white24,
                                                            valueColor:
                                                                const AlwaysStoppedAnimation(
                                                              AppColors.primary,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          '$progress%',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          )
                                        : Center(
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
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        controller: firstNameController,
                    hint: 'First name',
                    icon: Icons.badge_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: lastNameController,
                    hint: 'Last name',
                    icon: Icons.badge_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: usernameController,
                    hint: 'Username',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.iconDefault,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        label: 'Create Account',
                        isLoading: state is AuthLoading,
                        onPressed: submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
          ),
        ));
  }
}