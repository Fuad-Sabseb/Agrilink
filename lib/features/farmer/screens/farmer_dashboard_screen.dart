import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/produce_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../tabs/my_produce_tab.dart';
import '../tabs/order_requests_tab.dart';
import '../tabs/transport_requests_tab.dart';
import '../tabs/notifications_tab.dart';

/// Production-ready Farmer Dashboard with tabs and real-time statistics
class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _sessionService = SessionService();
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (_isInitialized) return;

    final userId = _sessionService.currentUserId;
    if (userId == null) return;

    try {
      // Load all data in parallel for better performance
      await Future.wait([
        context.read<ProduceProvider>().loadFarmerProduce(userId),
        context.read<OrderProvider>().loadFarmerOrders(userId),
        context.read<TransportProvider>().loadFarmerTransportRequests(userId),
        context.read<NotificationProvider>().loadUserNotifications(),
      ]);

      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: $e'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.textOnPrimary,
              onPressed: () {
                setState(() => _isInitialized = false);
                _loadDashboardData();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _sessionService.currentUser;
    final notificationProvider = context.watch<NotificationProvider>();
    final unreadCount = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farmer Dashboard',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (user != null)
              Text(
                user.fullName,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              setState(() => _isInitialized = false);
              await _loadDashboardData();
            },
            tooltip: 'Refresh',
          ),
          // Profile/Settings
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(FarmerRoutes.profile);
            },
            tooltip: 'Profile',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textOnPrimary,
          indicatorWeight: 3,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.6),
          labelStyle: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.labelMedium,
          tabs: [
            const Tab(
              icon: Icon(Icons.inventory_2_outlined, size: 20),
              text: 'My Produce',
            ),
            const Tab(
              icon: Icon(Icons.receipt_long_outlined, size: 20),
              text: 'Orders',
            ),
            const Tab(
              icon: Icon(Icons.local_shipping_outlined, size: 20),
              text: 'Transport',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                child: const Icon(Icons.notifications_outlined, size: 20),
              ),
              text: 'Notifications',
            ),
          ],
        ),
      ),
      body: !_isInitialized
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: const [
                MyProduceTab(),
                OrderRequestsTab(),
                TransportRequestsTab(),
                NotificationsTab(),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your dashboard...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
