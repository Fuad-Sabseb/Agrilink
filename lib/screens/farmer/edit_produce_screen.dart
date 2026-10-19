import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../models/produce_model.dart';
import '../../core/services/produce_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProduceScreen extends StatefulWidget {
  final ProduceModel produce;
  const EditProduceScreen({super.key, required this.produce});

  @override
  State<EditProduceScreen> createState() => _EditProduceScreenState();
}

class _EditProduceScreenState extends State<EditProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cropNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  final _produceService = ProduceService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cropNameController = TextEditingController(text: widget.produce.cropName);
    _quantityController = TextEditingController(text: widget.produce.quantity.toString());
    _unitController = TextEditingController(text: widget.produce.unit);
    _priceController = TextEditingController(text: widget.produce.pricePerUnit.toString());
    _descriptionController = TextEditingController(text: widget.produce.description);
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _produceService.updateProduce(
        id: widget.produce.id,
        cropName: _cropNameController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim(),
        pricePerUnit: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produce updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Edit Produce')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _cropNameController,
                labelText: 'Crop Name',
                prefixIcon: Icons.grass_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null,
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
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _unitController,
                      labelText: 'Unit',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
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
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Changes',
                onPressed: _handleUpdate,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
