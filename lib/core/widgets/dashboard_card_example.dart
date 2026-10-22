import 'package:flutter/material.dart';
import 'dashboard_card.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// Example usage of DashboardCard widget
/// 
/// This file demonstrates various ways to use the DashboardCard widget
/// in different scenarios across the AgriLink app.
class DashboardCardExample extends StatelessWidget {
  const DashboardCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DashboardCard Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Simple Cards
            Text(
              'Simple Cards',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const DashboardCard(
              title: 'Active Listings',
              icon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const DashboardCard(
              title: 'My Farms',
              icon: Icons.agriculture_outlined,
              iconColor: AppColors.success,
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 2: Cards with Subtitles
            Text(
              'Cards with Subtitles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const DashboardCard(
              title: 'Registered Farms',
              subtitle: '3 farms in Jimma Zone',
              icon: Icons.agriculture_outlined,
              iconColor: AppColors.roleFarmer,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const DashboardCard(
              title: 'Market Prices',
              subtitle: 'Last updated 2 hours ago',
              icon: Icons.trending_up,
              iconColor: AppColors.tertiary,
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 3: Interactive Cards with Navigation
            Text(
              'Interactive Cards (Tappable)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            DashboardCard(
              title: 'View All Orders',
              subtitle: 'You have 5 pending orders',
              icon: Icons.receipt_long_outlined,
              iconColor: AppColors.warning,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigating to Orders...'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            DashboardCard(
              title: 'Transport Requests',
              subtitle: 'Create new delivery request',
              icon: Icons.local_shipping_outlined,
              iconColor: AppColors.roleTransporter,
              trailing: const Icon(Icons.add_circle_outline, size: 20),
              onTap: () {
                // Navigate to transport request screen
              },
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 4: Cards with Badges
            Text(
              'Cards with Badges',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            DashboardCard(
              title: 'Pending Orders',
              subtitle: 'Requires your attention',
              icon: Icons.hourglass_empty,
              iconColor: AppColors.error,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '5',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                // Navigate to pending orders
              },
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            DashboardCard(
              title: 'Notifications',
              subtitle: 'New updates available',
              icon: Icons.notifications_outlined,
              iconColor: AppColors.primary,
              trailing: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () {
                // Navigate to notifications
              },
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 5: Role-Specific Cards
            Text(
              'Role-Specific Cards',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            // Farmer Card
            DashboardCard(
              title: 'Farmer Dashboard',
              subtitle: 'Manage your agricultural activities',
              icon: Icons.person_outlined,
              iconColor: AppColors.roleFarmer,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.roleFarmer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'FARMER',
                  style: TextStyle(
                    color: AppColors.roleFarmer,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            // Buyer Card
            DashboardCard(
              title: 'Buyer Dashboard',
              subtitle: 'Browse and purchase produce',
              icon: Icons.person_outlined,
              iconColor: AppColors.roleBuyer,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.roleBuyer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BUYER',
                  style: TextStyle(
                    color: AppColors.roleBuyer,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            // Transporter Card
            DashboardCard(
              title: 'Transporter Dashboard',
              subtitle: 'Manage deliveries and routes',
              icon: Icons.person_outlined,
              iconColor: AppColors.roleTransporter,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.roleTransporter.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'TRANSPORTER',
                  style: TextStyle(
                    color: AppColors.roleTransporter.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            // Bureau Officer Card
            DashboardCard(
              title: 'Bureau Officer Dashboard',
              subtitle: 'Conduct inspections and reports',
              icon: Icons.person_outlined,
              iconColor: AppColors.roleBureau,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.roleBureau.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BUREAU',
                  style: TextStyle(
                    color: AppColors.roleBureau,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 6: Grid Layout Example
            Text(
              'Grid Layout (2 columns)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Quick View',
                    icon: Icons.visibility_outlined,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppTokens.spaceM),
                Expanded(
                  child: DashboardCard(
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
