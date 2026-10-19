import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/form_validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  
  // Form keys for each step
  final _personalFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  
  // Controllers for basic info
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Role selection
  String? _selectedRole;
  
  // Role-specific data
  final Map<String, dynamic> _roleSpecificData = {};
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_personalFormKey.currentState!.validate()) return;
    if (_currentStep == 1 && _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }
    if (_currentStep == 2 && !_passwordFormKey.currentState!.validate()) return;
    if (_currentStep == 2 && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleRegister();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleRegister() async {
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.register(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!.toLowerCase(),
      location: _locationController.text.trim(),
      additionalData: {
        'email': _emailController.text.trim(),
        ..._roleSpecificData,
      },
    );

    if (!mounted) return;

    if (success) {
      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            phoneNumber: _phoneController.text.trim(),
            fromRegistration: true,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
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
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < 2 ? 8 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Step Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildRoleSelectionStep(),
                  _buildPasswordStep(),
                ],
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    children: [
                      CustomButton(
                        text: _currentStep == 2 ? 'Create Account' : 'Next',
                        onPressed: authProvider.isLoading ? null : () => _nextStep(),
                        isLoading: authProvider.isLoading,
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _previousStep,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            
            // Login Link
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Personal Information
  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about yourself',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            CustomTextField(
              controller: _nameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: FormValidators.phoneNumber,
              hint: '+251911234567',
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _emailController,
              labelText: 'Email (Optional)',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return FormValidators.email(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _locationController,
              labelText: 'Location (District/Village)',
              prefixIcon: Icons.location_on_outlined,
              validator: FormValidators.required,
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Role Selection
  Widget _buildRoleSelectionStep() {
    final roles = [
      {
        'value': 'farmer',
        'title': 'Farmer',
        'icon': Icons.agriculture,
        'description': 'Grow and sell crops, manage farms',
        'color': AppColors.roleFarmer,
      },
      {
        'value': 'buyer',
        'title': 'Buyer',
        'icon': Icons.shopping_cart,
        'description': 'Purchase crops and agricultural products',
        'color': AppColors.roleBuyer,
      },
      {
        'value': 'transporter',
        'title': 'Transporter',
        'icon': Icons.local_shipping,
        'description': 'Transport agricultural products',
        'color': AppColors.roleTransporter,
      },
      {
        'value': 'bureau_officer',
        'title': 'Bureau Officer',
        'icon': Icons.shield,
        'description': 'Government oversight and monitoring',
        'color': AppColors.roleBureau,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Your Role',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose what describes you best',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          ...roles.map((role) {
            final isSelected = _selectedRole == role['value'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedRole = role['value'] as String;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (role['color'] as Color).withValues(alpha: 0.12)
                        : AppColors.surface,
                    border: Border.all(
                      color: isSelected
                          ? (role['color'] as Color)
                          : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (role['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          role['icon'] as IconData,
                          size: 32,
                          color: role['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role['title'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role['description'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: role['color'] as Color,
                          size: 28,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Step 3: Password & Terms
  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Secure Your Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a strong password',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Password requirements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password must contain:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement('At least 8 characters'),
                  _buildPasswordRequirement('One uppercase letter'),
                  _buildPasswordRequirement('One number'),
                  _buildPasswordRequirement('One special character'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Terms and Conditions
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptTerms = !_acceptTerms;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: AppColors.textPrimary),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
