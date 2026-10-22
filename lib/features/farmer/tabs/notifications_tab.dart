import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/session_service.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Notifications Tab with real-time updates
class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab>
    with AutomaticKeepAliveClientMixin {
  final _sessionService = SessionService();
  String _selectedFilter = 'all'; // all, unread, order, transport, produce

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshData() async {
    final userId = _sessionService.currentUserId;
    if (userId != null) {
      await context.read<NotificationProvider>().loadUserNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final userId = _sessionService.currentUserId;
      if (userId == null) return;
      await context.read<NotificationProvider>().markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications marked as read'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await context.read<NotificationProvider>().deleteNotification(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  dynamic _getFilteredNotifications(dynamic notifications) {
    if (_selectedFilter == 'all') {
      return notifications;
    } else if (_selectedFilter == 'unread') {
      return notifications.where((n) => !n.isRead).toList();
    } else {
      // Filter by type
      return notifications.where((n) => n.type.name == _selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final provider = context.watch<NotificationProvider>();
    final allNotifications = provider.notifications;
    final filteredNotifications = _getFilteredNotifications(allNotifications);
    final unreadCount = provider.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Filter and Actions Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredNotifications.length} Notifications',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton.icon(
                        onPressed: _markAllAsRead,
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Mark all read'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all', allNotifications.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Unread', 'unread', unreadCount),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Orders',
                        'order',
                        allNotifications.where((n) => n.type == NotificationType.order).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Transport',
                        'transport',
                        allNotifications.where((n) => n.type == NotificationType.transport).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Produce',
                        'produce',
                        allNotifications.where((n) => n.type == NotificationType.produce).length,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: _buildNotificationsList(provider, filteredNotifications),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textOnPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildNotificationsList(
    NotificationProvider provider,
    dynamic notifications,
  ) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading notifications...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter != 'all' ? 'No notifications found' : 'No notifications yet',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter != 'all'
                  ? 'Try selecting a different filter'
                  : 'You\'ll see notifications here',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');
    
    Color typeColor = AppColors.textSecondary;
    IconData typeIcon = Icons.notifications_outlined;
    
    switch (notification.type) {
      case NotificationType.order:
        typeColor = AppColors.success;
        typeIcon = Icons.receipt_long_outlined;
        break;
      case NotificationType.transport:
        typeColor = AppColors.info;
        typeIcon = Icons.local_shipping_outlined;
        break;
      case NotificationType.produce:
        typeColor = AppColors.primary;
        typeIcon = Icons.agriculture_outlined;
        break;
      case NotificationType.system:
        typeColor = AppColors.textSecondary;
        typeIcon = Icons.info_outline;
        break;
      case NotificationType.marketing:
        typeColor = AppColors.accent;
        typeIcon = Icons.campaign_outlined;
        break;
      default:
        // Use already initialized defaults
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: AppColors.textOnPrimary,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Card(
        elevation: notification.isRead ? 1 : 3,
        shadowColor: AppColors.shadow12,
        color: notification.isRead ? AppColors.surface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead
              ? BorderSide.none
              : BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
        ),
        child: InkWell(
          onTap: () async {
            if (!notification.isRead) {
              await context.read<NotificationProvider>().markAsRead(notification.id);
            }
            // TODO: Handle action URL navigation
            if (notification.actionUrl != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigate to: ${notification.actionUrl}'),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFormat.format(notification.createdAt),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
