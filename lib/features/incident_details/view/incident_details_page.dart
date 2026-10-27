import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/status_badge.dart';
import '../../../core/design_system/app_button.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/entities/incident_category.dart';
import '../../../domain/entities/review_status.dart';

class IncidentDetailsPage extends StatelessWidget {
  final Incident? incident;

  const IncidentDetailsPage({
    super.key,
    this.incident,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback if accessed directly or route params
    final item = incident ??
        const Incident(
          id: '#A-2041',
          category: IncidentCategory.accident,
          title: 'Two-car collision, left lane blocked',
          description:
              'Kashmir Hwy eastbound before the F-7 underpass. Two cars on the shoulder side, one lane closed, traffic moving single file.',
          locationName: 'Kashmir Hwy eastbound before the F-7 underpass',
          areaCode: 'F-7',
          distanceKm: 1.8,
          reportedTime: '12 min ago',
          lastUpdateTime: '12 min ago',
          status: 'Active',
          reviewStatus: ReviewStatus.aiReviewed,
          photoTimestamp: '14:22',
          latitude: 33.7190,
          longitude: 73.0680,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Back button + INCIDENT · #A-2041
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INCIDENT  ·  ${item.id}',
                    style: AppTypography.technicalTag.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon & name
                    Row(
                      children: [
                        Icon(
                          item.category.iconData,
                          size: 18,
                          color: item.category.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.category.displayName.toUpperCase(),
                          style: AppTypography.sectionHeader.copyWith(
                            color: item.category.color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      item.title,
                      style: AppTypography.screenTitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Badges: AI reviewed + Not independently confirmed
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusBadge.aiReviewed(),
                        StatusBadge.notConfirmed(),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Photo card with diagonal striped preview + caption
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E252E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomPaint(
                              painter: _DiagonalStripeLargePainter(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'reporter photo  ·  taken in app ${item.photoTimestamp}',
                          style: AppTypography.technicalSub.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description text
                    Text(
                      item.description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2x2 Metadata grid in a card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetaItem('REPORTED', item.reportedTime),
                              ),
                              Expanded(
                                child: _buildMetaItem('LAST UPDATE', item.lastUpdateTime),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.border, height: 1),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetaItem('DISTANCE', '${item.distanceKm.toStringAsFixed(1)} km · approx.'),
                              ),
                              Expanded(
                                child: _buildMetaItem('STATUS', item.status),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mini map preview
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161D26),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _MiniMapPainter(),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: item.category.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  item.category.iconData,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons: Directions & Share
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Directions',
                            variant: AppButtonVariant.secondaryLight,
                            height: 48,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening directions in maps...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'Share',
                            variant: AppButtonVariant.secondaryDark,
                            height: 48,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Incident link copied to clipboard')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Secondary action links: Report incorrect info & Mark resolved
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feedback form opened')),
                            );
                          },
                          child: Text(
                            'Report incorrect info',
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.underline,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Incident marked as resolved')),
                            );
                          },
                          child: Text(
                            'Mark resolved',
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.underline,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Safety Disclaimer Note
                    Text(
                      'AI review checks that photo and description fit the category. It does not prove the incident occurred. Inzar is not an emergency service; call 15 or 1122 for emergencies.',
                      style: AppTypography.disclaimer.copyWith(
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.sectionHeader.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DiagonalStripeLargePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1E2632);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF283445)
      ..strokeWidth = 3.5;

    for (double i = -size.height; i < size.width; i += 18) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF2B3747)
      ..strokeWidth = 3.0;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.7), roadPaint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), roadPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF202A38)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.4), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
