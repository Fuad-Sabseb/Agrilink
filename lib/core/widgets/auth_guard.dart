import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';

/// Authentication Guard Widget
/// Wraps screens that require authentication
/// Redirects to login if user is not authenticated
class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String>? allowedRoles;
  final Widget? unauthorizedWidget;

  const AuthGuard({
    super.key,
    required this.child,
    this.allowedRoles,
    this.unauthorizedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if user is authenticated
        if (!authProvider.isAuthenticated) {
          // Redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check role authorization if roles are specified
        if (allowedRoles != null && allowedRoles!.isNotEmpty) {
          final userRole = authProvider.user?.role;
          
          if (userRole == null || !allowedRoles!.contains(userRole)) {
            // User role not authorized
            return unauthorizedWidget ??
                Scaffold(
                  appBar: AppBar(title: const Text('Unauthorized')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Unauthorized Access',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 48.0),
                          child: Text(
                            'You do not have permission to access this page.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                );
          }
        }

        // User is authenticated and authorized
        return child;
      },
    );
  }
}

/// Role-specific guard shortcuts
class FarmerGuard extends StatelessWidget {
  final Widget child;

  const FarmerGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: const ['farmer'],
      child: child,
    );
  }
}

class BuyerGuard extends StatelessWidget {
  final Widget child;

  const BuyerGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: const ['buyer'],
      child: child,
    );
  }
}

class TransporterGuard extends StatelessWidget {
  final Widget child;

  const TransporterGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: const ['transporter'],
      child: child,
    );
  }
}

class BureauOfficerGuard extends StatelessWidget {
  final Widget child;

  const BureauOfficerGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: const ['bureau_officer'],
      child: child,
    );
  }
}

/// Helper function to check if user has specific role
bool hasRole(BuildContext context, String role) {
  final authProvider = context.read<AuthProvider>();
  return authProvider.user?.role == role;
}

/// Helper function to check if user has any of the specified roles
bool hasAnyRole(BuildContext context, List<String> roles) {
  final authProvider = context.read<AuthProvider>();
  final userRole = authProvider.user?.role;
  return userRole != null && roles.contains(userRole);
}
