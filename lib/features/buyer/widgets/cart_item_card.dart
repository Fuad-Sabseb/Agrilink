import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Cart Item Card - Displays cart item with quantity controls
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onTap;

  const CartItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: AppColors.shadow12,
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
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.produceName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${item.farmerName}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ETB ${item.pricePerUnit.toStringAsFixed(2)}/${item.unit}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quantity controls
                    Row(
                      children: [
                        // Decrease button
                        Material(
                          color: AppColors.background,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () async {
                              if (item.quantity > 1) {
                                await cartProvider.updateQuantity(
                                  item.produceId,
                                  item.quantity - 1,
                                );
                              } else {
                                // Show confirmation dialog
                                _showRemoveDialog(context, cartProvider);
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                                size: 20,
                                color: item.quantity > 1
                                    ? AppColors.textPrimary
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Quantity display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.quantity} ${item.unit}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Increase button
                        Material(
                          color: AppColors.background,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () async {
                              if (item.quantity < item.availableQuantity) {
                                await cartProvider.updateQuantity(
                                  item.produceId,
                                  item.quantity + 1,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Maximum available quantity is ${item.availableQuantity} ${item.unit}',
                                    ),
                                    backgroundColor: AppColors.secondary,
                                  ),
                                );
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.add,
                                size: 20,
                                color: item.quantity < item.availableQuantity
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Total price
                        Text(
                          'ETB ${item.totalPrice.toStringAsFixed(2)}',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
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

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.background,
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.textSecondary,
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${item.produceName} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await cartProvider.removeItem(item.produceId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.produceName} removed from cart'),
                    backgroundColor: AppColors.info,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
