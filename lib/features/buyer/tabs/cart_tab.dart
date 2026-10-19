import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/theme/colors.dart';
import '../widgets/cart_item_card.dart';
import '../screens/checkout_screen.dart';

/// Cart Tab - Shopping cart view
class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Column(
          children: [
            // Cart items list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartProvider.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cartProvider.items[index];
                  return CartItemCard(
                    item: item,
                  );
                },
              ),
            ),

            // Order summary card
            _buildOrderSummary(context, cartProvider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: AppColors.disabled,
          ),
          const SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Browse our marketplace and add\nfresh produce to your cart',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              // Navigate to browse tab
              DefaultTabController.of(context).animateTo(0);
            },
            icon: const Icon(Icons.store),
            label: const Text('Start Shopping'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cartProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow12,
            offset: Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtotal
              _buildSummaryRow(
                context,
                'Subtotal',
                cartProvider.subtotal,
                isRegular: true,
              ),
              const SizedBox(height: 8),

              // Delivery fee
              _buildSummaryRow(
                context,
                'Delivery Fee',
                cartProvider.deliveryFee,
                isRegular: true,
              ),
              const SizedBox(height: 8),

              // Tax
              _buildSummaryRow(
                context,
                'Tax (15% VAT)',
                cartProvider.tax,
                isRegular: true,
              ),
              const Divider(height: 24),

              // Total
              _buildSummaryRow(
                context,
                'Total',
                cartProvider.total,
                isTotal: true,
              ),
              const SizedBox(height: 16),

              // Checkout button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text('Proceed to Checkout (${cartProvider.itemCount} items)'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Clear cart button
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  _showClearCartDialog(context, cartProvider);
                },
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Clear Cart'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isTotal = false,
    bool isRegular = false,
  }) {
    final theme = Theme.of(context);
    final textStyle = isTotal
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          )
        : isRegular
            ? theme.textTheme.bodyLarge
            : theme.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(
          '${amount.toStringAsFixed(2)} ETB',
          style: textStyle,
        ),
      ],
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    CartProvider cartProvider,
    String produceId,
    String produceName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "$produceName" from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              cartProvider.removeItem(produceId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$produceName removed from cart'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
