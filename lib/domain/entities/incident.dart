import 'package:equatable/equatable.dart';
import 'incident_category.dart';
import 'review_status.dart';

class Incident extends Equatable {
  final String id;
  final IncidentCategory category;
  final String title;
  final String description;
  final String locationName;
  final String areaCode;
  final double distanceKm;
  final String reportedTime;
  final String lastUpdateTime;
  final String status;
  final ReviewStatus reviewStatus;
  final String photoTimestamp;
  final double latitude;
  final double longitude;
  final bool isSelected;
  final String? photoUrl;

  const Incident({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.locationName,
    required this.areaCode,
    required this.distanceKm,
    required this.reportedTime,
    required this.lastUpdateTime,
    this.status = 'Active',
    required this.reviewStatus,
    this.photoTimestamp = '14:22',
    required this.latitude,
    required this.longitude,
    this.isSelected = false,
    this.photoUrl,
  });

  Incident copyWith({
    String? id,
    IncidentCategory? category,
    String? title,
    String? description,
    String? locationName,
    String? areaCode,
    double? distanceKm,
    String? reportedTime,
    String? lastUpdateTime,
    String? status,
    ReviewStatus? reviewStatus,
    String? photoTimestamp,
    double? latitude,
    double? longitude,
    bool? isSelected,
    String? photoUrl,
  }) {
    return Incident(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      areaCode: areaCode ?? this.areaCode,
      distanceKm: distanceKm ?? this.distanceKm,
      reportedTime: reportedTime ?? this.reportedTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      status: status ?? this.status,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      photoTimestamp: photoTimestamp ?? this.photoTimestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSelected: isSelected ?? this.isSelected,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        description,
        locationName,
        areaCode,
        distanceKm,
        reportedTime,
        lastUpdateTime,
        status,
        reviewStatus,
        photoTimestamp,
        latitude,
        longitude,
        isSelected,
        photoUrl,
      ];
}

