import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Structured result of an image compression operation.
class CompressedImageResult {
  /// The resulting file (compressed file, or original if compression was skipped or failed).
  final File file;

  /// Original file size in bytes before compression.
  final int originalSizeBytes;

  /// File size in bytes after compression (or same as original if skipped).
  final int compressedSizeBytes;

  /// Output width in pixels (if known).
  final int? width;

  /// Output height in pixels (if known).
  final int? height;

  /// Whether compression was performed and reduced the file size.
  final bool didCompress;

  const CompressedImageResult({
    required this.file,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    this.width,
    this.height,
    this.didCompress = false,
  });

  /// Bytes saved through compression.
  int get savedBytes => originalSizeBytes - compressedSizeBytes;

  /// Percentage of file size reduced (e.g. 78.5%).
  double get savedPercentage {
    if (originalSizeBytes <= 0) return 0.0;
    final ratio = (savedBytes / originalSizeBytes) * 100.0;
    return ratio > 0 ? ratio : 0.0;
  }

  /// Absolute path to the file to be uploaded.
  String get path => file.path;

  @override
  String toString() =>
      'CompressedImageResult(path: $path, didCompress: $didCompress, '
      'original: ${(originalSizeBytes / 1024).toStringAsFixed(1)} KB, '
      'compressed: ${(compressedSizeBytes / 1024).toStringAsFixed(1)} KB, '
      'saved: ${savedPercentage.toStringAsFixed(1)}%)';
}

/// Abstract contract for image compression service.
abstract class IImageCompressionService {
  /// Compresses the image at [sourcePath] before upload.
  ///
  /// - [maxWidth] and [maxHeight] constrain the image dimensions while preserving aspect ratio.
  /// - [quality] is the JPEG quality (0-100), with 75-80 being the sweet spot for mobile photos.
  /// - [minBytesToCompress] skips compression if the image is already small (e.g., < 200 KB).
  Future<CompressedImageResult> compressImage(
    String sourcePath, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 80,
    int minBytesToCompress = 200 * 1024,
  });
}

/// Production implementation of [IImageCompressionService] using [FlutterImageCompress]
/// with automatic EXIF orientation correction and graceful fallback.
class ImageCompressionService implements IImageCompressionService {
  const ImageCompressionService();

  @override
  Future<CompressedImageResult> compressImage(
    String sourcePath, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 80,
    int minBytesToCompress = 200 * 1024,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      debugPrint('[ImageCompressor] Source file does not exist: $sourcePath');
      return CompressedImageResult(
        file: sourceFile,
        originalSizeBytes: 0,
        compressedSizeBytes: 0,
        didCompress: false,
      );
    }

    final int originalSize;
    try {
      originalSize = await sourceFile.length();
    } catch (e) {
      debugPrint('[ImageCompressor] Failed to read source file length: $e');
      return CompressedImageResult(
        file: sourceFile,
        originalSizeBytes: 0,
        compressedSizeBytes: 0,
        didCompress: false,
      );
    }

    // Skip compression if the image is already compact
    if (originalSize < minBytesToCompress) {
      debugPrint(
        '[ImageCompressor] Image is already small (${(originalSize / 1024).toStringAsFixed(1)} KB < ${(minBytesToCompress / 1024).toStringAsFixed(0)} KB). Skipping compression.',
      );
      return CompressedImageResult(
        file: sourceFile,
        originalSizeBytes: originalSize,
        compressedSizeBytes: originalSize,
        didCompress: false,
      );
    }

    try {
      final targetPath = await _resolveTargetPath(sourcePath);

      debugPrint(
        '[ImageCompressor] Starting compression: ${p.basename(sourcePath)} '
        '(${(originalSize / 1024).toStringAsFixed(1)} KB) -> target max ${maxWidth}x$maxHeight @ quality $quality',
      );

      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: true,
      );

      if (compressedXFile == null) {
        debugPrint('[ImageCompressor] Compression returned null, falling back to original.');
        return CompressedImageResult(
          file: sourceFile,
          originalSizeBytes: originalSize,
          compressedSizeBytes: originalSize,
          didCompress: false,
        );
      }

      final compressedFile = File(compressedXFile.path);
      final compressedSize = await compressedFile.length();

      // Only use compressed file if it is actually smaller than the original
      if (compressedSize > 0 && compressedSize < originalSize) {
        final result = CompressedImageResult(
          file: compressedFile,
          originalSizeBytes: originalSize,
          compressedSizeBytes: compressedSize,
          didCompress: true,
        );

        debugPrint(
          '[ImageCompressor] Compression successful! '
          'Reduced from ${(originalSize / 1024).toStringAsFixed(1)} KB to '
          '${(compressedSize / 1024).toStringAsFixed(1)} KB '
          '(${result.savedPercentage.toStringAsFixed(1)}% cloud space saved).',
        );

        return result;
      } else {
        debugPrint(
          '[ImageCompressor] Compressed file (${(compressedSize / 1024).toStringAsFixed(1)} KB) was not smaller than original, using original.',
        );
        // Clean up unneeded compressed file if created
        try {
          if (await compressedFile.exists()) {
            await compressedFile.delete();
          }
        } catch (_) {}

        return CompressedImageResult(
          file: sourceFile,
          originalSizeBytes: originalSize,
          compressedSizeBytes: originalSize,
          didCompress: false,
        );
      }
    } catch (e) {
      debugPrint('[ImageCompressor] Compression failed with exception ($e). Falling back to original file.');
      return CompressedImageResult(
        file: sourceFile,
        originalSizeBytes: originalSize,
        compressedSizeBytes: originalSize,
        didCompress: false,
      );
    }
  }

  /// Determines a unique destination path inside the app cache/temporary directory.
  Future<String> _resolveTargetPath(String sourcePath) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = p.extension(sourcePath).toLowerCase();
    final ext = (extension == '.png' || extension == '.webp' || extension == '.jpeg' || extension == '.jpg')
        ? '.jpg'
        : (extension.isNotEmpty ? extension : '.jpg');
    final baseName = p.basenameWithoutExtension(sourcePath);
    final targetFileName = 'inzar_opt_${timestamp}_$baseName$ext';

    try {
      final cacheDir = await getTemporaryDirectory();
      return p.join(cacheDir.path, targetFileName);
    } catch (_) {
      final tempDir = Directory.systemTemp;
      return p.join(tempDir.path, targetFileName);
    }
  }
}

