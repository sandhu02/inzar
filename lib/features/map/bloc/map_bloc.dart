import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/repositories/incident_repository.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final IIncidentRepository? incidentRepository;

  MapBloc({this.incidentRepository}) : super(const MapState()) {
    on<MapInitialized>(_onInitialized);
    on<MapRadiusChanged>(_onRadiusChanged);
    on<MapIncidentSelected>(_onIncidentSelected);
    on<MapSearchQueried>(_onSearchQueried);
    on<MapRecenterPressed>(_onRecenterPressed);
    on<MapUserLocationUpdated>(_onUserLocationUpdated);
  }

  Future<void> _onUserLocationUpdated(
    MapUserLocationUpdated event,
    Emitter<MapState> emit,
  ) async {
    final areaText = event.locationArea ?? 'Current Location';
    emit(state.copyWith(
      userLatitude: event.latitude,
      userLongitude: event.longitude,
      locationArea: areaText,
    ));

    List<Incident> list = state.allIncidents;
    if (incidentRepository != null) {
      final res = await incidentRepository!.getNearbyIncidents(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: state.selectedRadiusKm,
      );
      if (res.isSuccess && res.data != null) {
        list = res.data!;
      }
    }

    final filtered = list.where((i) {
      if (i.distanceKm <= 0.0) return true;
      return i.distanceKm <= state.selectedRadiusKm;
    }).toList();
    final displayList = filtered.isNotEmpty ? filtered : list;

    Incident? selected = state.selectedIncident;
    final currentSelectedId = selected?.id;
    if (currentSelectedId != null && !displayList.any((i) => i.id == currentSelectedId)) {
      selected = displayList.isNotEmpty ? displayList.first : null;
    }

    emit(state.copyWith(
      allIncidents: list,
      filteredIncidents: displayList,
      selectedIncident: () => selected,
    ));
  }

  Future<void> _onInitialized(MapInitialized event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));

    List<Incident> list = [];
    if (incidentRepository != null) {
      final res = await incidentRepository!.getNearbyIncidents(
        latitude: state.userLatitude,
        longitude: state.userLongitude,
        radiusKm: state.selectedRadiusKm,
      );
      if (res.isSuccess && res.data != null) {
        list = res.data!;
      }
    }

    final filtered = list.where((i) {
      if (i.distanceKm <= 0.0) return true;
      return i.distanceKm <= state.selectedRadiusKm;
    }).toList();
    final displayList = filtered.isNotEmpty ? filtered : list;

    final defaultSelected = displayList.isNotEmpty
        ? displayList.firstWhere((i) => i.isSelected, orElse: () => displayList.first)
        : null;

    emit(state.copyWith(
      isLoading: false,
      allIncidents: list,
      filteredIncidents: displayList,
      selectedIncident: () => defaultSelected,
    ));
  }

  Future<void> _onRadiusChanged(MapRadiusChanged event, Emitter<MapState> emit) async {
    emit(state.copyWith(selectedRadiusKm: event.radiusKm, isLoading: true));

    List<Incident> list = state.allIncidents;
    if (incidentRepository != null) {
      final res = await incidentRepository!.getNearbyIncidents(
        latitude: state.userLatitude,
        longitude: state.userLongitude,
        radiusKm: event.radiusKm,
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        list = res.data!;
      }
    }

    final filtered = list.where((i) {
      if (i.distanceKm <= 0.0) return true;
      return i.distanceKm <= event.radiusKm;
    }).toList();
    final displayList = filtered.isNotEmpty ? filtered : list;

    Incident? selected = state.selectedIncident;
    final currentSelectedId = selected?.id;
    if (currentSelectedId != null && !displayList.any((i) => i.id == currentSelectedId)) {
      selected = displayList.isNotEmpty ? displayList.first : null;
    }

    emit(state.copyWith(
      isLoading: false,
      allIncidents: list,
      selectedRadiusKm: event.radiusKm,
      filteredIncidents: displayList,
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
          .where((i) => i.distanceKm <= 0.0 || i.distanceKm <= state.selectedRadiusKm)
          .toList();
      emit(state.copyWith(searchQuery: '', filteredIncidents: filtered.isNotEmpty ? filtered : state.allIncidents));
    } else {
      final filtered = state.allIncidents
          .where((i) =>
              (i.distanceKm <= 0.0 || i.distanceKm <= state.selectedRadiusKm) &&
              (i.title.toLowerCase().contains(query) ||
                  i.description.toLowerCase().contains(query) ||
                  i.areaCode.toLowerCase().contains(query) ||
                  i.locationName.toLowerCase().contains(query)))
          .toList();
      emit(state.copyWith(searchQuery: event.query, filteredIncidents: filtered));
    }
  }

  void _onRecenterPressed(MapRecenterPressed event, Emitter<MapState> emit) {
    final defaultSelected = state.filteredIncidents.isNotEmpty ? state.filteredIncidents.first : null;
    emit(state.copyWith(
      selectedIncident: () => defaultSelected,
    ));
  }
}
