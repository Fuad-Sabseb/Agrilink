import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/trip_model.dart';
import '../../../core/providers/transport_provider.dart';
import '../widgets/delivery_status_timeline.dart';
import 'proof_of_delivery_screen.dart';

/// Delivery Details Screen - Full delivery information and actions
class DeliveryDetailsScreen extends StatelessWidget {
  final Trip delivery;

  const DeliveryDetailsScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Details'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Share delivery details
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery #${delivery.id.length >= 8 ? delivery.id.substring(0, 8) : delivery.id}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    delivery.scheduledPickupTime != null
                        ? DateFormat(
                            'EEEE, MMM dd, yyyy - HH:mm',
                          ).format(delivery.scheduledPickupTime!)
                        : 'Not scheduled',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Status Timeline
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Progress',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DeliveryStatusTimeline(delivery: delivery),
                ],
              ),
            ),

            const Divider(height: 1),

            // Route Information
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRouteCard(context),
                ],
              ),
            ),

            const Divider(height: 1),

            // Earnings
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.attach_money,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${delivery.totalCost.toStringAsFixed(2)} ETB',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Total Earnings',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
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

            const SizedBox(height: 80), // Space for bottom action bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildLocationRow(
            Icons.location_on,
            'Pickup Location',
            delivery.pickupLocation,
            AppColors.primary,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                Column(
                  children: List.generate(
                    4,
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
                const SizedBox(width: 16),
                Text(
                  '${delivery.currentDistanceKm ?? 0.0} km • 30 min',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildLocationRow(
            Icons.place,
            'Delivery Location',
            delivery.deliveryLocation,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String location,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildBottomActionBar(BuildContext context) {
    final transportProvider = Provider.of<TransportProvider>(
      context,
      listen: false,
    );

    if (delivery.status == TripStatus.delivered ||
        delivery.status == TripStatus.cancelled) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Contact button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Contact farmer/buyer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact feature coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Contact'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Main action button
            Expanded(
              flex: 2,
              child: _buildActionButton(context, transportProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    TransportProvider transportProvider,
  ) {
    switch (delivery.status) {
      case TripStatus.matched:
        return FilledButton.icon(
          onPressed: () async {
            await transportProvider.markTripPickedUp(delivery.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marked as picked up!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          icon: const Icon(Icons.inventory),
          label: const Text('Mark Picked Up'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      case TripStatus.pickedUp:
        return FilledButton.icon(
          onPressed: () async {
            await transportProvider.markTripInTransit(delivery.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('In transit!'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            }
          },
          icon: const Icon(Icons.local_shipping),
          label: const Text('Start Transit'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
        );
      case TripStatus.inTransit:
        return FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProofOfDeliveryScreen(delivery: delivery),
              ),
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Delivery'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
