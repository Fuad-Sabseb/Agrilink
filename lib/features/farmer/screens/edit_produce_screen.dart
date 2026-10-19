import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/produce_provider.dart';
import '../../../models/produce_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Edit Produce Screen with update functionality
class EditProduceScreen extends StatefulWidget {
  final ProduceModel produce;

  const EditProduceScreen({
    super.key,
    required this.produce,
  });

  @override
  State<EditProduceScreen> createState() => _EditProduceScreenState();
}

class _EditProduceScreenState extends State<EditProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late final TextEditingController _cropNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _pricePerUnitController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  
  // Form values
  late String _selectedUnit;
  late String _selectedCropType;
  late String _selectedQualityGrade;
  late bool _isOrganic;
  late DateTime? _harvestDate;
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
    _initializeFormData();
  }

  void _initializeFormData() {
    _cropNameController = TextEditingController(text: widget.produce.cropName);
    _quantityController = TextEditingController(text: widget.produce.quantity.toString());
    _pricePerUnitController = TextEditingController(text: widget.produce.pricePerUnit.toString());
    _locationController = TextEditingController(text: widget.produce.location);
    _descriptionController = TextEditingController(text: widget.produce.description);
    
    _selectedUnit = widget.produce.unit;
    _selectedCropType = widget.produce.cropType;
    _selectedQualityGrade = widget.produce.qualityGrade ?? 'Grade A';
    _isOrganic = widget.produce.isOrganic;
    _harvestDate = widget.produce.harvestDate;
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? DateTime.now(),
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

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<ProduceProvider>();
      
      await provider.updateProduce(
        id: widget.produce.id,
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

      // Get the updated produce
      final updatedProduce = widget.produce.copyWith(
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
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Produce updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, updatedProduce);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update produce: $e'),
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
          'Edit Produce',
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
              color: AppColors.info.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Update your produce listing details',
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
                        'Update Produce',
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
