import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/models/demand_model.dart';

import '../../../core/models/crop_plot_model.dart';
/// Demand Card Widget
/// Compact display of a demand with status and urgency indicators
class DemandCard extends StatelessWidget {
  final Demand demand;
  final VoidCallback onTap;

  const DemandCard({
    super.key,
    required this.demand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(demand.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getCropDisplayName(demand.cropType),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusBadge(statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    demand.pickupLocation,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(demand.expiresAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: demand.isUrgent ? AppColors.error : AppColors.textSecondary,
                      fontWeight: demand.isUrgent ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    '${demand.minimumQuantityKg.toInt()}-${demand.maximumQuantityKg.toInt()} kg',
                    Icons.scale,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    'ETB ${demand.priceOfferPerKg}/kg',
                    Icons.attach_money,
                  ),
                  if (demand.transportProvided) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      'Transport',
                      Icons.local_shipping,
                    ),
                  ],
                ],
              ),
              if (demand.isUrgent) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in ${demand.hoursUntilExpiry} hours',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (demand.viewCount > 0 || demand.responseCount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (demand.viewCount > 0) ...[
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${demand.viewCount}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (demand.responseCount > 0) ...[
                      Icon(
                        Icons.reply,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${demand.responseCount} responses',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (demand.status.showPulse)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 1.0 - (value * 0.5)),
                  ),
                );
              },
              onEnd: () {
                // Loop animation
              },
            ),
          if (demand.status.showPulse) const SizedBox(width: 6),
          Text(
            demand.status.displayName,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuyingStatus status) {
    switch (status) {
      case BuyingStatus.buyingNow:
        return AppColors.success;
      case BuyingStatus.paused:
        return AppColors.warning;
      case BuyingStatus.filled:
        return AppColors.textSecondary;
      case BuyingStatus.expired:
        return AppColors.error;
    }
  }

  String _getCropDisplayName(CropType crop) {
    return crop.name[0].toUpperCase() + crop.name.substring(1);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.isNegative) {
      return 'Expired';
    } else {
      return 'Today';
    }
  }
}
