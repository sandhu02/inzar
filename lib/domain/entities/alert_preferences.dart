import 'package:equatable/equatable.dart';

class AlertPreferences extends Equatable {
  final bool enabled;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final List<String> categories;
  final String minUrgency; // 'routine' or 'high'

  const AlertPreferences({
    this.enabled = true,
    required this.latitude,
    required this.longitude,
    this.radiusKm = 5.0,
    this.categories = const [],
    this.minUrgency = 'routine',
  });

  AlertPreferences copyWith({
    bool? enabled,
    double? latitude,
    double? longitude,
    double? radiusKm,
    List<String>? categories,
    String? minUrgency,
  }) {
    return AlertPreferences(
      enabled: enabled ?? this.enabled,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      categories: categories ?? this.categories,
      minUrgency: minUrgency ?? this.minUrgency,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        latitude,
        longitude,
        radiusKm,
        categories,
        minUrgency,
      ];
}

