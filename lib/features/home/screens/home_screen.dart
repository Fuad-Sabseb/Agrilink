import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/dashboard_header.dart';
import '../../../core/widgets/action_grid.dart';
import '../../../core/providers/auth_provider.dart';

/// Home Screen / Dashboard
/// Main landing screen with KPI carousel, action grid, and quick access features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Role is now read from AuthProvider dynamically
  }

  /// Get user role from AuthProvider
  UserRole _getUserRole(BuildContext context) {
    try {
      final authProvider = context.read<AuthProvider>();
      final roleString = authProvider.user?.role.toLowerCase() ?? 'farmer';
      
      switch (roleString) {
        case 'buyer':
          return UserRole.buyer;
        case 'transporter':
          return UserRole.transporter;
        case 'bureau':
        case 'bureau_officer':
          return UserRole.bureau;
        case 'farmer':
        default:
          return UserRole.farmer;
      }
    } catch (e) {
      return UserRole.farmer; // Fallback
    }
  }
  String _selectedWoreda = 'Jimma Town';
  int _notificationCount = 3;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final currentRole = _getUserRole(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Dashboard Header
          DashboardHeader(
            currentRole: currentRole,
            selectedWoreda: _selectedWoreda,
            notificationCount: _notificationCount,
            onRoleTap: _showRoleSwitcher,
            onWoredaTap: _showWoredaSwitcher,
            onNotificationTap: _openNotifications,
          ),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Welcome Message
                  _buildWelcomeSection(localizations, currentRole),
                  
                  const SizedBox(height: 16),
                  
                  // KPI / Price Carousel (Mock)
                  _buildPriceCarousel(localizations),
                  
                  const SizedBox(height: 24),
                  
                  // Action Grid
                  _buildActionGrid(localizations),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Activity (Mock)
                  _buildRecentActivity(localizations),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AppLocalizations localizations, UserRole currentRole) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('welcome'),
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getRoleGreeting(localizations, currentRole),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCarousel(AppLocalizations localizations) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildPriceCard(localizations, index);
        },
      ),
    );
  }

  Widget _buildPriceCard(AppLocalizations localizations, int index) {
    final commodities = [
      localizations.coffee,
      localizations.maize,
      localizations.teff,
      localizations.wheat,
      localizations.potato,
    ];
    
    final prices = ['87.50', '42.30', '65.00', '55.80', '38.20'];
    final changes = ['+2.5%', '-1.2%', '+0.8%', '+1.5%', '-0.5%'];
    final isPositive = [true, false, true, true, false];

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: index == 0 ? AppColors.primaryGradient : null,
        color: index == 0 ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Commodity Name
          Text(
            commodities[index],
            style: AppTypography.labelLarge.copyWith(
              color: index == 0 ? AppColors.textOnPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Price
          Text(
            '${prices[index]} ${localizations.translate('birr')}',
            style: AppTypography.headlineSmall.copyWith(
              color: index == 0 ? AppColors.textOnPrimary : AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          // Change
          Row(
            children: [
              Icon(
                isPositive[index] ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: index == 0
                    ? AppColors.textOnPrimary
                    : (isPositive[index] ? AppColors.success : AppColors.error),
              ),
              const SizedBox(width: 4),
              Text(
                changes[index],
                style: AppTypography.labelSmall.copyWith(
                  color: index == 0
                      ? AppColors.textOnPrimary
                      : (isPositive[index] ? AppColors.success : AppColors.error),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                localizations.today,
                style: AppTypography.caption.copyWith(
                  color: index == 0
                      ? AppColors.textOnPrimary.withValues(alpha: 0.8)
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(AppLocalizations localizations) {
    final actions = [
      ActionGridItem(
        title: localizations.whereShouldISell,
        icon: Icons.analytics_outlined,
        iconColor: AppColors.primary,
        backgroundColor: AppColors.primaryVeryLight,
        onTap: () {
          // Navigate to Market Intelligence screen with Where Should I Sell tab
          Navigator.pushNamed(context, '/market_intelligence');
        },
      ),
      ActionGridItem(
        title: localizations.priceComparison,
        icon: Icons.compare_arrows_rounded,
        iconColor: AppColors.tertiary,
        backgroundColor: AppColors.tertiary.withValues(alpha: 0.12),
        onTap: () {
          // Navigate to Market Intelligence screen
          Navigator.pushNamed(context, '/market_intelligence');
        },
      ),
      ActionGridItem(
        title: localizations.nearbyMarkets,
        icon: Icons.map_outlined,
        iconColor: AppColors.accent,
        backgroundColor: AppColors.accent.withValues(alpha: 0.12),
        onTap: () => _showFeatureSnackbar(localizations.nearbyMarkets),
      ),
      ActionGridItem(
        title: localizations.activeBuyers,
        icon: Icons.people_outline,
        iconColor: AppColors.secondary,
        backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
        onTap: () => _showFeatureSnackbar(localizations.activeBuyers),
        badge: '5',
      ),
      ActionGridItem(
        title: localizations.translate('post_demand'),
        icon: Icons.post_add_outlined,
        iconColor: AppColors.secondaryLight,
        backgroundColor: AppColors.secondaryLight.withValues(alpha: 0.12),
        onTap: () => _showFeatureSnackbar(localizations.translate('post_demand')),
      ),
      ActionGridItem(
        title: localizations.translate('find_sellers'),
        icon: Icons.search_rounded,
        iconColor: AppColors.success,
        backgroundColor: AppColors.success.withValues(alpha: 0.12),
        onTap: () => _showFeatureSnackbar(localizations.translate('find_sellers')),
      ),
      ActionGridItem(
        title: localizations.translate('price_trends'),
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.tertiary,
        backgroundColor: AppColors.tertiary.withValues(alpha: 0.12),
        onTap: () => _showFeatureSnackbar(localizations.translate('price_trends')),
      ),
      ActionGridItem(
        title: localizations.translate('transport_cost'),
        icon: Icons.local_shipping_outlined,
        iconColor: AppColors.secondary,
        backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
        onTap: () => _showFeatureSnackbar(localizations.translate('transport_cost')),
      ),
    ];

    return ActionGrid(items: actions);
  }

  Widget _buildRecentActivity(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            'New buyer in Jimma Town',
            'Buying coffee now',
            Icons.shopping_cart_rounded,
            AppColors.roleBuyer,
          ),
          const SizedBox(height: 8),
          _buildActivityCard(
            'Price Update',
            'Maize price increased by 2.5%',
            Icons.trending_up_rounded,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  String _getRoleGreeting(AppLocalizations localizations, UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return 'Track prices and find the best markets for your harvest';
      case UserRole.buyer:
        return 'Connect with farmers and secure quality produce';
      case UserRole.transporter:
        return 'Find transport opportunities and optimize routes';
      case UserRole.bureau:
        return 'Monitor agricultural activity and market trends';
    }
    return 'Welcome to AgroLink'; // Fallback
  }

  void _showRoleSwitcher() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.agriculture),
              title: const Text('Farmer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/farmer_dashboard_new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Buyer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/buyer_dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Transporter'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/transporter_dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWoredaSwitcher() {
    // TODO: Implement woreda switcher dialog
    _showFeatureSnackbar('Woreda Switcher');
  }

  void _openNotifications() {
    // TODO: Implement notifications screen
    _showFeatureSnackbar('Notifications');
  }

  void _showFeatureSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Feature available in next update'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
