import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/features/activity/bloc/activity_bloc.dart';
import 'package:inzar/features/activity/bloc/activity_event.dart';
import 'package:inzar/domain/entities/review_status.dart';

void main() {
  group('ActivityBloc Tests', () {
    late ActivityBloc activityBloc;

    setUp(() {
      activityBloc = ActivityBloc();
    });

    tearDown(() {
      activityBloc.close();
    });

    test('ActivityInitialized loads user activity reports', () {
      activityBloc.add(const ActivityInitialized());

      expectLater(
        activityBloc.stream,
        emits(predicate<dynamic>((state) {
          return state.allReports.isNotEmpty &&
              state.filteredReports.length == state.allReports.length;
        })),
      );
    });

    test('ActivityFilterChanged filters review status properly', () async {
      activityBloc.add(const ActivityInitialized());
      await pumpEventQueue();

      activityBloc.add(const ActivityFilterChanged(ActivityFilter.review));
      await pumpEventQueue();

      expect(activityBloc.state.currentFilter, ActivityFilter.review);
      expect(
        activityBloc.state.filteredReports
            .every((r) => r.reviewStatus == ReviewStatus.underReview),
        isTrue,
      );
    });
  });
}

