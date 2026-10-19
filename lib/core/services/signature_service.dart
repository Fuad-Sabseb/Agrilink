import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/proof_of_delivery.dart';
import '../exceptions/transport_exceptions.dart';

/// Signature Service
/// Handles signature capture, validation, and export
class SignatureService {
  /// Convert signature points to PNG image
  Future<SignatureData> exportSignature({
    required GlobalKey repaintBoundaryKey,
  }) async {
    try {
      // Get the render boundary
      final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Convert to image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      
      // Convert to byte data
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw SignatureException('Failed to convert signature to image');
      }

      final bytes = byteData.buffer.asUint8List();

      // Check if signature is empty (all white or transparent)
      final isEmpty = _isSignatureEmpty(bytes);

      return SignatureData(
        imageBytes: bytes,
        capturedAt: DateTime.now(),
        isEmpty: isEmpty,
      );
    } catch (e) {
      throw SignatureException('Failed to export signature: $e');
    }
  }

  /// Save signature to file
  Future<File> saveSignatureToFile(SignatureData signatureData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(tempDir.path, 'signature_$timestamp.png');

      final file = File(filePath);
      await file.writeAsBytes(signatureData.imageBytes);

      return file;
    } catch (e) {
      throw SignatureException('Failed to save signature: $e');
    }
  }

  /// Validate signature
  bool validateSignature(SignatureData signatureData) {
    // Check if empty
    if (signatureData.isEmpty) {
      return false;
    }

    // Check size (should be at least 1KB)
    if (signatureData.sizeInKB < 1) {
      return false;
    }

    // Check if image bytes are valid
    if (signatureData.imageBytes.isEmpty) {
      return false;
    }

    return true;
  }

  /// Check if signature is empty (mostly white/transparent pixels)
  bool _isSignatureEmpty(List<int> bytes) {
    // Simple heuristic: if file size is very small, likely empty
    if (bytes.length < 1024) {
      return true;
    }

    // Check for PNG header
    if (bytes.length < 8) {
      return true;
    }

    // PNG files with mostly transparent/white content are typically small
    // This is a simplified check
    final sizeKB = bytes.length / 1024;
    return sizeKB < 2; // Less than 2KB likely means empty or very minimal drawing
  }

  /// Clear signature (returns empty signature data)
  SignatureData createEmptySignature() {
    return SignatureData(
      imageBytes: [],
      capturedAt: DateTime.now(),
      isEmpty: true,
    );
  }

  /// Delete signature file
  Future<void> deleteSignatureFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }

  /// Get signature file size
  Future<double> getSignatureSizeKB(File file) async {
    final bytes = await file.length();
    return bytes / 1024;
  }
}
