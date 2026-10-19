import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../core/services/order_service.dart';
import '../../core/services/produce_service.dart';
import '../../models/order_model.dart';
import '../../models/produce_model.dart';
import '../../widgets/order_card.dart';

class OrderRequestsScreen extends StatelessWidget {
  const OrderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();
    final orderService = OrderService();
    final produceService = ProduceService();

    final bool boxesOpen = Hive.isBoxOpen('orders') && Hive.isBoxOpen('produce');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Requests')),
      body: !boxesOpen
          ? _buildEmptyState()
          : ValueListenableBuilder<Box<OrderModel>>(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, orderBox, _) {
                return ValueListenableBuilder<Box<ProduceModel>>(
                  valueListenable: Hive.box<ProduceModel>('produce').listenable(),
                  builder: (context, produceBox, _) {
                    final userId = sessionService.currentUserId;
                    final orders = orderBox.values
                        .where((o) => o.farmerId == userId)
                        .toList()
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (orders.isEmpty) {
                      return _buildEmptyState();
                    }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
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

                  Widget? trailing;
                  if (order.status == 'pending') {
                    trailing = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await orderService.updateOrderStatus(order.id, 'cancelled');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order declined.')));
                            }
                          },
                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          child: const Text('Decline'),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () async {
                            await orderService.updateOrderStatus(order.id, 'confirmed');
                            // Deduct ordered quantity from produce stock
                            await produceService.deductQuantity(order.produceId, order.quantityOrdered);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order confirmed! ✅')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Accept'),
                        ),
                      ],
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
            Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.disabled),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'When buyers place orders for your produce, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
