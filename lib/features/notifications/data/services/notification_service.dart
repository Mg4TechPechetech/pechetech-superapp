import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<NotificationModel>> get notificationsStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', whereIn: [user.uid, null])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Stream<int> get unreadCountStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);
    return getUnreadCount(user.uid);
  }

  // Note: whereIn with null might be tricky in some Firebase versions.
  // Alternative is Filter.or if available.

  Stream<List<NotificationModel>> getNotifications(String? userId) {
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          // Filter in memory for simplicity if complex Firestore queries are limited
          return snapshot.docs
              .map((doc) {
                return NotificationModel.fromMap(doc.data(), doc.id);
              })
              .where((n) => n.userId == null || n.userId == userId)
              .toList();
        });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final query = await _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in query.docs) {
      final data = doc.data();
      if (data['userId'] == null || data['userId'] == user.uid) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    await batch.commit();
  }

  Stream<int> getUnreadCount(String? userId) {
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final data = doc.data();
            return data['userId'] == null || data['userId'] == userId;
          }).length;
        });
  }

  Future<void> seedDemoNotifications(String userId) async {
    final notifications = [
      {
        'title': 'Alerte Météo - Houle forte',
        'description':
            'Attention, une houle de 2.5m est prévue pour demain matin. Soyez prudent en mer.',
        'type': 'weather',
        'timestamp': Timestamp.now(),
        'isRead': false,
        'userId': userId,
      },
      {
        'title': 'Subvention Carburant',
        'description':
            'Votre demande de subvention pour le mois de Mai a été approuvée. Code: PT-8829.',
        'type': 'fuel',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 5)),
        ),
        'isRead': true,
        'userId': userId,
      },
      {
        'title': 'Prix du Marché',
        'description':
            'Le prix du Thon rouge est en hausse de 15% au port de Dakar.',
        'type': 'market',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'isRead': false,
        'userId': userId,
      },
      {
        'title': 'Nouveau message communautaire',
        'description':
            'Un nouveau sujet sur les filets biodégradables a été lancé dans votre zone.',
        'type': 'community',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 2)),
        ),
        'isRead': false,
        'userId': userId,
      },
      {
        'title': 'Rappel Journal de bord',
        'description':
            'N\'oubliez pas de remplir votre journal de bord pour votre sortie d\'hier.',
        'type': 'journal',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        'isRead': true,
        'userId': userId,
      },
    ];

    final batch = _firestore.batch();
    for (var n in notifications) {
      final docRef = _firestore.collection('notifications').doc();
      batch.set(docRef, n);
    }
    await batch.commit();
  }
}
