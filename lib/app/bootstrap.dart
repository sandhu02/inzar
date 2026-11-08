import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'di.dart';
import 'router.dart';
import '../core/storage/app_preferences.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/app_config_repository.dart';
import '../domain/repositories/category_repository.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env) if present
  try {
    await dotenv.load(fileName: ".env", isOptional: true);
  } catch (e) {
    debugPrint('[Bootstrap] .env file not found or failed to load: $e');
  }

  // Initialize Service Locator DI
  setupServiceLocator();

  // Determine initial screen flow based on onboarding and auth status
  try {
    final prefs = getIt<IAppPreferences>();
    final hasCompletedOnboarding = await prefs.isOnboardingCompleted();

    String initialLocation;
    if (!hasCompletedOnboarding) {
      // First time opening app -> start at onboarding
      initialLocation = '/onboarding';
    } else {
      final authRepo = getIt<IAuthRepository>();
      final authResult = await authRepo.checkAuthStatus();
      if (authResult.isSuccess && authResult.data != null) {
        // Returning user with valid session -> start at home map
        initialLocation = '/map';
      } else {
        // Onboarding already seen, but user not logged in -> start at sign-in
        initialLocation = '/sign-in';
      }
    }
    configureAppRouter(initialLocation: initialLocation);
  } catch (_) {
    configureAppRouter(initialLocation: '/onboarding');
  }

  // Eagerly warm up startup configurations in the background per Section 5 of guide
  unawaited(getIt<IAppConfigRepository>().getPublicConfig().then((_) {}).catchError((_) {}));
  unawaited(getIt<ICategoryRepository>().getCategories().then((_) {}).catchError((_) {}));

  runApp(await builder());
}
