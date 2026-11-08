import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/core/network/api_client.dart';
import 'package:inzar/core/network/token_storage.dart';

void main() {
  test('does not send a saved bearer token to login', () async {
    final storage = InMemoryTokenStorage();
    await storage.saveTokens(
      accessToken: 'saved-access-token',
      refreshToken: 'saved-refresh-token',
    );
    final adapter = _CaptureAdapter();
    final client = ApiClient(
      storage: storage,
      customDio: Dio(BaseOptions(baseUrl: 'https://unit.test/api/v1'))
        ..httpClientAdapter = adapter,
    );

    await client.dio.post('/auth/login', data: const {});

    expect(adapter.headers?['Authorization'], isNull);
  });

  test('sends the actual saved bearer token to protected endpoints', () async {
    final storage = InMemoryTokenStorage();
    await storage.saveTokens(
      accessToken: 'saved-access-token',
      refreshToken: 'saved-refresh-token',
    );
    final adapter = _CaptureAdapter();
    final client = ApiClient(
      storage: storage,
      customDio: Dio(BaseOptions(baseUrl: 'https://unit.test/api/v1'))
        ..httpClientAdapter = adapter,
    );

    await client.dio.get('/me');

    expect(adapter.headers?['Authorization'], 'Bearer saved-access-token');
  });
}

class _CaptureAdapter implements HttpClientAdapter {
  Map<String, dynamic>? headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    headers = Map<String, dynamic>.from(options.headers);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}
