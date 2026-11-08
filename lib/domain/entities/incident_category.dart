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
    iconData: Icons.menu_rounded,
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

  static IncidentCategory fromId(String? id) {
    if (id == null) return IncidentCategory.other;
    final normalized = id.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    return IncidentCategory.values.firstWhere(
      (c) => c.id == normalized || c.displayName.toLowerCase() == normalized,
      orElse: () {
        if (normalized.contains('fire')) return IncidentCategory.fire;
        if (normalized.contains('accid') || normalized.contains('crash')) return IncidentCategory.accident;
        if (normalized.contains('block') || normalized.contains('road')) return IncidentCategory.roadBlock;
        if (normalized.contains('flood') || normalized.contains('water')) return IncidentCategory.flooding;
        if (normalized.contains('gather') || normalized.contains('crowd')) return IncidentCategory.gathering;
        return IncidentCategory.other;
      },
    );
  }
}

/// Category metadata returned by backend GET /categories.
class CategoryData {
  final String id;
  final String slug;
  final String name;
  final String iconKey;
  final String colorHex;
  final int sortOrder;
  final String urgency;
  final String? safetyNote;

  const CategoryData({
    required this.id,
    required this.slug,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.sortOrder,
    required this.urgency,
    this.safetyNote,
  });

  IncidentCategory get asEnum => IncidentCategory.fromId(slug);

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? 'other',
      name: json['name']?.toString() ?? 'Other',
      iconKey: json['icon_key']?.toString() ?? 'other',
      colorHex: json['color_hex']?.toString() ?? '#90A4AE',
      sortOrder: json['sort_order'] is int ? json['sort_order'] as int : 0,
      urgency: json['urgency']?.toString() ?? 'routine',
      safetyNote: json['safety_note']?.toString(),
    );
  }
}
