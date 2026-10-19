import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../core/theme/colors.dart';

/// Signature Capture Dialog
/// Allows bureau officers to capture digital signatures for inspection completion
/// Requirements: 6.2-6.4, 16.1-16.12
class SignatureCaptureDialog extends StatefulWidget {
  const SignatureCaptureDialog({super.key});

  @override
  State<SignatureCaptureDialog> createState() => _SignatureCaptureDialogState();
}

class _SignatureCaptureDialogState extends State<SignatureCaptureDialog> {
  late final SignatureController _signatureController;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );

    _signatureController.addListener(() {
      setState(() {
        _hasSignature = _signatureController.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildSignatureCanvas()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.draw, color: Colors.white),
          const SizedBox(width: 12),
          const Text(
            'Digital Signature',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureCanvas() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Signature(
          controller: _signatureController,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign above to complete the inspection',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleClear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _hasSignature ? _handleSave : null,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Save Signature',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: AppColors.disabled,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleClear() {
    _signatureController.clear();
  }

  Future<void> _handleSave() async {
    if (!_hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature first'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }

    try {
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      
      if (signatureBytes == null) {
        throw Exception('Failed to capture signature');
      }

      // Convert to base64
      final String base64Signature = base64Encode(signatureBytes);

      if (!mounted) return;
      Navigator.of(context).pop(base64Signature);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing signature: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
