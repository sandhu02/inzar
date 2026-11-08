import 'package:equatable/equatable.dart';
import 'incident_category.dart';
import 'review_status.dart';

class Incident extends Equatable {
  final String id;
  final IncidentCategory category;
  final String? categoryId;
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
  final String? verificationLabel;
  final String? urgency;
  final int? ageMinutes;
  final double? distanceM;
  final bool isCluster;
  final int clusterCount;

  const Incident({
    required this.id,
    required this.category,
    this.categoryId,
    required this.title,
    this.description = '',
    required this.locationName,
    this.areaCode = '',
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
    this.verificationLabel,
    this.urgency,
    this.ageMinutes,
    this.distanceM,
    this.isCluster = false,
    this.clusterCount = 0,
  });

  Incident copyWith({
    String? id,
    IncidentCategory? category,
    String? categoryId,
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
    String? verificationLabel,
    String? urgency,
    int? ageMinutes,
    double? distanceM,
    bool? isCluster,
    int? clusterCount,
  }) {
    return Incident(
      id: id ?? this.id,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
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
      verificationLabel: verificationLabel ?? this.verificationLabel,
      urgency: urgency ?? this.urgency,
      ageMinutes: ageMinutes ?? this.ageMinutes,
      distanceM: distanceM ?? this.distanceM,
      isCluster: isCluster ?? this.isCluster,
      clusterCount: clusterCount ?? this.clusterCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        categoryId,
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
        verificationLabel,
        urgency,
        ageMinutes,
        distanceM,
        isCluster,
        clusterCount,
      ];
}
