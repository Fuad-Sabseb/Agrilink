import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/navigation/navigation_shell.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool fromRegistration;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.fromRegistration = false,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isVerifying = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  String? _mockOtpCode; // For testing purposes

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _sendOTP();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOTP() async {
    final authProvider = context.read<AuthProvider>();
    final mockCode = await authProvider.sendOTP(widget.phoneNumber);
    
    if (mockCode != null) {
      setState(() {
        _mockOtpCode = mockCode;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to ${widget.phoneNumber}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Show mock OTP in debug mode
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mock OTP Code: $mockCode'),
            backgroundColor: AppColors.tertiary,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0) return;

    _startCountdown();
    await _sendOTP();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      _controllers[index].text = value;
      
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // All digits entered, auto-verify
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      // Backspace - move to previous field
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final code = _controllers.map((c) => c.text).join();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter all 6 digits'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final authProvider = context.read<AuthProvider>();
    final isVerified = await authProvider.verifyOTP(
      phone: widget.phoneNumber,
      code: code,
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Phone number verified successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to role-based dashboard or home
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      final user = authProvider.user;
      final role = user?.role.toLowerCase();
      switch (role) {
        case 'farmer':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.farmerDashboard,
            (route) => false,
          );
          break;
        case 'buyer':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.buyerDashboard,
            (route) => false,
          );
          break;
        case 'transporter':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.transporterDashboard,
            (route) => false,
          );
          break;
        case 'bureau_officer':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.bureauDashboard,
            (route) => false,
          );
          break;
        default:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavigationShell()),
            (route) => false,
          );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid OTP code. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
      
      // Clear all fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Icon
              Icon(
                Icons.phonelink_lock_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                'We sent a 6-digit code to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.phoneNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              
              // Verify Button
              CustomButton(
                text: 'Verify',
                onPressed: _isVerifying ? null : () => _verifyOTP(),
                isLoading: _isVerifying,
              ),
              const SizedBox(height: 24),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  if (_resendCountdown > 0)
                    Text(
                      'Resend in $_resendCountdown s',
                      style: TextStyle(
                        color: AppColors.disabled,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _resendOTP,
                      child: Text(
                        'Resend',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              
              // Mock OTP Helper (remove in production)
              if (_mockOtpCode != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Test Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'OTP Code: ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SelectableText(
                            _mockOtpCode!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.primary,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Auto-fill OTP for testing
                          final digits = _mockOtpCode!.split('');
                          for (int i = 0; i < digits.length; i++) {
                            _controllers[i].text = digits[i];
                          }
                          setState(() {});
                        },
                        icon: const Icon(Icons.auto_fix_high, size: 18),
                        label: const Text('Auto-fill OTP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryVeryLight,
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
