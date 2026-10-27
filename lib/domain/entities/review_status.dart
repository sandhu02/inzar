import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ReviewStatus {
  aiReviewed(
    label: 'AI reviewed',
    icon: Icons.check_circle_outline_rounded,
    bgColor: AppColors.statusAiBadgeBg,
    borderColor: AppColors.statusAiBadgeBorder,
    textColor: AppColors.statusAiBadgeText,
  ),
  published(
    label: 'Published',
    icon: Icons.check_rounded,
    bgColor: AppColors.statusLiveBg,
    borderColor: AppColors.statusLiveBorder,
    textColor: AppColors.statusLiveText,
  ),
  underReview(
    label: 'Under review',
    icon: Icons.access_time_rounded,
    bgColor: AppColors.statusReviewBg,
    borderColor: AppColors.statusReviewBorder,
    textColor: AppColors.statusReviewText,
  ),
  notApproved(
    label: 'Not approved',
    icon: Icons.cancel_outlined,
    bgColor: AppColors.statusDeniedBg,
    borderColor: AppColors.statusDeniedBorder,
    textColor: AppColors.statusDeniedText,
  );

  const ReviewStatus({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
}

