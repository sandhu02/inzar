import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/core/config/app_config.dart';

void main() {
  setUp(() {
    AppConfig.instance.resetMapboxAccessToken();
    AppConfig.instance.resetApiBaseUrl();
  });

  test('defaults to the physical Android dev tunnel API URL', () {
    expect(
      AppConfig.defaultBaseUrl,
      'https://x6rjnjfw-8000.inc1.devtunnels.ms/api/v1',
    );
    expect(AppConfig.instance.apiBaseUrl, AppConfig.defaultBaseUrl);
  });

  test('falls back to OpenStreetMap when Mapbox token is not set', () {
    AppConfig.instance.mapboxAccessToken = '';
    expect(
      AppConfig.instance.getMapTileUrl(isDark: true),
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
  });

  test('returns Mapbox Dark and Streets URLs when token is set', () {
    AppConfig.instance.mapboxAccessToken = 'pk.test_token';
    expect(
      AppConfig.instance.getMapTileUrl(isDark: true),
      'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/256/{z}/{x}/{y}@2x?access_token=pk.test_token',
    );
    expect(
      AppConfig.instance.getMapTileUrl(isDark: false),
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=pk.test_token',
    );
  });

  tearDown(() {
    dotenv.clean();
    AppConfig.instance.resetMapboxAccessToken();
    AppConfig.instance.resetApiBaseUrl();
  });

  test('reads Mapbox token and API base URL from dotenv when initialized', () {
    dotenv.loadFromString(
      envString: 'MAPBOX_ACCESS_TOKEN=pk.dotenv_test_token\nAPI_BASE_URL=https://custom.backend.com/api/v1\n',
    );
    AppConfig.instance.resetMapboxAccessToken();
    AppConfig.instance.resetApiBaseUrl();

    expect(AppConfig.instance.mapboxAccessToken, 'pk.dotenv_test_token');
    expect(AppConfig.instance.apiBaseUrl, 'https://custom.backend.com/api/v1');
    expect(
      AppConfig.instance.getMapTileUrl(isDark: true),
      'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/256/{z}/{x}/{y}@2x?access_token=pk.dotenv_test_token',
    );
  });
}
