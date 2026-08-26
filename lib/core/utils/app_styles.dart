import 'package:flutter/material.dart';

import 'app_color.dart';

class AppStyles {
  AppStyles._();

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.43,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.43,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.43,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 14,
    height: 1.6,
    color: AppColors.textBody,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 13.5,
    color: AppColors.textSecondary,
    height: 1,
    letterSpacing: -0.28,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: 'SF Pro',
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  static const TextStyle floatingLabel = TextStyle(
    fontFamily: 'SF Pro',
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle dateText = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 12.5,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle itemDateText = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 11,
    color: AppColors.textHint,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle imagePickerAction = TextStyle(
    fontFamily: 'SF Pro',
    color: Colors.white,
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.3,
  );

  static const TextStyle snackBarText = TextStyle(
    fontFamily: 'SF Pro',
  );
}