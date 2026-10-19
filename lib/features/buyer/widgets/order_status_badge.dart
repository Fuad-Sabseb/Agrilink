import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Order Status Badge Widget
/// Reusable component for displaying order status with color-coded indicators
/// Supports all order statuses: pending, confirmed, in_transit, delivered, completed, cancelled, rejected
class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;
  final bool compact;
  final EdgeInsetsGeometry? padding;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.compact = false,
    this.padding,
  });

  /// Get color based on order status
  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.accent;
      case 'confirmed':
        return AppColors.info;
      case 'in_transit':
      case 'in transit':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get display label for status
  String _getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_transit':
      case 'in transit':
        return compact ? 'In Transit' : 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  /// Get icon based on status
  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_transit':
      case 'in transit':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.done_all;
      case 'completed':
        return Icons.verified;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.block;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusLabel = _getStatusLabel();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 4 : 6,
          ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              statusIcon,
              size: compact ? 14 : 16,
              color: statusColor,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            statusLabel,
            style: (compact ? AppTypography.bodySmall : AppTypography.bodyMedium).copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment Status Badge Widget
/// Similar to OrderStatusBadge but for payment status
class PaymentStatusBadge extends StatelessWidget {
  final String paymentStatus;
  final bool showIcon;
  final bool compact;

  const PaymentStatusBadge({
    super.key,
    required this.paymentStatus,
    this.showIcon = true,
    this.compact = false,
  });

  Color _getPaymentColor() {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return AppColors.accent;
      case 'paid':
      case 'completed':
        return AppColors.success;
      case 'partial':
        return AppColors.warning;
      case 'refunded':
        return AppColors.info;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPaymentLabel() {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'paid':
      case 'completed':
        return 'Paid';
      case 'partial':
        return 'Partial';
      case 'refunded':
        return 'Refunded';
      case 'failed':
        return 'Failed';
      default:
        return paymentStatus;
    }
  }

  IconData _getPaymentIcon() {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
      case 'completed':
        return Icons.check_circle;
      case 'partial':
        return Icons.pie_chart_outline;
      case 'refunded':
        return Icons.replay;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPaymentColor();
    final label = _getPaymentLabel();
    final icon = _getPaymentIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: compact ? 14 : 16,
              color: color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            label,
            style: (compact ? AppTypography.bodySmall : AppTypography.bodyMedium).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
