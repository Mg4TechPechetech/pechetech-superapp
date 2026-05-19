import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // weather, fuel, market, journal, community
  final bool isRead;
  final String? userId; // Null for global notifications
  final String? fishingZone; // Filter by zone

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.userId,
    this.fishingZone,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'isRead': isRead,
      'userId': userId,
      'fishingZone': fishingZone,
    };
  }

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return NotificationModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      type: map['type'] ?? 'info',
      isRead: map['isRead'] ?? false,
      userId: map['userId'],
      fishingZone: map['fishingZone'],
    );
  }
}
