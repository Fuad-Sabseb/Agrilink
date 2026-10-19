import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/services/session_service.dart';
import '../../core/services/order_service.dart';
import '../../core/services/logistics_service.dart';
import '../../core/services/produce_service.dart';
import '../../models/order_model.dart';
import '../../models/logistics_model.dart';
import 'package:intl/intl.dart';

class LogisticsStatusScreen extends StatefulWidget {
  const LogisticsStatusScreen({super.key});

  @override
  State<LogisticsStatusScreen> createState() => _LogisticsStatusScreenState();
}

class _LogisticsStatusScreenState extends State<LogisticsStatusScreen> {
  final _sessionService = SessionService();
  final _orderService = OrderService();
  final _logisticsService = LogisticsService();
  final _produceService = ProduceService();

  List<Map<String, dynamic>> _logisticsData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogistics();
  }

  void _loadLogistics() {
    setState(() => _isLoading = true);
    final userId = _sessionService.currentUserId;
    if (userId != null) {
      final orders = _orderService.getOrdersForFarmer(userId)
          .where((o) => o.status != 'pending' && o.status != 'cancelled');
      
      final List<Map<String, dynamic>> data = [];
      for (var order in orders) {
        final logistics = _logisticsService.getLogisticsByOrderId(order.id);
        if (logistics != null) {
          final produce = _produceService.getProduceById(order.produceId);
          data.add({
            'order': order,
            'logistics': logistics,
            'produceName': produce?.cropName ?? 'Unknown Crop',
          });
        }
      }
      
      setState(() {
        _logisticsData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Logistics Status'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _logisticsData.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async => _loadLogistics(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _logisticsData.length,
                itemBuilder: (context, index) {
                  final item = _logisticsData[index];
                  final OrderModel order = item['order'];
                  final LogisticsModel logistics = item['logistics'];
                  final String produceName = item['produceName'];

                  return _buildLogisticsCard(order, logistics, produceName);
                },
              ),
            ),
    );
  }

  Widget _buildLogisticsCard(OrderModel order, LogisticsModel logistics, String produceName) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');
    
    Color statusColor;
    IconData statusIcon;
    switch (logistics.status) {
      case 'awaiting':
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case 'in_transit':
        statusColor = AppColors.tertiary;
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppColors.disabled;
        statusIcon = Icons.help_outline;
    }

    return Card(
      elevation: 2,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$produceName (${order.quantityOrdered})',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Destination: ${order.deliveryLocation}',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    logistics.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: AppColors.border),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn('Pickup', logistics.pickupTime != null ? dateFormat.format(logistics.pickupTime!) : 'Pending'),
                _buildTimeColumn('Delivery', logistics.deliveryTime != null ? dateFormat.format(logistics.deliveryTime!) : 'Pending'),
              ],
            ),
            if (logistics.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        logistics.notes,
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(time, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ],
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
              'Confirmed orders that have been assigned to a transporter will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
