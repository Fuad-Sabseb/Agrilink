import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/preferences_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/biometric_service.dart';
import '../../../screens/auth/login_screen.dart';

/// Enhanced Settings Screen with Phase 9 features
/// Provides theme, language, notification settings, and account management
class SettingsScreenEnhanced extends StatefulWidget {
  const SettingsScreenEnhanced({super.key});

  @override
  State<SettingsScreenEnhanced> createState() => _SettingsScreenEnhancedState();
}

class _SettingsScreenEnhancedState extends State<SettingsScreenEnhanced> {
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
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final preferencesProvider = context.watch<PreferencesProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ========== APPEARANCE SECTION ==========
          _buildSectionHeader(l10n.appearance),
          
          // Theme Picker
          _buildListTile(
            icon: Icons.palette_outlined,
            title: l10n.theme,
            subtitle: _getThemeLabel(themeProvider.themeMode, l10n),
            onTap: () => _showThemePicker(context, themeProvider, l10n),
          ),
          
          // Language Picker
          _buildListTile(
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: _getLanguageLabel(localeProvider.languageCode, l10n),
            onTap: () => _showLanguagePicker(context, localeProvider, l10n),
          ),
          
          const Divider(height: 32),

          // ========== NOTIFICATIONS SECTION ==========
          _buildSectionHeader(l10n.notificationSettings),
          
          // Price Alerts
          _buildSwitchTile(
            icon: Icons.attach_money_outlined,
            title: l10n.priceAlerts,
            subtitle: 'Get notified about price changes',
            value: preferencesProvider.priceAlerts,
            onChanged: (value) => preferencesProvider.setPriceAlerts(value),
          ),
          
          // Order Updates
          _buildSwitchTile(
            icon: Icons.shopping_bag_outlined,
            title: l10n.orderNotifications,
            subtitle: 'Get notified about order status',
            value: preferencesProvider.orderUpdates,
            onChanged: (value) => preferencesProvider.setOrderUpdates(value),
          ),
          
          // Market Updates
          _buildSwitchTile(
            icon: Icons.store_outlined,
            title: l10n.marketUpdates,
            subtitle: 'Get market news and updates',
            value: preferencesProvider.marketUpdates,
            onChanged: (value) => preferencesProvider.setMarketUpdates(value),
          ),
          
          // System Notifications
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: l10n.systemNotifications,
            subtitle: 'Important system alerts',
            value: preferencesProvider.systemNotifications,
            onChanged: (value) => preferencesProvider.setSystemNotifications(value),
          ),
          
          // Inspection Reminders (Bureau only)
          if (authProvider.isBureauOfficer)
            _buildSwitchTile(
              icon: Icons.assignment_outlined,
              title: 'Inspection Reminders',
              subtitle: 'Get reminded about pending inspections',
              value: preferencesProvider.inspectionReminders,
              onChanged: (value) => preferencesProvider.setInspectionReminders(value),
            ),
          
          const Divider(height: 32),

          // ========== ACCOUNT SECTION ==========
          _buildSectionHeader('Account'),
          
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Profile Information',
            subtitle: user?.fullName ?? 'Not logged in',
            onTap: () {
              Navigator.pushNamed(context, '/profile/edit');
            },
          ),
          
          _buildListTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            subtitle: user?.phone ?? '',
            onTap: () {},
          ),
          
          _buildListTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: user?.location ?? '',
            onTap: () {},
          ),
          
          _buildListTile(
            icon: Icons.work_outline,
            title: 'Role',
            subtitle: _formatRole(user?.role ?? ''),
            onTap: null,
          ),
          
          const Divider(height: 32),

          // ========== SECURITY SECTION ==========
          _buildSectionHeader('Security'),
          
          _buildListTile(
            icon: Icons.lock_outline,
            title: l10n.changePassword,
            onTap: () {
              Navigator.pushNamed(context, '/settings/change-password');
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
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (value) => _toggleBiometric(),
              ),
            ),
          
          const Divider(height: 32),

          // ========== ABOUT SECTION ==========
          _buildSectionHeader('About'),
          
          _buildListTile(
            icon: Icons.info_outline,
            title: l10n.aboutApp,
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: () {
              Navigator.pushNamed(context, '/settings/privacy-policy');
            },
          ),
          
          _buildListTile(
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            onTap: () {
              Navigator.pushNamed(context, '/settings/terms');
            },
          ),
          
          _buildListTile(
            icon: Icons.help_outline,
            title: l10n.helpSupport,
            onTap: () {
              Navigator.pushNamed(context, '/settings/help');
            },
          ),
          
          const Divider(height: 32),

          // ========== LOGOUT BUTTON ==========
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(
                l10n.logout,
                style: const TextStyle(
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
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
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

  String _getThemeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  String _getLanguageLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'am':
        return l10n.amharic;
      case 'om':
        return l10n.afaanOromoo;
      default:
        return code;
    }
  }

  void _showThemePicker(BuildContext context, ThemeProvider themeProvider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.chooseTheme),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Divider(),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemDefault),
              subtitle: const Text('Follow device settings'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightMode),
              subtitle: const Text('Light theme'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkMode),
              subtitle: const Text('Dark theme'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider localeProvider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.selectLanguage),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Divider(),
            RadioListTile<String>(
              title: Text(l10n.english),
              subtitle: const Text('English'),
              value: 'en',
              groupValue: localeProvider.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(Locale(value!));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.amharic),
              subtitle: const Text('አማርኛ'),
              value: 'am',
              groupValue: localeProvider.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(Locale(value!));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.afaanOromoo),
              subtitle: const Text('Afaan Oromoo'),
              value: 'om',
              groupValue: localeProvider.languageCode,
              onChanged: (value) {
                localeProvider.setLocale(Locale(value!));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
                Navigator.pop(dialogContext);
                
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Logout', style: TextStyle(color: AppColors.error)),
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
      ],
    );
  }
}
