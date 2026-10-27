import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/design_system/incident_marker_view.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/entities/incident_category.dart';

class RadarMapCanvas extends StatelessWidget {
  final List<Incident> incidents;
  final Incident? selectedIncident;
  final int radiusKm;
  final ValueChanged<Incident> onIncidentTap;
  final VoidCallback onRecenterTap;

  const RadarMapCanvas({
    super.key,
    required this.incidents,
    required this.selectedIncident,
    required this.radiusKm,
    required this.onIncidentTap,
    required this.onRecenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight * 0.42);
        final radarRadius = math.min(constraints.maxWidth, constraints.maxHeight) * 0.38;

        return Stack(
          children: [
            // Custom Painter for Map background, roads, radar circles
            Positioned.fill(
              child: CustomPaint(
                painter: _MapBackgroundPainter(
                  center: center,
                  radarRadius: radarRadius,
                  radiusKm: radiusKm,
                ),
              ),
            ),

            // Incident Markers positioned relative to center
            ...incidents.map((incident) {
              final pos = _getIncidentScreenOffset(incident, center, radarRadius);
              final isSelected = selectedIncident?.id == incident.id;

              return Positioned(
                left: pos.dx - (isSelected ? 26 : 22),
                top: pos.dy - (isSelected ? 26 : 22),
                child: GestureDetector(
                  onTap: () => onIncidentTap(incident),
                  child: IncidentMarkerView(
                    category: incident.category,
                    isSelected: isSelected,
                    size: isSelected ? 44 : 38,
                  ),
                ),
              );
            }),

            // Cluster marker "4" on top-right of radar circle as in screenshot
            Positioned(
              left: center.dx + radarRadius * 0.72 - 18,
              top: center.dy - radarRadius * 0.72 - 18,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Color(0xFF101318),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),

            // Recenter floating button on bottom-right of map
            Positioned(
              right: 18,
              bottom: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRecenterTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderLight, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Offset _getIncidentScreenOffset(Incident incident, Offset center, double radarRadius) {
    // Relative positioning matching Screenshot 1:
    // - Flame marker: upper left
    // - Accident marker: upper right (selected)
    // - Road block (menu): lower left
    // - Flooding: lower right
    switch (incident.category) {
      case IncidentCategory.fire:
        return Offset(center.dx - radarRadius * 0.48, center.dy - radarRadius * 0.45);
      case IncidentCategory.accident:
        return Offset(center.dx + radarRadius * 0.44, center.dy - radarRadius * 0.35);
      case IncidentCategory.roadBlock:
        return Offset(center.dx - radarRadius * 0.30, center.dy + radarRadius * 0.15);
      case IncidentCategory.flooding:
        return Offset(center.dx + radarRadius * 0.15, center.dy + radarRadius * 0.35);
      case IncidentCategory.gathering:
        return Offset(center.dx - radarRadius * 0.65, center.dy + radarRadius * 0.45);
      case IncidentCategory.other:
        return Offset(center.dx + radarRadius * 0.60, center.dy + radarRadius * 0.50);
    }
  }
}

class _MapBackgroundPainter extends CustomPainter {
  final Offset center;
  final double radarRadius;
  final int radiusKm;

  _MapBackgroundPainter({
    required this.center,
    required this.radarRadius,
    required this.radiusKm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw stylized road networks (lines crisscrossing like Islamabad sector grids)
    final highwayPaint = Paint()
      ..color = const Color(0xFF2A3442).withValues(alpha: 0.7)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = const Color(0xFF1F2732).withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = const Color(0xFF18202A)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Diagonal arterial roads
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.05),
      highwayPaint,
    );
    canvas.drawLine(
      Offset(-50, size.height * 0.65),
      Offset(size.width + 50, size.height * 0.20),
      highwayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.85, size.height),
      highwayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.70, 0),
      Offset(size.width * 0.30, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.48),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.78),
      Offset(size.width, size.height * 0.72),
      minorRoadPaint,
    );

    // Subtle water shape in bottom background
    final waterPaint = Paint()..color = const Color(0xFF0F1E2A);
    final waterPath = Path()
      ..moveTo(0, size.height * 0.50)
      ..cubicTo(size.width * 0.35, size.height * 0.48, size.width * 0.7, size.height * 0.55, size.width, size.height * 0.52)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Dashed Radar Circle for current radius range
    final radarBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw dashed circle
    const dashCount = 48;
    const sweepAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radarRadius),
        i * sweepAngle,
        sweepAngle * 0.6,
        false,
        radarBorderPaint,
      );
    }

    // Inner subtle range circle
    final innerRangePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radarRadius * 0.5, innerRangePaint);

    // User location dot (blue with soft glow halo)
    final haloPaint = Paint()
      ..color = const Color(0xFF38B6FF).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, haloPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF38B6FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6.5, dotPaint);

    final innerWhiteDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, innerWhiteDot);
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.radarRadius != radarRadius ||
        oldDelegate.radiusKm != radiusKm;
  }
}
