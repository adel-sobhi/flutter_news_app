import 'package:flutter/material.dart';

import '../utils/app_color.dart';

class AppLoadingIndicator extends StatelessWidget {
  final Color color;

  const AppLoadingIndicator({super.key, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: color));
  }
}
