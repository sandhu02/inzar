import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/category_chip.dart';
import '../../../core/design_system/app_button.dart';
import '../../../domain/entities/incident_category.dart';
import '../flow/report_flow_bloc.dart';
import '../flow/report_flow_event.dart';
import '../flow/report_flow_state.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final currentDesc = context.read<ReportFlowBloc>().state.description;
    _descController = TextEditingController(text: currentDesc);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Back arrow + "Report incident"
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
                    'Report incident',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Form
            Expanded(
              child: BlocBuilder<ReportFlowBloc, ReportFlowState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo Captured Card
                        _buildPhotoCard(context, state),
                        const SizedBox(height: 24),

                        // CATEGORY Header
                        Text(
                          'CATEGORY',
                          style: AppTypography.sectionHeader,
                        ),
                        const SizedBox(height: 12),

                        // Category 2x3 Grid
                        _buildCategoryGrid(context, state),
                        const SizedBox(height: 24),

                        // DESCRIPTION Header
                        Text(
                          'DESCRIPTION',
                          style: AppTypography.sectionHeader,
                        ),
                        const SizedBox(height: 12),

                        // Description TextField
                        TextField(
                          controller: _descController,
                          maxLines: 4,
                          style: AppTypography.body,
                          decoration: InputDecoration(
                            hintText: 'Describe what is happening, any immediate danger...',
                            hintStyle: AppTypography.bodySecondary,
                          ),
                          onChanged: (val) {
                            context.read<ReportFlowBloc>().add(DescriptionChanged(val));
                          },
                        ),
                        const SizedBox(height: 24),

                        // LOCATION Header
                        Text(
                          'LOCATION',
                          style: AppTypography.sectionHeader,
                        ),
                        const SizedBox(height: 12),

                        // Location Card
                        _buildLocationCard(context, state),
                        const SizedBox(height: 32),

                        // Submit report button
                        AppButton(
                          label: 'Submit report',
                          variant: AppButtonVariant.primary,
                          isFullWidth: true,
                          height: 52,
                          borderRadius: 16,
                          onPressed: () {
                            context.read<ReportFlowBloc>().add(const ReportSubmitted());
                            context.push('/report/progress');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, ReportFlowState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail with diagonal pattern
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2632),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _SmallStripePainter()),
                  ),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'photo',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
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

          // Label and timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo captured',
                  style: AppTypography.titleMedium.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.photoTimestamp}  ·  taken in app',
                  style: AppTypography.technicalSub.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Retake button
          GestureDetector(
            onTap: () {
              context.read<ReportFlowBloc>().add(const RetakePhotoRequested());
              context.pop();
            },
            child: Text(
              'Retake',
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, ReportFlowState state) {
    const categories = IncidentCategory.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category == state.selectedCategory;
        return CategoryChip(
          category: category,
          isSelected: isSelected,
          onTap: () {
            context.read<ReportFlowBloc>().add(CategorySelected(category));
          },
        );
      },
    );
  }

  Widget _buildLocationCard(BuildContext context, ReportFlowState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Circular category icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: state.selectedCategory.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              state.selectedCategory.iconData,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Location name and precision
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.locationName,
                  style: AppTypography.titleMedium.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  state.shownPrecision,
                  style: AppTypography.disclaimer.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Adjust button
          GestureDetector(
            onTap: () {
              _showAdjustLocationDialog(context, state);
            },
            child: Text(
              'Adjust',
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdjustLocationDialog(BuildContext context, ReportFlowState state) {
    final controller = TextEditingController(text: state.locationName);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Adjust Location', style: AppTypography.titleMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter nearby landmark or road',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ReportFlowBloc>().add(
                      LocationAdjusted(
                        locationName: controller.text.trim(),
                        shownPrecision: 'Shown publicly at ~200 m',
                      ),
                    );
              }
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SmallStripePainter extends CustomPainter {
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

