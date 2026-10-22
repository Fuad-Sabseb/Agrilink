import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/navigation/tab_navigation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/produce_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/statistic_card.dart';
import '../../../core/widgets/action_card.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../routes/app_routes.dart';

/// Enhanced Farmer Dashboard with AppShell and statistics
class EnhancedFarmerDashboard extends StatefulWidget {
  const EnhancedFarmerDashboard({super.key});

  @override
  State<EnhancedFarmerDashboard> createState() =>
      _EnhancedFarmerDashboardState();
}

class _EnhancedFarmerDashboardState extends State<EnhancedFarmerDashboard> {
  final _sessionService = SessionService();
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    final userId = _sessionService.currentUserId;
    if (userId == null) return;

    try {
      await Future.wait([
        context.read<ProduceProvider>().loadFarmerProduce(userId),
        context.read<OrderProvider>().loadFarmerOrders(userId),
        context.read<NotificationProvider>().loadUserNotifications(userId),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _sessionService.currentUser;
    final notificationProvider = context.watch<NotificationProvider>();

    return AppShell(
      currentIndex: _currentIndex,
      onNavigationChange: (index) {
        setState(() => _currentIndex = index);
      },
      showBottomNav: true,
      showDrawer: true,
      title: _getTitle(),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadDashboardData,
        ),
      ],
      child: _buildContent(),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'My Produce';
      case 2:
        return 'Orders';
      case 3:
        return 'Marketplace';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return _buildMyProduceScreen();
      case 2:
        return _buildOrdersScreen();
      case 3:
        return _buildMarketplaceScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    final produceProvider = context.watch<ProduceProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final user = _sessionService.currentUser;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(user),
            const SizedBox(height: AppTokens.spaceXL),

            // Statistics Cards
            Text(
              'Overview',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildStatisticsGrid(produceProvider, orderProvider),
            const SizedBox(height: AppTokens.spaceXL),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildQuickActions(),
            const SizedBox(height: AppTokens.spaceXL),

            // Recent Activity
            Text(
              'Recent Activity',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildRecentActivity(orderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(dynamic user) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppTokens.spaceXXS),
          Text(
            user?.fullName ?? 'Farmer',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            "Let's grow your farm business today!",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(
    ProduceProvider produceProvider,
    OrderProvider orderProvider,
  ) {
    final activeListings = produceProvider.produce.length;
    final pendingOrders = orderProvider.orders
        .where((o) => o.status.toLowerCase() == 'pending')
        .length;
    final completedOrders = orderProvider.orders
        .where((o) => o.status.toLowerCase() == 'completed')
        .length;
    final totalRevenue = orderProvider.orders
        .where((o) => o.status.toLowerCase() == 'completed')
        .fold<double>(0, (sum, order) => sum + order.totalAmount);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTokens.spaceM,
      mainAxisSpacing: AppTokens.spaceM,
      childAspectRatio: 1.3,
      children: [
        StatisticCard(
          label: 'Active Listings',
          value: '$activeListings',
          icon: Icons.inventory_2_outlined,
          color: AppColors.primary,
          trend: activeListings > 0 ? '+$activeListings' : null,
          trendPositive: true,
        ),
        StatisticCard(
          label: 'Pending Orders',
          value: '$pendingOrders',
          icon: Icons.pending_actions,
          color: AppColors.warning,
        ),
        StatisticCard(
          label: 'Completed',
          value: '$completedOrders',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        StatisticCard(
          label: 'Revenue',
          value: '${totalRevenue.toStringAsFixed(0)} ETB',
          icon: Icons.attach_money,
          color: AppColors.accent,
          trend: totalRevenue > 0 ? '+12%' : null,
          trendPositive: true,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ActionCard(
          title: 'Where Should I Sell?',
          description: 'Compare market prices to find the best buyers',
          icon: Icons.analytics_outlined,
          primaryColor: AppColors.primary,
          isHighlight: true,
          onTap: () {
            Navigator.pushNamed(context, '/farmer/market-intelligence');
          },
        ),
        const SizedBox(height: AppTokens.spaceM),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'Add Produce',
                description: 'List new produce for sale',
                icon: Icons.add_circle_outline,
                primaryColor: AppColors.success,
                onTap: () {
                  Navigator.pushNamed(context, '/farmer/add-produce');
                },
              ),
            ),
            const SizedBox(width: AppTokens.spaceM),
            Expanded(
              child: ActionCard(
                title: 'My Farms',
                description: 'Manage your farms',
                icon: Icons.agriculture_outlined,
                primaryColor: AppColors.roleFarmer,
                onTap: () {
                  Navigator.pushNamed(context, '/farmer/farms');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(OrderProvider orderProvider) {
    final recentOrders = orderProvider.orders.take(5).toList();

    if (recentOrders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceXL),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppTokens.spaceM),
                Text(
                  'No recent orders',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentOrders.map((order) {
        return DashboardCard(
          title: 'Order #${order.id.substring(0, 8)}',
          subtitle: '${order.totalAmount.toStringAsFixed(2)} ETB',
          icon: Icons.receipt_long_outlined,
          iconColor: _getOrderStatusColor(order.status),
          trailing: Chip(
            label: Text(
              order.status,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: _getOrderStatusColor(order.status).withOpacity(0.1),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/farmer/order-details',
              arguments: order,
            );
          },
        );
      }).toList(),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.tertiary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildMyProduceScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text(
            'My Produce',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'This section will display your produce listings',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text(
            'Orders',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'This section will display all your orders',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text(
            'Marketplace',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Browse produce from other farmers',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
