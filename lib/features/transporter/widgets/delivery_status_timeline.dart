import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/trip_model.dart';
import '../../../core/theme/colors.dart';

/// Delivery Status Timeline - Visual delivery progress
class DeliveryStatusTimeline extends StatelessWidget {
  final Trip delivery;

  const DeliveryStatusTimeline({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    final currentStepIndex = _getCurrentStepIndex();

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index < currentStepIndex;
        final isCurrent = index == currentStepIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                // Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.disabled,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isCurrent
                            ? step['icon']
                            : step['icon'],
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                // Line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Step content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                    ),
                    if (step['time'] != null) ...[
                       const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, HH:mm').format(step['time']),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                    if (step['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step['description'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Map<String, dynamic>> _buildSteps() {
    return [
      {
        'title': 'Scheduled',
        'icon': Icons.schedule,
        'time': delivery.scheduledPickupTime,
        'description': 'Job accepted and scheduled',
      },
      {
        'title': 'Picked Up',
        'icon': Icons.inventory,
        'time': delivery.actualPickupTime,
        'description': 'Goods collected from ${delivery.pickupLocation}',
      },
      {
        'title': 'In Transit',
        'icon': Icons.local_shipping,
        'time': delivery.actualPickupTime,
        'description': delivery.currentLocation != null
            ? 'Current: ${delivery.currentLocation}'
            : 'On the way to destination',
      },
      {
        'title': 'Delivered',
        'icon': Icons.check_circle,
        'time': delivery.actualDeliveryTime,
        'description': 'Goods delivered to ${delivery.deliveryLocation}',
      },
      {
        'title': 'Completed',
        'icon': Icons.done_all,
        'time': delivery.actualDeliveryTime,
        'description': 'Trip completed and payment processed',
      },
    ];
  }

  int _getCurrentStepIndex() {
    switch (delivery.status) {
      case TripStatus.matched:
        return 0;
      case TripStatus.pickedUp:
        return 1;
      case TripStatus.inTransit:
        return 2;
      case TripStatus.delivered:
        return 3;
      case TripStatus.cancelled:
        return 0;
    }
  }
}
