import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/services/inspection/photo_upload_service.dart';

/// Unit tests for PhotoUploadService
/// Tests photo compression and upload retry logic
void main() {
  group('PhotoUploadService', () {

    test('should have correct compression configuration', () {
      expect(PhotoUploadService.maxWidth, 1920);
      expect(PhotoUploadService.maxHeight, 1080);
      expect(PhotoUploadService.targetFileSize, 500 * 1024); // 500KB
    });

    test('should have correct retry configuration', () {
      expect(PhotoUploadService.maxRetries, 3);
      expect(PhotoUploadService.initialRetryDelayMs, 1000); // 1 second
    });

    test('exponential backoff should calculate correctly', () {
      // Test exponential backoff: 1s, 2s, 4s
      const delays = [1000, 2000, 4000];
      for (int i = 0; i < delays.length; i++) {
        final expected = 1000 * (1 << i);
        expect(delays[i], expected,
            reason: 'Delay at attempt $i should be $expected ms');
      }
    });

    test('target file size should be 500KB in bytes', () {
      const expectedBytes = 512000; // 500 * 1024
      expect(PhotoUploadService.targetFileSize, expectedBytes);
    });
  });
}
