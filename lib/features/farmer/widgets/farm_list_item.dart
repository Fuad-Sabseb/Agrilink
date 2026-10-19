import 'package:flutter/material.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Farm List Item Widget
/// Displays a single farm in a list
class FarmListItem extends StatelessWidget {
  final Farm farm;
  final VoidCallback? onTap;

  const FarmListItem({
    super.key,
    required this.farm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.farmName,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${farm.woreda}, ${farm.kebele}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.crop_landscape,
                    '${farm.totalHectares.toStringAsFixed(1)} ha',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.local_florist,
                    '${farm.cropPlots.length} plots',
                  ),
                ],
              ),
              if (farm.cultivatedHectares > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: farm.cultivatedHectares / farm.totalHectares,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${farm.cultivatedHectares.toStringAsFixed(1)} ha cultivated',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
