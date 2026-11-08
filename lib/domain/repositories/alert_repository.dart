import '../../core/error/result.dart';
import '../entities/alert_preferences.dart';

abstract class IAlertRepository {
  Future<Result<AlertPreferences>> getAlertPreferences();
  Future<Result<void>> updateAlertPreferences(AlertPreferences preferences);
  Future<Result<void>> registerDeviceToken({required String token, required String platform});
  Future<Result<void>> unregisterDeviceToken(String token);
}

