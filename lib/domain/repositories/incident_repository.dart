import '../../core/error/result.dart';
import '../entities/incident.dart';
import '../entities/report_draft.dart';
import '../entities/review_status.dart';

class IncidentStatusResult {
  final String id;
  final ReviewStatus reviewStatus;
  final String? reviewReason;
  final String verificationLabel;
  final String lifecycleStatus;
  final DateTime? publishedAt;

  IncidentStatusResult({
    required this.id,
    required this.reviewStatus,
    this.reviewReason,
    this.verificationLabel = 'none',
    this.lifecycleStatus = 'active',
    this.publishedAt,
  });
}

abstract class IIncidentRepository {
  Future<Result<List<Incident>>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    required int radiusKm,
    String? categoryId,
    bool clustered = false,
  });

  Future<Result<List<Incident>>> getViewportIncidents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  });

  Future<Result<Incident>> getIncidentDetails(String id, {double? userLat, double? userLon});

  Future<Result<List<Incident>>> getMyReports();

  Future<Result<String>> submitIncidentReport({
    required ReportDraft draft,
    void Function(String step)? onProgress,
  });

  Future<Result<IncidentStatusResult>> checkIncidentStatus(String id);

  Future<Result<void>> flagIncident({
    required String id,
    required String type, // 'incorrect' | 'abuse' | 'resolved'
    String? note,
  });

  Future<Result<void>> resolveIncident(String id);
}

