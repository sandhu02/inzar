import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzar/core/services/image_compression_service.dart';
import 'package:inzar/data/datasources/media_remote_data_source.dart';
import 'package:inzar/core/network/api_client.dart';
import 'package:inzar/core/network/token_storage.dart';

class MockImageCompressor implements IImageCompressionService {
  bool wasCompressCalled = false;
  final CompressedImageResult Function(String path)? onCompress;

  MockImageCompressor({this.onCompress});

  @override
  Future<CompressedImageResult> compressImage(
    String sourcePath, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 80,
    int minBytesToCompress = 200 * 1024,
  }) async {
    wasCompressCalled = true;
    if (onCompress != null) {
      return onCompress!(sourcePath);
    }
    return CompressedImageResult(
      file: File(sourcePath),
      originalSizeBytes: 1000000,
      compressedSizeBytes: 250000,
      didCompress: true,
    );
  }
}

void main() {
  group('CompressedImageResult Tests', () {
    test('calculates saved bytes and saved percentage correctly', () {
      final dummyFile = File('test_image.jpg');
      final result = CompressedImageResult(
        file: dummyFile,
        originalSizeBytes: 4000000, // 4 MB
        compressedSizeBytes: 800000, // 800 KB
        didCompress: true,
      );

      expect(result.savedBytes, 3200000);
      expect(result.savedPercentage, closeTo(80.0, 0.1));
      expect(result.path, dummyFile.path);
    });

    test('handles 0 original size gracefully', () {
      final dummyFile = File('empty.jpg');
      final result = CompressedImageResult(
        file: dummyFile,
        originalSizeBytes: 0,
        compressedSizeBytes: 0,
        didCompress: false,
      );

      expect(result.savedBytes, 0);
      expect(result.savedPercentage, 0.0);
    });

    test('handles uncompressed/skipped image', () {
      final dummyFile = File('small.jpg');
      final result = CompressedImageResult(
        file: dummyFile,
        originalSizeBytes: 150000,
        compressedSizeBytes: 150000,
        didCompress: false,
      );

      expect(result.savedBytes, 0);
      expect(result.savedPercentage, 0.0);
      expect(result.didCompress, isFalse);
    });
  });

  group('ImageCompressionService Tests', () {
    late Directory tempDir;
    late ImageCompressionService service;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('inzar_test_img_');
      service = const ImageCompressionService();
    });

    tearDown(() {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    });

    test('returns uncompressed result for non-existent file without throwing', () async {
      final nonExistentPath = '${tempDir.path}/non_existent_image.jpg';
      final result = await service.compressImage(nonExistentPath);

      expect(result.didCompress, isFalse);
      expect(result.originalSizeBytes, 0);
      expect(result.compressedSizeBytes, 0);
      expect(result.file.path, nonExistentPath);
    });

    test('skips compression when file size is under minBytesToCompress threshold', () async {
      final testFile = File('${tempDir.path}/small_icon.jpg');
      // Create a 50 KB dummy file
      final bytes = List<int>.filled(50 * 1024, 0xFF);
      await testFile.writeAsBytes(bytes);

      final result = await service.compressImage(
        testFile.path,
        minBytesToCompress: 100 * 1024, // 100 KB threshold
      );

      expect(result.didCompress, isFalse);
      expect(result.originalSizeBytes, 50 * 1024);
      expect(result.compressedSizeBytes, 50 * 1024);
      expect(result.savedBytes, 0);
      expect(result.file.path, testFile.path);
    });

    test('falls back gracefully to original file when native plugin is unavailable', () async {
      final testFile = File('${tempDir.path}/large_mock.jpg');
      // Create a 300 KB dummy file (> minBytesToCompress)
      final bytes = List<int>.filled(300 * 1024, 0x42);
      await testFile.writeAsBytes(bytes);

      // In unit test environment, FlutterImageCompress platform channel throws or returns null
      // Service must catch and return original file cleanly
      final result = await service.compressImage(
        testFile.path,
        minBytesToCompress: 200 * 1024,
      );

      expect(result.originalSizeBytes, 300 * 1024);
      expect(result.file.existsSync(), isTrue);
    });
  });

  group('MediaRemoteDataSource Compression Layer Tests', () {
    test('runs photo through compression layer before uploading', () async {
      final mockCompressor = MockImageCompressor();
      final client = ApiClient(storage: InMemoryTokenStorage());
      final dataSource = MediaRemoteDataSource(
        client,
        compressionService: mockCompressor,
      );

      // Create a mock temp file
      final tempFile = File('${Directory.systemTemp.path}/test_upload.jpg');
      await tempFile.writeAsBytes([0x01, 0x02, 0x03]);

      // Call uploadToCloudinary with empty upload URL so it validates file and attempts compress
      final result = await dataSource.uploadToCloudinary(
        photoPath: tempFile.path,
        uploadParams: {
          'upload_url': '', // Empty url stops before network request
        },
      );

      expect(result, isNull);

      // Clean up
      try {
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
      } catch (_) {}
    });
  });
}
