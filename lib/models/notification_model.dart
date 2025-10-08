import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'Order Updates', 'New Books', 'Promotions', 'Account'
  final bool isRead;
  final DateTime timestamp;
  final Map<String, dynamic>? data; // Additional data for navigation

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.data,
  });

  // Create from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'All',
      isRead: data['isRead'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
      'data': data,
    };
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
    );
  }
}