import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/order_model.dart';

/// Checkout Screen - 3-step checkout flow
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  bool _isProcessing = false;

  // Delivery address fields
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  // Payment method
  String _paymentMethod = 'cash_on_delivery';

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Stepper(
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            controlsBuilder: _buildControls,
            steps: [
              // Step 1: Order Review
              Step(
                title: const Text('Review Order'),
                content: _buildOrderReview(cartProvider),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),

              // Step 2: Delivery Details
              Step(
                title: const Text('Delivery Details'),
                content: _buildDeliveryDetails(),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),

              // Step 3: Payment Method
              Step(
                title: const Text('Payment'),
                content: _buildPaymentMethod(),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderReview(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Items list
        ...cartProvider.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.produceName,
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${item.quantity} ${item.unit} × ${item.pricePerUnit.toStringAsFixed(2)} ETB',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.totalPrice.toStringAsFixed(2)} ETB',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        }),

        const Divider(height: 24),

        // Price breakdown
        _buildPriceRow('Subtotal', cartProvider.subtotal),
        const SizedBox(height: 8),
        _buildPriceRow('Delivery Fee', cartProvider.deliveryFee),
        const SizedBox(height: 8),
        _buildPriceRow('Tax (15% VAT)', cartProvider.tax),
        const Divider(height: 24),
        _buildPriceRow('Total', cartProvider.total, isTotal: true),
      ],
    );
  }

  Widget _buildDeliveryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+251 9XX XXX XXX',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Delivery Address',
            hintText: 'Street, House No., etc.',
            prefixIcon: Icon(Icons.home_outlined),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'City / Woreda',
            hintText: 'Enter your city',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Delivery Notes (Optional)',
            hintText: 'Special instructions for delivery',
            prefixIcon: Icon(Icons.note_outlined),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        RadioListTile<String>(
          value: 'cash_on_delivery',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          title: const Text('Cash on Delivery'),
          subtitle: const Text('Pay when you receive your order'),
          secondary: const Icon(Icons.money),
        ),

        RadioListTile<String>(
          value: 'bank_transfer',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          title: const Text('Bank Transfer'),
          subtitle: const Text('Transfer to farmer\'s account'),
          secondary: const Icon(Icons.account_balance),
        ),

        RadioListTile<String>(
          value: 'mobile_money',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          title: const Text('Mobile Money'),
          subtitle: const Text('Pay via mobile banking (CBE Birr, etc.)'),
          secondary: const Icon(Icons.phone_android),
        ),

        const SizedBox(height: 24),

        // Terms and conditions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.tertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'By placing this order, you agree to our Terms & Conditions and Privacy Policy.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _isProcessing ? null : details.onStepCancel,
              style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
              child: const Text('Back'),
            ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _isProcessing ? null : () => _onStepContinue(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_currentStep == 2 ? 'Place Order' : 'Continue'),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() async {
    if (_currentStep == 0) {
      // Order review - proceed to delivery
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      // Delivery details - validate and proceed to payment
      if (_validateDeliveryDetails()) {
        setState(() {
          _currentStep = 2;
        });
      }
    } else if (_currentStep == 2) {
      // Payment - place order
      await _placeOrder();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  bool _validateDeliveryDetails() {
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter your delivery address');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      _showError('Please enter your city');
      return false;
    }
    return true;
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Get buyer info
      final buyerId = authProvider.user?.id ?? 'buyer_unknown';
      final buyerName = authProvider.user?.fullName ?? 'Unknown Buyer';

      // Create separate order for each cart item (current OrderModel is single-item)
      final orders = <OrderModel>[];
      for (final cartItem in cartProvider.items) {
        final order = OrderModel(
          id: 'order_${DateTime.now().millisecondsSinceEpoch}_${cartItem.produceId}',
          produceId: cartItem.produceId,
          produceName: cartItem.produceName,
          buyerId: buyerId,
          buyerName: buyerName,
          farmerId: cartItem.farmerId,
          farmerName: cartItem.farmerName,
          quantityOrdered: cartItem.quantity,
          unit: cartItem.unit,
          pricePerUnit: cartItem.pricePerUnit,
          totalPrice: cartItem.totalPrice,
          status: 'pending',
          pickupLocation: 'Farmer Location', // TODO: Get from produce
          deliveryLocation: _addressController.text.trim(),
          deliveryInstructions: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
          paymentMethod: _paymentMethod,
          paymentStatus: 'pending',
          createdAt: DateTime.now(),
        );
        orders.add(order);
      }

      // Place all orders
      for (final order in orders) {
        await orderProvider.createOrder(order);
      }

      // Clear cart
      await cartProvider.clearCart();

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            icon: Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 64,
            ),
            title: Text('Order Placed Successfully!', style: TextStyle(color: AppColors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${orders.length} order(s) placed',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your orders have been placed and are being processed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  // Navigate back to dashboard and switch to orders tab
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  DefaultTabController.of(context).animateTo(1);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Orders'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to place order: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ETB',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.border,
          ),
          const SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Back to Shopping'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
