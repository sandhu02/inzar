import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final int defaultRadiusKm;
  final String mapCenter;
  final String mapStyle;
  final bool enableNearbyAlerts;
  final int alertRadiusKm;
  final String alertCategories;
  final bool locationPermissionGranted;
  final bool cameraPermissionGranted;
  final bool notificationPermissionGranted;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.defaultRadiusKm = 5,
    this.mapCenter = 'Current location',
    this.mapStyle = 'Dark',
    this.enableNearbyAlerts = true,
    this.alertRadiusKm = 10, // Matching Page 11
    this.alertCategories = 'All',
    this.locationPermissionGranted = true,
    this.cameraPermissionGranted = true,
    this.notificationPermissionGranted = false, // Matching Page 11 "Off · Enable"
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? defaultRadiusKm,
    String? mapCenter,
    String? mapStyle,
    bool? enableNearbyAlerts,
    int? alertRadiusKm,
    String? alertCategories,
    bool? locationPermissionGranted,
    bool? cameraPermissionGranted,
    bool? notificationPermissionGranted,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      defaultRadiusKm: defaultRadiusKm ?? this.defaultRadiusKm,
      mapCenter: mapCenter ?? this.mapCenter,
      mapStyle: mapStyle ?? this.mapStyle,
      enableNearbyAlerts: enableNearbyAlerts ?? this.enableNearbyAlerts,
      alertRadiusKm: alertRadiusKm ?? this.alertRadiusKm,
      alertCategories: alertCategories ?? this.alertCategories,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      cameraPermissionGranted: cameraPermissionGranted ?? this.cameraPermissionGranted,
      notificationPermissionGranted: notificationPermissionGranted ?? this.notificationPermissionGranted,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        defaultRadiusKm,
        mapCenter,
        mapStyle,
        enableNearbyAlerts,
        alertRadiusKm,
        alertCategories,
        locationPermissionGranted,
        cameraPermissionGranted,
        notificationPermissionGranted,
      ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void updateTheme(ThemeMode mode) => emit(state.copyWith(themeMode: mode));
  void updateDefaultRadius(int km) => emit(state.copyWith(defaultRadiusKm: km));
  void updateMapCenter(String center) => emit(state.copyWith(mapCenter: center));
  void updateMapStyle(String style) => emit(state.copyWith(mapStyle: style));
  void toggleAlerts(bool enabled) => emit(state.copyWith(enableNearbyAlerts: enabled));
  void updateAlertRadius(int km) => emit(state.copyWith(alertRadiusKm: km));
  void updateAlertCategories(String cats) => emit(state.copyWith(alertCategories: cats));
  void toggleLocationPermission() =>
      emit(state.copyWith(locationPermissionGranted: !state.locationPermissionGranted));
  void toggleCameraPermission() =>
      emit(state.copyWith(cameraPermissionGranted: !state.cameraPermissionGranted));
  void toggleNotificationPermission() =>
      emit(state.copyWith(notificationPermissionGranted: !state.notificationPermissionGranted));
}
