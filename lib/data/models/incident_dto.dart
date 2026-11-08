import '../../core/storage/incident_media_cache.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/incident_category.dart';
import '../../domain/entities/review_status.dart';

class IncidentDto {
  static Incident fromJson(Map<String, dynamic> json) {
    final isCluster = json.containsKey('cluster_id') || json.containsKey('count');
    if (isCluster) {
      final count = json['count'] is int ? json['count'] as int : int.tryParse(json['count'].toString()) ?? 1;
      final lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      final lon = (json['longitude'] as num?)?.toDouble() ?? 0.0;
      return Incident(
        id: json['cluster_id']?.toString() ?? 'cluster_${lat}_$lon',
        category: IncidentCategory.other,
        title: '$count incidents nearby',
        locationName: 'Clustered incidents',
        distanceKm: 0.0,
        reportedTime: '',
        lastUpdateTime: '',
        reviewStatus: ReviewStatus.published,
        latitude: lat,
        longitude: lon,
        isCluster: true,
        clusterCount: count,
      );
    }

    final id = json['id']?.toString() ?? '';
    final distanceM = (json['distance_m'] as num?)?.toDouble();
    final distanceKm = distanceM != null ? (distanceM / 1000.0) : 0.0;
    final ageMinutes = json['age_minutes'] as int?;

    String reportedTime = 'Just now';
    if (ageMinutes != null && ageMinutes > 0) {
      if (ageMinutes < 60) {
        reportedTime = '$ageMinutes min ago';
      } else {
        final hours = (ageMinutes / 60).floor();
        reportedTime = '$hours hr ago';
      }
    }

    final categoryId = json['category_id']?.toString();
    final categorySlug = json['category_slug']?.toString() ?? categoryId;
    final verificationLabel = json['verification_label']?.toString();

    // Map verification status to ReviewStatus badge
    ReviewStatus reviewStatus = ReviewStatus.published;
    if (verificationLabel == 'ai_reviewed' || verificationLabel == 'community_corroborated') {
      reviewStatus = ReviewStatus.aiReviewed;
    } else if (json['review_status'] == 'under_review' || json['review_status'] == 'checking') {
      reviewStatus = ReviewStatus.underReview;
    } else if (json['review_status'] == 'rejected') {
      reviewStatus = ReviewStatus.notApproved;
    }

    IncidentCategory category = IncidentCategory.fromId(categorySlug);
    if (category == IncidentCategory.other) {
      final combined = '${json['title'] ?? ''} ${json['description'] ?? ''}'.toLowerCase();
      if (combined.contains('fire')) {
        category = IncidentCategory.fire;
      } else if (combined.contains('accid') || combined.contains('crash')) {
        category = IncidentCategory.accident;
      } else if (combined.contains('block') || combined.contains('road')) {
        category = IncidentCategory.roadBlock;
      } else if (combined.contains('flood') || combined.contains('water')) {
        category = IncidentCategory.flooding;
      } else if (combined.contains('gather') || combined.contains('crowd') || combined.contains('protest')) {
        category = IncidentCategory.gathering;
      }
    }

    String? photoUrl = json['media_url']?.toString() ??
        json['media_thumbnail_url']?.toString() ??
        json['photo_url']?.toString() ??
        json['image_url']?.toString() ??
        json['thumbnail_url']?.toString() ??
        json['secure_url']?.toString();

    if ((photoUrl == null || photoUrl.isEmpty) &&
        json['media_urls'] is List &&
        (json['media_urls'] as List).isNotEmpty) {
      photoUrl = (json['media_urls'] as List).first.toString();
    }

    if ((photoUrl == null || photoUrl.isEmpty) && id.isNotEmpty) {
      photoUrl = IncidentMediaCache.get(id);
    }

    return Incident(
      id: id,
      category: category,
      categoryId: categoryId,
      title: json['title']?.toString() ?? 'Incident Report',
      description: json['description']?.toString() ?? '',
      locationName: json['place_label']?.toString() ?? 'Nearby Location',
      areaCode: json['place_label']?.toString() ?? '',
      distanceKm: distanceKm,
      distanceM: distanceM,
      reportedTime: reportedTime,
      lastUpdateTime: reportedTime,
      status: json['lifecycle_status']?.toString() ?? 'Active',
      reviewStatus: reviewStatus,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      photoUrl: photoUrl,
      verificationLabel: verificationLabel,
      urgency: json['urgency']?.toString(),
      ageMinutes: ageMinutes,
    );
  }
}

