import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/transport_request_model.dart';
import '../../../core/models/crop_plot_model.dart';

/// Job Card - Display available transport job
class JobCard extends StatelessWidget {
  final TransportRequest job;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;

  const JobCard({super.key, required this.job, this.onTap, this.onAccept});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate estimated earnings (mock calculation: base rate + distance bonus)
    final estimatedEarnings = _calculateEarnings();
    final distance = _calculateDistance();

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
              // Header: Crop type and earnings
              Row(
                children: [
                  // Crop icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCropIcon(job.cropType),
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Crop type and weight
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatCropType(job.cropType),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${job.quantityKg} kg',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Estimated earnings
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$estimatedEarnings ETB',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Estimated',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Divider(height: 24, color: AppColors.border),

              // Location details
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.pickupLocation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  children: List.generate(
                    2,
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
              ),

              Row(
                children: [
                  Icon(Icons.place, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.deliveryLocation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    Icons.straighten,
                    '$distance km',
                    AppColors.tertiary,
                  ),
                  _buildChip(
                    Icons.calendar_today,
                    DateFormat('MMM dd').format(job.requestedPickupDate),
                    AppColors.secondaryLight,
                  ),
                  if (job.requiresRefrigeration)
                    _buildChip(
                      Icons.ac_unit,
                      'Refrigerated',
                      AppColors.tertiary,
                    ),
                ],
              ),

              if (job.specialInstructions != null &&
                  job.specialInstructions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.specialInstructions!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (onAccept != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Accept Job'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

  int _calculateEarnings() {
    // Mock calculation: base rate + distance-based bonus + weight bonus
    final baseRate = 500;
    final distanceBonus = _calculateDistance() * 10;
    final weightBonus = (job.quantityKg / 100) * 50;
    final refrigerationBonus = job.requiresRefrigeration ? 200 : 0;

    return (baseRate + distanceBonus + weightBonus + refrigerationBonus)
        .toInt();
  }

  int _calculateDistance() {
    // Mock distance calculation - in real app, use Google Maps API
    return 15 + (job.quantityKg / 100).toInt();
  }

  IconData _getCropIcon(CropType cropType) {
    switch (cropType) {
      case CropType.coffee:
        return Icons.coffee;
      case CropType.maize:
        return Icons.grass;
      case CropType.teff:
        return Icons.grain;
      case CropType.wheat:
        return Icons.grass;
      case CropType.potato:
        return Icons.eco;
      case CropType.beans:
        return Icons.spa;
      default:
        return Icons.agriculture;
    }
  }

  String _formatCropType(CropType cropType) {
    return cropType.toString().split('.').last.toUpperCase();
  }
}
