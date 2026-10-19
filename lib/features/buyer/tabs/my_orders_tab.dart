import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../models/order_model.dart';
import '../widgets/order_card.dart';
import '../screens/order_details_screen.dart';
import '../../../core/utils/user_context.dart';

/// My Orders Tab - Order history and tracking
class MyOrdersTab extends StatefulWidget {
  const MyOrdersTab({super.key});

  @override
  State<MyOrdersTab> createState() => _MyOrdersTabState();
}

class _MyOrdersTabState extends State<MyOrdersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedFilter = _getFilterForIndex(_tabController.index);
      });
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getFilterForIndex(int index) {
    switch (index) {
      case 0:
        return 'all';
      case 1:
        return 'pending';
      case 2:
        return 'confirmed';
      case 3:
        return 'in_transit';
      case 4:
        return 'delivered';
      default:
        return 'all';
    }
  }

  Future<void> _loadOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    // Get current user ID from auth provider
    final userId = UserContext.getCurrentUserId(context);
    if (userId != null) {
      await orderProvider.fetchOrdersForBuyer(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status filter tabs
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'All Orders'),
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'In Transit'),
              Tab(text: 'Delivered'),
            ],
          ),
        ),

        // Orders list
        Expanded(
          child: Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (orderProvider.error != null) {
                return _buildErrorState(context, orderProvider);
              }

              final filteredOrders = _filterOrders(orderProvider.buyerOrders);

              if (filteredOrders.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return OrderCard(
                      order: order,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'all') {
      return orders;
    }

    return orders.where((order) {
      return order.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    String message;
    String submessage;

    switch (_selectedFilter) {
      case 'all':
        message = 'No Orders Yet';
        submessage = 'Start shopping to place your first order';
        break;
      default:
        final status = _selectedFilter.replaceAll('_', ' ');
        message = 'No ${_capitalize(status)} Orders';
        submessage = 'You don\'t have any orders with this status';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: AppColors.disabled,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            submessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (_selectedFilter == 'all') ...[
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                DefaultTabController.of(context).animateTo(0);
              },
              icon: const Icon(Icons.store),
              label: const Text('Browse Marketplace'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, OrderProvider orderProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Orders',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            orderProvider.error ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
