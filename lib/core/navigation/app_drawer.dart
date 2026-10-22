import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/role_badge.dart';
import '../../routes/app_routes.dart';

/// App Drawer with navigation and settings
class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppDrawer({
    super.key,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    
    final user = authProvider.user;
    final userRole = user?.role.toLowerCase() ?? '';
    final unreadCount = notificationProvider.unreadCount;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // User Header
            _buildUserHeader(context, user, userRole),
            
            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ..._buildRoleSpecificItems(context, userRole),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: unreadCount > 0
                        ? _buildBadge(unreadCount)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  const Divider(),
                  
                  // Theme Toggle
                  _buildThemeToggle(context, themeProvider),
                  
                  // Language Selector
                  _buildLanguageSelector(context, localeProvider),
                  
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/support');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Logout Button
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, dynamic user, String userRole) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryVeryLight,
                child: Text(
                  user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTokens.spaceXXS),
                    Text(
                      user?.email ?? '',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceM),
          RoleBadge(role: userRole),
        ],
      ),
    );
  }

  List<Widget> _buildRoleSpecificItems(BuildContext context, String userRole) {
    switch (userRole) {
      case 'farmer':
        return [
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.farmerDashboard);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.agriculture_outlined,
            title: 'My Farms',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/farmer/farms');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'My Produce',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/farmer/produce');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/farmer/orders');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Market Intelligence',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/farmer/market-intelligence');
            },
          ),
        ];
      case 'buyer':
        return [
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.buyerDashboard);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.store_outlined,
            title: 'Marketplace',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.marketplace);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart_outlined,
            title: 'My Cart',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/buyer/cart');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.favorite_outline,
            title: 'Favorites',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/buyer/favorites');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/buyer/orders');
            },
          ),
        ];
      case 'transporter':
        return [
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.transporterDashboard);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.work_outline,
            title: 'Available Jobs',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transporter/available-jobs');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.local_shipping_outlined,
            title: 'My Trips',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transporter/my-trips');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history_outlined,
            title: 'Trip History',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transporter/history');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Earnings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transporter/earnings');
            },
          ),
        ];
      case 'bureau_officer':
        return [
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.bureauDashboard);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.verified_outlined,
            title: 'Inspections',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bureau/inspections');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.agriculture_outlined,
            title: 'Registered Farms',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bureau/farms');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Reports',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bureau/reports');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Schedule',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/bureau/schedule');
            },
          ),
        ];
      default:
        return [
          _buildDrawerItem(
            context,
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.store_outlined,
            title: 'Marketplace',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.marketplace);
            },
          ),
        ];
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: AppTokens.iconM,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceL,
        vertical: AppTokens.spaceXXS,
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceXS,
        vertical: AppTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: AppTypography.caption.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    return SwitchListTile(
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: AppColors.primary,
        size: AppTokens.iconM,
      ),
      title: Text(
        'Dark Mode',
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        themeProvider.toggleTheme();
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceL,
        vertical: AppTokens.spaceXXS,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, LocaleProvider localeProvider) {
    return ListTile(
      leading: Icon(
        Icons.language,
        color: AppColors.primary,
        size: AppTokens.iconM,
      ),
      title: Text(
        'Language',
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: localeProvider.locale?.languageCode ?? 'en',
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
          DropdownMenuItem(value: 'om', child: Text('Afaan Oromoo')),
        ],
        onChanged: (value) {
          if (value != null) {
            localeProvider.setLocale(Locale(value));
          }
        },
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceL,
        vertical: AppTokens.spaceXXS,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: AppColors.error,
        ),
        title: Text(
          'Logout',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            }
          }
        },
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AgriLink',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(AppTokens.spaceS),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
        ),
        child: const Icon(
          Icons.agriculture,
          color: Colors.white,
          size: 40,
        ),
      ),
      children: [
        const Text(
          'AgriLink connects farmers, buyers, transporters, and government officials in a comprehensive agricultural marketplace ecosystem.',
        ),
        const SizedBox(height: AppTokens.spaceM),
        const Text(
          'Developed in Jimma Zone, Ethiopia',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
