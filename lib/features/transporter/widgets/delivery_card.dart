import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/trip_model.dart';

/// Delivery Card - Display delivery information
class DeliveryCard extends StatelessWidget {
  final Trip delivery;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Delivery #${delivery.id.length >= 8 ? delivery.id.substring(0, 8) : delivery.id}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(delivery.status, colorScheme),
                ],
              ),
              const SizedBox(height: 12),

              // Route information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            delivery.pickupLocation,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4, bottom: 4),
                      child: Row(
                        children: [
                          Column(
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 2,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${delivery.currentDistanceKm ?? 0.0} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            delivery.deliveryLocation,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Details row
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    delivery.scheduledPickupTime != null
                        ? DateFormat('MMM dd, HH:mm').format(delivery.scheduledPickupTime!)
                        : 'Not scheduled',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Icon(Icons.attach_money, size: 14, color: AppColors.primary),
                  Text(
                    '${delivery.totalCost.toStringAsFixed(0)} ETB',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),

              if (delivery.currentLocation != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, size: 14, color: AppColors.tertiaryDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Current: ${delivery.currentLocation}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (trailing != null) ...[
                const SizedBox(height: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TripStatus status, ColorScheme colorScheme) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case TripStatus.matched:
        color = AppColors.tertiary;
        label = 'Scheduled';
        icon = Icons.schedule;
        break;
      case TripStatus.pickedUp:
        color = AppColors.secondaryLight;
        label = 'Picked Up';
        icon = Icons.inventory;
        break;
      case TripStatus.inTransit:
        color = AppColors.secondary;
        label = 'In Transit';
        icon = Icons.local_shipping;
        break;
      case TripStatus.delivered:
        color = AppColors.success;
        label = 'Delivered';
        icon = Icons.check_circle;
        break;
      case TripStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
