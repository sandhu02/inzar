import 'package:get_it/get_it.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/token_storage.dart';
import '../core/storage/app_preferences.dart';
import '../core/services/permission_service.dart';
import '../core/services/image_compression_service.dart';
import '../data/datasources/alert_remote_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/category_remote_data_source.dart';
import '../data/datasources/config_remote_data_source.dart';
import '../data/datasources/incident_remote_data_source.dart';
import '../data/datasources/media_remote_data_source.dart';
import '../data/repositories/api_alert_repository.dart';
import '../data/repositories/api_app_config_repository.dart';
import '../data/repositories/api_auth_repository.dart';
import '../data/repositories/api_category_repository.dart';
import '../data/repositories/api_incident_repository.dart';
import '../domain/repositories/alert_repository.dart';
import '../domain/repositories/app_config_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/incident_repository.dart';
import '../features/settings/bloc/settings_cubit.dart';
import '../features/report/flow/report_flow_bloc.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/map/bloc/map_bloc.dart';
import '../features/activity/bloc/activity_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator({
  ITokenStorage? customStorage,
  ApiClient? customClient,
  IAppPreferences? customPreferences,
}) {
  // Reset if already initialized to allow clean re-registration in tests
  if (customStorage != null || customClient != null || customPreferences != null) {
    getIt.reset();
  }

  // Configuration
  if (!getIt.isRegistered<AppConfig>()) {
    getIt.registerLazySingleton<AppConfig>(() => AppConfig.instance);
  }

  // Network & Storage
  if (!getIt.isRegistered<ITokenStorage>()) {
    getIt.registerLazySingleton<ITokenStorage>(() => customStorage ?? SecureTokenStorage());
  }
  if (!getIt.isRegistered<IAppPreferences>()) {
    getIt.registerLazySingleton<IAppPreferences>(() => customPreferences ?? SecureAppPreferences());
  }
  if (!getIt.isRegistered<PermissionService>()) {
    getIt.registerLazySingleton<PermissionService>(() => const PermissionService());
  }
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() => customClient ?? ApiClient(storage: getIt<ITokenStorage>()));
  }

  // Data Sources
  if (!getIt.isRegistered<ConfigRemoteDataSource>()) {
    getIt.registerLazySingleton<ConfigRemoteDataSource>(() => ConfigRemoteDataSource(getIt<ApiClient>()));
  }
  if (!getIt.isRegistered<CategoryRemoteDataSource>()) {
    getIt.registerLazySingleton<CategoryRemoteDataSource>(() => CategoryRemoteDataSource(getIt<ApiClient>()));
  }
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(getIt<ApiClient>()));
  }
  if (!getIt.isRegistered<IncidentRemoteDataSource>()) {
    getIt.registerLazySingleton<IncidentRemoteDataSource>(() => IncidentRemoteDataSource(getIt<ApiClient>()));
  }
  if (!getIt.isRegistered<IImageCompressionService>()) {
    getIt.registerLazySingleton<IImageCompressionService>(() => const ImageCompressionService());
  }
  if (!getIt.isRegistered<MediaRemoteDataSource>()) {
    getIt.registerLazySingleton<MediaRemoteDataSource>(
      () => MediaRemoteDataSource(
        getIt<ApiClient>(),
        compressionService: getIt<IImageCompressionService>(),
      ),
    );
  }
  if (!getIt.isRegistered<AlertRemoteDataSource>()) {
    getIt.registerLazySingleton<AlertRemoteDataSource>(() => AlertRemoteDataSource(getIt<ApiClient>()));
  }

  // Repositories (Interface -> Concrete implementation)
  if (!getIt.isRegistered<IAppConfigRepository>()) {
    getIt.registerLazySingleton<IAppConfigRepository>(() => ApiAppConfigRepository(getIt<ConfigRemoteDataSource>()));
  }
  if (!getIt.isRegistered<ICategoryRepository>()) {
    getIt.registerLazySingleton<ICategoryRepository>(() => ApiCategoryRepository(getIt<CategoryRemoteDataSource>()));
  }
  if (!getIt.isRegistered<IAuthRepository>()) {
    getIt.registerLazySingleton<IAuthRepository>(() => ApiAuthRepository(getIt<AuthRemoteDataSource>(), getIt<ITokenStorage>()));
  }
  if (!getIt.isRegistered<IIncidentRepository>()) {
    getIt.registerLazySingleton<IIncidentRepository>(() => ApiIncidentRepository(
          getIt<IncidentRemoteDataSource>(),
          getIt<MediaRemoteDataSource>(),
          getIt<CategoryRemoteDataSource>(),
        ));
  }
  if (!getIt.isRegistered<IAlertRepository>()) {
    getIt.registerLazySingleton<IAlertRepository>(() => ApiAlertRepository(getIt<AlertRemoteDataSource>()));
  }

  // Blocs & Cubits
  if (!getIt.isRegistered<SettingsCubit>()) {
    getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit());
  }
  if (!getIt.isRegistered<ReportFlowBloc>()) {
    getIt.registerFactory<ReportFlowBloc>(() => ReportFlowBloc(incidentRepository: getIt<IIncidentRepository>()));
  }
  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(authRepository: getIt<IAuthRepository>()));
  }
  if (!getIt.isRegistered<MapBloc>()) {
    getIt.registerFactory<MapBloc>(() => MapBloc(incidentRepository: getIt<IIncidentRepository>()));
  }
  if (!getIt.isRegistered<ActivityBloc>()) {
    getIt.registerFactory<ActivityBloc>(() => ActivityBloc(incidentRepository: getIt<IIncidentRepository>()));
  }
}
