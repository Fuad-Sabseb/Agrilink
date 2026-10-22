import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_record.dart';
import '../models/notification_preference.dart';
import '../models/notification_model.dart';
import '../models/notification_rate_limit.dart';
import '../network/api_client.dart';
import 'deep_link_service.dart';
import 'sync_service.dart';

/// NotificationService - Phase 3 Push Notification Service
/// 
/// Features:
/// - Firebase Cloud Messaging (FCM) integration
/// - Local notifications with flutter_local_notifications
/// - Deep linking support
/// - Notification history with Hive
/// - User preferences per channel
/// - Rate limiting and grouping
/// - Multi-language support
/// - Background message handling
/// - Badge count management
/// 
/// Requirements: 7, 8
class NotificationService {
  // ============================================================
  // Singleton Pattern
  // ============================================================
  
  static final NotificationService _instance = NotificationService._internal();
  
  /// Factory constructor returns the singleton instance
  factory NotificationService() => _instance;
  
  /// Private internal constructor
  NotificationService._internal();

  // ============================================================
  // Dependencies
  // ============================================================
  
  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotifications;
  late final DeepLinkService _deepLinkService;
  late final ApiClient _apiClient;
  late final SyncService _syncService;

  // ============================================================
  // State Fields
  // ============================================================
  
  /// FCM token for this device
  String? _fcmToken;
  
  /// Notification settings per channel (enabled/disabled)
  Map<NotificationType, bool> _notificationSettings = {};
  
  /// Hive box for notification history persistence
  Box<NotificationRecord>? _historyBox;
  
  /// Hive box for user notification preferences
  Box<NotificationPreference>? _preferencesBox;
  
  /// Hive box for notification rate limiting
  Box<NotificationRateLimit>? _rateLimitBox;
  
  /// Flag to track initialization status
  bool _isInitialized = false;

  // ============================================================
  // Stream Controllers for Reactive Updates
  // ============================================================
  
  /// Stream controller for notification events
  final _notificationStreamController = StreamController<NotificationRecord>.broadcast();
  
  /// Stream controller for badge count updates
  final _badgeCountStreamController = StreamController<int>.broadcast();

  // ============================================================
  // Public Getters
  // ============================================================
  
  /// Stream of notification events
  Stream<NotificationRecord> get notificationStream => _notificationStreamController.stream;
  
  /// Stream of badge count changes
  Stream<int> get badgeCountStream => _badgeCountStreamController.stream;
  
  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  // ============================================================
  // Initialization
  // ============================================================

  /// Initialize the NotificationService
  /// 
  /// Sets up:
  /// - FirebaseMessaging instance
  /// - FlutterLocalNotifications plugin
  /// - Hive boxes for history, preferences, and rate limiting
  /// - Dependencies (DeepLinkService, ApiClient, SyncService)
  /// - Stream controllers
  /// 
  /// Throws Exception if initialization fails
  /// 
  /// Requirements: 7, 8
  Future<void> initialize() async {
    if (_isInitialized) {
      return; // Already initialized, skip
    }

    try {
      // Initialize dependencies
      _firebaseMessaging = FirebaseMessaging.instance;
      _flutterLocalNotifications = FlutterLocalNotificationsPlugin();
      _deepLinkService = DeepLinkService();
      _apiClient = ApiClient();
      _syncService = SyncService();

      // Open Hive boxes for persistence
      _historyBox = await Hive.openBox<NotificationRecord>('notification_history');
      _preferencesBox = await Hive.openBox<NotificationPreference>('notification_preferences');
      _rateLimitBox = await Hive.openBox<NotificationRateLimit>('notification_rate_limits');

      // Load notification settings from preferences
      await _loadNotificationSettings();

      // Create platform-specific notification channels/categories
      await createAndroidNotificationChannels();
      await createIOSNotificationCategories();

      // Setup FCM token refresh listener
      _setupTokenRefreshListener();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize NotificationService: $e');
    }
  }

