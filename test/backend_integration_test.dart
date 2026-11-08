import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/core/network/api_response.dart';
import 'package:inzar/core/network/token_storage.dart';
import 'package:inzar/data/models/incident_dto.dart';
import 'package:inzar/data/models/incident_detail_dto.dart';
import 'package:inzar/data/models/public_config_dto.dart';
import 'package:inzar/domain/entities/incident_category.dart';
import 'package:inzar/domain/entities/review_status.dart';

void main() {
  group('Backend API Models & Envelope Parsing Tests', () {
    test('ApiResponse parses standardized success envelope', () {
      final envelopeJson = {
        'status': true,
        'success': true,
        'status_code': 200,
        'data': {'id': '123', 'name': 'Test'},
      };

      final response = ApiResponse.fromJson(
        envelopeJson,
        (data) => (data as Map<String, dynamic>)['name'],
      );

      expect(response.isSuccess, isTrue);
      expect(response.statusCode, 200);
      expect(response.data, 'Test');
      expect(response.error, isNull);
    });

    test('ApiResponse handles direct raw JSON payload without envelope', () {
      final rawJson = {
        'max_search_radius_km': 50,
        'allowed_radius_options_km': [1, 5, 10, 25, 50],
        'max_description_length': 1000,
        'fuzz_distance_m': 200,
      };

      final response = ApiResponse.fromJson(
        rawJson,
        (data) => PublicConfigDto.fromJson(data as Map<String, dynamic>),
      );

      expect(response.isSuccess, isTrue);
      expect(response.data?.maxSearchRadiusKm, 50);
      expect(response.data?.fuzzDistanceM, 200);
    });

    test('ApiResponse parses error envelope with code and message', () {
      final errorJson = {
        'status': false,
        'success': false,
        'status_code': 401,
        'error': {
          'code': 'invalid_credentials',
          'message': 'Email or password incorrect',
        },
      };

      final response = ApiResponse.fromJson(errorJson, null);

      expect(response.isSuccess, isFalse);
      expect(response.statusCode, 401);
      expect(response.error?.code, 'invalid_credentials');
      expect(response.error?.message, 'Email or password incorrect');
    });

    test('IncidentDto maps nearby incident correctly', () {
      final incidentJson = {
        'id': 'inc_999',
        'category_id': 'd13e3872-test',
        'category_slug': 'fire',
        'title': 'Brush fire near highway',
        'latitude': 33.7294,
        'longitude': 73.0560,
        'place_label': 'Margalla Rd · F-7',
        'urgency': 'high',
        'age_minutes': 15,
        'distance_m': 1200.0,
        'verification_label': 'ai_reviewed',
        'media_thumbnail_url': 'https://res.cloudinary.com/test/photo.jpg',
      };

      final incident = IncidentDto.fromJson(incidentJson);

      expect(incident.id, 'inc_999');
      expect(incident.category, IncidentCategory.fire);
      expect(incident.distanceKm, 1.2);
      expect(incident.reportedTime, '15 min ago');
      expect(incident.reviewStatus, ReviewStatus.aiReviewed);
      expect(incident.photoUrl, 'https://res.cloudinary.com/test/photo.jpg');
    });

    test('IncidentDto handles clustered incident shape', () {
      final clusterJson = {
        'cluster_id': '33.72_73.05',
        'latitude': 33.72,
        'longitude': 73.05,
        'count': 8,
      };

      final cluster = IncidentDto.fromJson(clusterJson);

      expect(cluster.isCluster, isTrue);
      expect(cluster.clusterCount, 8);
      expect(cluster.id, '33.72_73.05');
    });

    test('IncidentDetailDto maps full incident details with timestamps', () {
      final detailJson = {
        'id': 'inc_full_1',
        'category_slug': 'accident',
        'title': 'Traffic incident',
        'description': 'Two cars collided at the turn',
        'latitude': 33.7190,
        'longitude': 73.0680,
        'place_label': 'F-7 Markaz',
        'review_status': 'published',
        'verification_label': 'community_corroborated',
        'reported_at': '2026-10-30T14:00:00Z',
        'last_confirmed_at': '2026-10-30T14:15:00Z',
        'distance_m': 450.0,
      };

      final detail = IncidentDetailDto.fromJson(detailJson);

      expect(detail.id, 'inc_full_1');
      expect(detail.category, IncidentCategory.accident);
      expect(detail.distanceKm, 0.45);
      expect(detail.reviewStatus, ReviewStatus.aiReviewed);
    });

    test('InMemoryTokenStorage saves and clears tokens', () async {
      final storage = InMemoryTokenStorage();
      await storage.saveTokens(accessToken: 'acc_123', refreshToken: 'ref_456');

      expect(await storage.getAccessToken(), 'acc_123');
      expect(await storage.getRefreshToken(), 'ref_456');

      await storage.clearTokens();
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });
  });
}

