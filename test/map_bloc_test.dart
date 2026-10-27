import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/features/map/bloc/map_bloc.dart';
import 'package:inzar/features/map/bloc/map_event.dart';

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

    test('MapInitialized loads sample incidents and filters within 5km', () {
      mapBloc.add(const MapInitialized());

      expectLater(
        mapBloc.stream,
        emits(predicate<dynamic>((state) {
          return state.allIncidents.isNotEmpty &&
              state.filteredIncidents.isNotEmpty &&
              state.selectedIncident != null;
        })),
      );
    });

    test('MapRadiusChanged updates radius and filters accordingly', () async {
      mapBloc.add(const MapInitialized());
      await pumpEventQueue();

      mapBloc.add(const MapRadiusChanged(1));
      await pumpEventQueue();

      expect(mapBloc.state.selectedRadiusKm, 1);
      expect(mapBloc.state.filteredIncidents.every((i) => i.distanceKm <= 1), isTrue);
    });
  });
}

