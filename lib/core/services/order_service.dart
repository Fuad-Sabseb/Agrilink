import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/order_model.dart';

/// OrderService - Manages orders with comprehensive status workflow
/// Status flow: pending → confirmed → in_transit → delivered → completed
/// Can also be: cancelled, rejected
/// 
/// Features:
/// - Full CRUD operations with validation
/// - Status workflow management with business rules
/// - Payment tracking
/// - Search and filter capabilities
/// - Offline-first with Hive caching
/// - Mock data generation for testing
/// - Error handling and logging
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Box<OrderModel>? _orderBox;
  final _uuid = const Uuid();
  bool _mockDataInitialized = false;

  // Valid status transitions
  static const Map<String, List<String>> _validTransitions = {
    'pending': ['confirmed', 'rejected', 'cancelled'],
    'confirmed': ['in_transit', 'cancelled'],
    'in_transit': ['delivered', 'cancelled'],
    'delivered': ['completed'],
    'rejected': [],
    'cancelled': [],
    'completed': [],
  };

  /// Initialize service and load mock data
  Future<void> initialize() async {
    try {
      _orderBox = await Hive.openBox<OrderModel>('orders');
      
      // Load mock data if box is empty
      if (_orderBox!.isEmpty && !_mockDataInitialized) {
        await _initializeMockData();
        _mockDataInitialized = true;
      }
    } catch (e) {
      throw Exception('Failed to initialize OrderService: $e');
    }
  }

  Box<OrderModel> get _box {
    if (_orderBox == null || !_orderBox!.isOpen) {
      throw Exception('OrderService not initialized. Call initialize() first.');
    }
    return _orderBox!;
  }

  // ============================================================
  // CREATE Operations
  // ============================================================

  /// Place a new order with validation
  Future<OrderModel> placeOrder({
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
    String paymentMethod = 'on_delivery',
  }) async {
    // Validation
    _validateOrderData(
      quantityOrdered: quantityOrdered,
      pricePerUnit: pricePerUnit,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
    );

    final id = _uuid.v4();
    final totalPrice = quantityOrdered * pricePerUnit;
    
    final order = OrderModel(
      id: id,
      produceId: produceId,
      produceName: produceName,
      buyerId: buyerId,
      buyerName: buyerName,
      farmerId: farmerId,
      farmerName: farmerName,
      quantityOrdered: quantityOrdered,
      unit: unit,
      pricePerUnit: pricePerUnit,
      totalPrice: totalPrice,
      status: 'pending',
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      deliveryInstructions: deliveryInstructions,
      estimatedDeliveryDate: estimatedDeliveryDate,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'on_delivery' ? 'pending' : 'pending',
      createdAt: DateTime.now(),
    );

    try {
      await _box.put(id, order);
      return order;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  // ============================================================
  // READ Operations
  // ============================================================

  /// Get order by ID
  OrderModel? getOrderById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to get order by ID: $e');
    }
  }

  /// Get all orders
  List<OrderModel> getAllOrders() {
    try {
      return _box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  /// Get orders for a specific buyer
  List<OrderModel> getOrdersForBuyer(String buyerId) {
    try {
      return _box.values
          .where((o) => o.buyerId == buyerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get buyer orders: $e');
    }
  }

  /// Get orders for a specific farmer
  List<OrderModel> getOrdersForFarmer(String farmerId) {
    try {
      return _box.values
          .where((o) => o.farmerId == farmerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get farmer orders: $e');
    }
  }

  /// Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    try {
      return _box.values
          .where((o) => o.status == status)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  /// Get all confirmed orders (for transport assignment)
  List<OrderModel> getAllConfirmedOrders() {
    return getOrdersByStatus('confirmed');
  }

  /// Get all active orders (not cancelled or completed)
  List<OrderModel> getActiveOrders() {
    try {
      return _box.values
          .where((o) => o.isActive)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get active orders: $e');
    }
  }

  /// Get orders requiring transport
  List<OrderModel> getOrdersRequiringTransport() {
    try {
      return _box.values
          .where((o) => o.requiresTransport && o.status == 'confirmed')
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get orders requiring transport: $e');
    }
  }

  /// Get overdue orders
  List<OrderModel> getOverdueOrders() {
    try {
      return _box.values
          .where((o) => o.isOverdue)
          .toList()
        ..sort((a, b) => b.estimatedDeliveryDate!
            .compareTo(a.estimatedDeliveryDate!));
    } catch (e) {
      throw Exception('Failed to get overdue orders: $e');
    }
  }

  /// Get orders by payment status
  List<OrderModel> getOrdersByPaymentStatus(String paymentStatus) {
    try {
      return _box.values
          .where((o) => o.paymentStatus == paymentStatus)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get orders by payment status: $e');
    }
  }

  /// Get pending payment orders
  List<OrderModel> getPendingPaymentOrders() {
    return getOrdersByPaymentStatus('pending');
  }

  // ============================================================
  // SEARCH & FILTER Operations
  // ============================================================

  /// Search orders by produce name, buyer name, or farmer name
  List<OrderModel> searchOrders(String query) {
    try {
      if (query.isEmpty) return getAllOrders();

      final lowerQuery = query.toLowerCase();
      return _box.values
          .where((o) =>
              o.produceName.toLowerCase().contains(lowerQuery) ||
              o.buyerName.toLowerCase().contains(lowerQuery) ||
              o.farmerName.toLowerCase().contains(lowerQuery) ||
              o.pickupLocation.toLowerCase().contains(lowerQuery) ||
              o.deliveryLocation.toLowerCase().contains(lowerQuery))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  /// Filter orders with multiple criteria
  List<OrderModel> filterOrders({
    String? status,
    String? paymentStatus,
    String? buyerId,
    String? farmerId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) {
    try {
      var results = _box.values.toList();

      if (status != null) {
        results = results.where((o) => o.status == status).toList();
      }

      if (paymentStatus != null) {
        results = results.where((o) => o.paymentStatus == paymentStatus).toList();
      }

      if (buyerId != null) {
        results = results.where((o) => o.buyerId == buyerId).toList();
      }

      if (farmerId != null) {
        results = results.where((o) => o.farmerId == farmerId).toList();
      }

      if (startDate != null) {
        results = results
            .where((o) => o.createdAt.isAfter(startDate) ||
                o.createdAt.isAtSameMomentAs(startDate))
            .toList();
      }

      if (endDate != null) {
        results = results
            .where((o) => o.createdAt.isBefore(endDate) ||
                o.createdAt.isAtSameMomentAs(endDate))
            .toList();
      }

      if (minAmount != null) {
        results = results.where((o) => o.totalPrice >= minAmount).toList();
      }

      if (maxAmount != null) {
        results = results.where((o) => o.totalPrice <= maxAmount).toList();
      }

      return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to filter orders: $e');
    }
  }

  // ============================================================
  // UPDATE Operations
  // ============================================================

  /// Update order status with validation
  Future<void> updateOrderStatus(
    String id,
    String newStatus, {
    String? cancellationReason,
  }) async {
    try {
      final order = getOrderById(id);
      if (order == null) {
        throw Exception('Order not found with ID: $id');
      }

      // Validate status transition
      if (!_canTransitionTo(order.status, newStatus)) {
        throw Exception(
            'Invalid status transition from ${order.status} to $newStatus');
      }

      final now = DateTime.now();
      DateTime? confirmedAt = order.confirmedAt;
      DateTime? completedAt = order.completedAt;
      DateTime? actualDeliveryDate = order.actualDeliveryDate;

      // Update timestamps based on status
      if (newStatus == 'confirmed' && confirmedAt == null) {
        confirmedAt = now;
      }
      if (newStatus == 'delivered' && actualDeliveryDate == null) {
        actualDeliveryDate = now;
      }
      if (newStatus == 'completed' && completedAt == null) {
        completedAt = now;
      }

      final updated = order.copyWith(
        status: newStatus,
        cancellationReason: cancellationReason,
        confirmedAt: confirmedAt,
        actualDeliveryDate: actualDeliveryDate,
        completedAt: completedAt,
        updatedAt: now,
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Confirm order (farmer accepts)
  Future<void> confirmOrder(String id) async {
    await updateOrderStatus(id, 'confirmed');
  }

  /// Reject order (farmer rejects)
  Future<void> rejectOrder(String id, String reason) async {
    await updateOrderStatus(id, 'rejected', cancellationReason: reason);
  }

  /// Cancel order (buyer or farmer cancels)
  Future<void> cancelOrder(String id, String reason) async {
    final order = getOrderById(id);
    if (order == null) {
      throw Exception('Order not found');
    }

    if (!order.canBeCancelled) {
      throw Exception('Order cannot be cancelled at this stage');
    }

    await updateOrderStatus(id, 'cancelled', cancellationReason: reason);
  }

  /// Mark order as in transit
  Future<void> markOrderInTransit(String id, {String? transportRequestId}) async {
    final order = getOrderById(id);
    if (order == null) {
      throw Exception('Order not found');
    }

    final updated = order.copyWith(
      status: 'in_transit',
      transportRequestId: transportRequestId,
      updatedAt: DateTime.now(),
    );

    await _box.put(id, updated);
  }

  /// Mark order as delivered
  Future<void> markOrderDelivered(String id) async {
    await updateOrderStatus(id, 'delivered');
  }

  /// Complete order (final step)
  Future<void> completeOrder(String id) async {
    await updateOrderStatus(id, 'completed');
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String id, String paymentStatus) async {
    try {
      final order = getOrderById(id);
      if (order == null) {
        throw Exception('Order not found with ID: $id');
      }

      if (!['pending', 'paid', 'partial', 'refunded'].contains(paymentStatus)) {
        throw Exception('Invalid payment status: $paymentStatus');
      }

      final updated = order.copyWith(
        paymentStatus: paymentStatus,
        updatedAt: DateTime.now(),
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Update estimated delivery date
  Future<void> updateEstimatedDeliveryDate(
    String id,
    DateTime estimatedDeliveryDate,
  ) async {
    try {
      final order = getOrderById(id);
      if (order == null) {
        throw Exception('Order not found with ID: $id');
      }

      final updated = order.copyWith(
        estimatedDeliveryDate: estimatedDeliveryDate,
        updatedAt: DateTime.now(),
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to update estimated delivery date: $e');
    }
  }

  /// Link order to transport request
  Future<void> linkTransportRequest(String orderId, String transportRequestId) async {
    try {
      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found with ID: $orderId');
      }

      final updated = order.copyWith(
        transportRequestId: transportRequestId,
        updatedAt: DateTime.now(),
      );

      await _box.put(orderId, updated);
    } catch (e) {
      throw Exception('Failed to link transport request: $e');
    }
  }

  // ============================================================
  // DELETE Operations
  // ============================================================

  /// Delete order by ID (use with caution!)
  Future<void> deleteOrder(String id) async {
    try {
      final order = getOrderById(id);
      if (order == null) {
        throw Exception('Order not found with ID: $id');
      }

      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Clear all orders (use with caution!)
  Future<void> clearAllOrders() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Failed to clear all orders: $e');
    }
  }

  // ============================================================
  // STATISTICS Operations
  // ============================================================

  /// Get order statistics for dashboard
  Map<String, dynamic> getOrderStatistics() {
    try {
      final allOrders = _box.values.toList();
      final activeOrders = allOrders.where((o) => o.isActive).toList();

      return {
        'totalOrders': allOrders.length,
        'activeOrders': activeOrders.length,
        'pendingOrders': allOrders.where((o) => o.status == 'pending').length,
        'confirmedOrders': allOrders.where((o) => o.status == 'confirmed').length,
        'inTransitOrders': allOrders.where((o) => o.status == 'in_transit').length,
        'deliveredOrders': allOrders.where((o) => o.status == 'delivered').length,
        'completedOrders': allOrders.where((o) => o.status == 'completed').length,
        'cancelledOrders': allOrders.where((o) => o.status == 'cancelled').length,
        'totalRevenue': allOrders
            .where((o) => o.status == 'completed')
            .fold<double>(0, (sum, o) => sum + o.totalPrice),
        'pendingRevenue': activeOrders.fold<double>(0, (sum, o) => sum + o.totalPrice),
        'averageOrderValue': allOrders.isEmpty
            ? 0.0
            : allOrders.fold<double>(0, (sum, o) => sum + o.totalPrice) /
                allOrders.length,
        'overdueOrders': allOrders.where((o) => o.isOverdue).length,
        'pendingPayments': allOrders.where((o) => o.paymentStatus == 'pending').length,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  /// Get buyer statistics
  Map<String, dynamic> getBuyerStatistics(String buyerId) {
    try {
      final buyerOrders = getOrdersForBuyer(buyerId);

      return {
        'totalOrders': buyerOrders.length,
        'activeOrders': buyerOrders.where((o) => o.isActive).length,
        'completedOrders': buyerOrders.where((o) => o.status == 'completed').length,
        'totalSpent': buyerOrders
            .where((o) => o.status == 'completed')
            .fold<double>(0, (sum, o) => sum + o.totalPrice),
        'pendingPayments': buyerOrders
            .where((o) => o.paymentStatus == 'pending')
            .fold<double>(0, (sum, o) => sum + o.totalPrice),
      };
    } catch (e) {
      throw Exception('Failed to get buyer statistics: $e');
    }
  }

  /// Get farmer statistics
  Map<String, dynamic> getFarmerStatistics(String farmerId) {
    try {
      final farmerOrders = getOrdersForFarmer(farmerId);

      return {
        'totalOrders': farmerOrders.length,
        'pendingOrders': farmerOrders.where((o) => o.status == 'pending').length,
        'activeOrders': farmerOrders.where((o) => o.isActive).length,
        'completedOrders': farmerOrders.where((o) => o.status == 'completed').length,
        'totalEarnings': farmerOrders
            .where((o) => o.status == 'completed')
            .fold<double>(0, (sum, o) => sum + o.totalPrice),
        'pendingEarnings': farmerOrders
            .where((o) => o.paymentStatus == 'pending' && o.status == 'completed')
            .fold<double>(0, (sum, o) => sum + o.totalPrice),
      };
    } catch (e) {
      throw Exception('Failed to get farmer statistics: $e');
    }
  }

  // ============================================================
  // VALIDATION & HELPERS
  // ============================================================

  void _validateOrderData({
    required double quantityOrdered,
    required double pricePerUnit,
    required String pickupLocation,
    required String deliveryLocation,
  }) {
    if (quantityOrdered <= 0) {
      throw Exception('Quantity must be greater than 0');
    }

    if (pricePerUnit <= 0) {
      throw Exception('Price per unit must be greater than 0');
    }

    if (pickupLocation.trim().isEmpty) {
      throw Exception('Pickup location cannot be empty');
    }

    if (deliveryLocation.trim().isEmpty) {
      throw Exception('Delivery location cannot be empty');
    }
  }

  bool _canTransitionTo(String currentStatus, String newStatus) {
    final allowedTransitions = _validTransitions[currentStatus];
    return allowedTransitions?.contains(newStatus) ?? false;
  }

  // ============================================================
  // MOCK DATA GENERATION
  // ============================================================

  /// Initialize mock order data for testing
  Future<void> _initializeMockData() async {
    final mockOrders = _generateMockOrders();
    for (final order in mockOrders) {
      await _box.put(order.id, order);
    }
  }

  /// Generate 15+ mock orders with various statuses
  List<OrderModel> _generateMockOrders() {
    final now = DateTime.now();

    return [
      // Pending orders
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_001',
        produceName: 'Teff (White)',
        buyerId: 'buyer_001',
        buyerName: 'Addis Restaurant Supply',
        farmerId: 'farmer_001',
        farmerName: 'Abebe Kebede',
        quantityOrdered: 100,
        unit: 'kg',
        pricePerUnit: 85.0,
        totalPrice: 8500.0,
        status: 'pending',
        pickupLocation: 'Addis Ababa',
        deliveryLocation: 'Addis Ababa, Bole',
        deliveryInstructions: 'Deliver to warehouse entrance',
        estimatedDeliveryDate: now.add(const Duration(days: 3)),
        paymentMethod: 'bank_transfer',
        paymentStatus: 'pending',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_002',
        produceName: 'Wheat',
        buyerId: 'buyer_002',
        buyerName: 'Bakery Union',
        farmerId: 'farmer_003',
        farmerName: 'Girma Hailu',
        quantityOrdered: 500,
        unit: 'kg',
        pricePerUnit: 45.0,
        totalPrice: 22500.0,
        status: 'pending',
        pickupLocation: 'Arsi',
        deliveryLocation: 'Addis Ababa',
        paymentMethod: 'on_delivery',
        paymentStatus: 'pending',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),

      // Confirmed orders
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_003',
        produceName: 'Tomatoes',
        buyerId: 'buyer_003',
        buyerName: 'Fresh Market Ltd',
        farmerId: 'farmer_010',
        farmerName: 'Selamawit Yohannes',
        quantityOrdered: 80,
        unit: 'kg',
        pricePerUnit: 25.0,
        totalPrice: 2000.0,
        status: 'confirmed',
        pickupLocation: 'Hawassa',
        deliveryLocation: 'Addis Ababa',
        deliveryInstructions: 'Handle with care, fragile items',
        estimatedDeliveryDate: now.add(const Duration(days: 2)),
        paymentMethod: 'mobile_money',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 1)),
        confirmedAt: now.subtract(const Duration(hours: 20)),
      ),
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_004',
        produceName: 'Coffee (Arabica)',
        buyerId: 'buyer_004',
        buyerName: 'Export Coffee Co',
        farmerId: 'farmer_019',
        farmerName: 'Tadesse Wolde',
        quantityOrdered: 200,
        unit: 'kg',
        pricePerUnit: 180.0,
        totalPrice: 36000.0,
        status: 'confirmed',
        pickupLocation: 'Sidamo',
        deliveryLocation: 'Dire Dawa',
        estimatedDeliveryDate: now.add(const Duration(days: 5)),
        paymentMethod: 'bank_transfer',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 2)),
        confirmedAt: now.subtract(const Duration(days: 1, hours: 18)),
      ),

      // In transit orders
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_005',
        produceName: 'Onions (Red)',
        buyerId: 'buyer_001',
        buyerName: 'Addis Restaurant Supply',
        farmerId: 'farmer_011',
        farmerName: 'Berhanu Taye',
        quantityOrdered: 150,
        unit: 'kg',
        pricePerUnit: 20.0,
        totalPrice: 3000.0,
        status: 'in_transit',
        pickupLocation: 'Mekelle',
        deliveryLocation: 'Addis Ababa',
        transportRequestId: 'trans_001',
        estimatedDeliveryDate: now.add(const Duration(days: 1)),
        paymentMethod: 'on_delivery',
        paymentStatus: 'pending',
        createdAt: now.subtract(const Duration(days: 3)),
        confirmedAt: now.subtract(const Duration(days: 2, hours: 12)),
      ),
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_006',
        produceName: 'Potatoes',
        buyerId: 'buyer_005',
        buyerName: 'Supermarket Chain',
        farmerId: 'farmer_013',
        farmerName: 'Tesfaye Worku',
        quantityOrdered: 300,
        unit: 'kg',
        pricePerUnit: 18.0,
        totalPrice: 5400.0,
        status: 'in_transit',
        pickupLocation: 'Chencha',
        deliveryLocation: 'Hawassa',
        transportRequestId: 'trans_002',
        estimatedDeliveryDate: now.add(const Duration(hours: 12)),
        paymentMethod: 'mobile_money',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 4)),
        confirmedAt: now.subtract(const Duration(days: 3, hours: 8)),
      ),

      // Delivered orders
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_007',
        produceName: 'Avocados',
        buyerId: 'buyer_003',
        buyerName: 'Fresh Market Ltd',
        farmerId: 'farmer_015',
        farmerName: 'Getachew Haile',
        quantityOrdered: 50,
        unit: 'kg',
        pricePerUnit: 80.0,
        totalPrice: 4000.0,
        status: 'delivered',
        pickupLocation: 'Yirgalem',
        deliveryLocation: 'Addis Ababa',
        transportRequestId: 'trans_003',
        estimatedDeliveryDate: now.subtract(const Duration(hours: 2)),
        actualDeliveryDate: now.subtract(const Duration(hours: 1)),
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 5)),
        confirmedAt: now.subtract(const Duration(days: 4, hours: 10)),
      ),

      // Completed orders
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_008',
        produceName: 'Chickpeas (Shimbra)',
        buyerId: 'buyer_002',
        buyerName: 'Bakery Union',
        farmerId: 'farmer_006',
        farmerName: 'Marta Tadesse',
        quantityOrdered: 200,
        unit: 'kg',
        pricePerUnit: 65.0,
        totalPrice: 13000.0,
        status: 'completed',
        pickupLocation: 'Gojjam',
        deliveryLocation: 'Addis Ababa',
        transportRequestId: 'trans_004',
        estimatedDeliveryDate: now.subtract(const Duration(days: 2)),
        actualDeliveryDate: now.subtract(const Duration(days: 1, hours: 20)),
        paymentMethod: 'bank_transfer',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 10)),
        confirmedAt: now.subtract(const Duration(days: 9)),
        completedAt: now.subtract(const Duration(days: 1, hours: 18)),
      ),
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_009',
        produceName: 'Lentils (Misir)',
        buyerId: 'buyer_004',
        buyerName: 'Export Coffee Co',
        farmerId: 'farmer_008',
        farmerName: 'Hanna Mekonnen',
        quantityOrdered: 150,
        unit: 'kg',
        pricePerUnit: 70.0,
        totalPrice: 10500.0,
        status: 'completed',
        pickupLocation: 'Wollo',
        deliveryLocation: 'Dire Dawa',
        estimatedDeliveryDate: now.subtract(const Duration(days: 5)),
        actualDeliveryDate: now.subtract(const Duration(days: 4, hours: 22)),
        paymentMethod: 'mobile_money',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 15)),
        confirmedAt: now.subtract(const Duration(days: 14)),
        completedAt: now.subtract(const Duration(days: 4, hours: 20)),
      ),
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_010',
        produceName: 'Maize (Yellow)',
        buyerId: 'buyer_001',
        buyerName: 'Addis Restaurant Supply',
        farmerId: 'farmer_005',
        farmerName: 'Mulugeta Assefa',
        quantityOrdered: 400,
        unit: 'kg',
        pricePerUnit: 30.0,
        totalPrice: 12000.0,
        status: 'completed',
        pickupLocation: 'Jimma',
        deliveryLocation: 'Addis Ababa',
        paymentMethod: 'cash',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 20)),
        confirmedAt: now.subtract(const Duration(days: 19)),
        completedAt: now.subtract(const Duration(days: 12)),
      ),

      // Cancelled order
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_011',
        produceName: 'Bananas',
        buyerId: 'buyer_005',
        buyerName: 'Supermarket Chain',
        farmerId: 'farmer_016',
        farmerName: 'Rahel Kebede',
        quantityOrdered: 100,
        unit: 'kg',
        pricePerUnit: 30.0,
        totalPrice: 3000.0,
        status: 'cancelled',
        pickupLocation: 'Arba Minch',
        deliveryLocation: 'Addis Ababa',
        cancellationReason: 'Buyer requested cancellation - changed order requirements',
        paymentMethod: 'on_delivery',
        paymentStatus: 'refunded',
        createdAt: now.subtract(const Duration(days: 7)),
      ),

      // Rejected order
      OrderModel(
        id: _uuid.v4(),
        produceId: 'prod_012',
        produceName: 'Cabbage',
        buyerId: 'buyer_003',
        buyerName: 'Fresh Market Ltd',
        farmerId: 'farmer_012',
        farmerName: 'Eyerusalem Alemu',
        quantityOrdered: 200,
        unit: 'kg',
        pricePerUnit: 15.0,
        totalPrice: 3000.0,
        status: 'rejected',
        pickupLocation: 'Holeta',
        deliveryLocation: 'Addis Ababa',
        cancellationReason: 'Insufficient stock available',
        paymentMethod: 'mobile_money',
        paymentStatus: 'refunded',
        createdAt: now.subtract(const Duration(days: 6)),
      ),

      // Additional orders for variety
      OrderModel(
        id: _uuid.v4(),
        produceName: 'Barley',
        produceId: 'prod_013',
        buyerId: 'buyer_002',
        buyerName: 'Bakery Union',
        farmerId: 'farmer_004',
        farmerName: 'Tigist Bekele',
        quantityOrdered: 250,
        unit: 'kg',
        pricePerUnit: 40.0,
        totalPrice: 10000.0,
        status: 'confirmed',
        pickupLocation: 'Gonder',
        deliveryLocation: 'Bahir Dar',
        estimatedDeliveryDate: now.add(const Duration(days: 4)),
        paymentMethod: 'bank_transfer',
        paymentStatus: 'pending',
        createdAt: now.subtract(const Duration(hours: 8)),
        confirmedAt: now.subtract(const Duration(hours: 6)),
      ),
      OrderModel(
        id: _uuid.v4(),
        produceName: 'Green Beans',
        produceId: 'prod_014',
        buyerId: 'buyer_004',
        buyerName: 'Export Coffee Co',
        farmerId: 'farmer_024',
        farmerName: 'Yeshi Mesfin',
        quantityOrdered: 100,
        unit: 'kg',
        pricePerUnit: 42.0,
        totalPrice: 4200.0,
        status: 'pending',
        pickupLocation: 'Ziway',
        deliveryLocation: 'Dire Dawa',
        deliveryInstructions: 'Export quality - inspect before loading',
        estimatedDeliveryDate: now.add(const Duration(days: 3)),
        paymentMethod: 'bank_transfer',
        paymentStatus: 'pending',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      
      // Overdue order (for testing)
      OrderModel(
        id: _uuid.v4(),
        produceName: 'Ginger',
        produceId: 'prod_015',
        buyerId: 'buyer_005',
        buyerName: 'Supermarket Chain',
        farmerId: 'farmer_021',
        farmerName: 'Fikru Belay',
        quantityOrdered: 60,
        unit: 'kg',
        pricePerUnit: 95.0,
        totalPrice: 5700.0,
        status: 'in_transit',
        pickupLocation: 'Wolaita',
        deliveryLocation: 'Hawassa',
        transportRequestId: 'trans_005',
        estimatedDeliveryDate: now.subtract(const Duration(days: 2)),
        paymentMethod: 'mobile_money',
        paymentStatus: 'paid',
        createdAt: now.subtract(const Duration(days: 8)),
        confirmedAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }


  /// Reload mock data (for testing/development)
  Future<void> reloadMockData() async {
    await clearAllOrders();
    await _initializeMockData();
  }

  /// Create a new order
  Future<void> createOrder(OrderModel order) async {
    try {
      // Ensure box is initialized
      if (_orderBox == null) {
        await initialize();
      }
      
      // Add to cache
      await _orderBox!.put(order.id, order);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }
}
