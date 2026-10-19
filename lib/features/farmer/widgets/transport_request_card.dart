import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/crop_plot_model.dart';
import '../../../core/models/transport_request_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Reusable Transport Request Card Widget
class TransportRequestCard extends StatelessWidget {
  final TransportRequest request;
  final VoidCallback onTap;

  const TransportRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.pending:
        return AppColors.accent;
      case RequestStatus.matched:
        return AppColors.info;
      case RequestStatus.accepted:
        return AppColors.success;
      case RequestStatus.cancelled:
        return AppColors.error;
      case RequestStatus.expired:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (request.status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.matched:
        return 'Matched';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.expired:
        return 'Expired';
    }
  }

  String _getCropTypeName() {
    switch (request.cropType) {
      case CropType.coffee:
        return 'Coffee';
      case CropType.teff:
        return 'Teff';
      case CropType.wheat:
        return 'Wheat';
      case CropType.maize:
        return 'Maize';
      case CropType.barley:
        return 'Barley';
      case CropType.sorghum:
        return 'Sorghum';
      case CropType.potato:
        return 'Potato';
      case CropType.beans:
        return 'Beans';
      case CropType.other:
        return 'Other';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Request ID and Status
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 20,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Request #${request.id.substring(0, 8)}',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Crop Type
              Text(
                _getCropTypeName(),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Quantity
              Row(
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${request.quantityKg.toStringAsFixed(1)} kg',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (request.requiresRefrigeration) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.ac_unit,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Refrigerated',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Route
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trip_origin,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                request.pickupLocation,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                request.deliveryLocation,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Pickup Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(request.requestedPickupDate),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (request.agreedPrice != null)
                    Text(
                      'ETB ${request.agreedPrice!.toStringAsFixed(2)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              // Responses count
              if (request.status == RequestStatus.pending && 
                  request.responseTransporterIds != null && 
                  request.responseTransporterIds!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${request.responseTransporterIds!.length} transporter(s) responded',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
