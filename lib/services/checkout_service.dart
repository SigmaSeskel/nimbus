import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nimbus/models/payment_method.dart';
import 'package:nimbus/services/notification_service.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String? get _userId => _auth.currentUser?.uid;

  // Sample coupon codes
  final Map<String, Map<String, dynamic>> _coupons = {
    'WELCOME10': {'discount': 10.0, 'type': 'fixed', 'minPurchase': 0.0},
    'SAVE20': {'discount': 20.0, 'type': 'fixed', 'minPurchase': 50.0},
    'PERCENT15': {'discount': 15.0, 'type': 'percentage', 'minPurchase': 30.0},
    'FREESHIP': {'discount': 5.99, 'type': 'fixed', 'minPurchase': 20.0},
  };

  // Get saved billing address
  Future<Map<String, dynamic>?> getSavedBillingAddress() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('billingAddress')) {
          return data['billingAddress'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error loading billing address: $e');
      return null;
    }
  }

  // Save billing address
  Future<void> saveBillingAddress(Map<String, dynamic> address) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'billingAddress': address,
      });
      print('✅ Billing address saved');
    } catch (e) {
      print('❌ Error saving billing address: $e');
    }
  }

  // Validate coupon code
  Future<Map<String, dynamic>?> validateCoupon(
    String code,
    double subtotal,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    final couponCode = code.trim().toUpperCase();
    
    if (!_coupons.containsKey(couponCode)) {
      throw 'Invalid coupon code';
    }

    final coupon = _coupons[couponCode]!;
    final minPurchase = coupon['minPurchase'] as double;

    if (subtotal < minPurchase) {
      throw 'Minimum purchase of \$${minPurchase.toStringAsFixed(2)} required';
    }

    double discount = 0.0;
    if (coupon['type'] == 'fixed') {
      discount = coupon['discount'] as double;
    } else if (coupon['type'] == 'percentage') {
      discount = subtotal * (coupon['discount'] as double) / 100;
    }

    return {
      'code': couponCode,
      'discount': discount,
      'type': coupon['type'],
    };
  }

  // Process payment
  Future<String> processPayment({
    required PaymentMethod paymentMethod,
    required Map<String, dynamic> billingAddress,
    required List<Map<String, dynamic>> cartItems,
    required double subtotal,
    required double tax,
    required double shipping,
    required double discount,
    required double total,
    String? couponCode,
  }) async {
    if (_userId == null) throw 'User not authenticated';

    try {
      print('🔵 Processing payment...');
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create order ID
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create order document
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .doc(orderId)
          .set({
        'orderId': orderId,
        'status': 'confirmed',
        'paymentMethod': paymentMethod.name,
        'billingAddress': billingAddress,
        'items': cartItems.map((item) => {
          'title': item['title'],
          'author': item['author'],
          'price': item['price'],
          'quantity': item['quantity'],
          'image': item['image'],
        }).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'shipping': shipping,
        'discount': discount,
        'total': total,
        'couponCode': couponCode,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Order created: $orderId');

      // Add books to user's purchased books
      final batch = _firestore.batch();
      for (var item in cartItems) {
        final bookRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('purchasedBooks')
            .doc();
        
        batch.set(bookRef, {
          'title': item['title'],
          'author': item['author'],
          'price': item['price'],
          'image': item['image'],
          'purchasedAt': FieldValue.serverTimestamp(),
          'orderId': orderId,
        });
      }
      await batch.commit();

      // Create order confirmation notification
      await _notificationService.createNotification(
        title: 'Order Confirmed! 🎊',
        body: 'Your order $orderId has been confirmed. Total: \$${total.toStringAsFixed(2)}',
        type: 'Order Updates',
        data: {
          'action': 'view_order',
          'orderId': orderId,
        },
      );

      // Clear cart (in real app, you would do this)
      // await clearCart();

      print('🎉 Payment processed successfully!');
      return orderId;
    } catch (e) {
      print('❌ Payment processing failed: $e');
      throw 'Payment failed: ${e.toString()}';
    }
  }

  // Clear user's cart
  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      final cartRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('cart');
      
      final snapshot = await cartRef.get();
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ Cart cleared');
    } catch (e) {
      print('❌ Error clearing cart: $e');
    }
  }

  // Get order details
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error fetching order: $e');
      return null;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for status update
      String notificationTitle = '';
      String notificationBody = '';

      switch (status) {
        case 'processing':
          notificationTitle = 'Order Processing 📦';
          notificationBody = 'Your order $orderId is being processed';
          break;
        case 'shipped':
          notificationTitle = 'Order Shipped! 🚚';
          notificationBody = 'Your order $orderId has been shipped';
          break;
        case 'delivered':
          notificationTitle = 'Order Delivered! ✅';
          notificationBody = 'Your order $orderId has been delivered';
          break;
        case 'cancelled':
          notificationTitle = 'Order Cancelled ❌';
          notificationBody = 'Your order $orderId has been cancelled';
          break;
      }

      if (notificationTitle.isNotEmpty) {
        await _notificationService.createNotification(
          title: notificationTitle,
          body: notificationBody,
          type: 'Order Updates',
          data: {
            'action': 'view_order',
            'orderId': orderId,
          },
        );
      }

      print('✅ Order status updated: $status');
    } catch (e) {
      print('❌ Error updating order status: $e');
    }
  }
}
