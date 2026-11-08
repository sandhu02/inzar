import 'package:permission_handler/permission_handler.dart';

/// Centralized service for querying and requesting runtime OS permissions.
class PermissionService {
  const PermissionService();

  /// Checks if location permission is currently granted.
  Future<bool> isLocationGranted() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      return status.isGranted || status.isLimited;
    } catch (_) {
      return false;
    }
  }

  /// Requests location permission from the OS.
  Future<bool> requestLocation() async {
    try {
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
      }
      return status.isGranted || status.isLimited;
    } catch (_) {
      return false;
    }
  }

  /// Checks if camera permission is currently granted.
  Future<bool> isCameraGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Requests camera permission from the OS.
  Future<bool> requestCamera() async {
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Checks if notifications permission is currently granted.
  Future<bool> isNotificationGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Requests notifications permission from the OS.
  Future<bool> requestNotification() async {
    try {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Opens the device settings if permission was permanently denied.
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }
}

