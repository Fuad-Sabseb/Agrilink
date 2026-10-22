import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../../routes/app_routes.dart';

/// Role-based bottom navigation bar
class AgriBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final String userRole;

  const AgriBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.userRole,
  });

  List<BottomNavigationBarItem> _getNavItems() {
    switch (userRole) {
      case 'farmer':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'My Produce',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Market',
          ),
        ];
      case 'buyer':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Browse',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ];
      case 'transporter':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Available',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'My Trips',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
        ];
      case 'bureau_officer':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.verified_outlined),
            activeIcon: Icon(Icons.verified),
            label: 'Inspections',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.agriculture_outlined),
            activeIcon: Icon(Icons.agriculture),
            label: 'Farms',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ];
      default:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Market',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
    }
  }

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default navigation behavior
    switch (userRole) {
      case 'farmer':
        final routes = [
          AppRoutes.farmerDashboard,
          '/farmer/produce',
          '/farmer/orders',
          AppRoutes.marketplace,
        ];
        if (index < routes.length) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
        break;
      case 'buyer':
        final routes = [
          AppRoutes.buyerDashboard,
          AppRoutes.marketplace,
          '/buyer/cart',
          '/buyer/orders',
        ];
        if (index < routes.length) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
        break;
      case 'transporter':
        final routes = [
          AppRoutes.transporterDashboard,
          '/transporter/available-jobs',
          '/transporter/my-trips',
          '/transporter/map',
        ];
        if (index < routes.length) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
        break;
      case 'bureau_officer':
        final routes = [
          AppRoutes.bureauDashboard,
          '/bureau/inspections',
          '/bureau/farms',
          '/bureau/reports',
        ];
        if (index < routes.length) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
        break;
      default:
        final routes = [
          AppRoutes.home,
          AppRoutes.marketplace,
          '/profile',
        ];
        if (index < routes.length) {
          Navigator.pushReplacementNamed(context, routes[index]);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow12,
            blurRadius: AppTokens.elevationL,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleTap(context, index),
        items: _getNavItems(),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.navLabel.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.navLabel,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: AppTokens.elevationL,
      ),
    );
  }
}
