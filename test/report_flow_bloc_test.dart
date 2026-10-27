import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/features/report/flow/report_flow_bloc.dart';
import 'package:inzar/features/report/flow/report_flow_event.dart';
import 'package:inzar/domain/entities/incident_category.dart';

void main() {
  group('ReportFlowBloc Tests', () {
    late ReportFlowBloc bloc;

    setUp(() {
      bloc = ReportFlowBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('capturing photo updates photoPath and timestamp', () async {
      bloc.add(const PhotoCaptured(photoPath: 'test.jpg', timestamp: '14:25'));
      await pumpEventQueue();

      expect(bloc.state.photoPath, 'test.jpg');
      expect(bloc.state.photoTimestamp, '14:25');
    });

    test('selecting category updates selectedCategory', () async {
      bloc.add(const CategorySelected(IncidentCategory.accident));
      await pumpEventQueue();

      expect(bloc.state.selectedCategory, IncidentCategory.accident);
    });

    test('retake resets photoPath', () async {
      bloc.add(const PhotoCaptured(photoPath: 'test.jpg', timestamp: '14:25'));
      await pumpEventQueue();

      bloc.add(const RetakePhotoRequested());
      await pumpEventQueue();

      expect(bloc.state.photoPath, isNull);
    });
  });
}

