import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nimbus/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get notifications stream for current user
  Stream<List<NotificationModel>> getNotifications() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get unread notification count
  Stream<int> getUnreadCount() {
    if (_userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create a new notification
  Future<void> createNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'data': data,
      });

      print('✅ Notification created: $title');
    } catch (e) {
      print('❌ Error creating notification: $e');
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  // Mark a notification as unread
  Future<void> markAsUnread(String notificationId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': false});

      print('✅ Notification marked as unread');
    } catch (e) {
      print('❌ Error marking notification as unread: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      print('✅ Notification deleted');
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .get();

      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All notifications cleared');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  // Sample method to create test notifications
  Future<void> createSampleNotifications() async {
    if (_userId == null) return;

    final sampleNotifications = [
      {
        'title': 'Order Shipped! 📦',
        'body': 'Your order #ORD-2024-001 has been shipped and is on its way.',
        'type': 'Order Updates',
        'data': {'action': 'view_order', 'orderId': 'ORD-2024-001'},
      },
      {
        'title': 'New Book Alert! 📚',
        'body': '"Atomic Habits" by James Clear is now available in our store.',
        'type': 'New Books',
        'data': {'action': 'view_book', 'bookId': 'book123'},
      },
      {
        'title': 'Order Delivered ✅',
        'body': 'Your order #ORD-2024-002 has been successfully delivered.',
        'type': 'Order Updates',
        'data': {'action': 'view_order', 'orderId': 'ORD-2024-002'},
      },
      {
        'title': 'Special Offer! 🎉',
        'body': 'Get 20% off on all fiction books this weekend!',
        'type': 'Promotions',
        'data': {'action': 'view_promotion', 'promoId': 'WEEKEND20'},
      },
      {
        'title': 'Security Alert 🔒',
        'body': 'New login detected from Bangkok, Thailand. Was this you?',
        'type': 'Account',
        'data': {'action': 'view_security'},
      },
      {
        'title': 'New Arrivals This Week 🆕',
        'body': '15 new books added to our collection. Check them out!',
        'type': 'New Books',
        'data': {'action': 'view_new_books'},
      },
      {
        'title': 'Order Confirmed 🎊',
        'body': 'Your order #ORD-2024-003 has been confirmed. Total: \$42.97',
        'type': 'Order Updates',
        'data': {'action': 'view_order', 'orderId': 'ORD-2024-003'},
      },
      {
        'title': 'Flash Sale! ⚡',
        'body': 'Limited time offer: Buy 2 Get 1 Free on selected titles!',
        'type': 'Promotions',
        'data': {'action': 'view_sale'},
      },
    ];

    for (var i = 0; i < sampleNotifications.length; i++) {
      final notification = sampleNotifications[i];
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .add({
        'title': notification['title'],
        'body': notification['body'],
        'type': notification['type'],
        'isRead': i > 3, // First 4 are unread
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(Duration(hours: i * 3)),
        ),
        'data': notification['data'],
      });
    }

    print('✅ Sample notifications created');
  }
}