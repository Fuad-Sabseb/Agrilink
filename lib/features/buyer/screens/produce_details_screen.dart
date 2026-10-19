import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../models/produce_model.dart';
import '../../../core/providers/cart_provider.dart';
import '../widgets/favorite_button.dart';
import '../../../core/models/farmer_model.dart';
import '../dialogs/contact_farmer_dialog.dart';
import 'farmer_profile_view_screen.dart';

/// Produce Details Screen - Full produce information and add to cart
class ProduceDetailsScreen extends StatefulWidget {
  final ProduceModel produce;

  const ProduceDetailsScreen({
    super.key,
    required this.produce,
  });

  @override
  State<ProduceDetailsScreen> createState() => _ProduceDetailsScreenState();
}

class _ProduceDetailsScreenState extends State<ProduceDetailsScreen> {
  int _currentImageIndex = 0;
  double _quantity = 1.0;
  final _quantityController = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with image carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            actions: [
              // Favorite button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FavoriteButton(produceId: widget.produce.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crop name and badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.produce.cropName,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (widget.produce.isOrganic)
                            _buildBadge(
                              'Organic',
                              AppColors.success,
                              Icons.eco_outlined,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Farmer info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.produce.farmerName,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  widget.produce.location,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Contact Farmer',
                                icon: Icon(Icons.phone_outlined, size: 20, color: AppColors.secondary),
                                onPressed: () {
                                  final farmer = Farmer(
                                    id: widget.produce.farmerId,
                                    name: widget.produce.farmerName,
                                    phoneNumber: '+251911234567',
                                    woreda: widget.produce.location.split(',').first.trim(),
                                    kebele: 'Kebele 01',
                                    registeredAt: DateTime.now().subtract(const Duration(days: 90)),
                                  );
                                  showContactFarmerDialog(context, farmer: farmer);
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FarmerProfileViewScreen(
                                        farmerId: widget.produce.farmerId,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                                child: const Text('View Profile'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.produce.pricePerUnit.toStringAsFixed(2)} ETB',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'per ${widget.produce.unit}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (widget.produce.qualityGrade != null)
                              _buildQualityBadge(widget.produce.qualityGrade!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 32),

                // Details section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailRow(
                        Icons.inventory_2_outlined,
                        'Available Quantity',
                        '${widget.produce.quantity} ${widget.produce.unit}',
                      ),
                      const SizedBox(height: 12),

                      _buildDetailRow(
                        Icons.category_outlined,
                        'Crop Type',
                        _capitalize(widget.produce.cropType),
                      ),
                      const SizedBox(height: 12),

                      if (widget.produce.harvestDate != null) ...[
                        _buildDetailRow(
                          Icons.calendar_today_outlined,
                          'Harvest Date',
                          DateFormat('MMM dd, yyyy').format(widget.produce.harvestDate!),
                        ),
                        const SizedBox(height: 12),
                      ],

                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Location',
                        widget.produce.location,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 32),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.produce.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),

      // Bottom add to cart bar
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.produce.imageUrls ?? [widget.produce.imageUrl].whereType<String>().toList();
    final hasImages = images.any((img) => img.isNotEmpty);

    if (!hasImages) {
      return Container(
        color: AppColors.surface,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: AppColors.border,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final imageUrl = images[index];
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 80,
                      color: AppColors.border,
                    ),
                  ),
                );
              },
            );
          },
        ),

        // Page indicators
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Quantity input
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() {
                                _quantity -= 1;
                                _quantityController.text = _quantity.toStringAsFixed(1);
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.background,
                            foregroundColor: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              suffix: Text(widget.produce.unit),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed != null && parsed > 0) {
                                setState(() {
                                  _quantity = parsed;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            if (_quantity < widget.produce.quantity) {
                              setState(() {
                                _quantity += 1;
                                _quantityController.text = _quantity.toStringAsFixed(1);
                              });
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.background,
                            foregroundColor: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Add to cart button
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  onPressed: widget.produce.isAvailable
                      ? () async {
                          final success = await cartProvider.addItem(
                            widget.produce,
                            _quantity,
                          );

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added to cart: ${widget.produce.cropName}'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                      DefaultTabController.of(context).animateTo(2);
                                    },
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    cartProvider.error ?? 'Failed to add to cart',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(
                    widget.produce.isAvailable
                        ? 'Add to Cart'
                        : 'Unavailable',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
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
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge(String grade) {
    Color color;
    switch (grade) {
      case 'A':
        color = AppColors.success;
        break;
      case 'B':
        color = AppColors.secondaryLight;
        break;
      case 'C':
        color = AppColors.secondary;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Grade $grade',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
