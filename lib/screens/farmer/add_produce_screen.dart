import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../core/services/produce_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddProduceScreen extends StatefulWidget {
  const AddProduceScreen({super.key});

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _produceService = ProduceService();
  final _sessionService = SessionService();
  bool _isLoading = false;

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleAddProduce() async {
    if (!_formKey.currentState!.validate()) return;

    final farmerId = _sessionService.currentUserId;
    final user = _sessionService.currentUser;
    if (farmerId == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _produceService.addProduce(
        farmerId: farmerId,
        farmerName: user.fullName,
        cropName: _cropNameController.text.trim(),
        cropType: 'Other', // Default crop type as string
        quantity: double.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim(),
        pricePerUnit: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        location: user.location,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produce added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Go back to dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Produce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _cropNameController,
                labelText: 'Crop Name (e.g., Maize, Tomatoes)',
                prefixIcon: Icons.grass_outlined,
                validator: (value) => value!.isEmpty ? 'Please enter crop name' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _quantityController,
                      labelText: 'Quantity',
                      prefixIcon: Icons.scale_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _unitController,
                      labelText: 'Unit (e.g., Kg)',
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _priceController,
                labelText: 'Price Per Unit (UGX)',
                prefixIcon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter price';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Multiline description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description (quality, variety, etc.)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Publish Listing',
                onPressed: _handleAddProduce,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
