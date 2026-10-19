import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../models/order_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../widgets/order_request_card.dart';
import '../screens/order_detail_screen.dart';

/// Order Requests Tab showing incoming orders for farmer
class OrderRequestsTab extends StatefulWidget {
  const OrderRequestsTab({super.key});

  @override
  State<OrderRequestsTab> createState() => _OrderRequestsTabState();
}

class _OrderRequestsTabState extends State<OrderRequestsTab>
    with AutomaticKeepAliveClientMixin {
  final _sessionService = SessionService();
  String _selectedFilter = 'all'; // all, pending, confirmed, in_transit, delivered, completed

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshData() async {
    final userId = _sessionService.currentUserId;
    if (userId != null) {
      await context.read<OrderProvider>().loadFarmerOrders(userId);
    }
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'all') {
      return orders;
    }
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  Future<void> _handleAcceptOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: Text(
          'Are you sure you want to accept this order from ${order.buyerName}?\n\n'
          'Quantity: ${order.quantityOrdered} ${order.unit}\n'
          'Total: ETB ${order.totalPrice.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<OrderProvider>().confirmOrder(order.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order accepted successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _refreshData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to accept order: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRejectOrder(OrderModel order) async {
    final TextEditingController reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject this order from ${order.buyerName}?',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g., Out of stock, Price changed',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<OrderProvider>().rejectOrder(order.id, 'Rejected by farmer');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order rejected'),
              backgroundColor: AppColors.info,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _refreshData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject order: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final provider = context.watch<OrderProvider>();
    final allOrders = provider.farmerOrders;
    final filteredOrders = _getFilteredOrders(allOrders);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', allOrders.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    'pending',
                    allOrders.where((o) => o.status == 'pending').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Confirmed',
                    'confirmed',
                    allOrders.where((o) => o.status == 'confirmed').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'In Transit',
                    'in_transit',
                    allOrders.where((o) => o.status == 'in_transit').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Delivered',
                    'delivered',
                    allOrders.where((o) => o.status == 'delivered').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Completed',
                    'completed',
                    allOrders.where((o) => o.status == 'completed').length,
                  ),
                ],
              ),
            ),
          ),

          // Statistics Bar
          _buildStatisticsBar(provider),

          // Orders List
          Expanded(
            child: _buildOrdersList(provider, filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textOnPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatisticsBar(OrderProvider provider) {
    final stats = provider.farmerStatistics;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Orders',
            '${stats['totalOrders'] ?? 0}',
            Icons.receipt_long_outlined,
            AppColors.primary,
          ),
          _buildStatItem(
            'Revenue',
            'ETB ${(stats['totalRevenue'] ?? 0).toStringAsFixed(0)}',
            Icons.attach_money,
            AppColors.success,
          ),
          _buildStatItem(
            'Avg Order',
            'ETB ${(stats['averageOrderValue'] ?? 0).toStringAsFixed(0)}',
            Icons.trending_up,
            AppColors.info,
          ),
          _buildStatItem(
            'Pending',
            '${stats['pendingOrders'] ?? 0}',
            Icons.pending_outlined,
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(OrderProvider provider, List<OrderModel> orders) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading orders...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load orders',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Unknown error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter != 'all' ? 'No orders found' : 'No orders yet',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter != 'all'
                  ? 'Try selecting a different filter'
                  : 'Orders will appear here when buyers place orders',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderRequestCard(
            order: order,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
              if (result == true) {
                _refreshData();
              }
            },
            onAccept: order.status == 'pending'
                ? () => _handleAcceptOrder(order)
                : null,
            onReject: order.status == 'pending'
                ? () => _handleRejectOrder(order)
                : null,
          );
        },
      ),
    );
  }
}
