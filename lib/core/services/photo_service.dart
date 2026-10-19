import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../exceptions/transport_exceptions.dart';

/// Photo Service
/// Handles camera access, photo capture, and compression
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Open settings if permission permanently denied
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Capture photo from camera
  Future<File?> capturePhoto() async {
    try {
      // Check permission
      if (!await hasCameraPermission()) {
        final granted = await requestCameraPermission();
        if (!granted) {
          throw PermissionDeniedException(
            permission: 'camera',
            message: 'Camera permission is required to capture proof of delivery',
          );
        }
      }

      // Capture photo
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) {
        return null; // User cancelled
      }

      return File(photo.path);
    } catch (e) {
      if (e is PermissionDeniedException) {
        rethrow;
      }
      throw PhotoCaptureException('Failed to capture photo: $e');
    }
  }

  /// Pick photo from gallery (alternative option)
  Future<File?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) {
        return null;
      }

      return File(photo.path);
    } catch (e) {
      throw PhotoCaptureException('Failed to pick photo: $e');
    }
  }

  /// Compress photo to target size
  Future<File> compressPhoto(File originalFile, {int maxSizeKB = 1024}) async {
    try {
      // Read original image
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw PhotoCaptureException('Failed to decode image');
      }

      // Resize if needed
      img.Image resized = image;
      if (image.width > 1920 || image.height > 1080) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1080 : null,
        );
      }

      // Compress with quality adjustment
      int quality = 85;
      List<int> compressed = img.encodeJpg(resized, quality: quality);

      // Reduce quality if still too large
      while (compressed.length > maxSizeKB * 1024 && quality > 20) {
        quality -= 10;
        compressed = img.encodeJpg(resized, quality: quality);
      }

      // Save compressed image
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedPath = path.join(
        tempDir.path,
        'compressed_${timestamp}_q$quality.jpg',
      );

      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressed);

      return compressedFile;
    } catch (e) {
      throw PhotoCaptureException('Failed to compress photo: $e');
    }
  }

  /// Get photo file size in KB
  Future<double> getFileSizeKB(File file) async {
    final bytes = await file.length();
    return bytes / 1024;
  }

  /// Validate photo file
  Future<bool> validatePhoto(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Check file size (max 5MB)
      final sizeKB = await getFileSizeKB(file);
      if (sizeKB > 5120) {
        return false;
      }

      // Check if it's a valid image
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete temp photo file
  Future<void> deletePhoto(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }

  /// Capture and compress photo in one operation
  Future<File?> captureAndCompressPhoto() async {
    final photo = await capturePhoto();
    if (photo == null) return null;

    try {
      // Check if compression needed
      final sizeKB = await getFileSizeKB(photo);
      if (sizeKB <= 1024) {
        return photo; // Already small enough
      }

      // Compress
      final compressed = await compressPhoto(photo);
      
      // Delete original
      await deletePhoto(photo);
      
      return compressed;
    } catch (e) {
      // If compression fails, return original
      return photo;
    }
  }
}
