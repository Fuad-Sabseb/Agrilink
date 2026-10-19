import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../models/order_model.dart';
import 'package:hive/hive.dart';
import '../../../core/models/farmer_model.dart';
import '../dialogs/contact_farmer_dialog.dart';
import '../widgets/order_status_timeline.dart';
import '../../../routes/app_routes.dart';

/// Order Details Screen - Detailed order view with tracking
class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Share order details
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.id,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy - HH:mm').format(order.createdAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Timeline
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OrderStatusTimeline(order: order),
                ],
              ),
            ),

            const Divider(height: 1),

            // Delivery Information
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Address',
                    order.deliveryLocation,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.location_city_outlined,
                    'City',
                    order.deliveryLocation,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Phone',
                    order.buyerName,
                  ),

                  if (order.deliveryInstructions != null && order.deliveryInstructions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.note_outlined,
                      'Notes',
                      order.deliveryInstructions!,
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Order Items
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Single produce item
                  _buildOrderItem(
                    order.produceName,
                    order.quantityOrdered,
                    order.unit,
                    order.pricePerUnit,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Price Summary
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildPriceRow('Subtotal', order.totalPrice),
                  const SizedBox(height: 8),

                  // _buildPriceRow('Delivery Fee', 0.0),
                  const SizedBox(height: 8),

                  // _buildPriceRow('Tax', 0.0),
                  const Divider(height: 24),

                  _buildPriceRow('Total', order.totalPrice, isTotal: true),
                  const SizedBox(height: 16),

                  // Payment method
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getPaymentIcon(order.paymentMethod),
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatPaymentMethod(order.paymentMethod),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _buildPaymentStatusBadge(order.paymentStatus),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Action buttons
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ETB',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(String name, double quantity, String unit, double pricePerUnit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('$quantity $unit', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            'ETB ${(quantity * pricePerUnit).toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }


  Widget _buildPaymentStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
        color = AppColors.success;
        label = 'Paid';
        break;
      case 'pending':
        color = AppColors.secondary;
        label = 'Pending';
        break;
      case 'failed':
        color = AppColors.error;
        label = 'Failed';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Contact farmer button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final farmer = Farmer(
                    id: order.farmerId,
                    name: order.farmerName,
                    phoneNumber: '+251911223344',
                    woreda: order.pickupLocation.split(',').first.trim(),
                    kebele: 'Kebele 01',
                    registeredAt: DateTime.now().subtract(const Duration(days: 90)),
                  );
                  showContactFarmerDialog(context, farmer: farmer);
                },
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Contact Farmer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Cancel/Track order button
            Expanded(
              child: order.status == 'pending'
                  ? FilledButton.icon(
                      onPressed: () {
                        _showCancelDialog(context);
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Order'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: () {
                        // Track order with GPS/map
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Live tracking feature coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('Track Order'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ),

            // Pay Now button for confirmed unpaid orders
            if (order.status == 'confirmed' && order.paymentStatus != 'paid') ...[
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.payment,
                      arguments: order,
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Cancel Order', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                if (Hive.isBoxOpen('orders')) {
                  final orderBox = Hive.box<OrderModel>('orders');
                  final existing = orderBox.get(order.id) ?? order;
                  final cancelled = existing.copyWith(
                    status: 'cancelled',
                    cancellationReason: 'Cancelled by buyer',
                    updatedAt: DateTime.now(),
                  );
                  await orderBox.put(order.id, cancelled);
                }
              } catch (_) {}

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order ${order.id} cancelled successfully'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash_on_delivery':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'mobile_money':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  String _formatPaymentMethod(String method) {
    return method
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
