import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/services/password_service.dart';
import '../../core/utils/validators/password_validator.dart';
import '../../features/profile/widgets/password_strength_indicator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen for password recovery via phone number OTP and resetting password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _passwordService = PasswordService();
  final _phoneFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0: Phone, 1: OTP, 2: New Password
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _resetToken;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleRequestOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();

    try {
      final response = await _passwordService.requestPasswordReset(phone);
      if (!mounted) return;

      if (response.isSuccess) {
        _startCountdown();
        setState(() {
          _currentStep = 1;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to $phone (Mock code: 123456)'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to send OTP'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();

    try {
      final response = await _passwordService.verifyResetOTP(
        phone: phone,
        otpCode: otp,
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _resetToken = response.data!.resetToken;
          _currentStep = 2;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP verified successfully! Please set your new password.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Invalid OTP code'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_resetToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reset token expired. Please start over.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isLoading = true);
    final newPassword = _newPasswordController.text;

    try {
      final response = await _passwordService.confirmPasswordReset(
        resetToken: _resetToken!,
        newPassword: newPassword,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.isSuccess) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: Icon(Icons.check_circle, color: AppColors.success, size: 56),
            title: const Text('Password Reset Successful'),
            content: const Text(
              'Your password has been reset successfully. You can now log in with your new credentials.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context); // Return to login
                },
                child: const Text('Proceed to Login'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to reset password'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator
              _buildStepProgress(),
              const SizedBox(height: 32),

              // Step Content
              if (_currentStep == 0) _buildPhoneStep(),
              if (_currentStep == 1) _buildOtpStep(),
              if (_currentStep == 2) _buildPasswordStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepProgress() {
    return Row(
      children: [
        _buildStepIndicator(0, 'Phone'),
        Expanded(child: Container(height: 2, color: _currentStep > 0 ? AppColors.primary : AppColors.border)),
        _buildStepIndicator(1, 'Verify'),
        Expanded(child: Container(height: 2, color: _currentStep > 1 ? AppColors.primary : AppColors.border)),
        _buildStepIndicator(2, 'New Password'),
      ],
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label) {
    final isDone = _currentStep > stepIndex;
    final isCurrent = _currentStep == stepIndex;

    final color = isDone
        ? AppColors.primary
        : isCurrent
            ? AppColors.primary
            : AppColors.border;

    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${stepIndex + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneStep() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_reset_rounded, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Forgot Your Password?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your registered phone number. We will send a verification OTP to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hint: 'e.g. +251911234567 or 0911234567',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
              if (cleaned.length < 9) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Send Verification OTP',
            isLoading: _isLoading,
            onPressed: _handleRequestOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Enter Verification Code',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to ${_phoneController.text.trim()}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _otpController,
          labelText: '6-Digit OTP',
          hint: '123456',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().length != 6) {
              return 'Enter 6 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _resendCountdown > 0
                  ? 'Resend OTP in ${_resendCountdown}s'
                  : "Didn't receive the code?",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            if (_resendCountdown == 0)
              TextButton(
                onPressed: _handleRequestOtp,
                child: const Text('Resend Code'),
              ),
          ],
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Verify Code',
          isLoading: _isLoading,
          onPressed: _handleVerifyOtp,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _currentStep = 0),
          child: const Text('Change Phone Number'),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Create New Password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your new password must be at least 8 characters and contain letters, numbers, and special characters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          CustomTextField(
            controller: _newPasswordController,
            labelText: 'New Password',
            hint: 'Enter new password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
            validator: (value) => PasswordValidator.validateNewPassword(value),
          ),
          PasswordStrengthIndicator(password: _newPasswordController.text),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm New Password',
            hint: 'Re-enter new password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (value) => PasswordValidator.validateConfirmPassword(
              value,
              _newPasswordController.text,
            ),
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: 'Save & Reset Password',
            isLoading: _isLoading,
            onPressed: _handleResetPassword,
          ),
        ],
      ),
    );
  }
}
