import '../../domain/entities/app_public_config.dart';

class PublicConfigDto {
  static AppPublicConfig fromJson(Map<String, dynamic> json) {
    final allowedRaw = json['allowed_radius_options_km'];
    List<int> allowed = const [1, 3, 5, 10, 25, 50];
    if (allowedRaw is List) {
      allowed = allowedRaw.map((e) => (e as num).toInt()).toList();
    }

    return AppPublicConfig(
      maxSearchRadiusKm: (json['max_search_radius_km'] as num?)?.toInt() ?? 50,
      allowedRadiusOptionsKm: allowed,
      maxDescriptionLength: (json['max_description_length'] as num?)?.toInt() ?? 1000,
      fuzzDistanceM: (json['fuzz_distance_m'] as num?)?.toInt() ?? 200,
    );
  }
}

