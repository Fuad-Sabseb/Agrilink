import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/providers/profile_provider.dart';
import 'package:agrolink/core/utils/validators/profile_validator.dart';
import 'package:agrolink/models/requests/profile_update_request.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _woredaController;
  late TextEditingController _cooperativeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _woredaController = TextEditingController(text: profile?.woreda ?? '');
    _cooperativeController = TextEditingController(text: profile?.cooperativeName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _woredaController.dispose();
    _cooperativeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final request = ProfileUpdateRequest(
      fullName: _nameController.text.trim(),
      location: _locationController.text.trim(),
      woreda: _woredaController.text.trim().isEmpty ? null : _woredaController.text.trim(),
      cooperativeName: _cooperativeController.text.trim().isEmpty ? null : _cooperativeController.text.trim(),
    );

    final success = await context.read<ProfileProvider>().updateProfile(request);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final error = context.read<ProfileProvider>().error ?? 'Failed to update profile';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                  ),
                  validator: ProfileValidator.validateFullName,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter your location',
                  ),
                  validator: ProfileValidator.validateLocation,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _woredaController,
                  decoration: const InputDecoration(
                    labelText: 'Woreda (Optional)',
                    hintText: 'Enter your woreda',
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cooperativeController,
                  decoration: const InputDecoration(
                    labelText: 'Cooperative Name (Optional)',
                    hintText: 'Enter cooperative name',
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
