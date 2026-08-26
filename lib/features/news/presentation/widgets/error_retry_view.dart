import 'package:flutter/material.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/widgets/primary_button.dart';

class ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData? icon;

  const ErrorRetryView({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 40, color: AppColors.textLightHint),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Try Again',
              onPressed: onRetry,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
