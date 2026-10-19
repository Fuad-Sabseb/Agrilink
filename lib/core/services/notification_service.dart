import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

/// NotificationService - Manages in-app notifications
/// 
/// Features:
/// - In-app notification management
/// - Notification types: order, transport, produce, system, marketing
/// - Read/unread tracking
/// - Priority levels
/// - Offline-first with Hive caching
/// - Mock data generation for testing
/// - Extensible for future push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Box<AppNotification>? _notificationBox;
  final _uuid = const Uuid();
  bool _mockDataInitialized = false;

  // Stream controller for real-time notification updates
  final _notificationStreamController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get notificationStream => _notificationStreamController.stream;

  /// Initialize service and load mock data
  Future<void> initialize() async {
    try {
      _notificationBox = await Hive.openBox<AppNotification>('notifications');
      
      // Load mock data if box is empty
      if (_notificationBox!.isEmpty && !_mockDataInitialized) {
        await _initializeMockData();
        _mockDataInitialized = true;
      }
    } catch (e) {
      throw Exception('Failed to initialize NotificationService: $e');
    }
  }

  Box<AppNotification> get _box {
    if (_notificationBox == null || !_notificationBox!.isOpen) {
      throw Exception('NotificationService not initialized. Call initialize() first.');
    }
    return _notificationBox!;
  }

  // ============================================================
  // CREATE Operations
  // ============================================================

  /// Create a new notification
  Future<AppNotification> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final id = _uuid.v4();
      final notification = AppNotification(
        id: id,
        userId: userId,
        title: title,
        message: message,
        type: type,
        priority: priority,
        isRead: false,
        actionUrl: actionUrl,
        data: data,
        createdAt: DateTime.now(),
      );

      await _box.put(id, notification);
      
      // Emit notification to stream for real-time updates
      _notificationStreamController.add(notification);
      
      return notification;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Send order notification
  Future<AppNotification> sendOrderNotification({
    required String userId,
    required String orderId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    return await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.order,
      priority: priority,
      actionUrl: '/orders/$orderId',
      data: {'orderId': orderId},
    );
  }

  /// Send transport notification
  Future<AppNotification> sendTransportNotification({
    required String userId,
    required String tripId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    return await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.transport,
      priority: priority,
      actionUrl: '/transport/$tripId',
      data: {'tripId': tripId},
    );
  }

  /// Send produce notification
  Future<AppNotification> sendProduceNotification({
    required String userId,
    required String produceId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    return await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.produce,
      priority: priority,
      actionUrl: '/produce/$produceId',
      data: {'produceId': produceId},
    );
  }

  /// Send system notification
  Future<AppNotification> sendSystemNotification({
    required String userId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    return await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.system,
      priority: priority,
    );
  }

  // ============================================================
  // READ Operations
  // ============================================================

  /// Get notification by ID
  AppNotification? getNotificationById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  /// Get all notifications
  List<AppNotification> getAllNotifications() {
    try {
      return _box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get all notifications: $e');
    }
  }

  /// Get notifications for a specific user
  List<AppNotification> getNotificationsForUser(String userId) {
    try {
      return _box.values
          .where((n) => n.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get user notifications: $e');
    }
  }

  /// Get unread notifications for a user
  List<AppNotification> getUnreadNotifications(String userId) {
    try {
      return _box.values
          .where((n) => n.userId == userId && !n.isRead)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get unread notifications: $e');
    }
  }

  /// Get read notifications for a user
  List<AppNotification> getReadNotifications(String userId) {
    try {
      return _box.values
          .where((n) => n.userId == userId && n.isRead)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get read notifications: $e');
    }
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(
    String userId,
    NotificationType type,
  ) {
    try {
      return _box.values
          .where((n) => n.userId == userId && n.type == type)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get notifications by type: $e');
    }
  }

  /// Get notifications by priority
  List<AppNotification> getNotificationsByPriority(
    String userId,
    NotificationPriority priority,
  ) {
    try {
      return _box.values
          .where((n) => n.userId == userId && n.priority == priority)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to get notifications by priority: $e');
    }
  }

  /// Get recent notifications (last N notifications)
  List<AppNotification> getRecentNotifications(String userId, {int limit = 10}) {
    try {
      final notifications = getNotificationsForUser(userId);
      return notifications.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get recent notifications: $e');
    }
  }

  // ============================================================
  // UPDATE Operations
  // ============================================================

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      final notification = getNotificationById(id);
      if (notification == null) {
        throw Exception('Notification not found');
      }

      final updated = notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark notification as unread
  Future<void> markAsUnread(String id) async {
    try {
      final notification = getNotificationById(id);
      if (notification == null) {
        throw Exception('Notification not found');
      }

      final updated = notification.copyWith(
        isRead: false,
        readAt: null,
      );

      await _box.put(id, updated);
    } catch (e) {
      throw Exception('Failed to mark notification as unread: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = getUnreadNotifications(userId);
      
      for (final notification in unreadNotifications) {
        await markAsRead(notification.id);
      }
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  // ============================================================
  // DELETE Operations
  // ============================================================

  /// Delete notification by ID
  Future<void> deleteNotification(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final userNotifications = getNotificationsForUser(userId);
      
      for (final notification in userNotifications) {
        await _box.delete(notification.id);
      }
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }

  /// Delete read notifications for a user
  Future<void> deleteReadNotifications(String userId) async {
    try {
      final readNotifications = getReadNotifications(userId);
      
      for (final notification in readNotifications) {
        await _box.delete(notification.id);
      }
    } catch (e) {
      throw Exception('Failed to delete read notifications: $e');
    }
  }

  /// Delete old notifications (older than specified days)
  Future<void> deleteOldNotifications(String userId, {int olderThanDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      final userNotifications = getNotificationsForUser(userId);
      
      final oldNotifications = userNotifications
          .where((n) => n.createdAt.isBefore(cutoffDate))
          .toList();
      
      for (final notification in oldNotifications) {
        await _box.delete(notification.id);
      }
    } catch (e) {
      throw Exception('Failed to delete old notifications: $e');
    }
  }

  /// Clear all notifications (admin only)
  Future<void> clearAllNotifications() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Failed to clear all notifications: $e');
    }
  }

  // ============================================================
  // STATISTICS Operations
  // ============================================================

  /// Get notification statistics for a user
  Map<String, dynamic> getNotificationStatistics(String userId) {
    try {
      final userNotifications = getNotificationsForUser(userId);
      final unreadNotifications = userNotifications.where((n) => !n.isRead).toList();

      return {
        'totalNotifications': userNotifications.length,
        'unreadCount': unreadNotifications.length,
        'readCount': userNotifications.where((n) => n.isRead).length,
        'orderNotifications': userNotifications
            .where((n) => n.type == NotificationType.order)
            .length,
        'transportNotifications': userNotifications
            .where((n) => n.type == NotificationType.transport)
            .length,
        'produceNotifications': userNotifications
            .where((n) => n.type == NotificationType.produce)
            .length,
        'systemNotifications': userNotifications
            .where((n) => n.type == NotificationType.system)
            .length,
        'highPriorityUnread': unreadNotifications
            .where((n) => n.priority == NotificationPriority.high)
            .length,
      };
    } catch (e) {
      throw Exception('Failed to get notification statistics: $e');
    }
  }

  /// Get unread count for a user
  int getUnreadCount(String userId) {
    try {
      return getUnreadNotifications(userId).length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  // ============================================================
  // MOCK DATA GENERATION
  // ============================================================

  /// Initialize mock notification data for testing
  Future<void> _initializeMockData() async {
    final mockNotifications = _generateMockNotifications();
    for (final notification in mockNotifications) {
      await _box.put(notification.id, notification);
    }
  }

  /// Generate 15+ mock notifications
  List<AppNotification> _generateMockNotifications() {
    final now = DateTime.now();

    return [
      // Farmer notifications (farmer_001)
      AppNotification(
        id: _uuid.v4(),
        userId: 'farmer_001',
        title: 'New Order Received',
        message: 'Addis Restaurant Supply ordered 100kg of your White Teff',
        type: NotificationType.order,
        priority: NotificationPriority.high,
        isRead: false,
        actionUrl: '/orders/order_001',
        data: {'orderId': 'order_001'},
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'farmer_001',
        title: 'Transport Matched',
        message: 'Your transport request has been matched with a transporter',
        type: NotificationType.transport,
        priority: NotificationPriority.normal,
        isRead: false,
        actionUrl: '/transport/trip_001',
        data: {'tripId': 'trip_001'},
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'farmer_001',
        title: 'Price Alert',
        message: 'Teff prices increased by 8% in Addis Ababa market',
        type: NotificationType.produce,
        priority: NotificationPriority.normal,
        isRead: true,
        readAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'farmer_001',
        title: 'Payment Received',
        message: 'Payment of 8,500 ETB received for order #ORD-12345',
        type: NotificationType.order,
        priority: NotificationPriority.high,
        isRead: true,
        readAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
      ),

      // Buyer notifications (buyer_001)
      AppNotification(
        id: _uuid.v4(),
        userId: 'buyer_001',
        title: 'Order Confirmed',
        message: 'Your order for 100kg White Teff has been confirmed by the farmer',
        type: NotificationType.order,
        priority: NotificationPriority.high,
        isRead: false,
        actionUrl: '/orders/order_001',
        data: {'orderId': 'order_001'},
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'buyer_001',
        title: 'Delivery in Progress',
        message: 'Your order is now in transit and will arrive in 4 hours',
        type: NotificationType.transport,
        priority: NotificationPriority.normal,
        isRead: false,
        actionUrl: '/orders/order_002',
        data: {'orderId': 'order_002'},
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'buyer_001',
        title: 'New Produce Available',
        message: 'Premium organic avocados now available in Yirgalem',
        type: NotificationType.produce,
        priority: NotificationPriority.low,
        isRead: true,
        readAt: now.subtract(const Duration(hours: 6)),
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'buyer_001',
        title: 'Order Delivered',
        message: 'Your order of 150kg onions has been delivered successfully',
        type: NotificationType.order,
        priority: NotificationPriority.normal,
        isRead: true,
        readAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),

      // Transporter notifications (transporter_001)
      AppNotification(
        id: _uuid.v4(),
        userId: 'transporter_001',
        title: 'New Transport Request',
        message: '800kg of wheat needs transport from Arsi to Addis Ababa',
        type: NotificationType.transport,
        priority: NotificationPriority.high,
        isRead: false,
        actionUrl: '/transport/request_001',
        data: {'requestId': 'request_001'},
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'transporter_001',
        title: 'Trip Accepted',
        message: 'Your bid for trip #T12345 has been accepted',
        type: NotificationType.transport,
        priority: NotificationPriority.high,
        isRead: false,
        actionUrl: '/transport/trip_002',
        data: {'tripId': 'trip_002'},
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'transporter_001',
        title: 'Payment Received',
        message: 'Payment of 5,200 ETB received for trip #T11223',
        type: NotificationType.transport,
        priority: NotificationPriority.normal,
        isRead: true,
        readAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'transporter_001',
        title: 'Rating Received',
        message: 'You received a 5-star rating from Girma Hailu',
        type: NotificationType.transport,
        priority: NotificationPriority.low,
        isRead: true,
        readAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),

      // System notifications (multiple users)
      AppNotification(
        id: _uuid.v4(),
        userId: 'farmer_001',
        title: 'System Maintenance',
        message: 'AgriLink will undergo maintenance on Dec 25 from 2-4 AM',
        type: NotificationType.system,
        priority: NotificationPriority.high,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'buyer_001',
        title: 'New Feature Available',
        message: 'Check out our new real-time transport tracking feature!',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        isRead: true,
        readAt: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5, hours: 1)),
      ),
      AppNotification(
        id: _uuid.v4(),
        userId: 'transporter_001',
        title: 'Profile Update Required',
        message: 'Please update your vehicle documents before Jan 1, 2027',
        type: NotificationType.system,
        priority: NotificationPriority.high,
        isRead: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      // Marketing notifications
      AppNotification(
        id: _uuid.v4(),
        userId: 'buyer_001',
        title: 'Special Offer',
        message: 'Get 10% off your next order of organic produce!',
        type: NotificationType.marketing,
        priority: NotificationPriority.low,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
    ];
  }

  /// Reload mock data (for testing/development)
  Future<void> reloadMockData() async {
    await clearAllNotifications();
    await _initializeMockData();
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}

  // Phase 9: Preferences integration
  dynamic _preferencesProvider;

  /// Set preferences provider for notification filtering
  void setPreferencesProvider(dynamic provider) {
    _preferencesProvider = provider;
  }

  /// Check if notification should be shown based on preferences
  bool _shouldShowNotification(AppNotification notification) {
    if (_preferencesProvider == null) return true;

    // Always show critical notifications regardless of preferences
    if (notification.priority == NotificationPriority.high) {
      return true;
    }

    // Check notification type preferences
    try {
      switch (notification.type) {
        case NotificationType.order:
          return _preferencesProvider.orderUpdates ?? true;
        case NotificationType.transport:
          return _preferencesProvider.orderUpdates ?? true;
        case NotificationType.produce:
          return _preferencesProvider.priceAlerts ?? true;
        case NotificationType.marketing:
          return _preferencesProvider.marketUpdates ?? true;
        case NotificationType.system:
          return _preferencesProvider.systemNotifications ?? true;
        default:
          return true;
      }
    } catch (e) {
      // If any error, default to showing notification
      return true;
    }
  }
