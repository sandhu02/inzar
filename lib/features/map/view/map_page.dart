import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../widgets/radar_map_canvas.dart';
import '../widgets/radius_bar.dart';
import '../widgets/preview_sheet.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc()..add(const MapInitialized()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return Stack(
              children: [
                // 1. Radar Map Background & Canvas
                Positioned.fill(
                  child: RadarMapCanvas(
                    incidents: state.filteredIncidents,
                    selectedIncident: state.selectedIncident,
                    radiusKm: state.selectedRadiusKm,
                    onIncidentTap: (incident) {
                      context.read<MapBloc>().add(MapIncidentSelected(incident));
                    },
                    onRecenterTap: () {
                      context.read<MapBloc>().add(const MapRecenterPressed());
                    },
                  ),
                ),

                // 2. Top Header & Incident Count Pill
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _buildTopHeader(context, state),
                      const SizedBox(height: 6),
                      _buildIncidentCountPill(state.incidentCount, state.selectedRadiusKm),
                    ],
                  ),
                ),

                // 3. Bottom Controls: Radius Bar + Preview Sheet
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadiusBar(
                        selectedRadiusKm: state.selectedRadiusKm,
                        onRadiusSelected: (radius) {
                          context.read<MapBloc>().add(MapRadiusChanged(radius));
                        },
                        onReportPressed: () {
                          context.push('/report/camera');
                        },
                      ),
                      const SizedBox(height: 12),
                      if (state.selectedIncident != null)
                        PreviewSheet(
                          incident: state.selectedIncident!,
                          onViewDetails: () {
                            context.push(
                              '/incident-details',
                              extra: state.selectedIncident,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, MapState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Orange Diamond Logo Glyph
              Transform.rotate(
                angle: 0.785398, // 45 deg
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INZAR',
                    style: AppTypography.screenTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    state.locationArea,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textPrimary),
              onPressed: () {
                _showSearchDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCountPill(int count, int radiusKm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        '$count incidents  ·  within $radiusKm km',
        style: AppTypography.technicalTag.copyWith(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Search Incidents', style: AppTypography.titleMedium),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. accident, fire, F-7, Margalla',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
          ),
          onChanged: (val) {
            context.read<MapBloc>().add(MapSearchQueried(val));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
