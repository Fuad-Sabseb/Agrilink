import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../core/theme/colors.dart';
import '../../models/order_model.dart';
import '../../core/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();
  
  String _selectedMethod = 'Telebirr';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Make Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.payment, size: 64, color: AppColors.secondary),
            const SizedBox(height: 24),
            Text(
              'Total Amount Due',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(order.totalPrice),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 48),
            Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodTile('Telebirr', Icons.phone_android),
            _buildPaymentMethodTile('CBE Birr', Icons.phone_android),
            _buildPaymentMethodTile('Bank Transfer', Icons.account_balance),
            _buildPaymentMethodTile('Cash on Delivery', Icons.money),
            const SizedBox(height: 24),
            if (_selectedMethod == 'Telebirr' || _selectedMethod == 'CBE Birr')
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '$_selectedMethod Number',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              )
            else if (_selectedMethod == 'Bank Transfer')
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Bank Account Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Account Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      setState(() => _isProcessing = true);
                      
                      // Mock network delay
                      await Future.delayed(const Duration(seconds: 2));
                      
                      await _paymentService.recordPayment(
                        orderId: order.id,
                        amount: order.totalPrice,
                        method: _selectedMethod.toLowerCase().replaceAll(' ', '_'),
                      );

                      // Update order in Hive persistence
                      try {
                        if (Hive.isBoxOpen('orders')) {
                          final orderBox = Hive.box<OrderModel>('orders');
                          final existingOrder = orderBox.get(order.id) ?? order;
                          final updatedOrder = existingOrder.copyWith(
                            status: 'confirmed',
                            paymentStatus: 'paid',
                            paymentMethod: _selectedMethod.toLowerCase().replaceAll(' ', '_'),
                            confirmedAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          await orderBox.put(order.id, updatedOrder);
                        }
                      } catch (_) {
                        // In case box is not opened or running in test mode
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Payment Successful! Order Confirmed.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.primary,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(String title, IconData fallbackIcon) {
    return RadioListTile<String>(
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      value: title,
      groupValue: _selectedMethod,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedMethod = value;
          });
        }
      },
      secondary: Icon(fallbackIcon, color: AppColors.secondary),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
