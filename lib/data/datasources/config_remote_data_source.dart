import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/public_config_dto.dart';
import '../../domain/entities/app_public_config.dart';

class ConfigRemoteDataSource {
  final ApiClient _client;

  ConfigRemoteDataSource(this._client);

  Future<ApiResponse<AppPublicConfig>> fetchPublicConfig() async {
    try {
      final response = await _client.dio.get('/config');
      return ApiResponse.fromJson(
        response.data,
        (json) => PublicConfigDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        status: false,
        success: false,
        statusCode: e.response?.statusCode ?? 500,
        error: ApiError.fromJson(e.response?.data),
      );
    }
  }
}

