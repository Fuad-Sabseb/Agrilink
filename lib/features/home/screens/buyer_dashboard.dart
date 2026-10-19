import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/widgets/refreshable_content.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData('buyer');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = authProvider.user;

    return RefreshableContent(
      onRefresh: () => dashboardProvider.refreshDashboard('buyer'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGreeting(context, user?.fullName ?? 'Buyer'),
          const SizedBox(height: 24),
          _buildSearchBar(context),
          const SizedBox(height: 24),
          if (dashboardProvider.data != null) _buildQuickStats(context, dashboardProvider.data!),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          if (dashboardProvider.data != null) _buildFeaturedProduce(context, dashboardProvider.data!),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String name) {
    return Text('Welcome, $name', style: Theme.of(context).textTheme.headlineMedium);
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search produce, farmers...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      readOnly: true,
    );
  }

  Widget _buildQuickStats(BuildContext context, Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('${data['activeOrders'] ?? 0} Orders')))),
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('${data['favorites'] ?? 0} Favorites')))),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      children: [
        Card(child: InkWell(onTap: () {}, child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart), Text('Browse')])))),
        Card(child: InkWell(onTap: () {}, child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.list), Text('My Orders')])))),
      ],
    );
  }

  Widget _buildFeaturedProduce(BuildContext context, Map<String, dynamic> data) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Featured Produce', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text('Featured items will appear here'),
      ],
    );
  }
}
