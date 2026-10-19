import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/trip_model.dart';
import '../../../core/models/proof_of_delivery.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/repositories/transport_repository.dart';
import '../../../core/exceptions/transport_exceptions.dart';
import '../../../core/services/logistics_service.dart';
import '../../../core/services/order_service.dart';
import '../widgets/signature_pad_widget.dart';

/// Proof of Delivery Screen - Capture POD and complete delivery
/// 
/// Integrates:
/// - Photo capture with compression
/// - Signature capture with validation
/// - Recipient name input
/// - Backend POD submission
/// - Error handling and validation
class ProofOfDeliveryScreen extends StatefulWidget {
  final Trip delivery;
  final TransportRepository? repository;

  const ProofOfDeliveryScreen({
    super.key,
    required this.delivery,
    this.repository,
  });

  @override
  State<ProofOfDeliveryScreen> createState() => _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends State<ProofOfDeliveryScreen> {
  late final TransportRepository _repository;
  final _recipientNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  File? _photoFile;
  SignatureData? _signatureData;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? TransportRepository();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get destination from trip 
    final String destination = widget.delivery.deliveryLocation.isNotEmpty
        ? widget.delivery.deliveryLocation
        : 'Destination';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Proof of Delivery'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Complete Delivery',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture proof of delivery to complete this trip',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Delivery info card
            Card(
              elevation: 0,
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery #${widget.delivery.id.length >= 8 ? widget.delivery.id.substring(0, 8) : widget.delivery.id}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(destination, style: TextStyle(color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error display
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recipient name
            Text(
              'Recipient Name *',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _recipientNameController,
              decoration: const InputDecoration(
                hintText: 'Enter recipient full name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),

            // Photo capture
            Text(
              'Delivery Photo *',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPhotoCapture(),
            const SizedBox(height: 24),

            // Signature capture
            SignaturePadWidget(
              label: 'Receiver Signature *',
              onSignatureCaptured: (signatureData) {
                setState(() {
                  _signatureData = signatureData;
                  _error = null;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signature captured successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Notes
            Text(
              'Delivery Notes (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any additional notes about the delivery...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _completeDelivery,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: const Text('Complete Delivery'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCapture() {
    return InkWell(
      onTap: _isSubmitting ? null : _capturePhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
        child: _photoFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _photoFile!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to capture photo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    setState(() {
      _error = null;
    });

    try {
      // capturePhoto returns a String? (file path)
      final photoFile = await _repository.capturePhoto();
      
      if (photoFile != null) {
        setState(() {
          _photoFile = photoFile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } on PermissionDeniedException catch (e) {
      _showPermissionDialog(e.message);
    } catch (e) {
      setState(() {
        _error = 'Failed to capture photo: $e';
      });
    }
  }

  Future<void> _completeDelivery() async {
    // Validation
    final recipientName = _recipientNameController.text.trim();
    
    if (recipientName.isEmpty) {
      setState(() {
        _error = 'Please enter recipient name';
      });
      return;
    }

    if (_photoFile == null) {
      setState(() {
        _error = 'Please capture a delivery photo';
      });
      return;
    }

    if (_signatureData == null) {
      setState(() {
        _error = 'Please capture receiver signature';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Submit proof of delivery to backend
      final proof = await _repository.captureProofOfDelivery(
        jobId: widget.delivery.id,
        photoFile: _photoFile,
        signatureData: _signatureData!,
        recipientName: recipientName,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      if (proof != null && mounted) {
        // Also mark trip as delivered in local provider
        final transportProvider = Provider.of<TransportProvider>(context, listen: false);
        await transportProvider.markTripDelivered(
          widget.delivery.id,
          note: _notesController.text.trim(),
        );

        // Also update legacy logistics and orders boxes if open
        try {
          if (Hive.isBoxOpen('logistics')) {
            await LogisticsService().updateLogisticsStatus(widget.delivery.id, 'delivered');
          }
          if (Hive.isBoxOpen('orders')) {
            await OrderService().updateOrderStatus(widget.delivery.transportRequestId, 'delivered');
          }
        } catch (_) {}

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              icon: Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 64,
              ),
              title: Text('Delivery Completed!', style: TextStyle(color: AppColors.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Great job! Your earnings have been updated.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Text(
                          'POD ID: ${proof.id.length >= 8 ? proof.id.substring(0, 8) : proof.id}',
                          style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    // Pop both dialog and POD screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
      }
    } on PhotoCaptureException catch (e) {
      setState(() {
        _error = 'Photo error: ${e.message}';
      });
    } on SignatureException catch (e) {
      setState(() {
        _error = 'Signature error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to complete delivery: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              // Try to open app settings
              // Note: This requires platform-specific implementation
              setState(() {
                _error = 'Please enable camera permission in app settings';
              });
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
