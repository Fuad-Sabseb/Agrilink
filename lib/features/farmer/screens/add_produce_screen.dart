import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/produce_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Add Produce Screen with comprehensive form validation
class AddProduceScreen extends StatefulWidget {
  const AddProduceScreen({super.key});

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SessionService();
  
  // Form controllers
  final _cropNameController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pricePerUnitController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _qualityGradeController = TextEditingController();
  
  // Form values
  String _selectedUnit = 'kg';
  String _selectedCropType = 'Other';
  String _selectedQualityGrade = 'Grade A';
  bool _isOrganic = false;
  DateTime? _harvestDate;
  bool _isSubmitting = false;

  final List<String> _units = ['kg', 'quintal', 'ton', 'bag', 'liter', 'piece'];
  final List<String> _cropTypes = [
    'Other',
    'Cereals',
    'Vegetables',
    'Fruits',
    'Legumes',
    'Coffee',
    'Spices',
  ];
  final List<String> _qualityGrades = [
    'Grade A',
    'Grade B',
    'Grade C',
    'Premium',
    'Standard',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    final user = _sessionService.currentUser;
    if (user != null && user.location.isNotEmpty) {
      _locationController.text = user.location;
    }
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _cropTypeController.dispose();
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _qualityGradeController.dispose();
    super.dispose();
  }

  Future<void> _selectHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _sessionService.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session expired. Please login again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<ProduceProvider>();
      
      await provider.addProduce(
        farmerId: user.id,
        farmerName: user.fullName,
        cropName: _cropNameController.text.trim(),
        cropType: _selectedCropType,
        quantity: double.parse(_quantityController.text.trim()),
        unit: _selectedUnit,
        pricePerUnit: double.parse(_pricePerUnitController.text.trim()),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        qualityGrade: _selectedQualityGrade,
        harvestDate: _harvestDate,
        isOrganic: _isOrganic,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Produce added successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add produce: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.textOnPrimary,
              onPressed: _submitForm,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
          'Add Produce',
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
            // Info Card
            Card(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fill in the details to list your produce',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Crop Name
            TextFormField(
              controller: _cropNameController,
              decoration: InputDecoration(
                labelText: 'Crop Name *',
                hintText: 'e.g., Teff, Coffee, Maize',
                prefixIcon: const Icon(Icons.agriculture_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter crop name';
                }
                if (value.trim().length < 2) {
                  return 'Crop name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Crop Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCropType,
              decoration: InputDecoration(
                labelText: 'Crop Type *',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _cropTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCropType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Quantity and Unit Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity *',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.inventory_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final quantity = double.tryParse(value.trim());
                      if (quantity == null || quantity <= 0) {
                        return 'Invalid quantity';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: InputDecoration(
                      labelText: 'Unit *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Per Unit
            TextFormField(
              controller: _pricePerUnitController,
              decoration: InputDecoration(
                labelText: 'Price Per Unit (ETB) *',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter price';
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Invalid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location *',
                hintText: 'e.g., Jimma, Oromia',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quality Grade
            DropdownButtonFormField<String>(
              value: _selectedQualityGrade,
              decoration: InputDecoration(
                labelText: 'Quality Grade',
                prefixIcon: const Icon(Icons.grade_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _qualityGrades.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQualityGrade = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Harvest Date
            InkWell(
              onTap: _selectHarvestDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Harvest Date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  suffixIcon: _harvestDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _harvestDate = null;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _harvestDate != null
                      ? '${_harvestDate!.day}/${_harvestDate!.month}/${_harvestDate!.year}'
                      : 'Select harvest date',
                  style: TextStyle(
                    color: _harvestDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Organic Checkbox
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              child: CheckboxListTile(
                title: Text(
                  'Organic Produce',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Grown without synthetic chemicals',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isOrganic,
                onChanged: (value) {
                  setState(() {
                    _isOrganic = value ?? false;
                  });
                },
                activeColor: AppColors.success,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe your produce quality, condition, etc.',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.textSecondary,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textOnPrimary,
                          ),
                        ),
                      )
                    : const Text(
                        'Add Produce',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
