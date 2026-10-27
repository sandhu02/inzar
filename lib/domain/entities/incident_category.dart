import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum IncidentCategory {
  fire(
    id: 'fire',
    displayName: 'Fire',
    iconData: Icons.local_fire_department_rounded,
    color: AppColors.catFire,
  ),
  accident(
    id: 'accident',
    displayName: 'Accident',
    iconData: Icons.warning_amber_rounded,
    color: AppColors.catAccident,
  ),
  roadBlock(
    id: 'road_block',
    displayName: 'Road block',
    iconData: Icons.menu_rounded, // Matches the triple horizontal line barrier icon in screenshots
    color: AppColors.catRoadBlock,
  ),
  flooding(
    id: 'flooding',
    displayName: 'Flooding',
    iconData: Icons.waves_rounded,
    color: AppColors.catFlooding,
  ),
  gathering(
    id: 'gathering',
    displayName: 'Gathering',
    iconData: Icons.people_outline_rounded,
    color: AppColors.catGathering,
  ),
  other(
    id: 'other',
    displayName: 'Other',
    iconData: Icons.change_history_rounded,
    color: AppColors.catOther,
  );

  const IncidentCategory({
    required this.id,
    required this.displayName,
    required this.iconData,
    required this.color,
  });

  final String id;
  final String displayName;
  final IconData iconData;
  final Color color;

  static IncidentCategory fromId(String id) {
    return IncidentCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => IncidentCategory.other,
    );
  }
}

