import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/status_badge.dart';
import '../../../core/design_system/app_button.dart';
import '../../../domain/entities/incident.dart';

class PreviewSheet extends StatelessWidget {
  final Incident incident;
  final VoidCallback onViewDetails;

  const PreviewSheet({
    super.key,
    required this.incident,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header meta line: CATEGORY · DISTANCE · TIME
          Row(
            children: [
              Text(
                incident.category.displayName.toUpperCase(),
                style: AppTypography.technicalTag.copyWith(
                  color: incident.category.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              Text(
                '  ·  ${incident.distanceKm.toStringAsFixed(1)} KM  ·  ${incident.reportedTime.toUpperCase()}',
                style: AppTypography.technicalTag.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Photo thumbnail + Title & AI Reviewed badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail with diagonal stripes
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2630),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DiagonalStripePainter(),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'photo',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and AI Reviewed Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: AppTypography.headlineMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    StatusBadge.aiReviewed(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Short description
          Text(
            incident.description,
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Full width "View details" button
          AppButton(
            label: 'View details',
            variant: AppButtonVariant.secondaryLight,
            isFullWidth: true,
            height: 48,
            onPressed: onViewDetails,
          ),
        ],
      ),
    );
  }
}

class _DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF29323F).withValues(alpha: 0.6)
      ..strokeWidth = 2.5;

    for (double i = -size.height; i < size.width; i += 12) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
