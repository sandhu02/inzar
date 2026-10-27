import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/entities/review_status.dart';

class StatusBadge extends StatelessWidget {
  final ReviewStatus? status;
  final String? customText;
  final IconData? customIcon;
  final Color? customBgColor;
  final Color? customBorderColor;
  final Color? customTextColor;
  final bool isSecondaryNotConfirmed;

  const StatusBadge({
    super.key,
    this.status,
    this.customText,
    this.customIcon,
    this.customBgColor,
    this.customBorderColor,
    this.customTextColor,
    this.isSecondaryNotConfirmed = false,
  });

  factory StatusBadge.aiReviewed() {
    return const StatusBadge(status: ReviewStatus.aiReviewed);
  }

  factory StatusBadge.notConfirmed() {
    return const StatusBadge(
      customText: 'Not independently confirmed',
      isSecondaryNotConfirmed: true,
    );
  }

  factory StatusBadge.fromStatus(ReviewStatus status) {
    return StatusBadge(status: status);
  }

  @override
  Widget build(BuildContext context) {
    if (isSecondaryNotConfirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.statusMutedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          'Not independently confirmed',
          style: AppTypography.disclaimer.copyWith(
            color: AppColors.statusMutedText,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      );
    }

    final st = status ?? ReviewStatus.published;
    final bg = customBgColor ?? st.bgColor;
    final border = customBorderColor ?? st.borderColor;
    final text = customTextColor ?? st.textColor;
    final label = customText ?? st.label;
    final icon = customIcon ?? st.icon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.disclaimer.copyWith(
              color: text,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

