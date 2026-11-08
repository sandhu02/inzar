import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../domain/entities/incident_category.dart';

class CategoryRemoteDataSource {
  final ApiClient _client;

  CategoryRemoteDataSource(this._client);

  Future<ApiResponse<List<CategoryData>>> fetchCategories() async {
    try {
      final response = await _client.dio.get('/categories');
      return ApiResponse.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <CategoryData>[];
        },
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

