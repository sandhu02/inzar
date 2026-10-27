import 'dart:async';
import 'package:flutter/material.dart';
import 'di.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Service Locator DI
  setupServiceLocator();

  runApp(await builder());
}

