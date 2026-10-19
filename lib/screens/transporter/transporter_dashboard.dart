import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../models/order_model.dart';
import '../../models/logistics_model.dart';
import '../../routes/app_routes.dart';

class TransporterDashboard extends StatelessWidget {
  const TransporterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final user = sessionService.currentUser;
    final userId = user?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transporter Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await sessionService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final isOrdersOpen = Hive.isBoxOpen('orders');
          final isLogisticsOpen = Hive.isBoxOpen('logistics');

          if (isOrdersOpen && isLogisticsOpen) {
            return ValueListenableBuilder<Box<OrderModel>>(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, orderBox, _) {
                return ValueListenableBuilder<Box<LogisticsModel>>(
                  valueListenable: Hive.box<LogisticsModel>('logistics').listenable(),
                  builder: (context, logisticsBox, _) {
                    final availablePickupsCount = orderBox.values.where((o) => o.status == 'confirmed').length;
                    final myDeliveries = logisticsBox.values.where((d) => d.transporterId == userId).toList();
                    final inTransitCount = myDeliveries.where((d) => d.status == 'in_transit' || d.status == 'awaiting').length;
                    final deliveredCount = myDeliveries.where((d) => d.status == 'delivered').length;

                    return _buildContent(
                      context,
                      user?.fullName ?? "Transporter",
                      availablePickupsCount,
                      inTransitCount,
                      deliveredCount,
                    );
                  },
                );
              },
            );
          }

          // Fallback if Hive boxes are not opened yet
          return _buildContent(
            context,
            user?.fullName ?? "Transporter",
            0,
            0,
            0,
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String userName,
    int availablePickupsCount,
    int inTransitCount,
    int deliveredCount,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome, $userName!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is your delivery overview',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Available\nPickups',
                  availablePickupsCount.toString(),
                  Icons.map,
                  AppColors.accent,
                  () => Navigator.pushNamed(context, AppRoutes.availableJobs),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'In\nTransit',
                  inTransitCount.toString(),
                  Icons.local_shipping,
                  AppColors.tertiary,
                  () => Navigator.pushNamed(context, AppRoutes.activeDeliveries),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Total Delivered',
            deliveredCount.toString(),
            Icons.check_circle,
            AppColors.success,
            () => Navigator.pushNamed(context, AppRoutes.earnings),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.availableJobs),
            icon: const Icon(Icons.search),
            label: const Text('Browse Available Jobs'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.activeDeliveries),
            icon: const Icon(Icons.local_shipping_outlined),
            label: const Text('Active Deliveries & POD'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.earnings),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Earnings & Transactions'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 3,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
