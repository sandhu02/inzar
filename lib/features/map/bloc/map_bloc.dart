import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';
import '../../../core/mock/mock_incidents.dart';
import '../../../domain/entities/incident.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(const MapState()) {
    on<MapInitialized>(_onInitialized);
    on<MapRadiusChanged>(_onRadiusChanged);
    on<MapIncidentSelected>(_onIncidentSelected);
    on<MapSearchQueried>(_onSearchQueried);
    on<MapRecenterPressed>(_onRecenterPressed);
  }

  void _onInitialized(MapInitialized event, Emitter<MapState> emit) {
    final list = MockIncidents.sampleIncidents;
    final filtered = list.where((i) => i.distanceKm <= state.selectedRadiusKm).toList();
    final defaultSelected = list.firstWhere((i) => i.isSelected, orElse: () => list.first);

    emit(state.copyWith(
      allIncidents: list,
      filteredIncidents: filtered,
      selectedIncident: () => defaultSelected,
    ));
  }

  void _onRadiusChanged(MapRadiusChanged event, Emitter<MapState> emit) {
    final filtered = state.allIncidents.where((i) => i.distanceKm <= event.radiusKm).toList();
    Incident? selected = state.selectedIncident;
    final currentSelectedId = selected?.id;
    if (currentSelectedId != null && !filtered.any((i) => i.id == currentSelectedId)) {
      selected = filtered.isNotEmpty ? filtered.first : null;
    }

    emit(state.copyWith(
      selectedRadiusKm: event.radiusKm,
      filteredIncidents: filtered,
      selectedIncident: () => selected,
    ));
  }

  void _onIncidentSelected(MapIncidentSelected event, Emitter<MapState> emit) {
    emit(state.copyWith(
      selectedIncident: () => event.incident,
    ));
  }

  void _onSearchQueried(MapSearchQueried event, Emitter<MapState> emit) {
    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      final filtered = state.allIncidents
          .where((i) => i.distanceKm <= state.selectedRadiusKm)
          .toList();
      emit(state.copyWith(searchQuery: '', filteredIncidents: filtered));
    } else {
      final filtered = state.allIncidents
          .where((i) =>
              i.distanceKm <= state.selectedRadiusKm &&
              (i.title.toLowerCase().contains(query) ||
                  i.description.toLowerCase().contains(query) ||
                  i.areaCode.toLowerCase().contains(query)))
          .toList();
      emit(state.copyWith(searchQuery: event.query, filteredIncidents: filtered));
    }
  }

  void _onRecenterPressed(MapRecenterPressed event, Emitter<MapState> emit) {
    // Recenter resets to the default selected incident or area
    final defaultSelected = state.filteredIncidents.isNotEmpty ? state.filteredIncidents.first : null;
    emit(state.copyWith(
      selectedIncident: () => defaultSelected,
    ));
  }
}