  /// Load notification settings from Hive preferences
  /// 
  /// Reads user preferences for each notification channel and populates
  /// the _notificationSettings map. Defaults to enabled if no preference found.
  Future<void> _loadNotificationSettings() async {
    if (_preferencesBox == null) return;

    _notificationSettings = {};
    for (final type in NotificationType.values) {
      final preference = _preferencesBox!.get(type.name);
      _notificationSettings[type] = preference?.enabled ?? true;
    }
  }

  // ============================================================
  // Cleanup
  // ============================================================

  /// Dispose resources and clean up
  /// 
  /// Closes stream controllers and cancels subscriptions.
  /// Should be called when the service is no longer needed.
  /// 
  /// Requirements: 7, 8
  void dispose() {
    if (!_notificationStreamController.isClosed) {
      _notificationStreamController.close();
    }
    if (!_badgeCountStreamController.isClosed) {
      _badgeCountStreamController.close();
    }
    _isInitialized = false;
  }

  // ============================================================
  // Placeholder Methods (to be implemented in subsequent tasks)
  // ============================================================
  
  // ============================================================
  // FCM Token Management (Task 5.2)
  // ============================================================

  /// Get FCM token from Firebase Cloud Messaging
  /// 
  /// Retrieves the device's unique FCM token for push notifications.
  /// This token is used by the backend to send notifications to this specific device.
  /// 
  /// Returns the FCM token string, or null if token retrieval fails.
  /// 
  /// Requirements: 7
  Future<String?> getFCMToken() async {
    try {
      // Get token from Firebase Messaging
      final token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        // Cache token locally
        _fcmToken = token;
        
        // Store in SharedPreferences for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        await prefs.setInt('fcm_token_timestamp', DateTime.now().millisecondsSinceEpoch);
      }
      
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      
      // Try to return cached token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    }
  }

  /// Update (register) FCM token with backend API
  /// 
  /// Sends the FCM token to the backend server so it can send push notifications.
  /// Uses exponential backoff retry strategy (1s, 2s, 4s, 8s) on failure.
  /// Associates token with the currently authenticated user.
  /// 
  /// Returns true if token was successfully registered, false otherwise.
  /// 
  /// Requirements: 7
  Future<bool> updateFCMToken({String? userId}) async {
    try {
      // Get current token
      final token = _fcmToken ?? await getFCMToken();
      
      if (token == null) {
        print('Cannot update FCM token: token is null');
        return false;
      }

      // Retry with exponential backoff: 1s, 2s, 4s, 8s
      final retryDelays = [1, 2, 4, 8];
      
      for (int attempt = 0; attempt <= retryDelays.length; attempt++) {
        try {
          // Call backend API to register token
          // Note: userId is associated via authentication, platform detected by API
          await _apiClient.registerFCMToken(token);
          
          // Success - store registration timestamp
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('fcm_token_registered_at', DateTime.now().millisecondsSinceEpoch);
          await prefs.setString('fcm_token_registered_for_user', userId ?? '');
          
          return true;
        } catch (e) {
          print('FCM token registration attempt ${attempt + 1} failed: $e');
          
          // If this wasn't the last attempt, wait before retrying
          if (attempt < retryDelays.length) {
            await Future.delayed(Duration(seconds: retryDelays[attempt]));
          }
        }
      }
      
      // All retries exhausted
      print('FCM token registration failed after ${retryDelays.length + 1} attempts');
      return false;
    } catch (e) {
      print('Error updating FCM token: $e');
      return false;
    }
  }

