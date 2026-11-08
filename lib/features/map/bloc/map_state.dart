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
  final double userLatitude;
  final double userLongitude;

  const MapState({
    this.selectedRadiusKm = 5,
    this.allIncidents = const [],
    this.filteredIncidents = const [],
    this.selectedIncident,
    this.locationArea = 'Margalla Rd · F-7',
    this.searchQuery = '',
    this.isLoading = false,
    this.userLatitude = 33.7294,
    this.userLongitude = 73.0560,
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
    double? userLatitude,
    double? userLongitude,
  }) {
    return MapState(
      selectedRadiusKm: selectedRadiusKm ?? this.selectedRadiusKm,
      allIncidents: allIncidents ?? this.allIncidents,
      filteredIncidents: filteredIncidents ?? this.filteredIncidents,
      selectedIncident: selectedIncident != null ? selectedIncident() : this.selectedIncident,
      locationArea: locationArea ?? this.locationArea,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
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
        userLatitude,
        userLongitude,
      ];
}

