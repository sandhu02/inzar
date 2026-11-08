import '../../domain/entities/alert_preferences.dart';

class AlertPreferencesDto {
  static AlertPreferences fromJson(Map<String, dynamic> json) {
    final catRaw = json['categories'];
    List<String> categories = [];
    if (catRaw is List) {
      categories = catRaw.map((e) => e.toString()).toList();
    }

    return AlertPreferences(
      enabled: json['enabled'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 33.7294,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.0560,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 5.0,
      categories: categories,
      minUrgency: json['min_urgency']?.toString() ?? 'routine',
    );
  }

  static Map<String, dynamic> toJson(AlertPreferences preferences) {
    return {
      'enabled': preferences.enabled,
      'latitude': preferences.latitude,
      'longitude': preferences.longitude,
      'radius_km': preferences.radiusKm,
      'categories': preferences.categories,
      'min_urgency': preferences.minUrgency,
    };
  }
}

