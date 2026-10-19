import 'package:flutter/material.dart';
import '../../../models/produce_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'favorite_button.dart';

/// Produce Card Widget - Displays produce in grid or list view
class ProduceCard extends StatelessWidget {
  final ProduceModel produce;
  final VoidCallback onTap;
  final bool isGridView;

  const ProduceCard({
    super.key,
    required this.produce,
    required this.onTap,
    this.isGridView = true,
  });

  Color _getStatusColor() {
    switch (produce.status) {
      case 'available':
        return AppColors.success;
      case 'reserved':
        return AppColors.accent;
      case 'sold':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: produce.imageUrls?.isNotEmpty ?? false
                      ? Image.network(
                          produce.imageUrls?.first ?? "",
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(produceId: produce.id),
                ),
                // Status badge
                if (produce.status != 'available')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        produce.status.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop name
                  Text(
                    produce.cropName,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Quality grade
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        produce.qualityGrade ?? "",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    'ETB ${produce.pricePerUnit.toStringAsFixed(2)}/${produce.unit}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Quantity
                  Text(
                    '${produce.quantity} ${produce.unit} available',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Farmer & Location
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          produce.farmerName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: produce.imageUrls?.isNotEmpty ?? false
                        ? Image.network(
                            produce.imageUrls?.first ?? "",
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(size: 100),
                          )
                        : _buildPlaceholderImage(size: 100),
                  ),
                  // Status badge
                  if (produce.status != 'available')
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          produce.status.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            produce.cropName,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FavoriteButton(produceId: produce.id, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          produce.qualityGrade ?? "",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ETB ${produce.pricePerUnit.toStringAsFixed(2)}/${produce.unit}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${produce.quantity} ${produce.unit} available',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          produce.farmerName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage({double? size}) {
    return Container(
      height: size ?? 140,
      width: size ?? double.infinity,
      color: AppColors.background,
      child: Icon(
        Icons.image_outlined,
        size: size != null ? size / 2 : 60,
        color: AppColors.textSecondary,
      ),
    );
  }
}
