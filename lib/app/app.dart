import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'di.dart';
import 'router.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/bloc/settings_cubit.dart';
import '../features/report/flow/report_flow_bloc.dart';
import '../features/auth/bloc/auth_bloc.dart';

class InzarApp extends StatelessWidget {
  final GoRouter? router;

  const InzarApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(
          value: getIt<SettingsCubit>(),
        ),
        BlocProvider<ReportFlowBloc>.value(
          value: getIt<ReportFlowBloc>(),
        ),
        BlocProvider<AuthBloc>.value(
          value: getIt<AuthBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            title: 'Inzar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.themeMode,
            routerConfig: router ?? appRouter,
          );
        },
      ),
    );
  }
}
