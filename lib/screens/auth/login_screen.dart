import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/utils/form_validators.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _biometricService = BiometricService();
  
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final savedIdentifier = prefs.getString('saved_identifier') ?? '';
    
    if (mounted) {
      setState(() {
        _rememberMe = rememberMe;
        if (rememberMe && savedIdentifier.isNotEmpty) {
          _identifierController.text = savedIdentifier;
        }
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final isSupported = await _biometricService.isDeviceSupported();
    final isEnabled = await _biometricService.isBiometricEnabled();
    
    if (mounted) {
      setState(() {
        _biometricAvailable = isSupported;
        _biometricEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    final authProvider = context.read<AuthProvider>();
    
    // Check if user has saved credentials
    final savedUser = await authProvider.authService.getUser();
    if (!mounted) return;
    if (savedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login with password first to enable biometric login'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Authenticate with biometrics
    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Authenticate to login to AgroLink',
    );

    if (!mounted) return;

    if (authenticated) {
      // User authenticated, restore session
      final restored = await authProvider.restoreSession(force: true);
      if (!mounted) return;
      
      if (restored && authProvider.isAuthenticated && authProvider.user != null) {
        final user = authProvider.user!;
        
        // Route based on role
        switch (user.role.toLowerCase()) {
          case 'farmer':
            Navigator.pushReplacementNamed(context, AppRoutes.farmerDashboard);
            break;
          case 'buyer':
            Navigator.pushReplacementNamed(context, AppRoutes.buyerDashboard);
            break;
          case 'transporter':
            Navigator.pushReplacementNamed(context, AppRoutes.transporterDashboard);
            break;
          case 'bureau_officer':
            Navigator.pushReplacementNamed(context, AppRoutes.bureauDashboard);
            break;
          default:
            Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to restore session. Please login with password.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric authentication failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.user;
      if (user == null) return;

      // Save or clear remember me preference
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_identifier', _identifierController.text.trim());
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_identifier');
      }

      if (!mounted) return;

      // Route based on role
      switch (user.role.toLowerCase()) {
        case 'farmer':
          Navigator.pushReplacementNamed(context, AppRoutes.farmerDashboard);
          break;
        case 'buyer':
          Navigator.pushReplacementNamed(context, AppRoutes.buyerDashboard);
          break;
        case 'transporter':
          Navigator.pushReplacementNamed(context, AppRoutes.transporterDashboard);
          break;
        case 'bureau_officer':
          Navigator.pushReplacementNamed(context, AppRoutes.bureauDashboard);
          break;
        default:
          Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo & Title
                  Icon(
                    Icons.agriculture_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to continue to AgriLink',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 48),
                  
                  // Phone/Email Input
                  CustomTextField(
                    controller: _identifierController,
                    labelText: 'Phone Number or Email',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number or email';
                      }
                      // Accept either phone or email
                      final isPhone = FormValidators.phoneNumber(value) == null;
                      final isEmail = FormValidators.email(value) == null;
                      if (!isPhone && !isEmail) {
                        return 'Please enter a valid phone number or email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Input
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
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text('Remember me'),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button with loading state from provider
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'Login',
                        onPressed: authProvider.isLoading ? null : () => _handleLogin(),
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Biometric Login Button (if available)
                  if (_biometricAvailable && _biometricEnabled) ...[
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _handleBiometricLogin,
                      icon: const Icon(Icons.fingerprint, size: 28),
                      label: const Text(
                        'Login with Biometrics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                  
                  // Mock credentials helper (remove in production)
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Test Credentials:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Farmer: +251911234567 / password: test123',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Buyer: buyer@test.com / password: test123',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
