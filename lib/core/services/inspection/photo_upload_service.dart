import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../inspection_api_service.dart';

/// Photo Upload Service for Inspection Photos
/// Handles photo compression and upload with retry logic
/// Requirements: 5.10, 5.11, 5.12, 15.1-15.13
class PhotoUploadService {
  final InspectionApiService _apiService;

  // Configuration constants
  static const int maxWidth = 1920;
  static const int maxHeight = 1080;
  static const int targetFileSize = 500 * 1024; // 500KB in bytes
  static const int maxRetries = 3;
  static const int initialRetryDelayMs = 1000; // 1 second

  PhotoUploadService({InspectionApiService? apiService})
      : _apiService = apiService ?? InspectionApiService();

  /// Upload a photo with compression and retry logic
  /// Returns the photo URL on success
  Future<String> uploadPhoto(
    String inspectionId,
    String photoPath, {
    Function(double)? onProgress,
  }) async {
    // Compress the image first
    final compressedPath = await _compressImage(photoPath);

    // Upload with retry logic
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxRetries) {
      try {
        if (onProgress != null) {
          onProgress((attempt + 0.5) / (maxRetries + 1));
        }

        final response =
            await _apiService.uploadPhoto(inspectionId, compressedPath);

        if (response.isSuccess && response.data != null) {
          if (onProgress != null) {
            onProgress(1.0);
          }

          // Clean up temporary compressed file
          final compressedFile = File(compressedPath);
          if (await compressedFile.exists()) {
            await compressedFile.delete();
          }

          return response.data!;
        }

        throw Exception(response.error ?? 'Upload failed');
      } catch (e) {
        lastException = e as Exception;
        attempt++;

        if (attempt < maxRetries) {
          // Exponential backoff: wait 1s, 2s, 4s
          final delayMs = initialRetryDelayMs * (1 << (attempt - 1));
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    // Clean up on failure
    final compressedFile = File(compressedPath);
    if (await compressedFile.exists()) {
      await compressedFile.delete();
    }

    throw lastException ??
        Exception('Failed to upload photo after $maxRetries attempts');
  }

  /// Compress image to meet size and dimension requirements
  /// - Resize to max 1920x1080 while maintaining aspect ratio
  /// - Compress to target ~500KB file size
  Future<String> _compressImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file not found: $imagePath');
    }

    // Read the image
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate new dimensions maintaining aspect ratio
    int newWidth = image.width;
    int newHeight = image.height;

    if (newWidth > maxWidth || newHeight > maxHeight) {
      final widthRatio = maxWidth / newWidth;
      final heightRatio = maxHeight / newHeight;
      final ratio = widthRatio < heightRatio ? widthRatio : heightRatio;

      newWidth = (newWidth * ratio).round();
      newHeight = (newHeight * ratio).round();
    }

    // Resize image if needed
    final resized = newWidth != image.width || newHeight != image.height
        ? img.copyResize(image, width: newWidth, height: newHeight)
        : image;

    // Compress with quality adjustment to target file size
    int quality = 85;
    Uint8List? compressedBytes;

    // Try different quality levels to reach target size
    while (quality >= 50) {
      compressedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );

      if (compressedBytes.length <= targetFileSize || quality <= 50) {
        break;
      }

      // Reduce quality for next iteration
      quality -= 10;
    }

    // Save compressed image to temporary file
    final directory = file.parent;
    final fileName = file.uri.pathSegments.last;
    final nameWithoutExtension = fileName.split('.').first;
    final compressedPath =
        '${directory.path}/${nameWithoutExtension}_compressed.jpg';

    final compressedFile = File(compressedPath);
    await compressedFile.writeAsBytes(compressedBytes!);

    return compressedPath;
  }

  /// Get compressed image size in KB for validation
  Future<int> getCompressedSizeKB(String imagePath) async {
    final compressedPath = await _compressImage(imagePath);
    final file = File(compressedPath);
    final bytes = await file.length();

    // Clean up temporary file
    await file.delete();

    return (bytes / 1024).round();
  }
}
