import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../core/services/logistics_service.dart';
import '../../models/logistics_model.dart';
import '../../models/order_model.dart';
import '../../models/produce_model.dart';
import '../../widgets/order_card.dart';
import '../../core/models/trip_model.dart';
import '../../core/models/crop_plot_model.dart';
import '../../features/transporter/screens/proof_of_delivery_screen.dart';

class MyDeliveriesScreen extends StatelessWidget {
  const MyDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final logisticsService = LogisticsService();

    final boxesOpen = Hive.isBoxOpen('logistics') && Hive.isBoxOpen('orders') && Hive.isBoxOpen('produce');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Deliveries')),
      body: !boxesOpen
          ? _buildEmptyState()
          : ValueListenableBuilder<Box<LogisticsModel>>(
              valueListenable: Hive.box<LogisticsModel>('logistics').listenable(),
              builder: (context, logisticsBox, _) {
                return ValueListenableBuilder<Box<OrderModel>>(
                  valueListenable: Hive.box<OrderModel>('orders').listenable(),
                  builder: (context, orderBox, _) {
                    return ValueListenableBuilder<Box<ProduceModel>>(
                      valueListenable: Hive.box<ProduceModel>('produce').listenable(),
                      builder: (context, produceBox, _) {
                        final userId = sessionService.currentUser?.id;
                        final myDeliveries = logisticsBox.values
                            .where((d) => d.transporterId == userId)
                            .toList()
                          ..sort((a, b) => (b.pickupTime ?? DateTime(0)).compareTo(a.pickupTime ?? DateTime(0)));

                        if (myDeliveries.isEmpty) {
                          return _buildEmptyState();
                        }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myDeliveries.length,
                    itemBuilder: (context, index) {
                      final logistics = myDeliveries[index];
                      final order = orderBox.values
                          .firstWhere(
                            (o) => o.id == logistics.orderId,
                            orElse: () => OrderModel(
                              id: '',
                              produceId: '',
                              produceName: 'Unknown',
                              buyerId: '',
                              buyerName: 'Unknown',
                              farmerId: '',
                              farmerName: 'Unknown',
                              quantityOrdered: 0,
                              unit: 'kg',
                              pricePerUnit: 0,
                              totalPrice: 0,
                              status: 'unknown',
                              pickupLocation: '',
                              deliveryLocation: '',
                              paymentMethod: 'cash',
                              paymentStatus: 'pending',
                              createdAt: DateTime.now(),
                            ),
                          );
                      final produce = produceBox.values
                          .firstWhere(
                            (p) => p.id == order.produceId,
                            orElse: () => ProduceModel(
                              id: '',
                              farmerId: '',
                              farmerName: 'Unknown',
                              cropName: 'Unknown',
                              cropType: 'other',
                              quantity: 0,
                              unit: 'kg',
                              pricePerUnit: 0,
                              description: 'Item not found',
                              status: 'unavailable',
                              location: 'Unknown',
                              createdAt: DateTime.now(),
                            ),
                          );

                      Widget? trailing;
                      if (logistics.status == 'awaiting') {
                        trailing = ElevatedButton(
                          onPressed: () async {
                            await logisticsService.updateLogisticsStatus(logistics.id, 'in_transit');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Delivery marked as In Transit!')),
                              );
                            }
                          },
                          child: const Text('Start Transit'),
                        );
                      } else if (logistics.status == 'in_transit') {
                        trailing = ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            final trip = Trip(
                              id: logistics.id,
                              transportRequestId: logistics.orderId,
                              farmerId: order.farmerId,
                              transporterId: logistics.transporterId,
                              vehicleId: 'vehicle_001',
                              routeId: 'route_001',
                              cropType: CropType.other,
                              quantityKg: order.quantityOrdered,
                              pickupLocation: order.pickupLocation.isNotEmpty ? order.pickupLocation : 'Farm Location',
                              deliveryLocation: order.deliveryLocation.isNotEmpty ? order.deliveryLocation : 'Buyer Location',
                              currentLocation: order.pickupLocation.isNotEmpty ? order.pickupLocation : 'In Transit',
                              totalCost: order.totalPrice * 0.15,
                              status: TripStatus.inTransit,
                              createdAt: logistics.pickupTime ?? DateTime.now(),
                              actualPickupTime: logistics.pickupTime ?? DateTime.now(),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProofOfDeliveryScreen(delivery: trip),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assignment_turned_in, size: 16, color: Colors.white),
                          label: const Text('Capture POD', style: TextStyle(color: Colors.white)),
                        );
                      }

                      return OrderCard(
                        order: order,
                        produce: produce,
                        trailing: trailing,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 80, color: AppColors.disabled),
            const SizedBox(height: 16),
            Text(
              'No Active Deliveries',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to the Pickups tab to accept available orders.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
