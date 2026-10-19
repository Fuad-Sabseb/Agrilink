import 'package:flutter/services.dart';
import '../../../models/order_model.dart';

/// Order Share Helper
/// Generates shareable order summaries for SMS/WhatsApp
/// 
/// Security:
/// - Excludes auth tokens and internal IDs
/// - Excludes sensitive payment details
/// - Only includes information relevant for coordination
class OrderShareHelper {
  /// Generate shareable order summary text
  /// 
  /// Includes:
  /// - Order ID (for reference)
  /// - Produce name and quantity
  /// - Pickup and delivery locations
  /// - Estimated delivery date
  /// - Basic status
  /// 
  /// Excludes:
  /// - Auth tokens
  /// - Internal database IDs (buyer/farmer/produce IDs)
  /// - Payment details
  /// - Personal phone numbers
  /// - Sensitive notes
  static String generateOrderSummary(OrderModel order) {
    final buffer = StringBuffer();
    
    buffer.writeln('📦 Order Summary');
    buffer.writeln();
    buffer.writeln('Order #${order.id}');
    buffer.writeln('Status: ${_formatStatus(order.status)}');
    buffer.writeln();
    buffer.writeln('🌾 Product Details:');
    buffer.writeln('${order.produceName}');
    buffer.writeln('Quantity: ${order.quantityOrdered.toStringAsFixed(1)} ${order.unit}');
    buffer.writeln('Price: ETB ${order.totalPrice.toStringAsFixed(2)}');
    buffer.writeln();
    buffer.writeln('📍 Locations:');
    buffer.writeln('Pickup: ${order.pickupLocation}');
    buffer.writeln('Delivery: ${order.deliveryLocation}');
    buffer.writeln();
    
    if (order.estimatedDeliveryDate != null) {
      buffer.writeln('📅 Estimated Delivery:');
      buffer.writeln(_formatDate(order.estimatedDeliveryDate!));
      buffer.writeln();
    }
    
    if (order.deliveryInstructions != null && 
        order.deliveryInstructions!.isNotEmpty) {
      buffer.writeln('📝 Delivery Notes:');
      buffer.writeln(order.deliveryInstructions);
      buffer.writeln();
    }
    
    buffer.writeln('Created: ${_formatDate(order.createdAt)}');
    
    return buffer.toString();
  }

  /// Generate minimal order reference
  /// Useful for quick sharing with shorter format
  static String generateQuickReference(OrderModel order) {
    return '''
Order #${order.id}
${order.produceName} - ${order.quantityOrdered.toStringAsFixed(1)} ${order.unit}
${_formatStatus(order.status)}
Delivery: ${order.deliveryLocation}
''';
  }

  /// Copy order summary to clipboard
  /// Returns true if successful
  static Future<bool> copyToClipboard(OrderModel order) async {
    try {
      final summary = generateOrderSummary(order);
      await Clipboard.setData(ClipboardData(text: summary));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Copy quick reference to clipboard
  /// Returns true if successful
  static Future<bool> copyQuickReferenceToClipboard(OrderModel order) async {
    try {
      final reference = generateQuickReference(order);
      await Clipboard.setData(ClipboardData(text: reference));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Format status for display
  static String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳ Pending Confirmation';
      case 'confirmed':
        return '✅ Confirmed';
      case 'in_transit':
        return '🚚 In Transit';
      case 'delivered':
        return '📦 Delivered';
      case 'completed':
        return '✔️ Completed';
      case 'cancelled':
        return '❌ Cancelled';
      case 'rejected':
        return '⛔ Rejected';
      default:
        return status;
    }
  }

  /// Format date to readable string
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    
    if (diff.inDays == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (diff.inDays == 1) {
      return 'Tomorrow ${_formatTime(date)}';
    } else if (diff.inDays == -1) {
      return 'Yesterday ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }

  /// Format time to 12-hour format
  static String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Validate that an order can be shared
  /// Some statuses might not be appropriate for sharing
  static bool canShare(OrderModel order) {
    // Don't share cancelled or rejected orders
    return order.status.toLowerCase() != 'cancelled' &&
           order.status.toLowerCase() != 'rejected';
  }

  /// Get share suggestion based on order status
  static String getShareSuggestion(OrderModel order) {
    switch (order.status.toLowerCase()) {
      case 'pending':
        return 'Share order details to coordinate with farmer';
      case 'confirmed':
        return 'Share delivery details with your team';
      case 'in_transit':
        return 'Track shipment and coordinate delivery';
      case 'delivered':
        return 'Confirm delivery and share receipt';
      case 'completed':
        return 'Share completed order summary';
      default:
        return 'Share order information';
    }
  }
}
