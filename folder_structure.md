lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp.router, theme from SettingsCubit
│   ├── router.dart                 # go_router + StatefulShellRoute (Map / Activity / Settings)
│   ├── di.dart                     # get_it + injectable registrations
│   └── bootstrap.dart              # init DI, DB, Bloc observer, error zone
├── core/
│   ├── theme/ + design_system/     # tokens, SnButton, StatusBadge, CategoryChip, RadiusSelector, skeletons
│   ├── error/                      # AppFailure (sealed), Result<T>
│   ├── network/
│   │   ├── api_client.dart         # dio + generated client
│   │   ├── auth_interceptor.dart   # attach access token, single-flight refresh on 401
│   │   ├── retry_interceptor.dart
│   │   └── connectivity_cubit.dart
│   ├── auth/                       # TokenStore (flutter_secure_storage), AuthRepository, AuthBloc
│   ├── location/ permissions/ storage/ background/ l10n/ utils/
├── domain/
│   ├── entities/                   # Incident, IncidentCategory, ReviewStatus, ReportDraft, GeoPoint
│   └── usecases/                   # only where real logic exists (SubmitReport, FuzzCoordinate)
├── data/
│   ├── incidents/                  # repository (interface + impl), remote source, drift cache, DTOs
│   ├── reports/                    # repository, upload source, drift drafts + queue
│   ├── alerts/                     # push token registration, alert preference sync
│   └── settings/
├── features/
│   ├── map/
│   │   ├── bloc/    map_bloc.dart, map_event.dart, map_state.dart
│   │   ├── view/    map_page.dart
│   │   └── widgets/ incident_marker, cluster_marker, preview_sheet, radius_bar
│   ├── incident_details/           # bloc/ (Cubit), view/, widgets/
│   ├── report/
│   │   ├── camera/                 # CameraCubit (camera package only)
│   │   ├── flow/    report_flow_bloc.dart, events, state   # one Bloc across capture→form→progress
│   │   └── view/    camera_page, preview_page, form_page, progress_page
│   ├── activity/                   # ActivityBloc (filters + status stream)
│   └── settings/                   # SettingsCubit, PermissionsCubit
└── shell/ main_shell.dart