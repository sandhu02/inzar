import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/report_draft.dart';
import '../../domain/entities/review_status.dart';
import '../../domain/repositories/incident_repository.dart';
import '../models/incident_dto.dart';
import '../models/incident_detail_dto.dart';

class IncidentRemoteDataSource {
  final ApiClient _client;

  IncidentRemoteDataSource(this._client);

  Future<ApiResponse<List<Incident>>> fetchNearbyIncidents({
    required double latitude,
    required double longitude,
    required int radiusKm,
    String? categoryId,
    bool clustered = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'lat': latitude,
        'lon': longitude,
        'radius_km': radiusKm,
        if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
        if (clustered) 'clustered': true,
      };

      final response = await _client.dio.get(
        '/incidents',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((e) => IncidentDto.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <Incident>[];
        },
      );
    } on DioException catch (e) {
      return _mapError<List<Incident>>(e);
    }
  }

  Future<ApiResponse<List<Incident>>> fetchViewportIncidents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  }) async {
    try {
      final queryParams = {
        'min_lat': minLat,
        'min_lon': minLon,
        'max_lat': maxLat,
        'max_lon': maxLon,
      };

      final response = await _client.dio.get(
        '/incidents',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((e) => IncidentDto.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <Incident>[];
        },
      );
    } on DioException catch (e) {
      return _mapError<List<Incident>>(e);
    }
  }

  Future<ApiResponse<Incident>> fetchIncidentDetails(
    String id, {
    double? userLat,
    double? userLon,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userLat != null) queryParams['lat'] = userLat;
      if (userLon != null) queryParams['lon'] = userLon;

      final response = await _client.dio.get(
        '/incidents/$id',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => IncidentDetailDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _mapError<Incident>(e);
    }
  }

  Future<ApiResponse<List<Incident>>> fetchMyIncidents() async {
    try {
      final response = await _client.dio.get('/me/incidents');
      return ApiResponse.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((e) => IncidentDto.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <Incident>[];
        },
      );
    } on DioException catch (e) {
      return _mapError<List<Incident>>(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createIncident(ReportDraft draft, {String? categoryUuid}) async {
    try {
      final payload = {
        'category_id': categoryUuid ?? draft.category.id,
        'title': draft.description.length > 50
            ? '${draft.description.substring(0, 47)}...'
            : draft.description,
        'description': draft.description,
        'latitude': draft.latitude,
        'longitude': draft.longitude,
        'place_label': draft.locationName,
      };

      final response = await _client.dio.post(
        '/incidents',
        data: payload,
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      );
    } on DioException catch (e) {
      return _mapError<Map<String, dynamic>>(e);
    }
  }

  Future<ApiResponse<IncidentStatusResult>> fetchIncidentStatus(String id) async {
    try {
      final response = await _client.dio.get('/incidents/$id/status');
      return ApiResponse.fromJson(
        response.data,
        (json) {
          final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
          final rawReview = map['review_status']?.toString();
          ReviewStatus revStatus = ReviewStatus.published;
          if (rawReview == 'needs_review' || rawReview == 'under_review' || rawReview == 'checking') {
            revStatus = ReviewStatus.underReview;
          } else if (rawReview == 'rejected') {
            revStatus = ReviewStatus.notApproved;
          }

          DateTime? publishedAt;
          if (map['published_at'] != null) {
            try {
              publishedAt = DateTime.parse(map['published_at'].toString());
            } catch (_) {}
          }

          return IncidentStatusResult(
            id: map['id']?.toString() ?? id,
            reviewStatus: revStatus,
            reviewReason: map['review_reason']?.toString(),
            verificationLabel: map['verification_label']?.toString() ?? 'none',
            lifecycleStatus: map['lifecycle_status']?.toString() ?? 'active',
            publishedAt: publishedAt,
          );
        },
      );
    } on DioException catch (e) {
      return _mapError<IncidentStatusResult>(e);
    }
  }

  Future<ApiResponse<void>> flagIncident({
    required String id,
    required String type,
    String? note,
  }) async {
    try {
      final response = await _client.dio.post(
        '/incidents/$id/flags',
        data: {
          'type': type,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return ApiResponse(status: true, success: true, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<void>> resolveIncident(String id) async {
    try {
      final response = await _client.dio.post('/incidents/$id/resolve', data: {});
      return ApiResponse(status: true, success: true, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  ApiResponse<T> _mapError<T>(DioException e) {
    return ApiResponse<T>(
      status: false,
      success: false,
      statusCode: e.response?.statusCode ?? 500,
      error: ApiError.fromJson(e.response?.data),
    );
  }
}
