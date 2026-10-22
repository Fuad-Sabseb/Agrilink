import 'package:flutter/material.dart';
import 'action_card.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// Example usage of ActionCard widget
/// 
/// This file demonstrates various ways to use the ActionCard widget
/// in different scenarios across the AgriLink app.
class ActionCardExample extends StatelessWidget {
  const ActionCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ActionCard Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Highlighted Hero Action
            Text(
              'Hero Action (Highlighted)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            ActionCard(
              title: 'Where Should I Sell?',
              description:
                  'Compare market prices and calculate net revenue to find the best place to sell your produce',
              icon: Icons.analytics_outlined,
              primaryColor: AppColors.primary,
              isHighlight: true,
              onTap: () {
                // Navigate to market intelligence screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigating to Market Intelligence...'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 2: Standard Action Cards
            Text(
              'Standard Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),

            // Farmer Actions
            ActionCard(
              title: 'Add Produce',
              description: 'List new crops for sale in the marketplace',
              icon: Icons.add_circle_outline,
              primaryColor: AppColors.success,
              onTap: () {
                // Navigate to add produce screen
              },
            ),
            const SizedBox(height: AppTokens.spaceM),

            ActionCard(
              title: 'View My Farms',
              description: 'Manage your registered farms and field information',
              icon: Icons.agriculture_outlined,
              primaryColor: AppColors.roleFarmer,
              onTap: () {
                // Navigate to farms screen
              },
            ),
            const SizedBox(height: AppTokens.spaceM),

            ActionCard(
              title: 'Scan Crop Disease',
              description: 'Use AI to identify crop diseases and get treatment advice',
              icon: Icons.camera_alt_outlined,
              primaryColor: AppColors.tertiary,
              onTap: () {
                // Navigate to crop scanner screen
              },
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 3: Role-Specific Actions
            Text(
              'Role-Specific Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),

            // Buyer Action
            ActionCard(
              title: 'Browse Marketplace',
              description: 'Find fresh produce from local farmers',
              icon: Icons.store_outlined,
              primaryColor: AppColors.roleBuyer,
              onTap: () {
                // Navigate to marketplace
              },
            ),
            const SizedBox(height: AppTokens.spaceM),

            // Transporter Action
            ActionCard(
              title: 'Available Jobs',
              description: 'Find transport requests near your location',
              icon: Icons.work_outline,
              primaryColor: AppColors.roleTransporter,
              onTap: () {
                // Navigate to transport jobs
              },
            ),
            const SizedBox(height: AppTokens.spaceM),

            // Bureau Officer Action
            ActionCard(
              title: 'Schedule Inspection',
              description: 'Create a new farm or produce inspection',
              icon: Icons.verified_outlined,
              primaryColor: AppColors.roleBureau,
              onTap: () {
                // Navigate to inspection scheduler
              },
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 4: Grid Layout Example
            Text(
              'Grid Layout (2 columns)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),

            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    title: 'Quick Action 1',
                    description: 'Short description',
                    icon: Icons.flash_on,
                    primaryColor: AppColors.warning,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppTokens.spaceM),
                Expanded(
                  child: ActionCard(
                    title: 'Quick Action 2',
                    description: 'Short description',
                    icon: Icons.stars,
                    primaryColor: AppColors.accent,
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
