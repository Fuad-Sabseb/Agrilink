import 'package:flutter/material.dart';
import 'statistic_card.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// Example usage of StatisticCard widget
/// 
/// This file demonstrates various ways to use the StatisticCard widget
/// to display agricultural metrics and statistics in the AgriLink app.
class StatisticCardExample extends StatelessWidget {
  const StatisticCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StatisticCard Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Simple Statistics (No Trends)
            Text(
              'Simple Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Total Farms',
              value: '3',
              icon: Icons.agriculture_outlined,
              color: AppColors.roleFarmer,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Active Listings',
              value: '12',
              icon: Icons.list_alt_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Pending Orders',
              value: '8',
              icon: Icons.hourglass_empty,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 2: Statistics with Positive Trends
            Text(
              'Statistics with Positive Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Revenue This Month',
              value: '25,450 ETB',
              icon: Icons.attach_money,
              color: AppColors.success,
              trend: '+12%',
              trendPositive: true,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Completed Deliveries',
              value: '47',
              icon: Icons.check_circle_outlined,
              color: AppColors.roleTransporter,
              trend: '+8',
              trendPositive: true,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Customer Satisfaction',
              value: '98%',
              icon: Icons.sentiment_satisfied_alt,
              color: AppColors.tertiaryDark,
              trend: '+3%',
              trendPositive: true,
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 3: Statistics with Negative Trends
            Text(
              'Statistics with Negative Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Pending Inspections',
              value: '5',
              icon: Icons.pending_actions,
              color: AppColors.error,
              trend: '-2',
              trendPositive: false,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            const StatisticCard(
              label: 'Transport Delays',
              value: '3',
              icon: Icons.timer_off,
              color: AppColors.warning,
              trend: '-40%',
              trendPositive: false,
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 4: Role-Specific Statistics
            Text(
              'Farmer Dashboard Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            Wrap(
              spacing: AppTokens.spaceM,
              runSpacing: AppTokens.spaceM,
              children: const [
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Total Produce',
                    value: '2,450 kg',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.roleFarmer,
                    trend: '+150 kg',
                    trendPositive: true,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Sold This Week',
                    value: '850 kg',
                    icon: Icons.point_of_sale,
                    color: AppColors.success,
                    trend: '+10%',
                    trendPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 5: Buyer Dashboard Statistics
            Text(
              'Buyer Dashboard Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            Wrap(
              spacing: AppTokens.spaceM,
              runSpacing: AppTokens.spaceM,
              children: const [
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Orders This Month',
                    value: '23',
                    icon: Icons.shopping_cart_outlined,
                    color: AppColors.roleBuyer,
                    trend: '+5',
                    trendPositive: true,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Cart Items',
                    value: '7',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Saved Farmers',
                    value: '12',
                    icon: Icons.favorite_outlined,
                    color: AppColors.error,
                    trend: '+3',
                    trendPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 6: Transporter Dashboard Statistics
            Text(
              'Transporter Dashboard Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            Wrap(
              spacing: AppTokens.spaceM,
              runSpacing: AppTokens.spaceM,
              children: const [
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Active Deliveries',
                    value: '6',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.roleTransporter,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Earnings',
                    value: '18,200 ETB',
                    icon: Icons.payments_outlined,
                    color: AppColors.success,
                    trend: '+2,500',
                    trendPositive: true,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Completed Trips',
                    value: '142',
                    icon: Icons.done_all,
                    color: AppColors.tertiaryDark,
                    trend: '+12',
                    trendPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 7: Bureau Officer Dashboard Statistics
            Text(
              'Bureau Officer Dashboard Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            Wrap(
              spacing: AppTokens.spaceM,
              runSpacing: AppTokens.spaceM,
              children: const [
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Inspections',
                    value: '34',
                    icon: Icons.verified_outlined,
                    color: AppColors.roleBureau,
                    trend: '+6',
                    trendPositive: true,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Pending Reports',
                    value: '8',
                    icon: Icons.description_outlined,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: StatisticCard(
                    label: 'Compliance Rate',
                    value: '94%',
                    icon: Icons.analytics_outlined,
                    color: AppColors.success,
                    trend: '+2%',
                    trendPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),

            // Section 8: Grid Layout Example (2 columns)
            Text(
              'Grid Layout (2 columns)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTokens.spaceM),
            
            Row(
              children: const [
                Expanded(
                  child: StatisticCard(
                    label: 'Total Views',
                    value: '1,234',
                    icon: Icons.visibility_outlined,
                    color: AppColors.primary,
                    trend: '+89',
                    trendPositive: true,
                  ),
                ),
                SizedBox(width: AppTokens.spaceM),
                Expanded(
                  child: StatisticCard(
                    label: 'Engagement',
                    value: '87%',
                    icon: Icons.thumb_up_outlined,
                    color: AppColors.tertiaryDark,
                    trend: '+5%',
                    trendPositive: true,
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
