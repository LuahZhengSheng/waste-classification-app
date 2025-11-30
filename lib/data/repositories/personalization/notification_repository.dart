import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';

class NotificationRepository extends GetxController {
  static NotificationRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _currentUserId => AuthenticationRepository.instance.authUser?.uid ?? '';

  CollectionReference get _notificationsRef =>
      _db.collection('users').doc(_currentUserId).collection('notifications');

  /// 【修改】使用 Firestore 自动生成 ID
  Future<void> createBulkNotificationsForUsers({
    required List<String> userIds,
    required String title,
    required String message,
    required String type,
    String? eventId,
  }) async {
    try {
      final batch = _db.batch();
      final timestamp = FieldValue.serverTimestamp();

      for (final userId in userIds) {
        // 【使用 Firestore 自动生成的 document reference】
        final notificationRef = _db
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(); // 自动生成 ID

        final notificationData = {
          'title': title,
          'message': message,
          'type': type,
          'isRead': false,
          'createdAt': timestamp,
        };

        if (eventId != null && eventId.isNotEmpty) {
          notificationData['eventId'] = eventId;
        }

        batch.set(notificationRef, notificationData);
      }

      await batch.commit();
      print('✅ Created notification records for ${userIds.length} users');
    } catch (e) {
      print('❌ Error creating bulk notification records: $e');
      throw 'Failed to create notification records: $e';
    }
  }

  /// 【修改】使用 Firestore 自动生成 ID
  Future<void> createNotificationForUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? eventId,
  }) async {
    try {
      // 【使用 Firestore 自动生成的 document reference】
      final notificationRef = _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(); // 自动生成 ID

      final notificationData = {
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (eventId != null && eventId.isNotEmpty) {
        notificationData['eventId'] = eventId;
      }

      await notificationRef.set(notificationData);
      print('✅ Created notification record for user $userId with ID: ${notificationRef.id}');
    } catch (e) {
      print('❌ Error creating notification record: $e');
      throw 'Failed to create notification record: $e';
    }
  }

  /// 获取单个通知的 Stream
  Stream<NotificationModel?> getNotificationStream(String notificationId) {
    return _notificationsRef
        .doc(notificationId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return NotificationModel.fromMap({
        ...data,
        'notificationId': doc.id,
      });
    });
  }

  /// Get real-time notifications stream with pagination
  Stream<List<NotificationModel>> getNotificationsStream({
    int limit = 15,
    DocumentSnapshot? lastDocument,
  }) {
    print('🔔 getNotificationsStream called - limit: $limit, lastDocument: ${lastDocument?.id ?? "null"}');

    Query query = _notificationsRef
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      print('➡️ Starting after document: ${lastDocument.id}');
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) {
      print('📦 Snapshot received - ${snapshot.docs.length} documents');
      print('📊 Has pending writes: ${snapshot.metadata.hasPendingWrites}');

      final notifications = snapshot.docs.map((doc) {
        print('📄 Processing document: ${doc.id}');
        final data = doc.data() as Map<String, dynamic>;

        try {
          final notification = NotificationModel.fromMap({
            ...data,
            'notificationId': doc.id,
          });
          print('✅ Successfully parsed notification: ${doc.id}');
          return notification;
        } catch (e) {
          print('❌ Error parsing notification ${doc.id}: $e');
          print('📝 Data content: $data');
          rethrow;
        }
      }).toList();

      print('🎯 Total notifications processed: ${notifications.length}');
      return notifications;
    });
  }

  Future<List<NotificationModel>> getNotifications({
    int limit = 15,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _notificationsRef
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel.fromMap({
          ...data,
          'notificationId': doc.id,
        });
      }).toList();
    } catch (e) {
      throw 'Failed to fetch notifications: $e';
    }
  }

  Future<DocumentSnapshot?> getLastDocument(List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return null;

    try {
      final lastNotification = notifications.last;
      final docSnapshot = await _notificationsRef.doc(lastNotification.notificationId).get();
      return docSnapshot;
    } catch (e) {
      return null;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final batch = _db.batch();
      final unreadNotifications = await _notificationsRef
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to mark all notifications as read: $e';
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  Future<void> batchDeleteNotifications(List<String> notificationIds) async {
    try {
      final batch = _db.batch();

      for (var id in notificationIds) {
        batch.delete(_notificationsRef.doc(id));
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to batch delete notifications: $e';
    }
  }

  Stream<int> getUnreadCountStream() {
    return _notificationsRef
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getTotalCountStream() {
    return _notificationsRef.snapshots().map((snapshot) => snapshot.docs.length);
  }

  /// 【修改】使用 Firestore 自动生成 ID
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    String? eventId,
  }) async {
    try {
      await _notificationsRef.add({
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        if (eventId != null && eventId.isNotEmpty) 'eventId': eventId,
      });
    } catch (e) {
      throw 'Failed to create notification: $e';
    }
  }
}
