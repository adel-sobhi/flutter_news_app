import 'package:flutter/material.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_styles.dart';
import '../../domain/entities/sources_response_entities.dart';

class SourceHorizontalList extends StatelessWidget {
  final List<SourcesEntity> sources;
  final int selectedIndex;
  final ValueChanged<int> onSourceTap;

  const SourceHorizontalList({
    super.key,
    required this.sources,
    required this.selectedIndex,
    required this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sources.length,
        separatorBuilder: (Context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedIndex;
          final String name = sources[index].name ?? '';

          return GestureDetector(
            onTap: () => onSourceTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                name,
                style: AppStyles.bodyMediumBold.copyWith(
                  fontSize: 14,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}