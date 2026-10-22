import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/notification_record.dart';
import '../../core/utils/notification_error_handler.dart';

/// Notification Test Screen - Demo UI for testing notifications
/// 
/// Features:
/// - Notification history list
/// - Unread count badge
/// - Mark as read functionality
/// - Test notification sender
/// - Error handling with localized messages
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _currentLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
          ),
          _buildUnreadBadge(),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (!notificationProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildLanguageIndicator(),
              _buildActionButtons(notificationProvider),
              Expanded(
                child: _buildNotificationList(notificationProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendTestNotification,
        icon: const Icon(Icons.send),
        label: const Text('Send Test'),
      ),
    );
  }

  Widget _buildLanguageIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue[50],
      child: Row(
        children: [
          const Icon(Icons.language, color: Colors.blue),
          const SizedBox(width: 8),
          Text('Language: $_currentLanguage'),
        ],
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final count = provider.unreadCount;
        if (count == 0) return const SizedBox();
        
        return Stack(
          children: [
            const IconButton(
              icon: Icon(Icons.notifications),
              onPressed: null,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: provider.unreadCount > 0
                  ? () => provider.markAllAsRead()
                  : null,
              icon: const Icon(Icons.done_all),
              label: const Text('Mark All Read'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider provider) {
    final notifications = provider.notifications;
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Send Test" to create a test notification',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationTile(notification, provider);
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    NotificationRecord notification,
    NotificationProvider provider,
  ) {
    final isUnread = !notification.read;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isUnread ? Colors.blue : Colors.grey[300],
        child: Icon(
          _getNotificationIcon(notification.type),
          color: isUnread ? Colors.white : Colors.grey[600],
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(notification.timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: isUnread
          ? IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => provider.markAsRead(notification.id),
              tooltip: 'Mark as read',
            )
          : null,
      onTap: () => _handleNotificationTap(notification, provider),
    );
  }

  IconData _getNotificationIcon(NotificationRecordType type) {
    switch (type) {
      case NotificationRecordType.order:
        return Icons.shopping_cart;
      case NotificationRecordType.transport:
        return Icons.local_shipping;
      case NotificationRecordType.priceAlert:
        return Icons.trending_up;
      case NotificationRecordType.system:
        return Icons.info;
      case NotificationRecordType.marketing:
        return Icons.campaign;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(
    NotificationRecord notification,
    NotificationProvider provider,
  ) {
    provider.handleNotificationTap(notification.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notification.deepLink != null
              ? 'Navigating to: ${notification.deepLink}'
              : 'No deep link in notification',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendTestNotification() {
    // In a real app, this would trigger a backend call
    // For now, we just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent! (Mock - requires backend)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      if (_currentLanguage == 'en') {
        _currentLanguage = 'om';
      } else if (_currentLanguage == 'om') {
        _currentLanguage = 'am';
      } else {
        _currentLanguage = 'en';
      }
    });
  }
}
