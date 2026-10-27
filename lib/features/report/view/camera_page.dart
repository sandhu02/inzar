import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../flow/report_flow_bloc.dart';
import '../flow/report_flow_event.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Simulated Camera Viewfinder with dark mountain silhouette
            Positioned.fill(
              child: CustomPaint(
                painter: _CameraViewfinderPainter(),
              ),
            ),

            // 2. Framing Reticle (4 corner brackets)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                height: MediaQuery.of(context).size.height * 0.52,
                child: CustomPaint(
                  painter: _CornerBracketsPainter(),
                ),
              ),
            ),

            // 3. Top Action Bar: Close & Flash
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button 'X'
                  _buildCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => context.pop(),
                  ),

                  // Flash Toggle Button
                  _buildCircleButton(
                    icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _isFlashOn ? AppColors.textHighlight : AppColors.textPrimary,
                    onTap: () {
                      setState(() {
                        _isFlashOn = !_isFlashOn;
                      });
                    },
                  ),
                ],
              ),
            ),

            // 4. Floating Guidance Pill: "Capture what's happening"
            Positioned(
              top: 76,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Text(
                    "Capture what's happening",
                    style: AppTypography.fontMono.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // 5. Bottom Controls: Location badge + Large Shutter Button
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Location Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.gps_fixed_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Location on  ·  shared approximately',
                        style: AppTypography.disclaimer.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Shutter Button
                  GestureDetector(
                    onTap: () {
                      final timeNow = DateFormat('HH:mm').format(DateTime.now());
                      context.read<ReportFlowBloc>().add(
                            PhotoCaptured(
                              photoPath: 'mock_captured_incident.jpg',
                              timestamp: timeNow,
                            ),
                          );
                      context.push('/report/form');
                    },
                    child: Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3.5,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.buttonLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const arm = 24.0;

    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(arm, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, arm), paint);

    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - arm, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - arm), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - arm, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - arm), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Subtle dark ambient gradient
    final bgPaint = Paint()..color = const Color(0xFF0D0F13);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle mountain silhouettes (like Margalla hills at dusk in Islamabad)
    final hillPaint1 = Paint()..color = const Color(0xFF13171D);
    final path1 = Path()
      ..moveTo(0, size.height * 0.58)
      ..lineTo(size.width * 0.25, size.height * 0.52)
      ..lineTo(size.width * 0.55, size.height * 0.56)
      ..lineTo(size.width * 0.8, size.height * 0.50)
      ..lineTo(size.width, size.height * 0.54)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, hillPaint1);

    final hillPaint2 = Paint()..color = const Color(0xFF181D24);
    final path2 = Path()
      ..moveTo(0, size.height * 0.68)
      ..lineTo(size.width * 0.4, size.height * 0.62)
      ..lineTo(size.width * 0.7, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.60)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, hillPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
