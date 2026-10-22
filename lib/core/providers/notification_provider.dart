import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_record.dart';
import '../services/notification_service.dart';

/// Phase 3 NotificationProvider - Simplified for Phase 3 implementation
/// 
/// Provides reactive access to NotificationService with:
/// - Notification history
/// - Unread count tracking
/// - Mark as read functionality
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationRecord> _notifications = [];
  int _unreadCount = 0;
  bool _isInitialized = false;
  StreamSubscription<NotificationRecord>? _notificationSubscription;
  StreamSubscription<int>? _badgeCountSubscription;

  // Getters
  List<NotificationRecord> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;
  bool get isLoading => !_isInitialized;

  /// Initialize provider and load notification history
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      
      _notificationSubscription = _notificationService.notificationStream.listen((notification) {
        _notifications.insert(0, notification);
        if (!notification.read) {
          _unreadCount++;
        }
        notifyListeners();
      });
      
      _badgeCountSubscription = _notificationService.badgeCountStream.listen((count) {
        _unreadCount = count;
        notifyListeners();
      });
      
      await _loadNotificationHistory();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('[NotificationProvider] Initialization error: $e');
    }
  }

  /// Load notification history from service
  Future<void> _loadNotificationHistory() async {
    try {
      _notifications = await _notificationService.getNotificationHistory();
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('[NotificationProvider] Error loading history: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].read) {
        _notifications[index] = _notifications[index].copyWith(read: true);
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        notifyListeners();
      }
    } catch (e) {
      print('[NotificationProvider] Error marking as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('[NotificationProvider] Error marking all as read: $e');
    }
  }

  /// Handle notification tap - delegate to service
  Future<bool> handleNotificationTap(String notificationId) async {
    try {
      final result = await _notificationService.handleNotificationTap(notificationId);
      await _loadNotificationHistory(); // Reload to update read status
      return result;
    } catch (e) {
      print('[NotificationProvider] Error handling notification tap: $e');
      return false;
    }
  }

  // Legacy compatibility methods
  Future<void> loadUserNotifications() async {
    await _loadNotificationHistory();
  }
  
  Future<void> deleteNotification(String notificationId) async {
    await markAsRead(notificationId);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _badgeCountSubscription?.cancel();
    super.dispose();
  }
}