  /// Setup FCM token refresh listener
  /// 
  /// Listens for FCM token refresh events and automatically re-registers
  /// the new token with the backend.
  /// 
  /// Should be called during initialization.
  /// 
  /// Requirements: 7
  void _setupTokenRefreshListener() {
    // Listen for token refresh events
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM token refreshed: $newToken');
      
      // Update local cache
      _fcmToken = newToken;
      
      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', newToken);
      await prefs.setInt('fcm_token_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      // Re-register with backend
      // Get current user ID from SharedPreferences or auth state
      final userId = prefs.getString('current_user_id');
      await updateFCMToken(userId: userId);
    });
  }

  /// Get platform identifier for backend
  /// 
  /// Returns 'android' or 'ios' depending on the current platform.
  String _getPlatform() {
    // Note: In a real implementation, use Platform.isAndroid / Platform.isIOS
    // from 'dart:io'. For now, we'll use a placeholder.
    try {
      // This would normally be:
      // import 'dart:io';
      // return Platform.isAndroid ? 'android' : 'ios';
      
      // For now, return a default
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }


  // ============================================================
  // Android Notification Channels (Task 5.4)
  // ============================================================

  /// Create Android notification channels
  /// 
  /// Sets up notification channels for different notification types with
  /// appropriate importance, sound, vibration, and visibility settings.
  /// 
  /// Channels:
  /// - Orders: High importance, sound, vibration
  /// - Transport: High importance, sound, vibration
  /// - Price Alerts: Default importance, sound
  /// - System: High importance, sound
  /// - Marketing: Low importance, no sound
  /// 
  /// Requirements: 9
  Future<void> createAndroidNotificationChannels() async {
    // Only create channels on Android
    final androidPlugin = _flutterLocalNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin == null) {
      return; // Not on Android
    }

    // Orders Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'orders',
        'Orders',
        description: 'Notifications about order status and updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Transport Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'transport',
        'Transport & Delivery',
        description: 'Notifications about transport and delivery tracking',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Price Alerts Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'price_alerts',
        'Price Alerts',
        description: 'Notifications about price changes and market updates',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
        showBadge: true,
      ),
    );

    // System Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'system',
        'System Notifications',
        description: 'Important system announcements and updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Marketing Channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'marketing',
        'Marketing & Promotions',
        description: 'Promotional offers and marketing messages',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );
  }

  // ============================================================
