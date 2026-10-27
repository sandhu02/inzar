import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../domain/entities/incident_category.dart';

class IncidentMarkerView extends StatelessWidget {
  final IncidentCategory category;
  final bool isSelected;
  final double size;

  const IncidentMarkerView({
    super.key,
    required this.category,
    this.isSelected = false,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color iconColor;

    switch (category) {
      case IncidentCategory.fire:
        bg = AppColors.catFire;
        iconColor = Colors.white;
        break;
      case IncidentCategory.accident:
        bg = const Color(0xFF1E242C);
        iconColor = AppColors.catAccident;
        break;
      case IncidentCategory.roadBlock:
        bg = Colors.white;
        iconColor = const Color(0xFF101318);
        break;
      case IncidentCategory.flooding:
        bg = const Color(0xFF64B5F6);
        iconColor = const Color(0xFF101318);
        break;
      case IncidentCategory.gathering:
        bg = AppColors.catGathering;
        iconColor = Colors.white;
        break;
      case IncidentCategory.other:
        bg = AppColors.catOther;
        iconColor = Colors.white;
        break;
    }

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Icon(
          category.iconData,
          size: size * 0.52,
          color: iconColor,
        ),
      ),
    );

    if (isSelected) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: content,
      );
    }

    return content;
  }
}
