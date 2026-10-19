import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/trip_model.dart';
import '../../../core/models/transporter_model.dart';
import '../../../core/models/vehicle_model.dart';
import '../../../core/models/crop_plot_model.dart';
import '../../../core/services/agrilogistics_service.dart';

/// Orders Screen - Phase 3
/// Module 4: AgriLogistics with transporter directory, multi-step booking flow
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.orders),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.local_shipping),
              text: 'My Trips',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: 'Find Transport',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTripsTab(),
          _buildFindTransportTab(),
        ],
      ),
    );
  }

  Widget _buildMyTripsTab() {
    // Mock farmer ID - in real app, get from auth
    final trips = AgriLogisticsService.getAllTrips();

    return trips.isEmpty
        ? _buildEmptyState(
            icon: Icons.directions_car_outlined,
            message: 'No trips yet',
            subtitle: 'Request transport to see your trips here',
          )
        : RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Refresh UI
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _buildTripCard(trip);
              },
            ),
          );
  }

  Widget _buildFindTransportTab() {
    final transporters = AgriLogisticsService.getAvailableTransporters();
    final stats = AgriLogisticsService.getLogisticsStats();

    return Column(
      children: [
        // Stats summary
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${stats['availableTransporters']}',
                'Available',
              ),
              Container(width: 1, height: 30, color: AppColors.border),
              _buildStatItem(
                '${stats['totalVehicles']}',
                'Vehicles',
              ),
              Container(width: 1, height: 30, color: AppColors.border),
              _buildStatItem(
                '${stats['totalRoutes']}',
                'Routes',
              ),
            ],
          ),
        ),

        // Transporters list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transporters.length,
            itemBuilder: (context, index) {
              final transporter = transporters[index];
              final vehicles =
                  AgriLogisticsService.getVehiclesByTransporter(transporter.id);
              return _buildTransporterCard(transporter, vehicles);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(Trip trip) {
    final theme = Theme.of(context);
    final transporter = AgriLogisticsService.getTransporterById(trip.transporterId);
    final vehicle = AgriLogisticsService.getVehicleById(trip.vehicleId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showTripDetailsDialog(trip);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  // Status icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${trip.status.color.substring(1)}')).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        trip.status.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.cropType.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${trip.quantityQuintals.toStringAsFixed(1)} quintals',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${trip.status.color.substring(1)}')),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trip.status.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Route
              Row(
                children: [
                  Icon(Icons.trip_origin,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trip.pickupLocation,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Icon(Icons.arrow_forward,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Icon(Icons.place, size: 16, color: AppColors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trip.deliveryLocation,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transporter and vehicle info
              if (transporter != null && vehicle != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transporter.businessName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${vehicle.model} • ${vehicle.plateNumber}',
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
                          Icon(Icons.star, size: 14, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(
                            transporter.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Timeline progress
              _buildTripProgress(trip),

              // Cost
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${trip.totalCost.toStringAsFixed(2)} ETB',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripProgress(Trip trip) {
    final theme = Theme.of(context);
    final steps = [
      TripStatus.matched,
      TripStatus.pickedUp,
      TripStatus.inTransit,
      TripStatus.delivered,
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Line
          final isCompleted = trip.currentStep > (index ~/ 2) + 1;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.primary : AppColors.border,
            ),
          );
        } else {
          // Step
          final stepIndex = index ~/ 2;
          final isCompleted = trip.currentStep > stepIndex + 1;
          final isCurrent = trip.currentStep == stepIndex + 1;

          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AppColors.primary
                  : AppColors.surface,
              border: Border.all(
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : AppColors.border,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${stepIndex + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCurrent ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildTransporterCard(Transporter transporter, List<Vehicle> vehicles) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showTransporterDetailsDialog(transporter, vehicles);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.local_shipping,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transporter.businessName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              if (index < transporter.rating.floor()) {
                                return Icon(Icons.star,
                                    size: 14, color: AppColors.gold);
                              } else if (index < transporter.rating) {
                                return Icon(Icons.star_half,
                                    size: 14, color: AppColors.gold);
                              } else {
                                return Icon(Icons.star_border,
                                    size: 14, color: AppColors.gold);
                              }
                            }),
                            const SizedBox(width: 4),
                            Text(
                              '${transporter.rating.toStringAsFixed(1)} (${transporter.totalTrips} trips)',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (transporter.isVerified)
                    Icon(
                      Icons.verified,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildTransporterStat(
                      icon: Icons.location_on,
                      label: transporter.baseLocation,
                    ),
                  ),
                  Expanded(
                    child: _buildTransporterStat(
                      icon: Icons.local_shipping,
                      label: '${vehicles.length} vehicles',
                    ),
                  ),
                  Expanded(
                    child: _buildTransporterStat(
                      icon: Icons.check_circle,
                      label: '${transporter.completionRate.toStringAsFixed(0)}% complete',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Standard routes
              if (transporter.standardRoutes.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: transporter.standardRoutes.take(3).map((route) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        route,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransporterStat({
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showTripDetailsDialog(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trip #${trip.id.substring(trip.id.length - 8)}'),
        content: Text('Full trip details coming in Phase 4'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTransporterDetailsDialog(
      Transporter transporter, List<Vehicle> vehicles) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transporter.businessName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone: ${transporter.phoneNumber}'),
              const SizedBox(height: 8),
              Text('Base: ${transporter.baseLocation}'),
              const SizedBox(height: 8),
              Text('Rating: ${transporter.rating}/5.0'),
              const SizedBox(height: 8),
              Text('Vehicles: ${vehicles.length}'),
              const SizedBox(height: 12),
              const Text('Available Vehicles:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...vehicles.map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${v.vehicleType.icon} ${v.model} - ${v.capacityQuintals} quintals',
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking feature coming soon')),
              );
            },
            child: const Text('Request Transport'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
