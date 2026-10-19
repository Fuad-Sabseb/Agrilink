import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Edit Farmer Profile Screen
/// Allows farmer to update their profile information
class EditFarmerProfileScreen extends StatefulWidget {
  const EditFarmerProfileScreen({super.key});

  @override
  State<EditFarmerProfileScreen> createState() =>
      _EditFarmerProfileScreenState();
}

class _EditFarmerProfileScreenState extends State<EditFarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SessionService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _woredaController = TextEditingController();
  final _kebeleController = TextEditingController();
  final _cooperativeController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final farmer = context.read<FarmerProvider>().farmer;
    if (farmer != null) {
      _nameController.text = farmer.name;
      _phoneController.text = farmer.phoneNumber;
      _woredaController.text = farmer.woreda;
      _kebeleController.text = farmer.kebele;
      _cooperativeController.text = farmer.cooperativeName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _woredaController.dispose();
    _kebeleController.dispose();
    _cooperativeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final farmerId = _sessionService.currentUserId;
    if (farmerId == null) return;

    setState(() => _isSubmitting = true);

    final updates = {
      'name': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'woreda': _woredaController.text.trim(),
      'kebele': _kebeleController.text.trim(),
      if (_cooperativeController.text.trim().isNotEmpty)
        'cooperativeName': _cooperativeController.text.trim(),
    };

    final success = await context.read<FarmerProvider>().updateFarmerProfile(
          farmerId: farmerId,
          updates: updates,
        );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final error = context.read<FarmerProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update profile'),
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
          'Edit Profile',
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                // Ethiopian phone number format: +251 or 0 followed by 9 digits
                final phoneRegex = RegExp(r'^(\+251|0)?[97]\d{8}$');
                if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
                  return 'Please enter a valid Ethiopian phone number';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _woredaController,
              decoration: InputDecoration(
                labelText: 'Woreda',
                hintText: 'Enter your woreda',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your woreda';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kebeleController,
              decoration: InputDecoration(
                labelText: 'Kebele',
                hintText: 'Enter your kebele',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your kebele';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cooperativeController,
              decoration: InputDecoration(
                labelText: 'Cooperative (Optional)',
                hintText: 'Enter your cooperative name',
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                        'Save Changes',
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
}