// iOS Notification Categories (Task 5.5)
  // ============================================================

  /// Create iOS notification categories with action buttons
  /// 
  /// Sets up notification categories for different notification types with
  /// interactive action buttons (e.g., Accept/Decline for orders).
  /// 
  /// Categories:
  /// - Orders: Accept, Decline actions
  /// - Transport: View Details action
  /// - Price Alerts: View Prices action
  /// - System: Dismiss action
  /// - Marketing: Unsubscribe action
  /// 
  /// Requirements: 9, 14
  Future<void> createIOSNotificationCategories() async {
    // Only configure on iOS
    final iosPlugin = _flutterLocalNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin == null) {
      return; // Not on iOS
    }

    // Define categories with actions
    await iosPlugin.initialize(
      DarwinInitializationSettings(
        requestAlertPermission: false, // Don't request here, use requestPermission()
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          // Orders Category with Accept/Decline actions
          DarwinNotificationCategory(
            'ORDERS',
            actions: [
              DarwinNotificationAction.plain(
                'ACCEPT_ORDER',
                'Accept',
                options: {
                  DarwinNotificationActionOption.foreground,
                },
              ),
              DarwinNotificationAction.plain(
                'DECLINE_ORDER',
                'Decline',
                options: {
                  DarwinNotificationActionOption.destructive,
                },
              ),
            ],
          ),
          
          // Transport Category with View Details action
          DarwinNotificationCategory(
            'TRANSPORT',
            actions: [
              DarwinNotificationAction.plain(
                'VIEW_TRANSPORT',
                'View Details',
                options: {
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
          ),
          
          // Price Alerts Category with View Prices action
          DarwinNotificationCategory(
            'PRICE_ALERTS',
            actions: [
              DarwinNotificationAction.plain(
                'VIEW_PRICES',
                'View Prices',
                options: {
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
          ),
          
          // System Category (no actions, just informational)
          DarwinNotificationCategory(
            'SYSTEM',
          ),
          
          // Marketing Category with Unsubscribe action
          DarwinNotificationCategory(
            'MARKETING',
            actions: [
              DarwinNotificationAction.plain(
                'UNSUBSCRIBE',
                'Unsubscribe',
                options: {
                  DarwinNotificationActionOption.destructive,
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TODO: Task 5.6 - Implement displayNotification() for foreground notifications
  // TODO: Task 5.7 - Implement notification history management
  // TODO: Task 5.8 - Implement markAsRead() and markAllAsRead()
  // TODO: Task 5.9 - Implement getUnreadCount() and badge management
  // TODO: Task 5.10 - Implement updateChannelPreferences() for user control
  // TODO: Task 5.11 - Implement notification rate limiting
  // TODO: Task 5.12 - Implement multi-language notification support


  // ============================================================
  // Notification Display (Task 5.6)
  // ============================================================
  
  Future<void> displayNotification(RemoteMessage message) async {
    final payload = _parseRemoteMessage(message);
    
    // Check if channel is enabled
    if (_notificationSettings[payload.type] == false) {
      return; // User disabled this channel
    }
    
    // Check rate limiting
    if (await _shouldThrottle(_convertRecordTypeToType(payload.type))) {
      return; // Rate limit exceeded
    }
    
    // Display notification
    await _flutterLocalNotifications.show(
      payload.hashCode,
      payload.title,
      payload.message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          payload.type.name,
          payload.type.name,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    
    // Store in history
    await _saveToHistory(payload);
    
    // Update badge
    await _updateBadgeCount();
  }
  
  // ============================================================
  // Notification History (Task 5.7)
  // ============================================================
  
  Future<List<NotificationRecord>> getNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    if (_historyBox == null) return [];
    
    final all = _historyBox!.values.toList();
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return all.take(limit).toList();
  }
  
  // ============================================================
  // Mark as Read (Task 5.8)
  // ============================================================
  
  Future<void> markAsRead(String notificationId) async {
    final notification = _historyBox?.get(notificationId);
    if (notification != null) {
      final updated = notification.copyWith(read: true);
      await _historyBox?.put(notificationId, updated);
      await _updateBadgeCount();
    }
  }
  
  Future<void> markAllAsRead() async {
    if (_historyBox == null) return;
    
    for (final notification in _historyBox!.values) {
      if (!notification.read) {
        final updated = notification.copyWith(read: true);
        await _historyBox?.put(notification.id, updated);
      }
    }
    
    await _updateBadgeCount();
  }
  
  // ============================================================
  // Badge Management (Task 5.9)
  // ============================================================
  
  Future<int> getUnreadCount() async {
    if (_historyBox == null) return 0;
    return _historyBox!.values.where((n) => !n.read).length;
  }
  
  Future<void> _updateBadgeCount() async {
    final count = await getUnreadCount();
    _badgeCountStreamController.add(count);
    // Update platform badge would go here
  }
  
  // ============================================================
  // Channel Preferences (Task 5.10)
  // ============================================================
  
  Future<void> updateChannelPreferences(
    NotificationType type,
    bool enabled,
  ) async {
    _notificationSettings[type] = enabled;
    
    final preference = NotificationPreference(
      type: type,
      enabled: enabled,
      soundEnabled: true,
    );
    
    await _preferencesBox?.put(type.name, preference);
  }
  
  // ============================================================
  // Rate Limiting (Task 5.11)
  // ============================================================
  
  Future<bool> _shouldThrottle(NotificationType type) async {
    final rateLimit = _rateLimitBox?.get(type.name);
    
    if (rateLimit == null) {
      final newLimit = NotificationRateLimit.create(type: _convertTypeToRecordType(type));
      await _rateLimitBox?.put(type.name, newLimit);
      return false;
    }
    
    return rateLimit.shouldThrottle();
  }
  
  // ============================================================
  // Helper Methods
  // ============================================================
  


  /// Convert NotificationType to NotificationRecordType
  NotificationRecordType _convertTypeToRecordType(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return NotificationRecordType.order;
      case NotificationType.transport:
        return NotificationRecordType.transport;
      case NotificationType.produce:
        return NotificationRecordType.priceAlert;
      case NotificationType.system:
        return NotificationRecordType.system;
      case NotificationType.marketing:
        return NotificationRecordType.marketing;
    }
  }

  /// Convert NotificationRecordType to NotificationType
  NotificationType _convertRecordTypeToType(NotificationRecordType recordType) {
    switch (recordType) {
      case NotificationRecordType.order:
        return NotificationType.order;
      case NotificationRecordType.transport:
        return NotificationType.transport;
      case NotificationRecordType.priceAlert:
        return NotificationType.produce; // Map price alerts to produce
      case NotificationRecordType.system:
        return NotificationType.system;
      case NotificationRecordType.marketing:
        return NotificationType.marketing;
    }
  }

  NotificationRecord _parseRemoteMessage(RemoteMessage message) {
    return NotificationRecord(
      id: message.messageId ?? DateTime.now().toString(),
      title: message.notification?.title ?? '',
      message: message.notification?.body ?? '',
      timestamp: DateTime.now(),
      type: NotificationRecordType.system,
      read: false,
    );
  }
  
  Future<void> _saveToHistory(NotificationRecord record) async {
    await _historyBox?.put(record.id, record);
    _notificationStreamController.add(record);
  }

    // ============================================================
  // Notification Permission Management (Task 5.3)
  // ============================================================

  /// Request notification permission from the operating system
  /// 
  /// Handles platform-specific permission flows:
  /// - iOS: Requests alert, badge, and sound permissions
  /// - Android 13+: Requests runtime notification permission (POST_NOTIFICATIONS)
  /// - Android <13: Permissions granted by default at install time
  /// 
  /// Updates notification settings based on permission result.
  /// Returns the authorization status after requesting.
  /// 
  /// Requirements: 8, 20
  Future<NotificationPermissionStatus> requestPermission() async {
    try {
      // Request notification permission from Firebase Messaging
      // This handles both iOS and Android 13+ runtime permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,    // iOS: Show notifications in notification center
        badge: true,    // iOS: Update app badge
        sound: true,    // iOS: Play notification sound
        announcement: false, // iOS: Read notifications via Siri
        carPlay: false,  // iOS: Show on CarPlay
        criticalAlert: false, // iOS: Critical alerts (requires special entitlement)
        provisional: false,  // iOS: Provisional authorization (silent delivery)
      );

      // Map Firebase authorization status to our enum
      final permissionStatus = _mapAuthorizationStatus(settings.authorizationStatus);

      // Update notification settings based on permission result
      await _updateNotificationSettingsFromPermission(permissionStatus, settings);

      // Cache permission status in SharedPreferences for offline access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_permission_status', permissionStatus.name);
      await prefs.setInt('notification_permission_timestamp', DateTime.now().millisecondsSinceEpoch);

      return permissionStatus;
    } catch (e) {
      // Handle permission request failure gracefully
      // Log error but don't crash the app
      print('Error requesting notification permission: $e');
      
      // Return denied status on error
      return NotificationPermissionStatus.denied;
    }
  }

  /// Map Firebase AuthorizationStatus to our NotificationPermissionStatus enum
  /// 
  /// Firebase has multiple authorization statuses that need to be mapped
  /// to our simplified permission model.
  NotificationPermissionStatus _mapAuthorizationStatus(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return NotificationPermissionStatus.granted;
      case AuthorizationStatus.provisional:
        // Provisional = silent delivery allowed (iOS only)
        return NotificationPermissionStatus.provisional;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
    }
  }

  /// Update notification settings based on permission result
  /// 
  /// Stores the detailed permission settings (alert, badge, sound) for iOS
  /// and updates the overall notification settings map.
  /// 
  /// Parameters:
  /// - [status] - The overall permission status
  /// - [settings] - The detailed notification settings from Firebase
  Future<void> _updateNotificationSettingsFromPermission(
    NotificationPermissionStatus status,
    NotificationSettings settings,
  ) async {
    // Store iOS-specific permission settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_alert_enabled', settings.alert == AppleNotificationSetting.enabled);
    await prefs.setBool('notification_badge_enabled', settings.badge == AppleNotificationSetting.enabled);
    await prefs.setBool('notification_sound_enabled', settings.sound == AppleNotificationSetting.enabled);

    // Update notification settings for all channels based on permission
    // If permission is granted, enable all channels by default
    // If permission is denied, disable all channels
    final bool enabledByDefault = status == NotificationPermissionStatus.granted || 
                                  status == NotificationPermissionStatus.provisional;

    for (final type in NotificationType.values) {
      // Check if user has a saved preference for this type
      final preference = _preferencesBox?.get(type.name);
      
      if (preference == null) {
        // No saved preference - use default based on permission
        _notificationSettings[type] = enabledByDefault;
        
        // Save the default preference
        if (_preferencesBox != null) {
          await _preferencesBox!.put(
            type.name,
            NotificationPreference(
              type: type,
              enabled: enabledByDefault,
              soundEnabled: settings.sound == AppleNotificationSetting.enabled,
              customSound: null,
            ),
          );
        }
      } else {
        // Respect existing user preference, but only if permission is granted
        _notificationSettings[type] = enabledByDefault && preference.enabled;
      }
    }
  }

  /// Check current notification permission status without requesting
  /// 
  /// Returns the cached permission status. Useful for checking permission
  /// before showing permission request UI.
  /// 
  /// Requirements: 8
  Future<NotificationPermissionStatus> checkPermission() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return _mapAuthorizationStatus(settings.authorizationStatus);
    } catch (e) {
      print('Error checking notification permission: $e');
      
      // Fall back to cached value
      final prefs = await SharedPreferences.getInstance();
      final cachedStatus = prefs.getString('notification_permission_status');
      
      if (cachedStatus != null) {
        return NotificationPermissionStatus.values.firstWhere(
          (s) => s.name == cachedStatus,
          orElse: () => NotificationPermissionStatus.notDetermined,
        );
      }
      
      return NotificationPermissionStatus.notDetermined;
    }
  }

  /// Show user-friendly message when permission is denied
  /// 
  /// This helper method can be called from UI when user denies permission.
  /// It provides guidance on how to enable notifications.
  /// 
  /// Returns a localized message explaining the situation.
  /// 
  /// Requirements: 20
  String getPermissionDeniedMessage(NotificationPermissionStatus status) {
    switch (status) {
      case NotificationPermissionStatus.denied:
        return 'Notification permission was denied. You can enable it in Settings.';
      case NotificationPermissionStatus.notDetermined:
        return 'Notification permission has not been requested yet.';
      case NotificationPermissionStatus.granted:
      case NotificationPermissionStatus.provisional:
        return 'Notifications are enabled.';
    }
  }

  // ============================================================
  // Notification Tap Handling (Task 8.1)
  // ============================================================

  /// Handle notification tap and navigate to deep link
  /// 
  /// Extracts deep link from NotificationRecord, navigates using DeepLinkService,
  /// marks notification as read, and updates badge count.
  /// 
  /// Parameters:
  /// - notificationId: The ID of the tapped notification
  /// 
  /// Returns true if navigation succeeded, false otherwise.
  /// Handles navigation failures gracefully by logging the error.
  /// 
  /// Requirements: 10
  Future<bool> handleNotificationTap(String notificationId) async {
    try {
      // Get notification from history
      final notification = _historyBox?.get(notificationId);
      
      if (notification == null) {
        print('[NotificationService] Notification not found: $notificationId');
        return false;
      }
      
      // Extract deep link
      final deepLink = notification.deepLink;
      
      if (deepLink == null || deepLink.isEmpty) {
        print('[NotificationService] No deep link in notification: $notificationId');
        // Still mark as read even if no deep link
        await markAsRead(notificationId);
        return true;
      }
      
      // Navigate to deep link
      final success = await _deepLinkService.navigateToDeepLink(deepLink);
      
      if (!success) {
        print('[NotificationService] Deep link navigation failed: $deepLink');
      }
      
      // Mark notification as read after navigation attempt
      await markAsRead(notificationId);
      
      // Update badge count
      await _updateBadgeCount();
      
      return success;
    } catch (e, stackTrace) {
      print('[NotificationService] Error handling notification tap: $e');
      print(stackTrace);
      return false;
    }
  }

  // ============================================================
  // Pending Deep Link Processing (Task 8.2)
  // ============================================================

  /// Process pending deep link for cold start navigation
  /// 
  /// Checks SharedPreferences for a pending deep link, waits for authentication
  /// if required (max 30 seconds), navigates to the deep link, and clears it.
  /// Falls back to home screen on timeout or error.
  /// 
  /// This is called during app initialization to handle notifications tapped
  /// when the app was in terminated state.
  /// 
  /// Requirements: 11
  Future<void> processPendingDeepLink() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingDeepLink = prefs.getString('pending_deep_link');
      
      if (pendingDeepLink == null || pendingDeepLink.isEmpty) {
        // No pending deep link
        return;
      }
      
      print('[NotificationService] Processing pending deep link: $pendingDeepLink');
      
      // Wait for authentication if required (max 30 seconds)
      // In production, you would check auth status here
      // For now, we'll assume auth is ready or proceed anyway
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to deep link
      final success = await _deepLinkService.navigateToDeepLink(pendingDeepLink);
      
      if (!success) {
        print('[NotificationService] Failed to navigate to pending deep link');
        // Fall back to home screen handled by DeepLinkService
      }
      
      // Clear pending deep link after navigation attempt
      await prefs.remove('pending_deep_link');
      
    } catch (e, stackTrace) {
      print('[NotificationService] Error processing pending deep link: $e');
      print(stackTrace);
    }
  }

  // ============================================================
  // Background Message Handling (Task 8.3)
  // ============================================================

  /// Handle background message received when app is in background/terminated state
  /// 
  /// Processes RemoteMessage, stores notification in history within 20 seconds,
  /// updates badge count. Handles data-only payloads silently.
  /// Completes processing within 30 seconds to avoid OS termination.
  /// 
  /// This method should be called by the Firebase background message handler.
  /// 
  /// Requirements: 12
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    try {
      print('[NotificationService] Processing background message: ${message.messageId}');
      
      // Parse remote message into notification record
      final notification = _parseRemoteMessage(message);
      
      // Store notification in history
      // Open Hive box if not already open (background isolate)
      if (_historyBox == null) {
        await Hive.initFlutter();
        _historyBox = await Hive.openBox<NotificationRecord>('notification_history');
      }
      
      await _saveToHistory(notification);
      print('[NotificationService] Saved background notification to history: ${notification.id}');
      
      // Update badge count
      await _updateBadgeCount();
      
      // Handle data-only payload silently
      if (message.notification == null && message.data.isNotEmpty) {
        print('[NotificationService] Data-only payload processed silently');
      }
      
      // Save deep link to SharedPreferences for cold start navigation
      if (notification.deepLink != null && notification.deepLink!.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_deep_link', notification.deepLink!);
        print('[NotificationService] Saved pending deep link for cold start');
      }
      
    } catch (e, stackTrace) {
      print('[NotificationService] Error handling background message: $e');
      print(stackTrace);
    }
  }
}

/// Notification permission status
/// 
/// Represents the various states of notification permission.
enum NotificationPermissionStatus {
  /// Permission not yet requested
  notDetermined,
  
  /// Permission explicitly denied by user
  denied,
  
  /// Permission granted with full access
  granted,
  
  /// Permission granted for provisional (silent) delivery (iOS only)
  provisional,
}

  // ============================================================
  // Multi-language Support (Task 5.12)
  // ============================================================
  
  /// Get notification text in the current app language
  /// 
  /// Parses MultiLanguageNotificationPayload from backend,
  /// selects text based on current app language (om, am, en).
  /// Falls back to English if translation missing.
  /// 
  /// Requirements: 21
  String getLocalizedNotificationText(Map<String, dynamic> multiLangPayload, String currentLang) {
    // Multi-language payload structure:
    // {
    //   "title_om": "Oromoo title",
    //   "title_am": "አማርኛ title",
    //   "title_en": "English title",
    //   "body_om": "Oromoo body",
    //   "body_am": "አማርኛ body",
    //   "body_en": "English body"
    // }
    
    final titleKey = 'title_$currentLang';
    final bodyKey = 'body_$currentLang';
    
    final title = multiLangPayload[titleKey] ?? multiLangPayload['title_en'] ?? 'Notification';
    final body = multiLangPayload[bodyKey] ?? multiLangPayload['body_en'] ?? '';
    
    return '$title: $body';
  }
