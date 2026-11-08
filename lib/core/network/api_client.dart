import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'token_storage.dart';

typedef OnSessionExpired = void Function();

class ApiClient {
  late final Dio dio;
  final ITokenStorage tokenStorage;
  final OnSessionExpired? onSessionExpired;

  bool _isRefreshing = false;

  ApiClient({ITokenStorage? storage, this.onSessionExpired, Dio? customDio})
    : tokenStorage = storage ?? SecureTokenStorage() {
    dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.instance.apiBaseUrl,
            connectTimeout: AppConfig.instance.connectTimeout,
            receiveTimeout: AppConfig.instance.receiveTimeout,
            sendTimeout: AppConfig.instance.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _setupInterceptors();
  }

  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always ensure the dynamic base URL is synced
          if (options.baseUrl != AppConfig.instance.apiBaseUrl) {
            options.baseUrl = AppConfig.instance.apiBaseUrl;
          }

          final accessToken = await tokenStorage.getAccessToken();
          if (!options.path.contains('/auth/') &&
              accessToken != null &&
              accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestPath = error.requestOptions.path;

          final isAuthEndpoint =
              requestPath.contains('/auth/login') ||
              requestPath.contains('/auth/signup') ||
              requestPath.contains('/auth/refresh');

          // Automatic Token Refresh on 401 Unauthorized
          if (statusCode == 401 && !isAuthEndpoint && !_isRefreshing) {
            _isRefreshing = true;
            final refreshed = await _refreshToken();
            _isRefreshing = false;

            if (refreshed) {
              final newAccessToken = await tokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              try {
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            } else {
              // Refresh failed or reuse detected - notify session expired
              await tokenStorage.clearTokens();
              onSessionExpired?.call();
            }
          }

          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => debugPrint('[API] $obj'),
        ),
      );
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.instance.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        // Check for either enveloped response or direct payload
        final payload =
            (body is Map<String, dynamic> && body.containsKey('data'))
            ? body['data']
            : body;

        if (payload is Map<String, dynamic>) {
          final newAccessToken = payload['access_token'] as String?;
          final newRefreshToken = payload['refresh_token'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('[ApiClient] Token refresh failed: $e');
      await tokenStorage.clearTokens();
    }
    return false;
  }
}
