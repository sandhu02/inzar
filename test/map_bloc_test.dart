import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/core/error/result.dart';
import 'package:inzar/domain/entities/incident.dart';
import 'package:inzar/domain/entities/incident_category.dart';
import 'package:inzar/domain/entities/report_draft.dart';
import 'package:inzar/domain/entities/review_status.dart';
import 'package:inzar/domain/repositories/incident_repository.dart';
import 'package:inzar/features/map/bloc/map_bloc.dart';
import 'package:inzar/features/map/bloc/map_event.dart';

class TestIncidentRepository implements IIncidentRepository {
  final List<Incident> testIncidents;

  TestIncidentRepository([this.testIncidents = const []]);

  @override
  Future<Result<List<Incident>>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    required int radiusKm,
    String? categoryId,
    bool clustered = false,
  }) async {
    return Result.success(testIncidents);
  }

  @override
  Future<Result<List<Incident>>> getViewportIncidents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  }) async =>
      Result.success(testIncidents);

  @override
  Future<Result<Incident>> getIncidentDetails(String id, {double? userLat, double? userLon}) async =>
      Result.success(testIncidents.first);

  @override
  Future<Result<List<Incident>>> getMyReports() async => Result.success(testIncidents);

  @override
  Future<Result<String>> submitIncidentReport({
    required ReportDraft draft,
    void Function(String step)? onProgress,
  }) async =>
      const Result.success('inc_test');

  @override
  Future<Result<IncidentStatusResult>> checkIncidentStatus(String id) async =>
      Result.success(IncidentStatusResult(
        id: id,
        reviewStatus: ReviewStatus.published,
        lifecycleStatus: 'Active',
      ));

  @override
  Future<Result<void>> flagIncident({required String id, required String type, String? note}) async =>
      const Result.success(null);

  @override
  Future<Result<void>> resolveIncident(String id) async => const Result.success(null);
}

void main() {
  group('MapBloc Tests', () {
    late MapBloc mapBloc;

    setUp(() {
      mapBloc = MapBloc();
    });

    tearDown(() {
      mapBloc.close();
    });

    test('initial state has default 5km radius and empty incidents', () {
      expect(mapBloc.state.selectedRadiusKm, 5);
      expect(mapBloc.state.allIncidents, isEmpty);
    });

    test('MapInitialized without repository loads empty incidents (no mock data)', () async {
      mapBloc.add(const MapInitialized());
      await pumpEventQueue();

      expect(mapBloc.state.allIncidents, isEmpty);
      expect(mapBloc.state.filteredIncidents, isEmpty);
      expect(mapBloc.state.selectedIncident, isNull);
    });

    test('MapInitialized with repository loads incidents and filters within radius', () async {
      const sample = [
        Incident(
          id: 'inc_1',
          category: IncidentCategory.fire,
          title: 'Fire incident',
          locationName: 'Test Area',
          distanceKm: 2.0,
          reportedTime: '10:00',
          lastUpdateTime: '10:05',
          reviewStatus: ReviewStatus.published,
          latitude: 33.72,
          longitude: 73.05,
        ),
        Incident(
          id: 'inc_2',
          category: IncidentCategory.accident,
          title: 'Far incident',
          locationName: 'Far Area',
          distanceKm: 15.0,
          reportedTime: '10:00',
          lastUpdateTime: '10:05',
          reviewStatus: ReviewStatus.published,
          latitude: 33.80,
          longitude: 73.15,
        ),
      ];

      final repoBloc = MapBloc(incidentRepository: TestIncidentRepository(sample));
      repoBloc.add(const MapInitialized());
      await pumpEventQueue();

      expect(repoBloc.state.allIncidents.length, 2);
      expect(repoBloc.state.filteredIncidents.length, 1);
      expect(repoBloc.state.selectedIncident?.id, 'inc_1');

      repoBloc.add(const MapRadiusChanged(25));
      await pumpEventQueue();
      expect(repoBloc.state.selectedRadiusKm, 25);
      expect(repoBloc.state.filteredIncidents.length, 2);

      repoBloc.add(const MapUserLocationUpdated(latitude: 33.72, longitude: 73.05));
      await pumpEventQueue();
      expect(repoBloc.state.userLatitude, 33.72);
      expect(repoBloc.state.userLongitude, 73.05);
      expect(repoBloc.state.locationArea, 'Current Location');

      await repoBloc.close();
    });
  });
}
