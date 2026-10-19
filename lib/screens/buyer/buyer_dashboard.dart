import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../models/produce_model.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../routes/app_routes.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final user = sessionService.currentUser;
    final userId = user?.id;

    final bool boxesOpen = Hive.isBoxOpen('produce') &&
        Hive.isBoxOpen('orders') &&
        Hive.isBoxOpen('payments');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buyer Dashboard'),
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
      body: !boxesOpen
          ? _buildDashboardView(context, user, 0, 0, 0)
          : ValueListenableBuilder<Box<ProduceModel>>(
              valueListenable: Hive.box<ProduceModel>('produce').listenable(),
              builder: (context, produceBox, _) {
                return ValueListenableBuilder<Box<OrderModel>>(
                  valueListenable: Hive.box<OrderModel>('orders').listenable(),
                  builder: (context, orderBox, _) {
                    return ValueListenableBuilder<Box<PaymentModel>>(
                      valueListenable: Hive.box<PaymentModel>('payments').listenable(),
                      builder: (context, paymentBox, _) {
                        final availableProduceCount = produceBox.values.where((p) => p.status == 'available').length;
                        final myOrders = orderBox.values.where((o) => o.buyerId == userId).toList();
                        final activeOrdersCount = myOrders.where((o) => o.status != 'delivered' && o.status != 'cancelled').length;
                        final pendingPaymentsCount = myOrders.where((o) {
                          if (o.status != 'confirmed') return false;
                          final paid = paymentBox.values.any((p) => p.orderId == o.id && p.status == 'completed');
                          return !paid;
                        }).length;

                        return _buildDashboardView(
                          context,
                          user,
                          availableProduceCount,
                          activeOrdersCount,
                          pendingPaymentsCount,
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildDashboardView(
    BuildContext context,
    dynamic user,
    int availableProduceCount,
    int activeOrdersCount,
    int pendingPaymentsCount,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome, ${user?.fullName ?? "Buyer"}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is your activity overview',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Available\nProduce',
                  availableProduceCount.toString(),
                  Icons.shopping_basket,
                  AppColors.primary,
                  () => Navigator.pushNamed(context, AppRoutes.browseProduce),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Active\nOrders',
                  activeOrdersCount.toString(),
                  Icons.local_shipping,
                  AppColors.secondary,
                  () => Navigator.pushNamed(context, AppRoutes.myOrders),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            'Pending Payments',
            pendingPaymentsCount.toString(),
            Icons.payment,
            AppColors.warning,
            () => Navigator.pushNamed(context, AppRoutes.myOrders),
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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.browseProduce),
            icon: const Icon(Icons.storefront),
            label: const Text('Browse Produce Marketplace'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.myOrders),
            icon: const Icon(Icons.receipt_long),
            label: const Text('View My Orders & History'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.marketIntelligence),
            icon: const Icon(Icons.trending_up),
            label: const Text('Market Prices & Demands'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color, [VoidCallback? onTap]) {
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
