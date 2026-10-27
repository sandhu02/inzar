import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/status_badge.dart';
import '../../../core/design_system/app_button.dart';
import '../../../domain/entities/review_status.dart';
import '../flow/report_flow_bloc.dart';
import '../flow/report_flow_state.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ReportFlowBloc, ReportFlowState>(
          builder: (context, state) {
            return Column(
              children: [
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SUBMISSION · 14:23
                        Text(
                          'SUBMISSION  ·  ${state.photoTimestamp}',
                          style: AppTypography.technicalTag.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Title
                        Text(
                          'Checking your report',
                          style: AppTypography.screenTitle.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Progress Step Card
                        _buildProgressCard(state),
                        const SizedBox(height: 14),

                        // Review time helper note
                        Text(
                          'Review can take a minute. You can leave; we will track it in Activity.',
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // POSSIBLE OUTCOMES Header
                        Text(
                          'POSSIBLE OUTCOMES',
                          style: AppTypography.sectionHeader,
                        ),
                        const SizedBox(height: 14),

                        // Outcome 1: Report is live (Published)
                        _buildOutcomeCard(
                          badge: const StatusBadge(status: ReviewStatus.published),
                          title: 'Report is live',
                          description:
                              'Photo and description fit the category. Your report is on the map as AI reviewed, not confirmed.',
                        ),
                        const SizedBox(height: 12),

                        // Outcome 2: A person will take a look (Under review)
                        _buildOutcomeCard(
                          badge: const StatusBadge(status: ReviewStatus.underReview),
                          title: 'A person will take a look',
                          description:
                              'We could not match photo and description with confidence. It is not public yet.',
                        ),
                        const SizedBox(height: 12),

                        // Outcome 3: Report not approved (Not approved)
                        _buildOutcomeCard(
                          badge: const StatusBadge(status: ReviewStatus.notApproved),
                          title: 'Report not approved',
                          description:
                              'The photo does not appear to show a fire. You can retake the photo or change the category and resubmit.',
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons: Back to map & Activity
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Back to map',
                          variant: AppButtonVariant.secondaryLight,
                          height: 48,
                          onPressed: () {
                            context.go('/map');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Activity',
                          variant: AppButtonVariant.secondaryDark,
                          height: 48,
                          onPressed: () {
                            context.go('/activity');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressCard(ReportFlowState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Step 1: Uploading photo (Complete)
          _buildStepRow(
            icon: Icons.check_rounded,
            iconBg: const Color(0xFF22C55E),
            iconColor: Colors.black,
            title: 'Uploading photo',
            isActive: true,
          ),
          const SizedBox(height: 16),

          // Step 2: Checking report (Current / In Progress)
          _buildStepRow(
            icon: null,
            isCurrent: true,
            title: 'Checking report',
            isActive: true,
          ),
          const SizedBox(height: 16),

          // Step 3: Published (Pending)
          _buildStepRow(
            icon: null,
            title: 'Published',
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    IconData? icon,
    Color? iconBg,
    Color? iconColor,
    required String title,
    bool isActive = false,
    bool isCurrent = false,
  }) {
    Widget indicator;
    if (icon != null) {
      indicator = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: iconBg ?? const Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: iconColor ?? Colors.black),
      );
    } else if (isCurrent) {
      indicator = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        ),
      );
    } else {
      indicator = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.5), width: 1.5),
        ),
      );
    }

    return Row(
      children: [
        indicator,
        const SizedBox(width: 14),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontSize: 15,
            fontWeight: isCurrent || icon != null ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildOutcomeCard({
    required Widget badge,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          badge,
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
