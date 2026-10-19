import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/order_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/produce_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Create Order Screen
/// Allows buyer to place an order for specific produce
/// Pre-fills data from selected produce and farmer
class CreateOrderScreen extends StatefulWidget {
  final ProduceModel produce;
  final String farmerName;
  final String farmerPhone;

  const CreateOrderScreen({
    super.key,
    required this.produce,
    required this.farmerName,
    required this.farmerPhone,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _deliveryInstructionsController = TextEditingController();

  String _paymentMethod = 'cash_on_delivery';
  DateTime? _estimatedDeliveryDate;
  bool _isSubmitting = false;

  double _totalPrice = 0.0;
  String? _quantityError;

  @override
  void initState() {
    super.initState();
    // Pre-fill with minimum viable quantity
    _quantityController.text = '1';
    _calculateTotal();

    // Listen to quantity changes
    _quantityController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _deliveryLocationController.dispose();
    _deliveryInstructionsController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalPrice = quantity * widget.produce.pricePerUnit;
      _quantityError = null;

      // Validate quantity against available stock
      if (quantity > widget.produce.quantity) {
        _quantityError =
            'Maximum available: ${widget.produce.quantity} ${widget.produce.unit}';
      } else if (quantity <= 0) {
        _quantityError = 'Quantity must be greater than 0';
      }
    });
  }

  Future<void> _selectDeliveryDate() async {
    final now = DateTime.now();
    final minDate = now.add(const Duration(days: 1));
    final maxDate = now.add(const Duration(days: 30));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _estimatedDeliveryDate ?? minDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _estimatedDeliveryDate = selectedDate;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_quantityError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_quantityError!),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_estimatedDeliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an estimated delivery date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<OrderProvider>();
      
      // Use proper AuthProvider and UserModel API
      final buyerId = authProvider.userId ?? 'buyer_unknown';
      final buyerName = authProvider.user?.fullName ?? 'Buyer';

      final order = await orderProvider.placeOrder(
        produceId: widget.produce.id,
        produceName: widget.produce.cropName,
        buyerId: buyerId,
        buyerName: buyerName,
        farmerId: widget.produce.farmerId,
        farmerName: widget.farmerName,
        quantityOrdered: double.parse(_quantityController.text),
        unit: widget.produce.unit,
        pricePerUnit: widget.produce.pricePerUnit,
        pickupLocation: widget.produce.location,
        deliveryLocation: _deliveryLocationController.text.trim(),
        deliveryInstructions:
            _deliveryInstructionsController.text.trim().isEmpty
                ? null
                : _deliveryInstructionsController.text.trim(),
        estimatedDeliveryDate: _estimatedDeliveryDate,
        paymentMethod: _paymentMethod,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (order != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate back to previous screen
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create order. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: const Text('Create Order'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Produce Summary Card
            _buildProduceSummaryCard(),
            const SizedBox(height: 20),

            // Farmer Information Card
            _buildFarmerInfoCard(),
            const SizedBox(height: 20),

            // Order Details Section
            _buildSectionHeader('Order Details'),
            const SizedBox(height: 12),

            // Quantity Input
            _buildQuantityInput(),
            const SizedBox(height: 16),

            // Delivery Location
            TextFormField(
              controller: _deliveryLocationController,
              decoration: InputDecoration(
                labelText: 'Delivery Location *',
                hintText: 'Enter your delivery address',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter delivery location';
                }
                return null;
              },
              maxLines: 2,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Estimated Delivery Date
            InkWell(
              onTap: _isSubmitting ? null : _selectDeliveryDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Estimated Delivery Date *',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                child: Text(
                  _estimatedDeliveryDate != null
                      ? DateFormat('MMMM dd, yyyy')
                          .format(_estimatedDeliveryDate!)
                      : 'Select delivery date',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _estimatedDeliveryDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Instructions (Optional)
            TextFormField(
              controller: _deliveryInstructionsController,
              decoration: InputDecoration(
                labelText: 'Delivery Instructions (Optional)',
                hintText: 'Any special instructions for delivery',
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              maxLines: 3,
              maxLength: 500,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 20),

            // Payment Method Section
            _buildSectionHeader('Payment Method'),
            const SizedBox(height: 12),
            _buildPaymentMethodSelector(),
            const SizedBox(height: 20),

            // Price Summary Card
            _buildPriceSummaryCard(),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProduceSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryVeryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.agriculture_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.produce.cropName,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.produce.cropType,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Quality Grade',
              widget.produce.qualityGrade ?? 'Standard',
              Icons.grade_outlined,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Available Quantity',
              '${widget.produce.quantity} ${widget.produce.unit}',
              Icons.inventory_outlined,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Price per ${widget.produce.unit}',
              '${widget.produce.pricePerUnit.toStringAsFixed(2)} ETB',
              Icons.attach_money,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Pickup Location',
              widget.produce.location,
              Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryVeryLight,
              child: Text(
                widget.farmerName.isNotEmpty
                    ? widget.farmerName[0].toUpperCase()
                    : 'F',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.farmerName,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.farmerPhone,
                        style: AppTypography.bodySmall.copyWith(
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
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _quantityController,
          decoration: InputDecoration(
            labelText: 'Quantity *',
            hintText: 'Enter quantity',
            suffixText: widget.produce.unit,
            prefixIcon: const Icon(Icons.shopping_cart_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: AppColors.surface,
            errorText: _quantityError,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter quantity';
            }
            final quantity = double.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return 'Quantity must be greater than 0';
            }
            if (quantity > widget.produce.quantity) {
              return 'Exceeds available quantity';
            }
            return null;
          },
          enabled: !_isSubmitting,
        ),
        if (_quantityError == null) ...[
          const SizedBox(height: 8),
          Text(
            'Available: ${widget.produce.quantity} ${widget.produce.unit}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Cash on Delivery'),
            subtitle: const Text('Pay when you receive the order'),
            value: 'cash_on_delivery',
            groupValue: _paymentMethod,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() => _paymentMethod = value!);
                  },
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('Mobile Money'),
            subtitle: const Text('Pay via Telebirr, M-Pesa, etc.'),
            value: 'mobile_money',
            groupValue: _paymentMethod,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() => _paymentMethod = value!);
                  },
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('Bank Transfer'),
            subtitle: const Text('Transfer to farmer\'s account'),
            value: 'bank_transfer',
            groupValue: _paymentMethod,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() => _paymentMethod = value!);
                  },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryCard() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;

    return Card(
      elevation: 2,
      color: AppColors.primaryVeryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  '${_totalPrice.toStringAsFixed(2)} ETB',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$quantity ${widget.produce.unit}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${_totalPrice.toStringAsFixed(2)} ETB',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
