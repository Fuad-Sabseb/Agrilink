import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/statistic_card.dart';
import '../../../core/widgets/action_card.dart';
import '../../../core/widgets/dashboard_card.dart';

/// Enhanced Buyer Dashboard
class EnhancedBuyerDashboard extends StatefulWidget {
  const EnhancedBuyerDashboard({super.key});

  @override
  State<EnhancedBuyerDashboard> createState() => _EnhancedBuyerDashboardState();
}

class _EnhancedBuyerDashboardState extends State<EnhancedBuyerDashboard> {
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
        context.read<CartProvider>().loadCart(userId),
        context.read<OrderProvider>().loadBuyerOrders(userId),
        context.read<FavoritesProvider>().loadFavorites(userId),
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
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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
        return 'Buyer Dashboard';
      case 1:
        return 'Browse Marketplace';
      case 2:
        return 'My Cart';
      case 3:
        return 'My Orders';
      default:
        return 'Buyer Dashboard';
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
        return _buildMarketplaceScreen();
      case 2:
        return _buildCartScreen();
      case 3:
        return _buildOrdersScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
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

            // Statistics
            Text(
              'Shopping Overview',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildStatisticsGrid(cartProvider, orderProvider, favoritesProvider),
            const SizedBox(height: AppTokens.spaceXL),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildQuickActions(),
            const SizedBox(height: AppTokens.spaceXL),

            // Featured Categories
            Text(
              'Shop by Category',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTokens.spaceM),
            _buildCategoryCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppTokens.spaceXXS),
                Text(
                  user?.fullName ?? 'Buyer',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceS),
                Text(
                  'Find fresh produce from local farmers',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: AppColors.textOnPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(
    CartProvider cartProvider,
    OrderProvider orderProvider,
    FavoritesProvider favoritesProvider,
  ) {
    final cartItems = cartProvider.itemCount;
    final totalOrders = orderProvider.orders.length;
    final pendingOrders = orderProvider.orders
        .where((o) => o.status.toLowerCase() == 'pending')
        .length;
    final favorites = favoritesProvider.favorites.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTokens.spaceM,
      mainAxisSpacing: AppTokens.spaceM,
      childAspectRatio: 1.3,
      children: [
        StatisticCard(
          label: 'Cart Items',
          value: '$cartItems',
          icon: Icons.shopping_cart_outlined,
          color: AppColors.roleBuyer,
        ),
        StatisticCard(
          label: 'Total Orders',
          value: '$totalOrders',
          icon: Icons.receipt_long_outlined,
          color: AppColors.tertiaryDark,
        ),
        StatisticCard(
          label: 'Pending',
          value: '$pendingOrders',
          icon: Icons.hourglass_empty,
          color: AppColors.warning,
        ),
        StatisticCard(
          label: 'Favorites',
          value: '$favorites',
          icon: Icons.favorite_outline,
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        ActionCard(
          title: 'Browse Fresh Produce',
          description: 'Explore the marketplace for quality produce',
          icon: Icons.store_outlined,
          primaryColor: AppColors.roleBuyer,
          isHighlight: true,
          onTap: () {
            setState(() => _currentIndex = 1);
          },
        ),
        const SizedBox(height: AppTokens.spaceM),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'View Cart',
                description: 'Check your cart items',
                icon: Icons.shopping_cart_outlined,
                primaryColor: AppColors.tertiary,
                onTap: () {
                  setState(() => _currentIndex = 2);
                },
              ),
            ),
            const SizedBox(width: AppTokens.spaceM),
            Expanded(
              child: ActionCard(
                title: 'My Orders',
                description: 'Track your orders',
                icon: Icons.receipt_long_outlined,
                primaryColor: AppColors.warning,
                onTap: () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCards() {
    final categories = [
      {'name': 'Vegetables', 'icon': Icons.spa_outlined, 'color': AppColors.success},
      {'name': 'Fruits', 'icon': Icons.apple_outlined, 'color': AppColors.error},
      {'name': 'Grains', 'icon': Icons.grass_outlined, 'color': AppColors.warning},
      {'name': 'Coffee', 'icon': Icons.coffee_outlined, 'color': AppColors.secondary},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTokens.spaceM,
        mainAxisSpacing: AppTokens.spaceM,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () {
            // Navigate to category
          },
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
          child: Container(
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusM),
              border: Border.all(
                color: (category['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 40,
                  color: category['color'] as Color,
                ),
                const SizedBox(height: AppTokens.spaceS),
                Text(
                  category['name'] as String,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            color: AppColors.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('Browse Marketplace', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Marketplace integration coming soon',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('My Cart', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Cart items will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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
            color: AppColors.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTokens.spaceM),
          Text('My Orders', style: AppTypography.headlineMedium),
          const SizedBox(height: AppTokens.spaceS),
          Text(
            'Order history will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
