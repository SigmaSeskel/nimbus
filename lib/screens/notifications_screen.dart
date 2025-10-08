import 'package:flutter/material.dart';
import 'package:nimbus/services/notification_service.dart';
import 'package:nimbus/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'All';
  bool _showUnreadOnly = false;

  final List<String> _filters = [
    'All',
    'Order Updates',
    'New Books',
    'Promotions',
    'Account',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Filter toggle
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.mark_email_read : Icons.mark_email_unread,
              color: const Color(0xFF64B5F6),
            ),
            onPressed: () {
              setState(() {
                _showUnreadOnly = !_showUnreadOnly;
              });
            },
            tooltip: _showUnreadOnly ? 'Show All' : 'Show Unread',
          ),
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2C3E50)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAllNotifications();
              } else if (value == 'settings') {
                _showNotificationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Color(0xFF64B5F6)),
                    SizedBox(width: 12),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Clear all'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Color(0xFF2C3E50)),
                    SizedBox(width: 12),
                    Text('Notification settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFF64B5F6).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF64B5F6) : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF64B5F6) : Colors.transparent,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF64B5F6),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading notifications',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                List<NotificationModel> notifications = snapshot.data ?? [];

                // Apply filters
                if (_selectedFilter != 'All') {
                  notifications = notifications
                      .where((n) => n.type == _selectedFilter)
                      .toList();
                }

                if (_showUnreadOnly) {
                  notifications = notifications.where((n) => !n.isRead).toList();
                }

                // Sort by date (newest first)
                notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                // Group by date
                Map<String, List<NotificationModel>> groupedNotifications = {};
                for (var notification in notifications) {
                  String dateKey = _getDateKey(notification.timestamp);
                  if (!groupedNotifications.containsKey(dateKey)) {
                    groupedNotifications[dateKey] = [];
                  }
                  groupedNotifications[dateKey]!.add(notification);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedNotifications.length,
                  itemBuilder: (context, index) {
                    String dateKey = groupedNotifications.keys.elementAt(index);
                    List<NotificationModel> dateNotifications =
                        groupedNotifications[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
                          child: Text(
                            dateKey,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        // Notifications for this date
                        ...dateNotifications.map((notification) {
                          return _buildNotificationCard(notification);
                        }).toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        _notificationService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // Could implement undo functionality here
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey[200]!
                  : const Color(0xFF64B5F6).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF64B5F6),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTimeAgo(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // More options
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'mark_read') {
                    _notificationService.markAsRead(notification.id);
                  } else if (value == 'mark_unread') {
                    _notificationService.markAsUnread(notification.id);
                  } else if (value == 'delete') {
                    _notificationService.deleteNotification(notification.id);
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read, size: 18),
                          SizedBox(width: 12),
                          Text('Mark as read'),
                        ],
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'mark_unread',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_unread, size: 18),
                          SizedBox(width: 12),
                          Text('Mark as unread'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showUnreadOnly ? Icons.mark_email_read : Icons.notifications_none,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            _showUnreadOnly ? 'No unread notifications' : 'No notifications yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly
                ? 'You\'re all caught up!'
                : 'We\'ll notify you when something new arrives',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Order Updates':
        return Icons.local_shipping_outlined;
      case 'New Books':
        return Icons.auto_stories;
      case 'Promotions':
        return Icons.local_offer_outlined;
      case 'Account':
        return Icons.person_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Order Updates':
        return Colors.blue;
      case 'New Books':
        return Colors.green;
      case 'Promotions':
        return Colors.orange;
      case 'Account':
        return Colors.purple;
      default:
        return const Color(0xFF64B5F6);
    }
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return '${now.difference(date).inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }

    // Handle navigation based on notification data
    if (notification.data != null && notification.data!.containsKey('action')) {
      final action = notification.data!['action'];
      
      if (action == 'view_order') {
        // Navigate to order details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening order details...'),
            duration: Duration(seconds: 1),
          ),
        );
      } else if (action == 'view_book') {
        // Navigate to book details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening book details...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _markAllAsRead() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark all as read?'),
        content: const Text('This will mark all notifications as read.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationService.markAllAsRead();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
            ),
            child: const Text('Mark All'),
          ),
        ],
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationService.clearAllNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),

                _buildNotificationToggle(
                  'Order Updates',
                  'Get notified about your orders',
                  Icons.local_shipping_outlined,
                  true,
                ),
                _buildNotificationToggle(
                  'New Books',
                  'Notifications about new arrivals',
                  Icons.auto_stories,
                  true,
                ),
                _buildNotificationToggle(
                  'Promotions',
                  'Special offers and deals',
                  Icons.local_offer_outlined,
                  false,
                ),
                _buildNotificationToggle(
                  'Account Activity',
                  'Security and account updates',
                  Icons.security,
                  true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    IconData icon,
    bool initialValue,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF64B5F6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeColor: const Color(0xFF64B5F6),
                onChanged: (newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}