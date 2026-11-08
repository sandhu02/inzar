import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../domain/entities/alert_preferences.dart';
import '../models/alert_preferences_dto.dart';

class AlertRemoteDataSource {
  final ApiClient _client;

  AlertRemoteDataSource(this._client);

  Future<ApiResponse<AlertPreferences>> fetchAlertPreferences() async {
    try {
      final response = await _client.dio.get('/me/alert-preferences');
      return ApiResponse.fromJson(
        response.data,
        (json) => AlertPreferencesDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _mapError<AlertPreferences>(e);
    }
  }

  Future<ApiResponse<AlertPreferences>> updateAlertPreferences(AlertPreferences preferences) async {
    try {
      final response = await _client.dio.put(
        '/me/alert-preferences',
        data: AlertPreferencesDto.toJson(preferences),
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => AlertPreferencesDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _mapError<AlertPreferences>(e);
    }
  }

  Future<ApiResponse<void>> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    try {
      final response = await _client.dio.post(
        '/me/devices',
        data: {'token': token, 'platform': platform},
      );
      return ApiResponse(status: true, success: true, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<void>> unregisterDeviceToken(String token) async {
    try {
      final response = await _client.dio.delete('/me/devices/$token');
      return ApiResponse(status: true, success: true, statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  ApiResponse<T> _mapError<T>(DioException e) {
    return ApiResponse<T>(
      status: false,
      success: false,
      statusCode: e.response?.statusCode ?? 500,
      error: ApiError.fromJson(e.response?.data),
    );
  }
}

