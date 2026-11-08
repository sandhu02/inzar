import '../../core/error/result.dart';
import '../entities/app_public_config.dart';

abstract class IAppConfigRepository {
  Future<Result<AppPublicConfig>> getPublicConfig();
}

