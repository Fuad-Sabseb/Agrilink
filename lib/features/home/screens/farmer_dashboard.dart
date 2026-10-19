import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/widgets/refreshable_content.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData('farmer');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = authProvider.user;

    return RefreshableContent(
      onRefresh: () => dashboardProvider.refreshDashboard('farmer'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting
          _buildGreeting(context, user?.fullName ?? 'Farmer'),
          const SizedBox(height: 24),

          // Search bar
          _buildSearchBar(context),
          const SizedBox(height: 24),

          // Quick stats
          if (dashboardProvider.data != null)
            _buildQuickStats(context, dashboardProvider.data!),
          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActions(context),
          const SizedBox(height: 24),

          // Market prices
          if (dashboardProvider.data != null)
            _buildMarketPrices(context, dashboardProvider.data!),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search produce, buyers, orders...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      onTap: () {
        // Navigate to search screen
      },
      readOnly: true,
    );
  }

  Widget _buildQuickStats(BuildContext context, Map<String, dynamic> data) {
    final activeOrders = data['activeOrders'] ?? 0;
    final totalListings = data['totalListings'] ?? 0;
    final monthlyRevenue = data['monthlyRevenue'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Active Orders',
            '$activeOrders',
            Icons.shopping_bag,
            AppColors.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Listings',
            '$totalListings',
            Icons.inventory,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Revenue',
            'ETB ${monthlyRevenue.toStringAsFixed(0)}',
            Icons.trending_up,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(context, 'Post Produce', Icons.add_circle, AppColors.primary),
            _buildActionCard(context, 'View Orders', Icons.list_alt, AppColors.tertiary),
            _buildActionCard(context, 'My Farms', Icons.agriculture, AppColors.secondary),
            _buildActionCard(context, 'Earnings', Icons.account_balance_wallet, AppColors.accent),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to respective screen
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketPrices(BuildContext context, Map<String, dynamic> data) {
    final prices = (data['marketPrices'] as List?) ?? [];
    
    if (prices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Market Prices',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...prices.take(5).map((price) => _buildPriceItem(context, price)),
      ],
    );
  }

  Widget _buildPriceItem(BuildContext context, dynamic price) {
    final commodity = price['commodity'] ?? 'Unknown';
    final amount = price['price'] ?? 0.0;
    final unit = price['unit'] ?? 'kg';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.agriculture),
        ),
        title: Text(commodity),
        trailing: Text(
          'ETB $amount/$unit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
