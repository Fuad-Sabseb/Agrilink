import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/widgets/refreshable_content.dart';

class TransporterDashboard extends StatefulWidget {
  const TransporterDashboard({super.key});

  @override
  State<TransporterDashboard> createState() => _TransporterDashboardState();
}

class _TransporterDashboardState extends State<TransporterDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData('transporter');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = authProvider.user;

    return RefreshableContent(
      onRefresh: () => dashboardProvider.refreshDashboard('transporter'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGreeting(context, user?.fullName ?? 'Transporter'),
          const SizedBox(height: 24),
          _buildSearchBar(context),
          const SizedBox(height: 24),
          if (dashboardProvider.data != null) _buildQuickStats(context, dashboardProvider.data!),
          const SizedBox(height: 24),
          _buildQuickActions(context),
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
        hintText: 'Search trips, jobs...',
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
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('${data['activeTrips'] ?? 0} Active Trips')))),
        Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('${data['availableJobs'] ?? 0} Available')))),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      children: [
        Card(child: InkWell(onTap: () {}, child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.local_shipping), Text('View Trips')])))),
        Card(child: InkWell(onTap: () {}, child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.work), Text('Available Jobs')])))),
      ],
    );
  }
}
