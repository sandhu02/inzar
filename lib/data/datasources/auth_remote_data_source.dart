import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_dto.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  Future<ApiResponse<UserProfile>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _client.dio.post(
        '/auth/signup',
        data: {
          'email': email,
          'password': password,
          if (displayName != null && displayName.isNotEmpty)
            'display_name': displayName,
        },
      );

      return await _handleTokenResponse(
        response.data,
        signInMethod: 'Email',
        allowUnverified: true,
      );
    } on DioException catch (e) {
      return _mapError<UserProfile>(e);
    }
  }

  Future<ApiResponse<UserProfile>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return await _handleTokenResponse(response.data, signInMethod: 'Email');
    } on DioException catch (e) {
      return _mapError<UserProfile>(e);
    }
  }

  Future<ApiResponse<UserProfile>> googleLogin({
    required String idToken,
  }) async {
    try {
      final response = await _client.dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      return await _handleTokenResponse(response.data, signInMethod: 'Google');
    } on DioException catch (e) {
      return _mapError<UserProfile>(e);
    }
  }

  Future<ApiResponse<UserProfile>> getMe() async {
    try {
      final response = await _client.dio.get('/me');
      return ApiResponse.fromJson(
        response.data,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _mapError<UserProfile>(e);
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final refreshToken = await _client.tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _client.dio.post(
          '/auth/logout',
          data: {'refresh_token': refreshToken},
        );
      }
      await _client.tokenStorage.clearTokens();
      return ApiResponse(status: true, success: true, statusCode: 200);
    } on DioException catch (e) {
      await _client.tokenStorage.clearTokens();
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<void>> deleteAccount() async {
    try {
      await _client.dio.delete('/me');
      await _client.tokenStorage.clearTokens();
      return ApiResponse(status: true, success: true, statusCode: 200);
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<void>> verifyEmail(String token) async {
    try {
      final response = await _client.dio.post(
        '/auth/verify-email',
        data: {'token': token},
      );
      return ApiResponse(
        status: true,
        success: true,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<void>> resendVerification(String email) async {
    try {
      final response = await _client.dio.post(
        '/auth/resend-verification',
        data: {'email': email},
      );
      return ApiResponse(
        status: true,
        success: true,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _client.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return ApiResponse(
        status: true,
        success: true,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _client.dio.post(
        '/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );
      return ApiResponse(
        status: true,
        success: true,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _mapError<void>(e);
    }
  }

  Future<ApiResponse<UserProfile>> _handleTokenResponse(
    dynamic data, {
    required String signInMethod,
    bool allowUnverified = false,
  }) async {
    if (data is Map<String, dynamic> &&
        (data['success'] == false || data['status'] == false)) {
      return ApiResponse(
        status: false,
        success: false,
        statusCode: data['status_code'] as int? ?? 400,
        error: ApiError.fromJson(data['error'] ?? data['message']),
      );
    }

    final payload = (data is Map<String, dynamic> && data.containsKey('data'))
        ? data['data']
        : data;

    if (payload is Map<String, dynamic>) {
      final tokens = payload['tokens'];
      final accessToken =
          payload['access_token'] ??
          (tokens is Map ? tokens['access_token'] : null);
      final refreshToken =
          payload['refresh_token'] ??
          (tokens is Map ? tokens['refresh_token'] : null);
      final userJson = payload['user'] is Map<String, dynamic>
          ? payload['user'] as Map<String, dynamic>
          : payload;

      final user = UserDto.fromJson(userJson, signInMethod: signInMethod);
      if (!user.isEmailVerified && !allowUnverified) {
        return ApiResponse(
          status: false,
          success: false,
          statusCode: 403,
          error: ApiError(
            code: 'email_not_verified',
            message: 'Please verify your email before signing in.',
          ),
        );
      }

      if (user.isEmailVerified) {
        if (accessToken == null ||
            accessToken.toString().isEmpty ||
            refreshToken == null ||
            refreshToken.toString().isEmpty) {
          return ApiResponse(
            status: false,
            success: false,
            statusCode: 500,
            error: ApiError(
              code: 'invalid_response',
              message: 'The server did not return valid session tokens.',
            ),
          );
        }
        await _client.tokenStorage.saveTokens(
          accessToken: accessToken.toString(),
          refreshToken: refreshToken.toString(),
        );
      }

      return ApiResponse(
        status: true,
        success: true,
        statusCode: 200,
        data: user,
      );
    }

    return ApiResponse(
      status: false,
      success: false,
      statusCode: 500,
      error: ApiError(
        code: 'invalid_response',
        message: 'Unexpected server response structure',
      ),
    );
  }

  ApiResponse<T> _mapError<T>(DioException e) {
    return ApiResponse<T>(
      status: false,
      success: false,
      statusCode: e.response?.statusCode ?? 500,
      error: e.response == null
          ? ApiError(
              code: 'network_error',
              message: e.message ?? 'Could not connect to the server.',
            )
          : ApiError.fromJson(e.response?.data),
    );
  }
}
