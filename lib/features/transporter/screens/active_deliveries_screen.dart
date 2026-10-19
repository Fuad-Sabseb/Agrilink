import '../../../core/utils/user_context.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/transport_provider.dart';
import '../../../core/models/trip_model.dart';
import '../widgets/delivery_card.dart';
import 'delivery_details_screen.dart';

/// Active Deliveries Screen - Manage deliveries with status tabs
class ActiveDeliveriesScreen extends StatefulWidget {
  const ActiveDeliveriesScreen({super.key});

  @override
  State<ActiveDeliveriesScreen> createState() => _ActiveDeliveriesScreenState();
}

class _ActiveDeliveriesScreenState extends State<ActiveDeliveriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDeliveries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);
    // TODO: Get actual transporter ID from auth
    final userId = UserContext.getCurrentUserId(context) ?? 'transporter_123';
    await transportProvider.loadTripsByTransporter(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Deliveries'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Consumer<TransportProvider>(
        builder: (context, transportProvider, child) {
          if (transportProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDeliveriesList(
                transportProvider.trips.where((t) =>
                  t.status == TripStatus.matched ||
                  t.status == TripStatus.pickedUp ||
                  t.status == TripStatus.inTransit
                ).toList(),
                'active',
              ),
              _buildDeliveriesList(
                transportProvider.trips.where((t) =>
                  t.status == TripStatus.delivered
                ).toList(),
                'completed',
              ),
              _buildDeliveriesList(
                transportProvider.trips.where((t) =>
                  t.status == TripStatus.cancelled
                ).toList(),
                'cancelled',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeliveriesList(List<Trip> deliveries, String type) {
    if (deliveries.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadDeliveries,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return DeliveryCard(
            delivery: delivery,
            onTap: () => _navigateToDetails(delivery),
            trailing: _buildActionButton(delivery),
          );
        },
      ),
    );
  }

  Widget? _buildActionButton(Trip delivery) {
    switch (delivery.status) {
      case TripStatus.matched:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _updateStatus(delivery, TripStatus.pickedUp),
            icon: const Icon(Icons.inventory),
            label: const Text('Mark Picked Up'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        );
      case TripStatus.pickedUp:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _updateStatus(delivery, TripStatus.inTransit),
            icon: const Icon(Icons.local_shipping),
            label: const Text('Start Transit'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        );
      case TripStatus.inTransit:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _navigateToDetails(delivery),
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark Delivered'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        );
      default:
        return null;
    }
  }

  Future<void> _updateStatus(Trip delivery, TripStatus newStatus) async {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);
    bool success = false;

    switch (newStatus) {
      case TripStatus.pickedUp:
        success = await transportProvider.markTripPickedUp(delivery.id);
        break;
      case TripStatus.inTransit:
        success = await transportProvider.markTripInTransit(delivery.id);
        break;
      case TripStatus.delivered:
        success = await transportProvider.markTripDelivered(delivery.id);
        break;
      default:
        break;
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toString().split('.').last}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update status'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToDetails(Trip delivery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailsScreen(delivery: delivery),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    String submessage;
    IconData icon;

    switch (type) {
      case 'active':
        message = 'No Active Deliveries';
        submessage = 'Accept jobs from Available Jobs tab';
        icon = Icons.local_shipping_outlined;
        break;
      case 'completed':
        message = 'No Completed Deliveries';
        submessage = 'Completed deliveries will appear here';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'No Cancelled Deliveries';
        submessage = 'Cancelled deliveries will appear here';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No Deliveries';
        submessage = '';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.border),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            submessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
