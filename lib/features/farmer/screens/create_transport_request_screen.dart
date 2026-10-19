import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/models/crop_plot_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Create Transport Request Screen
class CreateTransportRequestScreen extends StatefulWidget {
  const CreateTransportRequestScreen({super.key});

  @override
  State<CreateTransportRequestScreen> createState() =>
      _CreateTransportRequestScreenState();
}

class _CreateTransportRequestScreenState
    extends State<CreateTransportRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SessionService();
  final _quantityController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _instructionsController = TextEditingController();

  CropType? _selectedCropType;
  DateTime? _requestedPickupDate;
  bool _requiresRefrigeration = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _pickupLocationController.dispose();
    _deliveryLocationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(days: 1));
    final lastDate = now.add(const Duration(days: 90));

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _requestedPickupDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCropType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select crop type'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_requestedPickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select pickup date'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final farmerId = _sessionService.currentUserId;
    if (farmerId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final transportProvider = context.read<TransportProvider>();
      
      await transportProvider.createTransportRequest(
        farmerId: farmerId,
        cropType: _selectedCropType!,
        quantityKg: double.parse(_quantityController.text.trim()),
        pickupLocation: _pickupLocationController.text.trim(),
        deliveryLocation: _deliveryLocationController.text.trim(),
        requestedPickupDate: _requestedPickupDate!,
        requiresRefrigeration: _requiresRefrigeration,
        specialInstructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transport request created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          'Request Transport',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<CropType>(
              initialValue: _selectedCropType,
              decoration: InputDecoration(
                labelText: 'Crop Type',
                hintText: 'Select crop type',
                prefixIcon: const Icon(Icons.grass),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: CropType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getCropTypeName(type)),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedCropType = value),
              validator: (value) {
                if (value == null) return 'Please select crop type';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity in kg',
                prefixIcon: const Icon(Icons.scale),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = double.tryParse(value.trim());
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid quantity greater than 0';
                }
                if (quantity > 50000) {
                  return 'Maximum quantity is 50,000 kg';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pickupLocationController,
              decoration: InputDecoration(
                labelText: 'Pickup Location',
                hintText: 'Enter pickup location',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter pickup location';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deliveryLocationController,
              decoration: InputDecoration(
                labelText: 'Delivery Location',
                hintText: 'Enter delivery location',
                prefixIcon: const Icon(Icons.pin_drop),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter delivery location';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _isSubmitting ? null : _selectPickupDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Pickup Date',
                  hintText: 'Select pickup date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _requestedPickupDate != null
                      ? '${_requestedPickupDate!.day}/${_requestedPickupDate!.month}/${_requestedPickupDate!.year}'
                      : 'Tap to select date',
                  style: _requestedPickupDate != null
                      ? AppTypography.bodyMedium
                      : AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _requiresRefrigeration,
              onChanged: _isSubmitting
                  ? null
                  : (value) =>
                      setState(() => _requiresRefrigeration = value ?? false),
              title: const Text('Requires Refrigeration'),
              subtitle: const Text('Check if produce needs cold storage'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: InputDecoration(
                labelText: 'Special Instructions (Optional)',
                hintText: 'Enter any special instructions',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Create Request',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCropTypeName(CropType type) {
    switch (type) {
      case CropType.teff:
        return 'Teff';
      case CropType.wheat:
        return 'Wheat';
      case CropType.barley:
        return 'Barley';
      case CropType.maize:
        return 'Maize';
      case CropType.sorghum:
        return 'Sorghum';
      case CropType.beans:
        return 'Beans';
      case CropType.potato:
        return 'Potato';
      case CropType.coffee:
        return 'Coffee';
      case CropType.other:
        return 'Other';
    }
  }
}
