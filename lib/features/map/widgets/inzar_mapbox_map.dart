import 'package:flutter/material.dart';
import '../../../domain/entities/incident.dart';
import 'inzar_map.dart';

/// Legacy adapter delegating to the production-grade [InzarMap].
class InzarMapboxMap extends StatelessWidget {
  final List<Incident> incidents;
  final Incident? selectedIncident;
  final int radiusKm;
  final ValueChanged<Incident> onIncidentTap;
  final VoidCallback onRecenterTap;

  const InzarMapboxMap({
    super.key,
    required this.incidents,
    required this.selectedIncident,
    required this.radiusKm,
    required this.onIncidentTap,
    required this.onRecenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return InzarMap(
      incidents: incidents,
      selectedIncident: selectedIncident,
      radiusKm: radiusKm,
      onIncidentTap: onIncidentTap,
      onRecenterTap: onRecenterTap,
    );
  }
}
