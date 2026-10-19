import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/order_service.dart';
import '../../core/services/logistics_service.dart';
import '../../core/services/session_service.dart';
import '../../models/order_model.dart';
import '../../models/produce_model.dart';
import '../../widgets/order_card.dart';

class AvailablePickupsScreen extends StatelessWidget {
  const AvailablePickupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final logisticsService = LogisticsService();
    final orderService = OrderService();

    final boxesOpen = Hive.isBoxOpen('orders') && Hive.isBoxOpen('produce');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Available Pickups')),
      body: !boxesOpen
          ? _buildEmptyState()
          : ValueListenableBuilder<Box<OrderModel>>(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, orderBox, _) {
                return ValueListenableBuilder<Box<ProduceModel>>(
                  valueListenable: Hive.box<ProduceModel>('produce').listenable(),
                  builder: (context, produceBox, _) {
                    final availablePickups = orderBox.values
                        .where((o) => o.status == 'confirmed')
                        .toList()
                      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                    if (availablePickups.isEmpty) {
                      return _buildEmptyState();
                    }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: availablePickups.length,
                itemBuilder: (context, index) {
                  final order = availablePickups[index];
                  final produce = produceBox.values.firstWhere(
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

                  return OrderCard(
                    order: order,
                    produce: produce,
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final user = sessionService.currentUser;
                        if (user == null) return;
                        try {
                          await logisticsService.createLogisticsEntry(
                            orderId: order.id,
                            transporterId: user.id,
                            notes: '',
                          );
                          await orderService.updateOrderStatus(order.id, 'picked_up');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Pickup Accepted! 🚛'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accept Pickup'),
                    ),
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
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 100),
        Icon(Icons.local_shipping_outlined, size: 80, color: AppColors.disabled),
        const SizedBox(height: 16),
        Text(
          'You\'re all caught up!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'No pickups available right now. Pull down to refresh.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
