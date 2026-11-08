import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/design_system/incident_marker_view.dart';
import '../../../domain/entities/incident.dart';

/// Production-ready interactive map displaying actual streets, roads, and neighborhoods.
///
/// Backed by Mapbox raster tile services with OpenStreetMap fallback. Supports
/// panning, pinch-to-zoom, user GPS location, dynamic radius boundary circles,
/// and interactive incident pins.
class InzarMap extends StatefulWidget {
  final List<Incident> incidents;
  final Incident? selectedIncident;
  final int radiusKm;
  final ValueChanged<Incident> onIncidentTap;
  final VoidCallback onRecenterTap;
  final ValueChanged<LatLng>? onLocationDetermined;
  final bool isDarkStyle;

  const InzarMap({
    super.key,
    required this.incidents,
    required this.selectedIncident,
    required this.radiusKm,
    required this.onIncidentTap,
    required this.onRecenterTap,
    this.onLocationDetermined,
    this.isDarkStyle = true,
  });

  @override
  State<InzarMap> createState() => _InzarMapState();
}

class _InzarMapState extends State<InzarMap> with TickerProviderStateMixin {
  late final MapController _mapController;
  LatLng _userPosition = LatLng(
    AppConfig.instance.defaultLatitude,
    AppConfig.instance.defaultLongitude,
  );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _determinePosition();
  }

  @override
  void didUpdateWidget(covariant InzarMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.radiusKm != widget.radiusKm) {
      _zoomToRadius(widget.radiusKm);
    }
    if (oldWidget.selectedIncident?.id != widget.selectedIncident?.id &&
        widget.selectedIncident != null) {
      final inc = widget.selectedIncident!;
      if (inc.latitude != 0.0 && inc.longitude != 0.0) {
        _animateTo(LatLng(inc.latitude, inc.longitude), 14.5);
      }
    }
  }

  Future<void> _determinePosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[InzarMap] Device location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request user permission for location access
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('[InzarMap] Location permission denied ($permission).');
        return;
      }

      // Fast snap: use last known position immediately if available
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        final pos = LatLng(lastPos.latitude, lastPos.longitude);
        setState(() {
          _userPosition = pos;
        });
        _animateTo(pos, _getZoomForRadius(widget.radiusKm));
        widget.onLocationDetermined?.call(pos);
      }

      // Accurate update: fetch fresh GPS fix
      final freshPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        final pos = LatLng(freshPos.latitude, freshPos.longitude);
        setState(() {
          _userPosition = pos;
        });
        _animateTo(pos, _getZoomForRadius(widget.radiusKm));
        widget.onLocationDetermined?.call(pos);
      }
    } catch (e) {
      debugPrint('[InzarMap] Failed to determine location: $e');
    }
  }

  double _getZoomForRadius(int radiusKm) {
    if (radiusKm <= 1) return 14.5;
    if (radiusKm <= 5) return 12.8;
    if (radiusKm <= 10) return 11.5;
    if (radiusKm <= 25) return 10.0;
    return 8.8;
  }

  void _zoomToRadius(int radiusKm) {
    _animateTo(_userPosition, _getZoomForRadius(radiusKm));
  }

  void _animateTo(LatLng target, double zoom) {
    try {
      _mapController.move(target, zoom);
    } catch (_) {}
  }

  void _handleRecenter() async {
    widget.onRecenterTap();
    await _determinePosition();
    _animateTo(_userPosition, _getZoomForRadius(widget.radiusKm));
  }

  @override
  Widget build(BuildContext context) {
    final tileUrl = AppConfig.instance.getMapTileUrl(
      isDark: widget.isDarkStyle,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _userPosition,
            initialZoom: _getZoomForRadius(widget.radiusKm),
            minZoom: 3.0,
            maxZoom: 18.5,
          ),
          children: [
            // Mapbox / OSM street map layer
            TileLayer(
              urlTemplate: tileUrl,
              userAgentPackageName: 'com.inzar.app',
              maxZoom: 19,
            ),

            // Radius boundary circle around current location
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _userPosition,
                  radius: (widget.radiusKm * 1000).toDouble(),
                  useRadiusInMeter: true,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderColor: AppColors.primary.withValues(alpha: 0.4),
                  borderStrokeWidth: 1.5,
                ),
              ],
            ),

            // User location indicator (pulsing blue dot)
            MarkerLayer(
              markers: [
                Marker(
                  point: _userPosition,
                  width: 32,
                  height: 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2196F3).withValues(alpha: 0.25),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2196F3),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Real incident pins
                ...widget.incidents
                    .where((i) => i.latitude != 0.0 && i.longitude != 0.0)
                    .map((incident) {
                  final isSelected = widget.selectedIncident?.id == incident.id;
                  final size = isSelected ? 46.0 : 38.0;

                  return Marker(
                    point: LatLng(incident.latitude, incident.longitude),
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onIncidentTap(incident),
                      child: IncidentMarkerView(
                        category: incident.category,
                        isSelected: isSelected,
                        size: size,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        // Recenter Floating Button on bottom-right of map
        Positioned(
          right: 18,
          bottom: widget.selectedIncident != null ? 220 : 96,
          child: GestureDetector(
            onTap: _handleRecenter,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

