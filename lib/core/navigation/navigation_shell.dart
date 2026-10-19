import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../localization/app_localizations.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/market/screens/market_intelligence_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

/// Main Navigation Shell
/// Bottom navigation bar with 5 main sections matching Lao Agrolink pattern
class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  // Navigation screens
  final List<Widget> _screens = const [
    HomeScreen(),
    MarketIntelligenceScreen(),
    MarketplaceScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(localizations),
    );
  }

  Widget _buildBottomNavigationBar(AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: localizations.home,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.analytics_rounded,
                label: localizations.marketIntelligence,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.store_rounded,
                label: localizations.marketplace,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.receipt_long_rounded,
                label: localizations.orders,
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: localizations.profile,
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: AppColors.primaryLight.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryLight.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background indicator for selected state
                  if (isSelected)
                    Container(
                      width: 40,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryVeryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  // Icon
                  Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: AppTypography.navLabel.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
