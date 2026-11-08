import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/services/image_compression_service.dart';

class MediaRemoteDataSource {
  final ApiClient _client;
  final IImageCompressionService _compressionService;

  MediaRemoteDataSource(
    this._client, {
    IImageCompressionService? compressionService,
  }) : _compressionService = compressionService ?? const ImageCompressionService();

  /// Uploads photo directly to Cloudinary using backend-signed parameters
  /// per Section 7 Step 3 of FLUTTER_INTEGRATION_GUIDE.md.
  /// Automatically optimizes and compresses the image before upload.
  Future<Map<String, dynamic>?> uploadToCloudinary({
    required String photoPath,
    required Map<String, dynamic> uploadParams,
    void Function(String step)? onProgress,
  }) async {
    try {
      final uploadUrl = uploadParams['upload_url']?.toString();
      if (uploadUrl == null || uploadUrl.isEmpty) {
        return null;
      }

      final file = File(photoPath);
      final exists = await file.exists();
      if (!exists) {
        throw Exception('File does not exist at $photoPath');
      }

      // 1. Compress image through compression layer before upload to save upload time and cloud bandwidth
      onProgress?.call('Optimizing image for upload...');
      final compressedResult = await _compressionService.compressImage(photoPath);
      final uploadFile = compressedResult.file;
      final uploadPath = uploadFile.path;

      // 2. Prepare multipart upload with optimized image
      final fileName = uploadPath.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(uploadPath, filename: fileName),
        'api_key': uploadParams['api_key'],
        'timestamp': uploadParams['timestamp'],
        'folder': uploadParams['folder'],
        'public_id': uploadParams['public_id'],
        'signature': uploadParams['signature'],
      });

      final uploadDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      final sizeKb = (compressedResult.compressedSizeBytes / 1024).toStringAsFixed(0);
      onProgress?.call('Uploading optimized image ($sizeKb KB)...');

      final cdnResponse = await uploadDio.post(uploadUrl, data: formData);
      if (cdnResponse.statusCode == 200 && cdnResponse.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(cdnResponse.data as Map);
        data['local_compressed_path'] = uploadPath;
        data['compressed_bytes'] = compressedResult.compressedSizeBytes;
        return data;
      }
    } catch (e) {
      // If Cloudinary upload fails (e.g. offline or mock credentials in local backend),
      // we log and return null.
      debugPrint('[MediaRemoteDataSource] Cloudinary upload failed: $e');
    }
    return null;
  }

  /// Confirms Cloudinary upload with Inzar backend
  /// per Section 7 Step 4 of FLUTTER_INTEGRATION_GUIDE.md.
  Future<ApiResponse<Map<String, dynamic>>> confirmMediaUpload({
    required String incidentId,
    required String cloudinaryPublicId,
    required String secureUrl,
    int width = 1920,
    int height = 1080,
    int bytes = 500000,
    String format = 'jpg',
  }) async {
    try {
      final response = await _client.dio.post(
        '/incidents/$incidentId/media/confirm',
        data: {
          'cloudinary_public_id': cloudinaryPublicId,
          'secure_url': secureUrl,
          'width': width,
          'height': height,
          'bytes': bytes,
          'format': format,
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
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

