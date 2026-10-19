import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/order_model.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Order Detail Screen with full information and status management
class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Color _getStatusColor() {
    switch (_order.status) {
      case 'pending':
        return AppColors.accent;
      case 'confirmed':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'in_transit':
        return AppColors.info;
      case 'delivered':
        return AppColors.success;
      case 'completed':
        return AppColors.textSecondary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    return _order.status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _handleConfirmOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text(
          'Are you sure you want to confirm this order? '
          'The buyer will be notified and you\'ll be expected to fulfill the order.',
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
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<OrderProvider>().confirmOrder(_order.id);
        setState(() {
          _order = _order.copyWith(status: 'confirmed');
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order confirmed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to confirm order: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRejectOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: const Text(
          'Are you sure you want to reject this order? '
          'This action cannot be undone.',
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
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<OrderProvider>().rejectOrder(_order.id, 'Rejected by farmer');
        setState(() {
          _order = _order.copyWith(status: 'rejected');
        });
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order rejected'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject order: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleMarkInTransit() async {
    try {
      await context.read<OrderProvider>().markOrderInTransit(_order.id, 'transporter_tbd');
      setState(() {
        _order = _order.copyWith(status: 'in_transit');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order marked as in transit'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleMarkDelivered() async {
    try {
      await context.read<OrderProvider>().markOrderDelivered(_order.id);
      setState(() {
        _order = _order.copyWith(status: 'delivered');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order marked as delivered'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('MMMM dd, yyyy \'at\' hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(
          'Order Details',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 48,
                    color: statusColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusLabel(),
                    style: AppTypography.headlineMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${_order.id.substring(0, 12)}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Produce Information
                  _buildInfoCard(
                    'Produce Details',
                    Icons.agriculture_outlined,
                    AppColors.primary,
                    [
                      _buildInfoRow('Product', _order.produceName),
                      _buildInfoRow(
                        'Quantity',
                        '${_order.quantityOrdered} ${_order.unit}',
                      ),
                      _buildInfoRow(
                        'Price per ${_order.unit}',
                        currencyFormat.format(_order.pricePerUnit),
                      ),
                      _buildInfoRow(
                        'Total Amount',
                        currencyFormat.format(_order.totalPrice),
                        isBold: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Buyer Information
                  _buildInfoCard(
                    'Buyer Information',
                    Icons.person_outline,
                    AppColors.info,
                    [
                      _buildInfoRow('Name', _order.buyerName),
                      _buildInfoRow('Buyer ID', _order.buyerId.substring(0, 12)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Delivery Information
                  _buildInfoCard(
                    'Delivery Information',
                    Icons.local_shipping_outlined,
                    AppColors.accent,
                    [
                      _buildInfoRow('Pickup Location', _order.pickupLocation),
                      _buildInfoRow('Delivery Location', _order.deliveryLocation),
                      if (_order.deliveryInstructions != null)
                        _buildInfoRow('Instructions', _order.deliveryInstructions!),
                      if (_order.estimatedDeliveryDate != null)
                        _buildInfoRow(
                          'Est. Delivery',
                          DateFormat('MMM dd, yyyy').format(_order.estimatedDeliveryDate!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Information
                  _buildInfoCard(
                    'Payment Details',
                    Icons.payment_outlined,
                    AppColors.success,
                    [
                      _buildInfoRow('Method', _order.paymentMethod),
                      _buildInfoRow(
                        'Status',
                        _order.paymentStatus.split('_').map((w) => 
                          w[0].toUpperCase() + w.substring(1)
                        ).join(' '),
                      ),
                      // Paid amount tracking would be added here if needed
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Timeline
                  _buildInfoCard(
                    'Order Timeline',
                    Icons.timeline_outlined,
                    AppColors.textSecondary,
                    [
                      _buildInfoRow(
                        'Created',
                        dateFormat.format(_order.createdAt),
                      ),
                      if (_order.confirmedAt != null)
                        _buildInfoRow(
                          'Confirmed',
                          dateFormat.format(_order.confirmedAt!),
                        ),
                      if (_order.actualDeliveryDate != null)
                        _buildInfoRow(
                          'Delivered',
                          dateFormat.format(_order.actualDeliveryDate!),
                        ),
                      if (_order.completedAt != null)
                        _buildInfoRow(
                          'Completed',
                          dateFormat.format(_order.completedAt!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 100), // Space for bottom actions
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  IconData _getStatusIcon() {
    switch (_order.status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'in_transit':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.done_all;
      case 'completed':
        return Icons.verified_outlined;
      case 'cancelled':
        return Icons.close;
      default:
        return Icons.info_outline;
    }
  }

  Widget? _buildActionButtons() {
    if (_order.status == 'pending') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleRejectOrder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reject Order'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _handleConfirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Accept Order'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_order.status == 'confirmed') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _handleMarkInTransit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Mark as In Transit'),
          ),
        ),
      );
    }

    if (_order.status == 'in_transit') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _handleMarkDelivered,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Mark as Delivered'),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
