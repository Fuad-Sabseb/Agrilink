import 'package:flutter/foundation.dart';
import '../../models/order_model.dart';
import '../services/order_service.dart';

/// Order Provider - State Management
///
/// Features:
/// - Centralized order state management
/// - Order filtering and search
/// - Role-based order views (buyer, farmer)
/// - Automatic UI updates via ChangeNotifier
/// - Role-specific data loading (buyer, farmer)
class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OrderModel> get allOrders => _allOrders;
  List<OrderModel> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderProvider() {
    loadAllOrders();
  }

  /// Load all orders from service
  Future<void> loadAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allOrders = await _orderService.getAllOrders();
      _filteredOrders = _allOrders;
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter orders by status
  void filterByStatus(String? status) {
    if (status == null || status.isEmpty || status == 'all') {
      _filteredOrders = _allOrders;
    } else {
      _filteredOrders =
          _allOrders.where((order) => order.status == status).toList();
    }
    notifyListeners();
  }

  /// Search orders by produce name, buyer name, or farmer name
  void searchOrders(String query) {
    if (query.isEmpty) {
      _filteredOrders = _allOrders;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredOrders = _allOrders.where((order) {
        return order.produceName.toLowerCase().contains(lowerQuery) ||
            order.buyerName.toLowerCase().contains(lowerQuery) ||
            order.farmerName.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  /// Get orders for a specific farmer
  List<OrderModel> getFarmerOrders(String farmerId) {
    return _allOrders.where((order) => order.farmerId == farmerId).toList();
  }

  /// Get orders for a specific buyer
  List<OrderModel> getBuyerOrders(String buyerId) {
    return _allOrders.where((order) => order.buyerId == buyerId).toList();
  }

  /// Get order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return _allOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Get pending orders (for farmer view)
  List<OrderModel> get pendingOrders {
    return _allOrders.where((order) => order.status == 'pending').toList();
  }

  /// Get confirmed orders (for farmer view)
  List<OrderModel> get confirmedOrders {
    return _allOrders.where((order) => order.status == 'confirmed').toList();
  }

  /// Get completed orders
  List<OrderModel> get completedOrders {
    return _allOrders.where((order) => order.status == 'completed').toList();
  }

  /// Get in-transit orders (for transporter view)
  List<OrderModel> get inTransitOrders {
    return _allOrders.where((order) => order.status == 'in_transit').toList();
  }

  /// Get orders requiring transport
  List<OrderModel> get ordersNeedingTransport {
    return _allOrders
        .where((order) =>
            order.status == 'confirmed' && order.transportRequestId == null)
        .toList();
  }

  /// Confirm an order (farmer accepts buyer's order)
  Future<bool> confirmOrder(String orderId) async {
    try {
      await _orderService.updateOrderStatus(
        orderId,
        'confirmed',
      );
      // Reload orders to get updated data
      await loadAllOrders();
      return true;
    } catch (e) {
      _error = 'Failed to confirm order: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await _orderService.updateOrderStatus(
        orderId,
        'cancelled',
        cancellationReason: reason,
      );
      // Reload orders to get updated data
      await loadAllOrders();
      return true;
    } catch (e) {
      _error = 'Failed to cancel order: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark order as in-transit (transporter picked up)
  Future<bool> markOrderInTransit(String orderId, String transporterId) async {
    try {
      await _orderService.updateOrderStatus(
        orderId,
        'in_transit',
      );
      // Note: transporterId update would need a separate method
      // Reload orders to get updated data
      await loadAllOrders();
      return true;
    } catch (e) {
      _error = 'Failed to mark order in transit: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark order as delivered
  Future<bool> markOrderDelivered(String orderId) async {
    try {
      await _orderService.updateOrderStatus(
        orderId,
        'delivered',
      );
      // Reload orders to get updated data
      await loadAllOrders();
      return true;
    } catch (e) {
      _error = 'Failed to mark order delivered: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mark order as completed (payment received)
  Future<bool> completeOrder(String orderId) async {
    try {
      await _orderService.updateOrderStatus(
        orderId,
        'completed',
      );
      // Reload orders to get updated data
      await loadAllOrders();
      return true;
    } catch (e) {
      _error = 'Failed to complete order: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update order in the list
  void _updateOrderInList(OrderModel updatedOrder) {
    final index = _allOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _allOrders[index] = updatedOrder;
    }

    final filteredIndex =
        _filteredOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (filteredIndex != -1) {
      _filteredOrders[filteredIndex] = updatedOrder;
    }
  }

  /// Get order statistics for buyer dashboard
  Map<String, dynamic> get buyerStatistics {
    if (_allOrders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'averageOrderValue': 0.0,
        'pendingOrders': 0,
        'confirmedOrders': 0,
        'completedOrders': 0,
      };
    }

    final totalSpent = _allOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.totalPrice,
    );

    return {
      'totalOrders': _allOrders.length,
      'totalSpent': totalSpent,
      'averageOrderValue': totalSpent / _allOrders.length,
      'pendingOrders': _allOrders.where((o) => o.status == 'pending').length,
      'confirmedOrders': _allOrders.where((o) => o.status == 'confirmed').length,
      'completedOrders': _allOrders.where((o) => o.status == 'completed').length,
    };
  }

  /// Get farmer statistics
  Map<String, dynamic> get farmerStatistics {
    if (_allOrders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
        'pendingOrders': 0,
        'confirmedOrders': 0,
        'completedOrders': 0,
      };
    }

    final totalRevenue = _allOrders.fold<double>(
      0.0,
      (sum, order) => sum + order.totalPrice,
    );

    return {
      'totalOrders': _allOrders.length,
      'totalRevenue': totalRevenue,
      'averageOrderValue': totalRevenue / _allOrders.length,
      'pendingOrders': _allOrders.where((o) => o.status == 'pending').length,
      'confirmedOrders': _allOrders.where((o) => o.status == 'confirmed').length,
      'completedOrders': _allOrders.where((o) => o.status == 'completed').length,
    };
  }

  /// Get orders for a specific buyer
  List<OrderModel> get buyerOrders {
    // Return orders filtered by buyer role
    return _filteredOrders;
  }

  /// Fetch orders for buyer
  Future<void> fetchOrdersForBuyer(String buyerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Filter orders by buyer ID
      _filteredOrders = _allOrders.where((order) => order.buyerId == buyerId).toList();
    } catch (e) {
      _error = 'Failed to fetch buyer orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new order
  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      // Add order to service
      await _orderService.createOrder(order);
      // Reload all orders
      await loadAllOrders();
      return order;
    } catch (e) {
      _error = 'Failed to create order: $e';
      notifyListeners();
      return null;
    }
  }

  /// Place a new order (used by buyer create order screen)
  Future<OrderModel?> placeOrder({
    required String produceId,
    required String produceName,
    required String buyerId,
    required String buyerName,
    required String farmerId,
    required String farmerName,
    required double quantityOrdered,
    required String unit,
    required double pricePerUnit,
    required String pickupLocation,
    required String deliveryLocation,
    String? deliveryInstructions,
    DateTime? estimatedDeliveryDate,
    required String paymentMethod,
  }) async {
    try {
      final order = OrderModel(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        produceId: produceId,
        produceName: produceName,
        buyerId: buyerId,
        buyerName: buyerName,
        farmerId: farmerId,
        farmerName: farmerName,
        quantityOrdered: quantityOrdered,
        unit: unit,
        pricePerUnit: pricePerUnit,
        totalPrice: quantityOrdered * pricePerUnit,
        status: 'pending',
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        deliveryInstructions: deliveryInstructions,
        estimatedDeliveryDate: estimatedDeliveryDate,
        paymentMethod: paymentMethod,
        paymentStatus: 'pending',
        createdAt: DateTime.now(),
      );

      // Create order
      return await createOrder(order);
    } catch (e) {
      _error = 'Failed to place order: $e';
      notifyListeners();
      return null;
    }
  }

  /// Load orders for a specific farmer
  Future<void> loadFarmerOrders(String farmerId) async {
    await fetchOrdersForBuyer(farmerId);  // Reuse existing method
  }

  /// Reject an order (farmer rejects buyer's order)
  Future<bool> rejectOrder(String orderId, String reason) async {
    return await cancelOrder(orderId, reason);  // Reuse cancel logic
  }

  /// Getter for farmer orders
  List<OrderModel> get farmerOrders => buyerOrders;

  /// Getter for error state
  bool get hasError => _error != null;
}

