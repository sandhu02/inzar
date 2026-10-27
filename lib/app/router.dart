import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/incident.dart';
import '../shell/main_shell.dart';
import '../features/map/view/map_page.dart';
import '../features/activity/view/activity_page.dart';
import '../features/settings/view/settings_page.dart';
import '../features/incident_details/view/incident_details_page.dart';
import '../features/report/view/camera_page.dart';
import '../features/report/view/form_page.dart';
import '../features/report/view/progress_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/map',
  routes: [
    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // 1. Map Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MapPage(),
              ),
            ),
          ],
        ),

        // 2. Activity Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activity',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ActivityPage(),
              ),
            ),
          ],
        ),

        // 3. Settings Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsPage(),
              ),
            ),
          ],
        ),
      ],
    ),

    // Full screen routes
    GoRoute(
      path: '/incident-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final incident = state.extra as Incident?;
        return IncidentDetailsPage(incident: incident);
      },
    ),
    GoRoute(
      path: '/report/camera',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CameraPage(),
    ),
    GoRoute(
      path: '/report/form',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FormPage(),
    ),
    GoRoute(
      path: '/report/progress',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProgressPage(),
    ),
  ],
);

