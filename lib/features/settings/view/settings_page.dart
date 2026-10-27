import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final cubit = context.read<SettingsCubit>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title: Settings
                  Text(
                    'Settings',
                    style: AppTypography.screenTitle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: MAP PREFERENCES
                  Text('MAP PREFERENCES', style: AppTypography.sectionHeader),
                  const SizedBox(height: 10),
                  _buildCard(
                    children: [
                      _buildRowItem(
                        icon: Icons.radar_rounded,
                        title: 'Default Search Radius',
                        subtitle: '${state.defaultRadiusKm} km around you',
                        trailing: DropdownButton<int>(
                          value: state.defaultRadiusKm,
                          dropdownColor: AppColors.surfaceElevated,
                          underline: const SizedBox(),
                          items: [1, 5, 10, 25, 50].map((km) {
                            return DropdownMenuItem(
                              value: km,
                              child: Text('$km km', style: AppTypography.body),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) cubit.updateDefaultRadius(val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 2: NOTIFICATIONS
                  Text('NOTIFICATIONS & ALERTS', style: AppTypography.sectionHeader),
                  const SizedBox(height: 10),
                  _buildCard(
                    children: [
                      _buildRowItem(
                        icon: Icons.notifications_active_outlined,
                        title: 'Nearby Incident Alerts',
                        subtitle: 'Notify for verified incidents within radius',
                        trailing: Switch(
                          value: state.enableNearbyAlerts,
                          activeThumbColor: AppColors.primary,
                          onChanged: cubit.toggleAlerts,
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        icon: Icons.adjust_rounded,
                        title: 'Alert Distance',
                        subtitle: '${state.alertRadiusKm} km radius',
                        trailing: DropdownButton<int>(
                          value: state.alertRadiusKm,
                          dropdownColor: AppColors.surfaceElevated,
                          underline: const SizedBox(),
                          items: [1, 5, 10, 25].map((km) {
                            return DropdownMenuItem(
                              value: km,
                              child: Text('$km km', style: AppTypography.body),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) cubit.updateAlertRadius(val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 3: PERMISSIONS
                  Text('PERMISSIONS', style: AppTypography.sectionHeader),
                  const SizedBox(height: 10),
                  _buildCard(
                    children: [
                      _buildRowItem(
                        icon: Icons.location_on_outlined,
                        title: 'Location Access',
                        subtitle: state.locationPermissionGranted
                            ? 'Shared approximately (~200m fuzzing)'
                            : 'Permission denied',
                        trailing: Icon(
                          state.locationPermissionGranted ? Icons.check_circle_rounded : Icons.cancel_outlined,
                          color: state.locationPermissionGranted ? AppColors.statusLiveText : AppColors.statusDeniedText,
                          size: 20,
                        ),
                        onTap: cubit.toggleLocationPermission,
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera Access',
                        subtitle: state.cameraPermissionGranted
                            ? 'Required for capturing live incident proof'
                            : 'Permission denied',
                        trailing: Icon(
                          state.cameraPermissionGranted ? Icons.check_circle_rounded : Icons.cancel_outlined,
                          color: state.cameraPermissionGranted ? AppColors.statusLiveText : AppColors.statusDeniedText,
                          size: 20,
                        ),
                        onTap: cubit.toggleCameraPermission,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 4: APPEARANCE
                  Text('APPEARANCE', style: AppTypography.sectionHeader),
                  const SizedBox(height: 10),
                  _buildCard(
                    children: [
                      _buildRowItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Theme',
                        subtitle: state.themeMode == ThemeMode.dark
                            ? 'Dark (Optimized for map readability)'
                            : state.themeMode == ThemeMode.light
                                ? 'Light theme'
                                : 'System default',
                        trailing: DropdownButton<ThemeMode>(
                          value: state.themeMode,
                          dropdownColor: AppColors.surfaceElevated,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                            DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                            DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                          ],
                          onChanged: (mode) {
                            if (mode != null) cubit.updateTheme(mode);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 5: PRIVACY & EMERGENCY NOTICE
                  Text('PRIVACY & SAFETY', style: AppTypography.sectionHeader),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Privacy by Default',
                              style: AppTypography.titleMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inzar never exposes your personal identity or exact GPS coordinates. Reports are public only with approximate fuzzed location coordinates (~200m).',
                          style: AppTypography.bodySecondary.copyWith(fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 14),
                        Text(
                          'EMERGENCY ASSISTANCE',
                          style: AppTypography.sectionHeader.copyWith(color: AppColors.catFire),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Inzar is not an emergency service. In case of immediate life hazard or severe fire, contact emergency services:\n• Police: 15\n• Rescue / Ambulance / Fire: 1122',
                          style: AppTypography.disclaimer.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Version
                  Center(
                    child: Text(
                      'Inzar v1.0.0 (Build 1) • Production UI',
                      style: AppTypography.technicalSub.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRowItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
