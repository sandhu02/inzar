import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/activity_bloc.dart';
import '../bloc/activity_event.dart';
import '../bloc/activity_state.dart';
import '../widgets/activity_item_card.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityBloc()..add(const ActivityInitialized()),
      child: const _ActivityView(),
    );
  }
}

class _ActivityView extends StatelessWidget {
  const _ActivityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Title: Activity
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'Activity',
                    style: AppTypography.screenTitle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // Filter Chips Row: All, Review, Live, Denied
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ActivityFilter.values.map((filter) {
                        final isSelected = filter == state.currentFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              context.read<ActivityBloc>().add(ActivityFilterChanged(filter));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.buttonLight : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                filter.label,
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
                  ),
                ),
                const SizedBox(height: 16),

                // Reports List
                Expanded(
                  child: state.filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                "No reports under '${state.currentFilter.label}'",
                                style: AppTypography.bodySecondary,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          itemCount: state.filteredReports.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = state.filteredReports[index];
                            return ActivityItemCard(
                              incident: report,
                              onTap: () {
                                context.push('/incident-details', extra: report);
                              },
                            );
                          },
                        ),
                ),

                // Bottom prompt: Back to map to report
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        context.go('/map');
                      },
                      child: Text(
                        'Back to map to report',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

