import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import 'event_repository.dart';

class EventRegistrationRepository extends GetxController {
  static EventRegistrationRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EventRepository eventRepository = EventRepository.instance;

  /// Collection reference
  CollectionReference get _registrationsCollection =>
      _db.collection('eventRegistrations');

  /// Get registration by registration ID
  Future<Map<String, dynamic>?> getRegistrationById(
      String registrationId) async {
    try {
      final doc = await _registrationsCollection.doc(registrationId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return {
            'registrationId': doc.id,
            'userId': data['userId'] ?? '',
            'eventId': data['eventId'] ?? '',
            'createdAt':
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'isCancelled': data['isCancelled'] ?? false,
          };
        }
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get registration by registration ID with DocumentSnapshot
  Future<DocumentSnapshot<Map<String, dynamic>>?> getRegistrationSnapshotById(
      String registrationId) async {
    try {
      final doc = await _registrationsCollection.doc(registrationId).get();
      return doc.exists ? doc as DocumentSnapshot<Map<String, dynamic>> : null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get user's registered events with real-time updates
  Stream<List<Event>> getUserRegisteredEvents(String userId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((registrations) async {
        print('📋 开始处理用户 $userId 的注册记录');
        print('🔍 找到 ${registrations.docs.length} 条注册记录');

        if (registrations.docs.isEmpty) {
          print('❌ 用户没有任何注册记录');
          return [];
        }

        // 使用 Map 来确保每个事件只保留最新的注册记录
        final latestRegistrations = <String, QueryDocumentSnapshot>{};

        for (final doc in registrations.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) {
            print('⚠️ 跳过空数据的注册文档: ${doc.id}');
            continue;
          }

          final eventId = data['eventId'] as String?;
          final isCancelled = data['isCancelled'] as bool? ?? false;
          final createdAt = data['createdAt']?.toString() ?? '未知时间';

          print('📝 处理注册记录: 文档ID=${doc.id}, 活动ID=$eventId, 是否取消=$isCancelled, 创建时间=$createdAt');

          // 只处理未取消的注册，并且只保留每个事件的最新记录
          if (eventId != null) {
            if (!latestRegistrations.containsKey(eventId)) {
              latestRegistrations[eventId] = doc;
              print('✅ 添加活动 $eventId 的最新注册记录');
            } else {
              print('⏩ 跳过活动 $eventId 的旧注册记录，已存在更新记录');
            }
          } else if (isCancelled) {
            print('🚫 跳过已取消的注册: 活动 $eventId');
          } else {
            print('❓ 无效的注册记录: 活动ID为空');
          }
        }

        final eventIds = latestRegistrations.keys.toList();
        print('🎯 最终有效的活动ID列表: $eventIds');
        print('📊 有效活动数量: ${eventIds.length}');

        if (eventIds.isEmpty) {
          print('❌ 没有找到有效的活动ID');
          return [];
        }

        // Split into chunks of 10 (Firestore 'in' query limit)
        final chunks = <List<String>>[];
        for (var i = 0; i < eventIds.length; i += 10) {
          chunks.add(
            eventIds.sublist(
              i,
              i + 10 > eventIds.length ? eventIds.length : i + 10,
            ),
          );
        }

        print('📦 将活动ID分成 ${chunks.length} 批进行查询');

        // Fetch events for all chunks
        final allEvents = <Event>[];
        for (var i = 0; i < chunks.length; i++) {
          final chunk = chunks[i];
          print('🔍 正在查询第 ${i + 1} 批活动, 包含 ${chunk.length} 个活动: $chunk');

          final eventsQuery = await _db
              .collection('events')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          print('✅ 第 ${i + 1} 批查询成功, 找到 ${eventsQuery.docs.length} 个活动');

          final chunkEvents = eventsQuery.docs.map((doc) {
            final event = Event.fromSnapshot(doc);
            print('🎉 成功解析活动: ${event.eventId} - ${event.title}');
            return event;
          }).toList();

          allEvents.addAll(chunkEvents);
        }

        print('🎊 查询完成! 总共找到 ${allEvents.length} 个活动');
        print('📋 最终活动列表:');
        for (final event in allEvents) {
          print('   - ${event.eventId}: ${event.title}');
        }

        return allEvents;
      });
    } on FirebaseException catch (e) {
      print('🔥 Firebase错误: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } catch (e) {
      print('💥 未知错误: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Check if user's registration is cancelled
  Stream<Map<String, bool>> getUserCancelledRegistrations(String userId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final cancelledMap = <String, bool>{};
        final processedEvents = <String>{};

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final eventId = data['eventId'] as String?;
          final isCancelled = data['isCancelled'] as bool? ?? false;

          // 只处理每个事件的最新记录
          if (eventId != null && !processedEvents.contains(eventId)) {
            cancelledMap[eventId] = isCancelled;
            processedEvents.add(eventId);
          }
        }
        return cancelledMap;
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Register user for event
  Future<void> registerForEvent(String userId, String eventId) async {
    try {
      // Check if already registered
      final existingRegistration = await _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        throw 'You are already registered for this event';
      }

      // Get event to check capacity
      final event = await eventRepository.getEventByIdFuture(eventId);

      if (event.isFullyBooked) {
        throw 'Event is fully booked';
      }

      if (!event.isRegistrationOpen) {
        throw 'Registration is closed for this event';
      }

      // Create registration
      await _registrationsCollection.add({
        'userId': userId,
        'eventId': eventId,
        'createdAt': Timestamp.now(),
        'isCancelled': false,
      });

      // Update event registered count
      await eventRepository.updateEventRegisteredCount(eventId, 1);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (e is String) rethrow;
      throw 'Something went wrong. Please try again';
    }
  }

  /// Cancel event registration
  Future<void> cancelRegistration(String userId, String eventId) async {
    try {
      // Find registration - 只查找最新的未取消注册
      final registrations = await _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (registrations.docs.isEmpty) {
        throw 'Registration not found';
      }

      // Cancel registration
      final registrationId = registrations.docs.first.id;
      await _registrationsCollection.doc(registrationId).update({
        'isCancelled': true,
      });

      // Update event registered count
      await eventRepository.updateEventRegisteredCount(eventId, -1);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (e is String) rethrow;
      throw 'Something went wrong. Please try again';
    }
  }

  /// Check if user is registered for event
  Stream<bool> isUserRegistered(String userId, String eventId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get registration ID for a user and event
  Future<String?> getRegistrationId(String userId, String eventId) async {
    try {
      final registrations = await _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (registrations.docs.isNotEmpty) {
        return registrations.docs.first.id;
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get user registration ID (alias for getRegistrationId for compatibility)
  Future<String> getUserRegistrationId(String userId, String eventId) async {
    try {
      final registrationId = await getRegistrationId(userId, eventId);
      return registrationId ?? '';
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get all registrations for an event
  Stream<List<DocumentSnapshot>> getEventRegistrations(String eventId) {
    try {
      return _registrationsCollection
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Cancel all registrations for an event (admin use)
  Future<void> cancelAllEventRegistrations(String eventId) async {
    try {
      final registrations = await _registrationsCollection
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .get();

      final batch = _db.batch();

      for (final doc in registrations.docs) {
        batch.update(doc.reference, {
          'isCancelled': true,
        });
      }

      await batch.commit();
      print('Cancelled ${registrations.docs.length} registrations for event $eventId');
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to cancel registrations: $e';
    }
  }
}
