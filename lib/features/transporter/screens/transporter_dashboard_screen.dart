import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/models/trip_model.dart';
import 'available_jobs_screen.dart';
import 'active_deliveries_screen.dart';
import 'earnings_screen.dart';
import 'delivery_details_screen.dart';

/// Transporter Dashboard Screen - Main hub with stats and quick actions
class TransporterDashboardScreen extends StatefulWidget {
  const TransporterDashboardScreen({super.key});

  @override
  State<TransporterDashboardScreen> createState() => _TransporterDashboardScreenState();
}

class _TransporterDashboardScreenState extends State<TransporterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);
    await transportProvider.loadPendingTransportRequests();
    await transportProvider.loadActiveTrips();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transporter Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to notifications
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<TransportProvider>(
          builder: (context, transportProvider, child) {
            if (transportProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final availableJobsCount = transportProvider.filteredRequests.length;
            final activeTrips = transportProvider.filteredTrips.where((t) => 
              t.status == TripStatus.inTransit || t.status == TripStatus.pickedUp
            ).toList();
            final completedThisMonth = _getCompletedThisMonth(transportProvider.trips);
            final earningsThisMonth = _getEarningsThisMonth(transportProvider.trips);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.primaryContainer.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready to make deliveries today?',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        context,
                        'Available Jobs',
                        availableJobsCount.toString(),
                        Icons.work_outline,
                        AppColors.tertiary,
                        () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AvailableJobsScreen())),
                      ),
                      _buildStatCard(
                        context,
                        'Active Deliveries',
                        activeTrips.length.toString(),
                        Icons.local_shipping_outlined,
                        AppColors.secondary,
                        () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ActiveDeliveriesScreen())),
                      ),
                      _buildStatCard(
                        context,
                        'Completed',
                        completedThisMonth.toString(),
                        Icons.check_circle_outline,
                        AppColors.success,
                        null,
                      ),
                      _buildStatCard(
                        context,
                        'Earnings',
                        '${earningsThisMonth.toStringAsFixed(0)} ETB',
                        Icons.attach_money,
                        AppColors.accent,
                        () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const EarningsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active deliveries section
                  if (activeTrips.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Deliveries',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, 
                            MaterialPageRoute(builder: (_) => const ActiveDeliveriesScreen())),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...activeTrips.take(2).map((trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildActiveDeliveryCard(context, trip),
                    )),
                  ],

                  // Quick actions
                  const SizedBox(height: 24),
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildQuickAction(
                        context,
                        'Browse Jobs',
                        Icons.work_outline,
                        AppColors.tertiary,
                        () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AvailableJobsScreen())),
                      ),
                      _buildQuickAction(
                        context,
                        'My Deliveries',
                        Icons.local_shipping_outlined,
                        AppColors.secondary,
                        () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ActiveDeliveriesScreen())),
                      ),
                      _buildQuickAction(
                        context,
                        'Earnings',
                        Icons.account_balance_wallet_outlined,
                        AppColors.accent,
                        () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const EarningsScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDeliveryCard(BuildContext context, Trip trip) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_shipping, color: AppColors.secondary),
        ),
        title: Text('Delivery #${trip.id.length >= 8 ? trip.id.substring(0, 8) : trip.id}'),
        subtitle: Text(trip.deliveryLocation),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliveryDetailsScreen(delivery: trip),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCompletedThisMonth(List<Trip> trips) {
    final now = DateTime.now();
    return trips.where((t) => 
      t.status == TripStatus.delivered &&
      t.actualDeliveryTime != null &&
      t.actualDeliveryTime!.year == now.year &&
      t.actualDeliveryTime!.month == now.month
    ).length;
  }

  double _getEarningsThisMonth(List<Trip> trips) {
    final now = DateTime.now();
    return trips.where((t) => 
      t.status == TripStatus.delivered &&
      t.actualDeliveryTime != null &&
      t.actualDeliveryTime!.year == now.year &&
      t.actualDeliveryTime!.month == now.month
    ).fold(0.0, (sum, t) => sum + t.totalCost);
  }
}
