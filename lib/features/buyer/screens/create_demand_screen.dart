import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/buyer_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/crop_plot_model.dart';

/// Create Demand Screen
/// 8-field form for creating a new buying demand
class CreateDemandScreen extends StatefulWidget {
  const CreateDemandScreen({super.key});

  @override
  State<CreateDemandScreen> createState() => _CreateDemandScreenState();
}

class _CreateDemandScreenState extends State<CreateDemandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SessionService();
  final _minQuantityController = TextEditingController();
  final _maxQuantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  CropType? _selectedCropType;
  QualityGrade? _selectedPreferredGrade;
  List<QualityGrade> _selectedAcceptedGrades = [];
  DateTime? _selectedExpiryDate;
  bool _transportProvided = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _minQuantityController.dispose();
    _maxQuantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(hours: 1));
    final lastDate = now.add(const Duration(days: 90));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 7)),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  void _showAcceptedGradesDialog() {
    final tempSelected = List<QualityGrade>.from(_selectedAcceptedGrades);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Accepted Quality Grades'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: QualityGrade.values.map((grade) {
                final isSelected = tempSelected.contains(grade);
                return CheckboxListTile(
                  title: Text(_getGradeDisplayName(grade)),
                  value: isSelected,
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        tempSelected.add(grade);
                      } else {
                        tempSelected.remove(grade);
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedAcceptedGrades = tempSelected);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCropType == null) {
      _showError('Please select a crop type');
      return;
    }

    if (_selectedPreferredGrade == null) {
      _showError('Please select a preferred quality grade');
      return;
    }

    if (_selectedExpiryDate == null) {
      _showError('Please select an expiry date');
      return;
    }

    final buyerId = _sessionService.currentUserId;
    if (buyerId == null) {
      _showError('Please login to create a demand');
      return;
    }

    setState(() => _isSubmitting = true);

    final minQty = double.parse(_minQuantityController.text.trim());
    final maxQty = double.parse(_maxQuantityController.text.trim());
    final price = double.parse(_priceController.text.trim());

    final demand = await context.read<BuyerProvider>().createDemand(
          buyerId: buyerId,
          cropType: _selectedCropType!,
          preferredGrade: _selectedPreferredGrade!,
          minimumQuantityKg: minQty,
          maximumQuantityKg: maxQty,
          priceOfferPerKg: price,
          pickupLocation: _locationController.text.trim(),
          expiresAt: _selectedExpiryDate!,
          additionalNotes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          transportProvided: _transportProvided,
          acceptedGrades: _selectedAcceptedGrades.isNotEmpty
              ? _selectedAcceptedGrades
              : null,
        );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (demand != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Demand created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final error = context.read<BuyerProvider>().demandsError;
        _showError(error ?? 'Failed to create demand');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
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
          'Create Demand',
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
            _buildInfoCard(),
            const SizedBox(height: 16),
            
            // 1. Crop Type
            DropdownButtonFormField<CropType>(
              initialValue: _selectedCropType,
              decoration: InputDecoration(
                labelText: 'Crop Type *',
                prefixIcon: const Icon(Icons.eco),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: CropType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getCropDisplayName(type)),
                );
              }).toList(),
              onChanged: _isSubmitting ? null : (value) {
                setState(() => _selectedCropType = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a crop type';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 2. Preferred Quality Grade
            DropdownButtonFormField<QualityGrade>(
              initialValue: _selectedPreferredGrade,
              decoration: InputDecoration(
                labelText: 'Preferred Quality Grade *',
                prefixIcon: const Icon(Icons.star),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: QualityGrade.values.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(_getGradeDisplayName(grade)),
                );
              }).toList(),
              onChanged: _isSubmitting ? null : (value) {
                setState(() => _selectedPreferredGrade = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a quality grade';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 2.5. Accepted Grades (Multi-select)
            InkWell(
              onTap: _isSubmitting ? null : _showAcceptedGradesDialog,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Accepted Grades (Optional)',
                  prefixIcon: const Icon(Icons.checklist),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selectedAcceptedGrades.isEmpty
                      ? 'Tap to select'
                      : _selectedAcceptedGrades
                          .map((g) => _getGradeDisplayName(g))
                          .join(', '),
                  style: AppTypography.bodyMedium.copyWith(
                    color: _selectedAcceptedGrades.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 3. Minimum Quantity
            TextFormField(
              controller: _minQuantityController,
              decoration: InputDecoration(
                labelText: 'Minimum Quantity (kg) *',
                hintText: 'Enter minimum quantity',
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter minimum quantity';
                }
                final qty = double.tryParse(value.trim());
                if (qty == null || qty <= 0) {
                  return 'Quantity must be greater than 0';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            
            // 4. Maximum Quantity
            TextFormField(
              controller: _maxQuantityController,
              decoration: InputDecoration(
                labelText: 'Maximum Quantity (kg) *',
                hintText: 'Enter maximum quantity',
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter maximum quantity';
                }
                final maxQty = double.tryParse(value.trim());
                if (maxQty == null || maxQty <= 0) {
                  return 'Quantity must be greater than 0';
                }
                final minQty = double.tryParse(_minQuantityController.text.trim());
                if (minQty != null && maxQty < minQty) {
                  return 'Max quantity must be >= min quantity';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            
            // 5. Price Offer
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price Offer per kg (ETB) *',
                hintText: 'Enter price per kg',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter price offer';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Price must be greater than 0';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            
            // 6. Pickup Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Pickup Location *',
                hintText: 'Enter woreda/town',
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
            
            // 7. Expiry Date
            InkWell(
              onTap: _isSubmitting ? null : _selectExpiryDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Expiry Date *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selectedExpiryDate == null
                      ? 'Select expiry date'
                      : _formatDate(_selectedExpiryDate!),
                  style: AppTypography.bodyMedium.copyWith(
                    color: _selectedExpiryDate == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 8. Transport Provided Toggle
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('I provide transport'),
                subtitle: const Text('Will you arrange transportation?'),
                value: _transportProvided,
                onChanged: _isSubmitting ? null : (value) {
                  setState(() => _transportProvided = value);
                },
                activeTrackColor: AppColors.primary,
                secondary: const Icon(Icons.local_shipping),
              ),
            ),
            const SizedBox(height: 16),
            
            // 9. Additional Notes (Optional)
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Any special requirements...',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              maxLength: 500,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 32),
            
            // Submit Button
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
                        'Create Demand',
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

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Create a demand to let farmers know what crops you\'re looking to buy.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCropDisplayName(CropType crop) {
    return crop.name[0].toUpperCase() + crop.name.substring(1);
  }

  String _getGradeDisplayName(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.premium:
        return 'Premium';
      case QualityGrade.grade1:
        return 'Grade 1';
      case QualityGrade.grade2:
        return 'Grade 2';
      case QualityGrade.grade3:
        return 'Grade 3';
      case QualityGrade.standard:
        return 'Standard';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
