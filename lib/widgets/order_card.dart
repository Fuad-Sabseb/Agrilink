import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/produce_model.dart';
import '../core/services/user_service.dart';
import '../core/services/logistics_service.dart';
import '../core/theme/colors.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final ProduceModel? produce;
  final VoidCallback? onTap;
  final Widget? trailing;

  const OrderCard({
    super.key,
    required this.order,
    this.produce,
    this.onTap,
    this.trailing,
  });

  Color _getStatusColor() {
    switch (order.status.toLowerCase()) {
      case 'pending': return AppColors.accent; // Golden Harvest
      case 'confirmed': return AppColors.tertiary; // Sky Blue
      case 'picked_up': return AppColors.secondary; // Coffee Brown
      case 'in_transit': return AppColors.secondaryLight; // Light Coffee Brown
      case 'delivered': return AppColors.primary; // Rich Earth Green
      case 'cancelled': return AppColors.error; // Deep Terracotta
      default: return AppColors.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 0);
    final userService = UserService();
    final logisticsService = LogisticsService();

    final buyer = userService.getUserById(order.buyerId);
    final farmer = userService.getUserById(order.farmerId);

    // Find transporter if order has been picked up
    final logisticsEntries = logisticsService.getDeliveriesForOrder(order.id);
    final transporter = logisticsEntries.isNotEmpty
        ? userService.getUserById(logisticsEntries.first.transporterId)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: Crop name + status badge ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      produce?.cropName ?? 'Unknown Produce',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Text(
                      order.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Quantity + Price ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    'Qty Ordered',
                    '${order.quantityOrdered} ${produce?.unit ?? ''}',
                    Icons.shopping_cart_outlined,
                  ),
                  _buildInfoColumn(
                    'Total',
                    currencyFormat.format(order.totalPrice),
                    Icons.payments_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // ── People involved ──
              if (buyer != null)
                _buildPersonRow(Icons.person, 'Buyer', buyer.fullName, buyer.phone, AppColors.roleBuyer),
              if (farmer != null)
                _buildPersonRow(Icons.agriculture, 'Farmer', farmer.fullName, farmer.phone, AppColors.roleFarmer),
              if (transporter != null) ...[
                const SizedBox(height: 4),
                _buildPersonRow(Icons.local_shipping, 'Transporter', transporter.fullName, transporter.phone, AppColors.roleTransporter),
              ],

              const SizedBox(height: 8),

              // ── Delivery location + action button ──
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 15, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'To: ${order.deliveryLocation}',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonRow(IconData icon, String role, String name, String phone, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            '$role: ',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          Text(
            name,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
          Text(
            '($phone)',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}
