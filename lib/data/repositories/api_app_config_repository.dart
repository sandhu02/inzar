import '../../core/error/result.dart';
import '../../domain/entities/app_public_config.dart';
import '../../domain/repositories/app_config_repository.dart';
import '../datasources/config_remote_data_source.dart';

class ApiAppConfigRepository implements IAppConfigRepository {
  final ConfigRemoteDataSource _dataSource;
  AppPublicConfig? _cachedConfig;

  ApiAppConfigRepository(this._dataSource);

  @override
  Future<Result<AppPublicConfig>> getPublicConfig() async {
    if (_cachedConfig != null) {
      return Result.success(_cachedConfig!);
    }

    final response = await _dataSource.fetchPublicConfig();
    if (response.isSuccess && response.data != null) {
      _cachedConfig = response.data!;
      return Result.success(response.data!);
    }

    const fallback = AppPublicConfig();
    return const Result.success(fallback);
  }
}
