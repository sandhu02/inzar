import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/entities/incident_category.dart';

class CategoryChip extends StatelessWidget {
  final IncidentCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.border;
    final bgColor = isSelected ? AppColors.surfaceElevated : AppColors.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.iconData,
                size: 26,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                category.displayName,
                style: AppTypography.chipLabel.copyWith(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
