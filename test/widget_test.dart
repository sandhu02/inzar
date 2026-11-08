import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/app/app.dart';
import 'package:inzar/app/di.dart';
import 'package:inzar/app/router.dart';
import 'package:inzar/core/network/token_storage.dart';
import 'package:inzar/core/storage/app_preferences.dart';

void main() {
  setUp(() {
    setupServiceLocator(
      customStorage: InMemoryTokenStorage(),
      customPreferences: InMemoryAppPreferences(),
    );
    configureAppRouter(initialLocation: '/onboarding');
  });

  testWidgets('First launch continues to sign-in without bypassing auth', (
    WidgetTester tester,
  ) async {
    // Set standard phone screen size so all widgets are within viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const InzarApp());
    await tester.pumpAndSettle();

    // 1. Initial screen: Onboarding
    expect(find.text('INZAR'), findsWidgets);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // 2. User taps Skip -> navigates to Sign In / Sign Up
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.text('Sign in to track your reports.'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsNothing);

    // An unauthenticated user cannot reach the map through the sign-in screen.
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.text('+ Report'), findsNothing);
  });

  testWidgets(
    'Direct map navigation redirects without an authenticated token',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      configureAppRouter(initialLocation: '/map');
      await tester.pumpWidget(const InzarApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome back.'), findsOneWidget);
      expect(find.text('+ Report'), findsNothing);
    },
  );
}
