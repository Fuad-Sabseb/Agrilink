import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Order Status Timeline Widget - Visual timeline of order progress
class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderStatusTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _buildTimelineSteps();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            return _TimelineStep(
              step: step,
              isLast: isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  List<_TimelineStepData> _buildTimelineSteps() {
    final steps = <_TimelineStepData>[];

    // Order placed
    steps.add(_TimelineStepData(
      title: 'Order Placed',
      subtitle: 'Your order has been received',
      date: order.createdAt,
      icon: Icons.check_circle,
      isCompleted: true,
    ));

    // Confirmed
    if (order.confirmedAt != null || _isStatusReached('confirmed')) {
      steps.add(_TimelineStepData(
        title: 'Order Confirmed',
        subtitle: 'Farmer has confirmed your order',
        date: order.confirmedAt,
        icon: Icons.verified,
        isCompleted: order.confirmedAt != null,
        isPending: order.status == 'pending',
      ));
    }

    // In Transit
    if (_isStatusReached('in_transit')) {
      steps.add(_TimelineStepData(
        title: 'In Transit',
        subtitle: 'Your order is on the way',
        date: null,
        icon: Icons.local_shipping,
        isCompleted: order.status == 'delivered' || 
                      order.status == 'completed',
        isPending: order.status == 'confirmed',
      ));
    }

    // Delivered
    if (_isStatusReached('delivered')) {
      steps.add(_TimelineStepData(
        title: 'Delivered',
        subtitle: 'Order has been delivered',
        date: order.actualDeliveryDate,
        icon: Icons.done_all,
        isCompleted: order.actualDeliveryDate != null,
        isPending: order.status == 'in_transit',
      ));
    }

    // Completed
    if (order.completedAt != null || order.status == 'completed') {
      steps.add(_TimelineStepData(
        title: 'Completed',
        subtitle: 'Thank you for your order!',
        date: order.completedAt,
        icon: Icons.celebration,
        isCompleted: order.completedAt != null,
        isPending: order.status == 'delivered',
      ));
    }

    // Cancelled
    if (order.status == 'cancelled') {
      steps.add(_TimelineStepData(
        title: 'Cancelled',
        subtitle: order.cancellationReason ?? 'Order was cancelled',
        date: null,
        icon: Icons.cancel,
        isCompleted: false,
        isCancelled: true,
      ));
    }

    return steps;
  }

  bool _isStatusReached(String status) {
    const statusOrder = [
      'pending',
      'confirmed',
      'in_transit',
      'delivered',
      'completed',
    ];

    final currentIndex = statusOrder.indexOf(order.status);
    final targetIndex = statusOrder.indexOf(status);

    return currentIndex >= targetIndex;
  }
}

class _TimelineStepData {
  final String title;
  final String subtitle;
  final DateTime? date;
  final IconData icon;
  final bool isCompleted;
  final bool isPending;
  final bool isCancelled;

  _TimelineStepData({
    required this.title,
    required this.subtitle,
    this.date,
    required this.icon,
    this.isCompleted = false,
    this.isPending = false,
    this.isCancelled = false,
  });
}

class _TimelineStep extends StatelessWidget {
  final _TimelineStepData step;
  final bool isLast;

  const _TimelineStep({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd • HH:mm');

    Color getColor() {
      if (step.isCancelled) return AppColors.error;
      if (step.isCompleted) return AppColors.success;
      if (step.isPending) return AppColors.accent;
      return AppColors.textSecondary;
    }

    final color = getColor();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: step.isCompleted || step.isPending || step.isCancelled
                      ? color.withValues(alpha: 0.15)
                      : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  step.icon,
                  size: 20,
                  color: color,
                ),
              ),
              // Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.isCompleted
                        ? color.withValues(alpha: 0.3)
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    step.title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: step.isCompleted || step.isPending || step.isCancelled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
                  Text(
                    step.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Date
                  if (step.date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(step.date!),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  // Pending indicator
                  if (step.isPending) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'In progress...',
                          style: AppTypography.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
