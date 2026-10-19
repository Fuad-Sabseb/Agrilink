import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// NotificationProvider - State management for notifications
/// 
/// Provides reactive access to NotificationService with:
/// - Loading states
/// - Error handling
/// - Automatic UI updates via ChangeNotifier
/// - Real-time notification streams
/// - Unread count tracking
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  List<AppNotification> _filteredNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<AppNotification>? _notificationSubscription;

  // Getters
  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get filteredNotifications => _filteredNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _filteredNotifications.isEmpty && !_isLoading;
  bool get hasUnread => _unreadCount > 0;

  /// Initialize provider and load data
  Future<void> initialize({String? userId}) async {
    await _setLoading(true);
    try {
      await _notificationService.initialize();
      
      // Subscribe to notification stream
      _notificationSubscription = _notificationService.notificationStream.listen(
        (notification) {
          // Add new notification to list
          _notifications.insert(0, notification);
          _filteredNotifications.insert(0, notification);
          _updateUnreadCount();
          notifyListeners();
        },
      );

      if (userId != null) {
        await loadNotificationsForUser(userId);
      }
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Load notifications for a specific user
  Future<void> loadNotificationsForUser(String userId) async {
    await _setLoading(true);
    try {
      _notifications = _notificationService.getNotificationsForUser(userId);
      _filteredNotifications = _notifications;
      _updateUnreadCount();
      _clearError();
    } catch (e) {
      _setError('Failed to load notifications: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Load unread notifications
  Future<void> loadUnreadNotifications(String userId) async {
    await _setLoading(true);
    try {
      _notifications = _notificationService.getUnreadNotifications(userId);
      _filteredNotifications = _notifications;
      _updateUnreadCount();
      _clearError();
    } catch (e) {
      _setError('Failed to load unread notifications: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Load recent notifications
  Future<void> loadRecentNotifications(String userId, {int limit = 10}) async {
    await _setLoading(true);
    try {
      _notifications = _notificationService.getRecentNotifications(userId, limit: limit);
      _filteredNotifications = _notifications;
      _updateUnreadCount();
      _clearError();
    } catch (e) {
      _setError('Failed to load recent notifications: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Send order notification
  Future<bool> sendOrderNotification({
    required String userId,
    required String orderId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      await _notificationService.sendOrderNotification(
        userId: userId,
        orderId: orderId,
        title: title,
        message: message,
        priority: priority,
      );
      // No need to reload - stream will update
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to send order notification: $e');
      return false;
    }
  }

  /// Send transport notification
  Future<bool> sendTransportNotification({
    required String userId,
    required String tripId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      await _notificationService.sendTransportNotification(
        userId: userId,
        tripId: tripId,
        title: title,
        message: message,
        priority: priority,
      );
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to send transport notification: $e');
      return false;
    }
  }

  /// Send produce notification
  Future<bool> sendProduceNotification({
    required String userId,
    required String produceId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    try {
      await _notificationService.sendProduceNotification(
        userId: userId,
        produceId: produceId,
        title: title,
        message: message,
        priority: priority,
      );
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to send produce notification: $e');
      return false;
    }
  }

  /// Send system notification
  Future<bool> sendSystemNotification({
    required String userId,
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.high,
  }) async {
    try {
      await _notificationService.sendSystemNotification(
        userId: userId,
        title: title,
        message: message,
        priority: priority,
      );
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to send system notification: $e');
      return false;
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = notification.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        
        final filteredIndex = _filteredNotifications.indexWhere((n) => n.id == notificationId);
        if (filteredIndex != -1) {
          _filteredNotifications[filteredIndex] = _notifications[index];
        }
      }
      
      _updateUnreadCount();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to mark notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);
      
      // Update local lists
      _notifications = _notifications.map((n) {
        if (n.userId == userId && !n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
      
      _filteredNotifications = _filteredNotifications.map((n) {
        if (n.userId == userId && !n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
      
      _updateUnreadCount();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to mark all as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      _notifications.removeWhere((n) => n.id == notificationId);
      _filteredNotifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete notification: $e');
      return false;
    }
  }

  /// Delete all notifications for user
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      await _notificationService.deleteAllNotifications(userId);
      
      _notifications.removeWhere((n) => n.userId == userId);
      _filteredNotifications.removeWhere((n) => n.userId == userId);
      _updateUnreadCount();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete all notifications: $e');
      return false;
    }
  }

  /// Delete read notifications
  Future<bool> deleteReadNotifications(String userId) async {
    try {
      await _notificationService.deleteReadNotifications(userId);
      
      _notifications.removeWhere((n) => n.userId == userId && n.isRead);
      _filteredNotifications.removeWhere((n) => n.userId == userId && n.isRead);
      _updateUnreadCount();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete read notifications: $e');
      return false;
    }
  }

  /// Delete old notifications (older than specified days)
  Future<bool> deleteOldNotifications(String userId, {int olderThanDays = 30}) async {
    try {
      await _notificationService.deleteOldNotifications(userId, olderThanDays: olderThanDays);
      
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      _notifications.removeWhere((n) => n.userId == userId && n.createdAt.isBefore(cutoffDate));
      _filteredNotifications.removeWhere((n) => n.userId == userId && n.createdAt.isBefore(cutoffDate));
      _updateUnreadCount();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete old notifications: $e');
      return false;
    }
  }

  /// Filter notifications by type
  void filterByType(NotificationType type) {
    _filteredNotifications = _notifications
        .where((n) => n.type == type)
        .toList();
    notifyListeners();
  }

  /// Filter notifications by priority
  void filterByPriority(NotificationPriority priority) {
    _filteredNotifications = _notifications
        .where((n) => n.priority == priority)
        .toList();
    notifyListeners();
  }

  /// Filter notifications by read status
  void filterByReadStatus(bool isRead) {
    _filteredNotifications = _notifications
        .where((n) => n.isRead == isRead)
        .toList();
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _filteredNotifications = _notifications;
    notifyListeners();
  }

  /// Get notification statistics
  Map<String, dynamic> getStatistics(String userId) {
    return _notificationService.getNotificationStatistics(userId);
  }

  /// Get notification by ID
  AppNotification? getNotificationById(String notificationId) {
    return _notificationService.getNotificationById(notificationId);
  }

  // Private helpers
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> _setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Reload mock data (for testing)
  Future<void> reloadMockData() async {
    await _setLoading(true);
    try {
      await _notificationService.reloadMockData();
      await loadNotificationsForUser('farmer_001'); // Default test user
    } finally {
      await _setLoading(false);
    }
  }
  /// Load notifications for a specific user
  Future<void> loadUserNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = _notificationService.getNotificationsForUser(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
