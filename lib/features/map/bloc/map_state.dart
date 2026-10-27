import 'package:equatable/equatable.dart';
import '../../../domain/entities/incident.dart';

class MapState extends Equatable {
  final int selectedRadiusKm;
  final List<Incident> allIncidents;
  final List<Incident> filteredIncidents;
  final Incident? selectedIncident;
  final String locationArea;
  final String searchQuery;
  final bool isLoading;

  const MapState({
    this.selectedRadiusKm = 5,
    this.allIncidents = const [],
    this.filteredIncidents = const [],
    this.selectedIncident,
    this.locationArea = 'Margalla Rd · F-7',
    this.searchQuery = '',
    this.isLoading = false,
  });

  int get incidentCount => filteredIncidents.length;

  MapState copyWith({
    int? selectedRadiusKm,
    List<Incident>? allIncidents,
    List<Incident>? filteredIncidents,
    Incident? Function()? selectedIncident,
    String? locationArea,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MapState(
      selectedRadiusKm: selectedRadiusKm ?? this.selectedRadiusKm,
      allIncidents: allIncidents ?? this.allIncidents,
      filteredIncidents: filteredIncidents ?? this.filteredIncidents,
      selectedIncident: selectedIncident != null ? selectedIncident() : this.selectedIncident,
      locationArea: locationArea ?? this.locationArea,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        selectedRadiusKm,
        allIncidents,
        filteredIncidents,
        selectedIncident,
        locationArea,
        searchQuery,
        isLoading,
      ];
}

