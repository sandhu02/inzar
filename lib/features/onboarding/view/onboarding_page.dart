import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _locationAllowed = false;
  bool _cameraAllowed = false;
  bool _notificationsAllowed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Logo + Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Diamond icon
                      Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'INZAR',
                        style: AppTypography.screenTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 2)
                    GestureDetector(
                      onTap: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStepOne(),
                  _buildStepTwo(),
                  _buildStepThree(),
                ],
              ),
            ),

            // Bottom Navigation & Actions
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Circular Radar Graphic
          Expanded(
            child: Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: CustomPaint(
                  painter: _OnboardingRadarPainter(),
                ),
              ),
            ),
          ),

          // Step 1 / 3
          _buildStepTag(1),
          const SizedBox(height: 12),

          // Title
          Text(
            "See what's\nhappening near you.",
            style: AppTypography.screenTitle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            'Reports from people around you, checked by AI, on a live map within the radius you choose.',
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Graphic for step 2 (Camera / Verification)
          Expanded(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.statusAiBadgeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.statusAiBadgeBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.statusAiBadgeText),
                            const SizedBox(width: 4),
                            Text(
                              'AI Verified',
                              style: AppTypography.technicalSub.copyWith(
                                color: AppColors.statusAiBadgeText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Step 2 / 3
          _buildStepTag(2),
          const SizedBox(height: 12),

          // Title
          Text(
            "Capture quickly.\nVerify intelligently.",
            style: AppTypography.screenTitle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            'Built-in camera for real-time proof. AI checks photo and category match before reports appear nearby.',
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepThree() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Step 3 / 3
          _buildStepTag(3),
          const SizedBox(height: 12),

          // Title
          Text(
            "Allow only what you\nneed.",
            style: AppTypography.screenTitle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'You can change any of these later in Settings.',
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Permission Cards (matching Page 8)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildPermissionCard(
                    icon: Icons.my_location_rounded,
                    title: 'Location',
                    subtitle: 'Show incidents near you. Only while using the app.',
                    isAllowed: _locationAllowed,
                    onToggle: () {
                      setState(() {
                        _locationAllowed = !_locationAllowed;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionCard(
                    icon: Icons.camera_alt_outlined,
                    title: 'Camera',
                    subtitle: 'Take photos for reports. No gallery access.',
                    isAllowed: _cameraAllowed,
                    onToggle: () {
                      setState(() {
                        _cameraAllowed = !_cameraAllowed;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionCard(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Nearby alerts within your radius. Optional.',
                    isAllowed: _notificationsAllowed,
                    onToggle: () {
                      setState(() {
                        _notificationsAllowed = !_notificationsAllowed;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isAllowed,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Icon in circular container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 14),

          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // "Allow" Button
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isAllowed ? AppColors.statusLiveBg : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAllowed ? AppColors.statusLiveBorder : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Text(
                isAllowed ? 'Allowed' : 'Allow',
                style: AppTypography.buttonText.copyWith(
                  color: isAllowed ? AppColors.statusLiveText : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTag(int step) {
    return Row(
      children: [
        Text(
          '$step',
          style: AppTypography.technicalTag.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          ' / 3',
          style: AppTypography.technicalTag.copyWith(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_currentPage == 2) {
      // Step 3 has full-width Continue button + disclaimer (matching Page 8)
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          children: [
            AppButton(
              label: 'Continue',
              variant: AppButtonVariant.secondaryLight,
              isFullWidth: true,
              height: 50,
              onPressed: _finishOnboarding,
            ),
            const SizedBox(height: 14),
            Text(
              'Inzar does not replace local emergency services.',
              style: AppTypography.disclaimer.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Steps 1 & 2 have Page Indicator on left and "Next" on right (matching Page 7)
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicators: long pill for active, small dots for inactive
          Row(
            children: List.generate(3, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          // Next Button
          AppButton(
            label: 'Next',
            variant: AppButtonVariant.secondaryLight,
            height: 44,
            borderRadius: 22,
            onPressed: _onNext,
          ),
        ],
      ),
    );
  }
}

class _OnboardingRadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // Roads
    final roadPaint = Paint()
      ..color = const Color(0xFF283445)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.75, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.65), roadPaint);

    // Dashed Radar circle
    final radarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashCount = 36;
    const sweep = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep * 0.6,
        false,
        radarPaint,
      );
    }

    // Inner subtle range
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius * 0.55, innerPaint);

    // Center user location dot
    final haloPaint = Paint()..color = const Color(0xFF38B6FF).withValues(alpha: 0.25);
    canvas.drawCircle(center, 12, haloPaint);
    final dotPaint = Paint()..color = const Color(0xFF38B6FF);
    canvas.drawCircle(center, 5.5, dotPaint);

    // Flame pin (upper left)
    _drawPin(canvas, Offset(center.dx - radius * 0.45, center.dy - radius * 0.35), AppColors.catFire, Icons.local_fire_department_rounded);

    // Accident pin with white halo (upper right)
    final accidentCenter = Offset(center.dx + radius * 0.42, center.dy - radius * 0.25);
    final haloAccident = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(accidentCenter, 18, haloAccident);
    _drawPin(canvas, accidentCenter, const Color(0xFF1E242C), Icons.warning_amber_rounded, iconColor: AppColors.catAccident);

    // Water wave pin (lower right)
    _drawPin(canvas, Offset(center.dx + radius * 0.1, center.dy + radius * 0.45), const Color(0xFF64B5F6), Icons.waves_rounded, iconColor: const Color(0xFF101318));
  }

  void _drawPin(Canvas canvas, Offset pos, Color bg, IconData icon, {Color iconColor = Colors.white}) {
    final bgPaint = Paint()..color = bg;
    canvas.drawCircle(pos, 14, bgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 16,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

