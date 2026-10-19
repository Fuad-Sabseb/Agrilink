import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../screens/auth/login_screen.dart';

/// Settings Screen
/// Provides app settings, account management, and logout functionality
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _biometricService = BiometricService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _isCheckingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final isSupported = await _biometricService.isDeviceSupported();
    final isEnabled = await _biometricService.isBiometricEnabled();
    
    if (mounted) {
      setState(() {
        _biometricAvailable = isSupported;
        _biometricEnabled = isEnabled;
        _isCheckingBiometric = false;
      });
    }
  }

  Future<void> _toggleBiometric() async {
    final newState = await _biometricService.toggleBiometric();
    
    if (mounted) {
      setState(() {
        _biometricEnabled = newState;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState 
                ? 'Biometric login enabled' 
                : 'Biometric login disabled',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Profile Information',
            subtitle: user?.fullName ?? 'Not logged in',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile edit coming soon')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            subtitle: user?.phone ?? '',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone update coming soon')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: user?.location ?? '',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location update coming soon')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.work_outline,
            title: 'Role',
            subtitle: _formatRole(user?.role ?? ''),
            onTap: null,
          ),
          const Divider(height: 32),

          // App Settings Section
          _buildSectionHeader('App Settings'),
          _buildListTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings available in app settings')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          _buildListTile(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: 'Light mode',
            onTap: () {
              _showThemeDialog(context);
            },
          ),
          const Divider(height: 32),

          // Security Section
          _buildSectionHeader('Security'),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change coming soon')),
              );
            },
          ),
          if (_biometricAvailable && !_isCheckingBiometric)
            ListTile(
              leading: const Icon(Icons.fingerprint_outlined, size: 24),
              title: const Text(
                'Biometric Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Use fingerprint or face ID',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (value) => _toggleBiometric(),
              ),
            ),
          const Divider(height: 32),

          // About Section
          _buildSectionHeader('About'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'About AgriLink',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const SingleChildScrollView(
                    child: Text('AgroLink Privacy Policy\n\nYour privacy is important to us. This app collects location data to enable farm management and transport tracking features.'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Terms of Service'),
                  content: const SingleChildScrollView(
                    child: Text('AgroLink Terms of Service\n\nBy using this app, you agree to our terms and conditions.'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Help & Support'),
                  content: const Text('For assistance, please contact:\n\nEmail: support@agrolink.et\nPhone: +251-XXX-XXXX'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.error, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();

                if (!context.mounted) return;

                // Navigate to login screen and clear all routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AgriLink',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.agriculture_rounded,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'AgriLink is a comprehensive agricultural supply chain platform '
          'connecting farmers, buyers, transporters, and government officials.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features include:\n'
          '• Market intelligence & price monitoring\n'
          '• Farm & farmer registry\n'
          '• Buyer marketplace\n'
          '• Logistics tracking\n'
          '• Government oversight\n'
          '• Production planning',
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Amharic (አማርኛ)'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('am'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Afaan Oromoo'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(const Locale('om'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('System'),
              leading: const Icon(Icons.settings_system_daydream),
              onTap: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

}