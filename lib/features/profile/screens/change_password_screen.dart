import 'package:flutter/material.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/services/password_service.dart';
import 'package:agrolink/core/utils/validators/password_validator.dart';
import 'package:agrolink/features/profile/widgets/secure_text_field.dart';
import 'package:agrolink/features/profile/widgets/password_strength_indicator.dart';
import 'package:agrolink/features/profile/widgets/password_requirements_list.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordService = PasswordService();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final response = await _passwordService.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        String errorMessage = response.error ?? 'Failed to change password';
        if (response.statusCode == 401) {
          errorMessage = 'Current password is incorrect';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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
        title: const Text('Change Password'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SecureTextField(
              controller: _currentPasswordController,
              label: 'Current Password',
              validator: PasswordValidator.validateCurrentPassword,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            SecureTextField(
              controller: _newPasswordController,
              label: 'New Password',
              validator: (value) => PasswordValidator.validateNewPassword(
                value,
                currentPassword: _currentPasswordController.text,
              ),
              textInputAction: TextInputAction.next,
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _newPasswordController,
              builder: (context, value, child) {
                return PasswordStrengthIndicator(password: value.text);
              },
            ),
            const SizedBox(height: 16),
            SecureTextField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              validator: (value) => PasswordValidator.validateConfirmPassword(
                value,
                _newPasswordController.text,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _changePassword(),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _newPasswordController,
              builder: (context, value, child) {
                return PasswordRequirementsList(password: value.text);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
