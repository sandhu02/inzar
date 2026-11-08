import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user_profile.dart';

abstract class ITokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> saveUser(UserProfile user);
  Future<UserProfile?> getUser();
  Future<void> clearTokens();
}

class SecureTokenStorage implements ITokenStorage {
  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'inzar_access_token';
  static const String _keyRefreshToken = 'inzar_refresh_token';
  static const String _keyUser = 'inzar_user_profile';

  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage();

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    try {
      await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
    } catch (_) {}
  }

  @override
  Future<UserProfile?> getUser() async {
    try {
      final raw = await _storage.read(key: _keyUser);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return UserProfile.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUser);
    } catch (_) {}
  }
}

/// In-memory storage for unit testing or fallback.
class InMemoryTokenStorage implements ITokenStorage {
  String? _accessToken;
  String? _refreshToken;
  UserProfile? _user;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    _user = user;
  }

  @override
  Future<UserProfile?> getUser() async => _user;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
  }
}
