import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../bloc/settings_cubit.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

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
          child: Column(
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
              const SizedBox(height: 20),

              // Profile Card (matching Page 11 screenshot)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final user = authState.user;
                  final name = user?.name ?? 'Sign In';
                  final email = user?.email ?? 'Sign in to sync your reports';
                  final initials = user?.initials ?? '?';
                  final isAuthenticated = authState.isAuthenticated;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (isAuthenticated) {
                          context.push('/profile');
                        } else {
                          context.push('/sign-in');
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Row(
                          children: [
                            // Circular initials avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.borderLight, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Name & Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Chevron right
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section 1: MAP
              Text(
                'MAP',
                style: AppTypography.sectionHeader.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final cubit = context.read<SettingsCubit>();
                  return _buildCard(
                    children: [
                      _buildRowItem(
                        label: 'Default radius',
                        value: '${state.defaultRadiusKm} km',
                        onTap: () {
                          _showRadiusDialog(context, cubit, state.defaultRadiusKm);
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        label: 'Map center',
                        value: state.mapCenter,
                        onTap: () {
                          _showMapCenterDialog(context, cubit, state.mapCenter);
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        label: 'Map style',
                        value: state.mapStyle,
                        onTap: () {
                          _showMapStyleDialog(context, cubit, state.mapStyle);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section 2: ALERTS
              Text(
                'ALERTS',
                style: AppTypography.sectionHeader.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final cubit = context.read<SettingsCubit>();
                  return _buildCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nearby alerts', style: AppTypography.body),
                            Switch(
                              value: state.enableNearbyAlerts,
                              activeTrackColor: AppColors.primary,
                              thumbColor: WidgetStateProperty.resolveWith<Color>(
                                (states) => states.contains(WidgetState.selected)
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                              onChanged: cubit.toggleAlerts,
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        label: 'Alert radius',
                        value: '${state.alertRadiusKm} km',
                        onTap: () {
                          _showAlertRadiusDialog(context, cubit, state.alertRadiusKm);
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        label: 'Categories',
                        value: state.alertCategories,
                        onTap: () {
                          _showCategoriesDialog(context, cubit, state.alertCategories);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section 3: PERMISSIONS
              Text(
                'PERMISSIONS',
                style: AppTypography.sectionHeader.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final cubit = context.read<SettingsCubit>();
                  return _buildCard(
                    children: [
                      _buildRowItem(
                        label: 'Location',
                        value: state.locationPermissionGranted ? 'Allowed' : 'Off · Enable',
                        valueColor: state.locationPermissionGranted ? AppColors.textSecondary : AppColors.textHighlight,
                        onTap: cubit.toggleLocationPermission,
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        label: 'Camera',
                        value: state.cameraPermissionGranted ? 'Allowed' : 'Off · Enable',
                        valueColor: state.cameraPermissionGranted ? AppColors.textSecondary : AppColors.textHighlight,
                        onTap: cubit.toggleCameraPermission,
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      _buildRowItem(
                        label: 'Notifications',
                        value: state.notificationPermissionGranted ? 'Allowed' : 'Off · Enable',
                        valueColor: state.notificationPermissionGranted ? AppColors.textSecondary : AppColors.textHighlight,
                        onTap: cubit.toggleNotificationPermission,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section 4: PRIVACY
              Text(
                'PRIVACY',
                style: AppTypography.sectionHeader.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              _buildCard(
                children: [
                  _buildRowItem(
                    label: 'Privacy policy',
                    value: '',
                    onTap: () {
                      _showPolicyDialog(context, 'Privacy Policy', 'Inzar is designed with privacy by default. We do not track personal identities or publish precise personal coordinates. All reports undergo coordinate fuzzing (~200m).');
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildRowItem(
                    label: 'How location is handled',
                    value: '',
                    onTap: () {
                      _showPolicyDialog(context, 'How Location is Handled', 'When you report an incident, your device location is obtained locally to anchor the report. Before publication, coordinates are fuzzed to approximately 200m to protect reporter privacy.');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 5: APPEARANCE
              Text(
                'APPEARANCE',
                style: AppTypography.sectionHeader.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final cubit = context.read<SettingsCubit>();
                  final themeLabel = state.themeMode == ThemeMode.dark
                      ? 'Dark'
                      : state.themeMode == ThemeMode.light
                          ? 'Light'
                          : 'System';

                  return _buildCard(
                    children: [
                      _buildRowItem(
                        label: 'Theme',
                        value: themeLabel,
                        onTap: () {
                          _showThemeDialog(context, cubit, state.themeMode);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Onboarding shortcut for testing/reviewing
              Center(
                child: TextButton.icon(
                  onPressed: () => context.push('/onboarding'),
                  icon: const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.textSecondary),
                  label: Text('View Onboarding Tour', style: AppTypography.bodySmall),
                ),
              ),
              const SizedBox(height: 12),
            ],
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
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: AppTypography.bodySecondary.copyWith(
                  color: valueColor ?? AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showRadiusDialog(BuildContext context, SettingsCubit cubit, int current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Default radius', style: AppTypography.titleMedium),
        children: [1, 5, 10, 25, 50].map((km) {
          return SimpleDialogOption(
            onPressed: () {
              cubit.updateDefaultRadius(km);
              Navigator.pop(ctx);
            },
            child: Text('$km km', style: AppTypography.body),
          );
        }).toList(),
      ),
    );
  }

  void _showAlertRadiusDialog(BuildContext context, SettingsCubit cubit, int current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Alert radius', style: AppTypography.titleMedium),
        children: [1, 5, 10, 25].map((km) {
          return SimpleDialogOption(
            onPressed: () {
              cubit.updateAlertRadius(km);
              Navigator.pop(ctx);
            },
            child: Text('$km km', style: AppTypography.body),
          );
        }).toList(),
      ),
    );
  }

  void _showMapCenterDialog(BuildContext context, SettingsCubit cubit, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Map center', style: AppTypography.titleMedium),
        children: ['Current location', 'Last viewed area'].map((c) {
          return SimpleDialogOption(
            onPressed: () {
              cubit.updateMapCenter(c);
              Navigator.pop(ctx);
            },
            child: Text(c, style: AppTypography.body),
          );
        }).toList(),
      ),
    );
  }

  void _showMapStyleDialog(BuildContext context, SettingsCubit cubit, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Map style', style: AppTypography.titleMedium),
        children: ['Dark', 'High contrast', 'Standard'].map((s) {
          return SimpleDialogOption(
            onPressed: () {
              cubit.updateMapStyle(s);
              Navigator.pop(ctx);
            },
            child: Text(s, style: AppTypography.body),
          );
        }).toList(),
      ),
    );
  }

  void _showCategoriesDialog(BuildContext context, SettingsCubit cubit, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Categories', style: AppTypography.titleMedium),
        children: ['All', 'High urgency only', 'Custom'].map((c) {
          return SimpleDialogOption(
            onPressed: () {
              cubit.updateAlertCategories(c);
              Navigator.pop(ctx);
            },
            child: Text(c, style: AppTypography.body),
          );
        }).toList(),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsCubit cubit, ThemeMode current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text('Theme', style: AppTypography.titleMedium),
        children: [
          SimpleDialogOption(
            onPressed: () {
              cubit.updateTheme(ThemeMode.dark);
              Navigator.pop(ctx);
            },
            child: Text('Dark', style: AppTypography.body),
          ),
          SimpleDialogOption(
            onPressed: () {
              cubit.updateTheme(ThemeMode.light);
              Navigator.pop(ctx);
            },
            child: Text('Light', style: AppTypography.body),
          ),
          SimpleDialogOption(
            onPressed: () {
              cubit.updateTheme(ThemeMode.system);
              Navigator.pop(ctx);
            },
            child: Text('System', style: AppTypography.body),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTypography.titleMedium),
        content: Text(content, style: AppTypography.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
