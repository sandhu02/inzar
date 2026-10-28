import 'package:get_it/get_it.dart';
import '../features/settings/bloc/settings_cubit.dart';
import '../features/report/flow/report_flow_bloc.dart';
import '../features/auth/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Blocs & Cubits
  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit());
  getIt.registerLazySingleton<ReportFlowBloc>(() => ReportFlowBloc());
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc());
}
