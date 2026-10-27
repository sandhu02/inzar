import 'package:equatable/equatable.dart';
import '../../../domain/entities/incident.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapInitialized extends MapEvent {
  const MapInitialized();
}

class MapRadiusChanged extends MapEvent {
  final int radiusKm;
  const MapRadiusChanged(this.radiusKm);

  @override
  List<Object?> get props => [radiusKm];
}

class MapIncidentSelected extends MapEvent {
  final Incident? incident;
  const MapIncidentSelected(this.incident);

  @override
  List<Object?> get props => [incident];
}

class MapSearchQueried extends MapEvent {
  final String query;
  const MapSearchQueried(this.query);

  @override
  List<Object?> get props => [query];
}

class MapRecenterPressed extends MapEvent {
  const MapRecenterPressed();
}

