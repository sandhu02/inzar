import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/status_badge.dart';
import '../../../domain/entities/incident.dart';

class ActivityItemCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const ActivityItemCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail with diagonal stripes
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2530),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _CardStripePainter()),
                      ),
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            'photo',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
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

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name
                    Text(
                      incident.category.displayName.toUpperCase(),
                      style: AppTypography.sectionHeader.copyWith(
                        color: incident.category.color,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Incident Title
                    Text(
                      incident.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Timestamp and Area
                    Text(
                      '${incident.reportedTime}  ·  ${incident.areaCode}',
                      style: AppTypography.technicalSub.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status Badge
                    StatusBadge.fromStatus(incident.reviewStatus),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF283445)
      ..strokeWidth = 2.0;

    for (double i = -size.height; i < size.width; i += 10) {
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

