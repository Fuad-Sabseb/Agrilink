import 'package:flutter/material.dart';
import '../models/produce_model.dart';
import 'package:intl/intl.dart';
import '../core/theme/colors.dart';

class ProduceCard extends StatelessWidget {
  final ProduceModel produce;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProduceCard({
    super.key,
    required this.produce,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor() {
    switch (produce.status.toLowerCase()) {
      case 'available':
        return AppColors.primary;
      case 'reserved':
        return AppColors.accent;
      case 'sold':
        return AppColors.textSecondary;
      default:
        return AppColors.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 0);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    produce.cropName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Text(
                      produce.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                produce.description,
                style: TextStyle(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    'Quantity',
                    '${produce.quantity} ${produce.unit}',
                    Icons.scale_outlined,
                  ),
                  _buildInfoColumn(
                    'Price per ${produce.unit}',
                    currencyFormat.format(produce.pricePerUnit),
                    Icons.payments_outlined,
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null) ...[
                Divider(height: 24, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        label: Text('Edit', style: TextStyle(color: AppColors.primary)),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        label: Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }
}
