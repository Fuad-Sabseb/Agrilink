import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/core/theme/colors.dart';
import 'package:agrolink/core/providers/auth_provider.dart';
import 'package:agrolink/features/farmer/screens/farmer_dashboard_screen.dart';
import 'package:agrolink/features/buyer/screens/buyer_dashboard_screen.dart';
import 'package:agrolink/features/transporter/screens/transporter_dashboard_screen.dart';
import 'package:agrolink/features/bureau/screens/bureau_dashboard_screen.dart';

/// Widget for backend-validated role switching
/// Only displays if user has multiple authorized roles
/// Shows loading state during switch and handles errors appropriately
class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  bool _isSwitching = false;

  /// Get human-readable role name
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'farmer':
        return 'Farmer';
      case 'buyer':
        return 'Buyer';
      case 'transporter':
        return 'Transporter';
      case 'bureau_officer':
        return 'Bureau Officer';
      default:
        return role;
    }
  }

  /// Navigate to role-specific dashboard
  void _navigateToDashboard(BuildContext context, String role) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId ?? '';
    
    Widget dashboardScreen;
    
    switch (role) {
      case 'farmer':
        dashboardScreen = const FarmerDashboardScreen();
        break;
      case 'buyer':
        dashboardScreen = const BuyerDashboardScreen();
        break;
      case 'transporter':
        dashboardScreen = const TransporterDashboardScreen();
        break;
      case 'bureau_officer':
        dashboardScreen = BureauDashboardScreen(officerId: userId);
        break;
      default:
        // Fallback to farmer dashboard
        dashboardScreen = const FarmerDashboardScreen();
    }

    // Navigate and clear stack to prevent back navigation issues
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => dashboardScreen),
      (route) => false,
    );
  }

  /// Handle role switch with error handling
  Future<void> _handleRoleSwitch(String newRole) async {
    if (_isSwitching) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentRole = authProvider.currentRole;

    // Don't switch if already on this role
    if (currentRole == newRole) return;

    setState(() {
      _isSwitching = true;
    });

    try {
      final success = await authProvider.switchRole(newRole);

      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${_getRoleDisplayName(newRole)}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to role-specific dashboard
        _navigateToDashboard(context, newRole);
      } else {
        // Show error from provider
        final error = authProvider.error ?? 'Role switch failed';
        _showError(error);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  /// Show error message
  void _showError(String message) {
    String displayMessage = message;

    // Handle specific error cases
    if (message.contains('403') || message.contains('unauthorized')) {
      displayMessage = 'You are not authorized for this role';
    } else if (message.contains('network') || 
               message.contains('offline') ||
               message.contains('connection')) {
      displayMessage = 'Cannot switch role offline. Please check your connection.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Don't show if user doesn't have multiple roles
        if (!authProvider.hasMultipleRoles) {
          return const SizedBox.shrink();
        }

        final availableRoles = authProvider.availableRoles;
        final currentRole = authProvider.currentRole;

        // Don't show if no roles available
        if (availableRoles.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Switch Role',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                
                // Show loading indicator or dropdown
                if (_isSwitching)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Switching role...'),
                        ],
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: currentRole,
                    decoration: const InputDecoration(
                      labelText: 'Current Role',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: availableRoles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              _getRoleIcon(role),
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(_getRoleDisplayName(role)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newRole) {
                      if (newRole != null && newRole != currentRole) {
                        _handleRoleSwitch(newRole);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get icon for role
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'farmer':
        return Icons.agriculture;
      case 'buyer':
        return Icons.shopping_cart;
      case 'transporter':
        return Icons.local_shipping;
      case 'bureau_officer':
        return Icons.business;
      default:
        return Icons.person;
    }
  }
}
