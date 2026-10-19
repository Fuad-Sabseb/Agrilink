import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../models/order_model.dart';
import '../../models/produce_model.dart';
import '../../models/payment_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/order_card.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();

    final bool boxesOpen = Hive.isBoxOpen('orders') &&
        Hive.isBoxOpen('payments') &&
        Hive.isBoxOpen('produce');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: !boxesOpen
          ? _buildEmptyState()
          : ValueListenableBuilder<Box<OrderModel>>(
              valueListenable: Hive.box<OrderModel>('orders').listenable(),
              builder: (context, orderBox, _) {
                return ValueListenableBuilder<Box<PaymentModel>>(
                  valueListenable: Hive.box<PaymentModel>('payments').listenable(),
                  builder: (context, paymentBox, _) {
                    return ValueListenableBuilder<Box<ProduceModel>>(
                      valueListenable: Hive.box<ProduceModel>('produce').listenable(),
                      builder: (context, produceBox, _) {
                        final userId = sessionService.currentUser?.id;
                        final myOrders = orderBox.values
                            .where((o) => o.buyerId == userId)
                            .toList()
                          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                        if (myOrders.isEmpty) {
                          return _buildEmptyState();
                        }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: myOrders.length,
                    itemBuilder: (context, index) {
                      final order = myOrders[index];
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
                      final isPaid = paymentBox.values
                          .any((p) => p.orderId == order.id && p.status == 'completed');

                      return OrderCard(
                        order: order,
                        produce: produce,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.orderDetails,
                            arguments: order,
                          );
                        },
                        trailing: order.status == 'confirmed' && !isPaid
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.payment,
                                    arguments: order,
                                  );
                                },
                                child: const Text('Pay Now'),
                              )
                            : null,
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
            Icon(Icons.list_alt_outlined, size: 80, color: AppColors.disabled),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to the Market tab to browse and order fresh produce.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
