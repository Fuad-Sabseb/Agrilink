import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../models/produce_model.dart';
import '../../models/order_model.dart';
import '../../routes/app_routes.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  final _sessionService = SessionService();

  Future<void> _handleLogout() async {
    await _sessionService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final user = _sessionService.currentUser;
    final userId = user?.id;

    final bool boxesOpen = Hive.isBoxOpen('produce') && Hive.isBoxOpen('orders');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: !boxesOpen
          ? _buildDashboardView(user, 0, 0)
          : ValueListenableBuilder<Box<ProduceModel>>(
              valueListenable: Hive.box<ProduceModel>('produce').listenable(),
              builder: (context, produceBox, _) {
                return ValueListenableBuilder<Box<OrderModel>>(
                  valueListenable: Hive.box<OrderModel>('orders').listenable(),
                  builder: (context, orderBox, _) {
                    final totalProduce = produceBox.values.where((p) => p.farmerId == userId).length;
                    final pendingOrders = orderBox.values.where((o) => o.farmerId == userId && o.status == 'pending').length;

                    return _buildDashboardView(user, totalProduce, pendingOrders);
                  },
                );
              },
            ),
    );
  }

  Widget _buildDashboardView(dynamic user, int totalProduce, int pendingOrders) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user?.fullName ?? "Farmer"}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Overview
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'My Produce',
                  totalProduce.toString(),
                  Icons.inventory_2_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending Orders',
                  pendingOrders.toString(),
                  Icons.pending_actions_outlined,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
