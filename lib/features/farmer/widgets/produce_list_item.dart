import 'package:flutter/material.dart';
import '../../../models/produce_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'package:intl/intl.dart';

/// Reusable Produce List Item Widget
class ProduceListItem extends StatelessWidget {
  final ProduceModel produce;
  final VoidCallback onTap;

  const ProduceListItem({
    super.key,
    required this.produce,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (produce.status) {
      case 'available':
        return AppColors.success;
      case 'sold':
        return AppColors.info;
      case 'reserved':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (produce.status) {
      case 'available':
        return 'Available';
      case 'sold':
        return 'Sold';
      case 'reserved':
        return 'Reserved';
      default:
        return produce.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  image: produce.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(produce.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: produce.imageUrl == null
                    ? Icon(
                        Icons.agriculture_outlined,
                        size: 40,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crop Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            produce.cropName,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _getStatusLabel(),
                            style: AppTypography.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Crop Type
                    Text(
                      produce.cropType,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quantity and Price
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${produce.quantity} ${produce.unit}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ETB ${produce.pricePerUnit}/${produce.unit}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location and Date
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            produce.location,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(produce.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
