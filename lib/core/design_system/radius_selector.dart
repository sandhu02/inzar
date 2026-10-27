import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RadiusSelector extends StatelessWidget {
  final int selectedRadiusKm;
  final ValueChanged<int> onRadiusSelected;
  final List<int> options;

  const RadiusSelector({
    super.key,
    required this.selectedRadiusKm,
    required this.onRadiusSelected,
    this.options = const [1, 5, 10, 25, 50],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((radius) {
          final isSelected = radius == selectedRadiusKm;
          return GestureDetector(
            onTap: () => onRadiusSelected(radius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.buttonLight : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$radius',
                  style: AppTypography.buttonText.copyWith(
                    color: isSelected ? AppColors.buttonLightText : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

