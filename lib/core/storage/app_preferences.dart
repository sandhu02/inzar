import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for general application preferences & first-time flags.
abstract class IAppPreferences {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
  Future<void> clear();
}

/// Secure storage-backed implementation of [IAppPreferences].
class SecureAppPreferences implements IAppPreferences {
  final FlutterSecureStorage _storage;
  static const String _keyOnboardingCompleted = 'inzar_onboarding_completed';

  SecureAppPreferences([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      final value = await _storage.read(key: _keyOnboardingCompleted);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      await _storage.write(key: _keyOnboardingCompleted, value: completed.toString());
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _keyOnboardingCompleted);
    } catch (_) {}
  }
}

/// In-memory implementation for testing or fallback.
class InMemoryAppPreferences implements IAppPreferences {
  bool onboardingCompleted;

  InMemoryAppPreferences({this.onboardingCompleted = false});

  @override
  Future<bool> isOnboardingCompleted() async => onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    onboardingCompleted = completed;
  }

  @override
  Future<void> clear() async {
    onboardingCompleted = false;
  }
}

