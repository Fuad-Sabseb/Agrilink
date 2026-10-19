import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/proof_of_delivery.dart';
import '../../../core/services/signature_service.dart';

/// Signature Pad Widget - Capture and validate digital signatures
/// 
/// Features:
/// - Real-time signature drawing with customizable pen
/// - Clear/redo functionality
/// - Empty signature detection
/// - PNG export with transparent background
/// - Validation feedback
class SignaturePadWidget extends StatefulWidget {
  final Function(SignatureData) onSignatureCaptured;
  final Color backgroundColor;
  final Color penColor;
  final double penStrokeWidth;
  final String? label;

  const SignaturePadWidget({
    super.key,
    required this.onSignatureCaptured,
    this.backgroundColor = Colors.white,
    this.penColor = Colors.black,
    this.penStrokeWidth = 3.0,
    this.label,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  late final SignatureController _controller;
  final SignatureService _signatureService = SignatureService();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.penStrokeWidth,
      penColor: widget.penColor,
      exportBackgroundColor: widget.backgroundColor,
    );
    
    // Listen for signature changes to clear errors
    _controller.addListener(_onSignatureChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSignatureChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSignatureChanged() {
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  Future<void> _captureSignature() async {
    if (_controller.isEmpty) {
      setState(() {
        _error = 'Please provide a signature';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final signatureData = await _signatureService.exportSignature(
        repaintBoundaryKey: _repaintBoundaryKey,
      );

      // Validate signature is not empty
      final isValid = _signatureService.validateSignature(
        signatureData,
      );

      if (!isValid) {
        setState(() {
          _error = 'Signature appears to be empty';
          _isProcessing = false;
        });
        return;
      }

      widget.onSignatureCaptured(signatureData);
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to capture signature: $e';
          _isProcessing = false;
        });
      }
    }
  }

  void _clearSignature() {
    _controller.clear();
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Signature pad
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _error != null ? AppColors.error : AppColors.border,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Signature(
                controller: _controller,
                backgroundColor: widget.backgroundColor,
                height: 200,
              ),
            ),
          ),
        ),
        
        // Error message
        if (_error != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _clearSignature,
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
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _captureSignature,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isProcessing ? 'Processing...' : 'Confirm'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        // Helper text
        const SizedBox(height: 8),
        Text(
          'Draw your signature in the box above',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
