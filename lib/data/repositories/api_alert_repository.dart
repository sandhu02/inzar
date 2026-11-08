import '../../core/config/app_config.dart';
import '../../core/error/app_failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/alert_preferences.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_data_source.dart';

class ApiAlertRepository implements IAlertRepository {
  final AlertRemoteDataSource _dataSource;

  ApiAlertRepository(this._dataSource);

  @override
  Future<Result<AlertPreferences>> getAlertPreferences() async {
    final response = await _dataSource.fetchAlertPreferences();
    if (response.isSuccess && response.data != null) {
      return Result.success(response.data!);
    }

    final fallback = AlertPreferences(
      enabled: true,
      latitude: AppConfig.instance.defaultLatitude,
      longitude: AppConfig.instance.defaultLongitude,
      radiusKm: 5.0,
      categories: const [],
      minUrgency: 'routine',
    );
    return Result.success(fallback);
  }

  @override
  Future<Result<void>> updateAlertPreferences(AlertPreferences preferences) async {
    final response = await _dataSource.updateAlertPreferences(preferences);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to update alert preferences'),
    );
  }

  @override
  Future<Result<void>> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    final response = await _dataSource.registerDeviceToken(token: token, platform: platform);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to register device token'),
    );
  }

  @override
  Future<Result<void>> unregisterDeviceToken(String token) async {
    final response = await _dataSource.unregisterDeviceToken(token);
    if (response.isSuccess) {
      return const Result.success(null);
    }
    return Result.failure(
      ServerFailure(response.error?.message ?? 'Failed to unregister device token'),
    );
  }
}
