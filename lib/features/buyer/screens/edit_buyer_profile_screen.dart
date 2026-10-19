import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/buyer_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/buyer_model.dart';

/// Edit Buyer Profile Screen
/// Allows buyer to update their profile information
class EditBuyerProfileScreen extends StatefulWidget {
  const EditBuyerProfileScreen({super.key});

  @override
  State<EditBuyerProfileScreen> createState() => _EditBuyerProfileScreenState();
}

class _EditBuyerProfileScreenState extends State<EditBuyerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionService = SessionService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _locationController = TextEditingController();

  BuyerType? _selectedBuyerType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final buyer = context.read<BuyerProvider>().buyer;
    if (buyer != null) {
      _nameController.text = buyer.name;
      _phoneController.text = buyer.phoneNumber;
      _businessNameController.text = buyer.businessName;
      _locationController.text = buyer.location;
      _selectedBuyerType = buyer.buyerType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBuyerType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a buyer type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final buyerId = _sessionService.currentUserId;
    if (buyerId == null) return;

    setState(() => _isSubmitting = true);

    final updates = {
      'name': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'businessName': _businessNameController.text.trim(),
      'location': _locationController.text.trim(),
      'buyerType': _selectedBuyerType!.name,
    };

    final success = await context.read<BuyerProvider>().updateBuyerProfile(
          buyerId: buyerId,
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
        final error = context.read<BuyerProvider>().profileError;
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
            _buildInfoCard(),
            const SizedBox(height: 16),
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
                if (value.trim().length > 50) {
                  return 'Name must not exceed 50 characters';
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
              controller: _businessNameController,
              decoration: InputDecoration(
                labelText: 'Business Name',
                hintText: 'Enter your business name',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your business name';
                }
                if (value.trim().length < 2) {
                  return 'Business name must be at least 2 characters';
                }
                if (value.trim().length > 100) {
                  return 'Business name must not exceed 100 characters';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Enter your location (Woreda/Town)',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BuyerType>(
              initialValue: _selectedBuyerType,
              decoration: InputDecoration(
                labelText: 'Buyer Type',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: BuyerType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() => _selectedBuyerType = value);
                    },
              validator: (value) {
                if (value == null) {
                  return 'Please select a buyer type';
                }
                return null;
              },
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
            const SizedBox(height: 16),
            _buildValidationInfo(),
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
                'Update your profile information to ensure accurate communication with farmers.',
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

  Widget _buildValidationInfo() {
    return Card(
      elevation: 1,
      color: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Validation Rules',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildValidationItem('Name: 2-50 characters'),
            _buildValidationItem('Phone: Valid Ethiopian number (09XXXXXXXX)'),
            _buildValidationItem('Business Name: 2-100 characters'),
            _buildValidationItem('Location: Required'),
            _buildValidationItem('Buyer Type: Must be selected'),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
