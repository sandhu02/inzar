import 'package:equatable/equatable.dart';
import 'incident_category.dart';

class ReportDraft extends Equatable {
  final String? photoPath;
  final String photoTimestamp;
  final IncidentCategory category;
  final String description;
  final String locationName;
  final String shownPrecision;
  final double latitude;
  final double longitude;

  const ReportDraft({
    this.photoPath,
    this.photoTimestamp = '14:22',
    this.category = IncidentCategory.fire,
    this.description = 'Brush fire on the slope above Trail 4, smoke drifting toward the road. No people nearby.',
    this.locationName = 'Near Trail 4, Margalla Rd',
    this.shownPrecision = 'Shown publicly at ~200 m',
    this.latitude = 33.7294,
    this.longitude = 73.0754,
  });

  ReportDraft copyWith({
    String? photoPath,
    String? photoTimestamp,
    IncidentCategory? category,
    String? description,
    String? locationName,
    String? shownPrecision,
    double? latitude,
    double? longitude,
  }) {
    return ReportDraft(
      photoPath: photoPath ?? this.photoPath,
      photoTimestamp: photoTimestamp ?? this.photoTimestamp,
      category: category ?? this.category,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      shownPrecision: shownPrecision ?? this.shownPrecision,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        photoPath,
        photoTimestamp,
        category,
        description,
        locationName,
        shownPrecision,
        latitude,
        longitude,
      ];
}

