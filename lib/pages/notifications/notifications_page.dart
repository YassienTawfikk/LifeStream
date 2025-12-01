import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/models/notification.dart' as models;
import 'package:life_stream/widgets/index.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<models.Notification> mockNotifications = [
    models.Notification(
      id: '1',
      title: 'New Item Posted',
      message: 'A new item matching your interests was posted',
      type: 'info',
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    models.Notification(
      id: '2',
      title: 'Your Item Got Popular',
      message: 'Your sunset photo reached 1000 views!',
      type: 'success',
      isRead: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    models.Notification(
      id: '3',
      title: 'New Follower',
      message: 'Sarah Johnson started following you',
      type: 'info',
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    models.Notification(
      id: '4',
      title: 'Update Available',
      message: 'A new version of LifeStream is available',
      type: 'warning',
      isRead: true,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Color _getTypeColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              // Mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                ),
              );
            },
          ),
        ],
      ),
      body: mockNotifications.isEmpty
          ? EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              description: 'You are all caught up!',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: mockNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = mockNotifications[index];
                return AppCard(
                  backgroundColor: notification.isRead
                      ? Theme.of(context).cardColor
                      : Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  onTap: () {
                    // Handle notification tap
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getTypeColor(notification.type)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(notification.type),
                          color: _getTypeColor(notification.type),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTextStyles.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTime(notification.timestamp),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
