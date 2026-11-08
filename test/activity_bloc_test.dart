import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/core/error/result.dart';
import 'package:inzar/domain/entities/incident.dart';
import 'package:inzar/domain/entities/incident_category.dart';
import 'package:inzar/domain/entities/report_draft.dart';
import 'package:inzar/domain/entities/review_status.dart';
import 'package:inzar/domain/repositories/incident_repository.dart';
import 'package:inzar/features/activity/bloc/activity_bloc.dart';
import 'package:inzar/features/activity/bloc/activity_event.dart';

class TestActivityRepository implements IIncidentRepository {
  final List<Incident> testReports;

  TestActivityRepository([this.testReports = const []]);

  @override
  Future<Result<List<Incident>>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    required int radiusKm,
    String? categoryId,
    bool clustered = false,
  }) async =>
      Result.success(testReports);

  @override
  Future<Result<List<Incident>>> getViewportIncidents({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  }) async =>
      Result.success(testReports);

  @override
  Future<Result<Incident>> getIncidentDetails(String id, {double? userLat, double? userLon}) async =>
      Result.success(testReports.first);

  @override
  Future<Result<List<Incident>>> getMyReports() async => Result.success(testReports);

  @override
  Future<Result<String>> submitIncidentReport({
    required ReportDraft draft,
    void Function(String step)? onProgress,
  }) async =>
      const Result.success('inc_1');

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
  group('ActivityBloc Tests', () {
    late ActivityBloc activityBloc;

    setUp(() {
      activityBloc = ActivityBloc();
    });

    tearDown(() {
      activityBloc.close();
    });

    test('ActivityInitialized without reports has empty list (no mock data)', () async {
      activityBloc.add(const ActivityInitialized());
      await pumpEventQueue();

      expect(activityBloc.state.allReports, isEmpty);
      expect(activityBloc.state.filteredReports, isEmpty);
    });

    test('ActivityFilterChanged filters review status properly', () async {
      const reports = [
        Incident(
          id: 'rep_1',
          category: IncidentCategory.fire,
          title: 'Report Under Review',
          locationName: 'F-7',
          distanceKm: 1.0,
          reportedTime: '12:00',
          lastUpdateTime: '12:10',
          reviewStatus: ReviewStatus.underReview,
          latitude: 33.72,
          longitude: 73.05,
        ),
        Incident(
          id: 'rep_2',
          category: IncidentCategory.flooding,
          title: 'Report Live',
          locationName: 'Rawal',
          distanceKm: 5.0,
          reportedTime: '11:00',
          lastUpdateTime: '11:30',
          reviewStatus: ReviewStatus.published,
          latitude: 33.70,
          longitude: 73.10,
        ),
      ];

      final repoBloc = ActivityBloc(incidentRepository: TestActivityRepository(reports));
      repoBloc.add(const ActivityInitialized());
      await pumpEventQueue();

      expect(repoBloc.state.allReports.length, 2);

      repoBloc.add(const ActivityFilterChanged(ActivityFilter.review));
      await pumpEventQueue();

      expect(repoBloc.state.currentFilter, ActivityFilter.review);
      expect(repoBloc.state.filteredReports.length, 1);
      expect(repoBloc.state.filteredReports.first.reviewStatus, ReviewStatus.underReview);

      await repoBloc.close();
    });
  });
}
