import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final int defaultRadiusKm;
  final bool enableNearbyAlerts;
  final int alertRadiusKm;
  final bool locationPermissionGranted;
  final bool cameraPermissionGranted;
  final bool notificationPermissionGranted;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.defaultRadiusKm = 5,
    this.enableNearbyAlerts = true,
    this.alertRadiusKm = 5,
    this.locationPermissionGranted = true,
    this.cameraPermissionGranted = true,
    this.notificationPermissionGranted = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? defaultRadiusKm,
    bool? enableNearbyAlerts,
    int? alertRadiusKm,
    bool? locationPermissionGranted,
    bool? cameraPermissionGranted,
    bool? notificationPermissionGranted,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      defaultRadiusKm: defaultRadiusKm ?? this.defaultRadiusKm,
      enableNearbyAlerts: enableNearbyAlerts ?? this.enableNearbyAlerts,
      alertRadiusKm: alertRadiusKm ?? this.alertRadiusKm,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      cameraPermissionGranted: cameraPermissionGranted ?? this.cameraPermissionGranted,
      notificationPermissionGranted: notificationPermissionGranted ?? this.notificationPermissionGranted,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        defaultRadiusKm,
        enableNearbyAlerts,
        alertRadiusKm,
        locationPermissionGranted,
        cameraPermissionGranted,
        notificationPermissionGranted,
      ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void updateTheme(ThemeMode mode) => emit(state.copyWith(themeMode: mode));
  void updateDefaultRadius(int km) => emit(state.copyWith(defaultRadiusKm: km));
  void toggleAlerts(bool enabled) => emit(state.copyWith(enableNearbyAlerts: enabled));
  void updateAlertRadius(int km) => emit(state.copyWith(alertRadiusKm: km));
  void toggleLocationPermission() =>
      emit(state.copyWith(locationPermissionGranted: !state.locationPermissionGranted));
  void toggleCameraPermission() =>
      emit(state.copyWith(cameraPermissionGranted: !state.cameraPermissionGranted));
  void toggleNotificationPermission() =>
      emit(state.copyWith(notificationPermissionGranted: !state.notificationPermissionGranted));
}

