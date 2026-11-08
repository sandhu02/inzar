import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Application & Backend Configuration.
///
/// The development target is the backend tunnel accessed by the physical Android
/// test device.
class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  /// Optional override for a different Android test server.
  static const String _dartDefineBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get _envBaseUrl {
    if (dotenv.isInitialized) {
      final url = dotenv.env['API_BASE_URL']?.trim();
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }
    return _dartDefineBaseUrl;
  }
  static const String defaultBaseUrl =
      'https://x6rjnjfw-8000.inc1.devtunnels.ms/api/v1';

  /// Dynamic runtime override for API Base URL.
  String? _runtimeBaseUrl;

  /// Active Base URL for all API calls.
  String get apiBaseUrl =>
      _runtimeBaseUrl ??
      (_envBaseUrl.isNotEmpty ? _envBaseUrl : defaultBaseUrl);

  set apiBaseUrl(String value) {
    var clean = value.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    _runtimeBaseUrl = clean;
  }

  /// Resets runtime override for API Base URL, returning to environment or default.
  void resetApiBaseUrl() {
    _runtimeBaseUrl = null;
  }

  /// Mapbox public access token for tile rendering.
  /// Can be loaded from `.env` (via flutter_dotenv), `--dart-define=MAPBOX_ACCESS_TOKEN=pk.xxx`,
  /// or pasted into [defaultMapboxAccessToken].
  static const String _dartDefineMapboxToken =
      String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static String get _envMapboxToken {
    if (dotenv.isInitialized) {
      final token = dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }
    return _dartDefineMapboxToken;
  }
  static const String defaultMapboxAccessToken = '';

  String? _runtimeMapboxToken;

  /// Active Mapbox access token.
  String get mapboxAccessToken =>
      _runtimeMapboxToken ??
      (_envMapboxToken.isNotEmpty
          ? _envMapboxToken
          : defaultMapboxAccessToken);

  set mapboxAccessToken(String value) {
    _runtimeMapboxToken = value.trim();
  }

  /// Resets runtime override for Mapbox access token, returning to environment or default.
  void resetMapboxAccessToken() {
    _runtimeMapboxToken = null;
  }

  /// Resolves the tile URL template for flutter_map.
  /// Uses official Mapbox Dark or Streets styles when a token is provided.
  /// Falls back to OpenStreetMap if no token is available to ensure the map renders
  /// cleanly without watermarks.
  String getMapTileUrl({bool isDark = true}) {
    final token = mapboxAccessToken;
    if (token.isNotEmpty) {
      final styleId = isDark ? 'mapbox/dark-v11' : 'mapbox/streets-v12';
      return 'https://api.mapbox.com/styles/v1/$styleId/tiles/256/{z}/{x}/{y}@2x?access_token=$token';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  /// Default map center: Islamabad (Margalla / F-7 area per Inzar UX)
  final double defaultLatitude = 33.7294;
  final double defaultLongitude = 73.0560;

  /// Network Timeouts
  final Duration connectTimeout = const Duration(seconds: 15);
  final Duration receiveTimeout = const Duration(seconds: 30);
  final Duration sendTimeout = const Duration(seconds: 30);
}
