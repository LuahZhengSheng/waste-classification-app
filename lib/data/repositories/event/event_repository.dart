import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../features/event/models/location_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';

class EventRepository extends GetxController {
  static EventRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String _eventPosterPath = 'event/event_poster';

  /// Create new event
  Future<void> createEvent(Event event) async {
    try {
      await _db.collection('events').add(event.toJson());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to create event: $e';
    }
  }

  /// Update existing event
  Future<void> updateEvent(Event event) async {
    try {
      await _db.collection('events').doc(event.eventId).update(event.toJson());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to update event: $e';
    }
  }

  /// Upload event poster to Firebase Storage
  Future<String> uploadEventPoster(Uint8List imageBytes, String fileName) async {
    try {
      print('Storage - Starting upload: $_eventPosterPath/$fileName');
      print('Storage - File size: ${imageBytes.length} bytes');

      final ref = _storage.ref().child('$_eventPosterPath/$fileName');
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/webp', // 明确指定内容类型
        ),
      );

      // 监听上传进度
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        print('Storage - Upload progress: ${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes}');
      });

      final taskSnapshot = await uploadTask;
      print('Storage - Upload completed: ${taskSnapshot.totalBytes} bytes');

      return fileName;
    } on FirebaseException catch (e) {
      print('Storage - FirebaseException: ${e.code} - ${e.message}');
      print('Storage - Stack trace: ${e.stackTrace}');
      throw 'Firebase Storage error (${e.code}): ${e.message}';
    } catch (e) {
      print('Storage - Unexpected error: $e');
      print('Storage - Stack trace: $e');
      throw 'Failed to upload event poster: $e';
    }
  }

  /// Delete event poster from Firebase Storage
  Future<void> deleteEventPoster(String fileName) async {
    try {
      if (fileName.isEmpty) return;

      final ref = _storage.ref().child('$_eventPosterPath/$fileName');
      await ref.delete();
    } on FirebaseException catch (e) {
      // Ignore if file doesn't exist
      if (e.code != 'object-not-found') {
        throw FFirebaseException(e.code).message;
      }
    } catch (e) {
      print('Failed to delete event poster: $e');
    }
  }

  /// Get event poster URL from Firebase Storage
  Future<String?> getEventPosterUrl(String fileName) async {
    try {
      print('📁 Getting event poster URL for: $fileName');

      if (fileName.isEmpty) return null;

      String storagePath = fileName;
      if (!storagePath.startsWith('$_eventPosterPath/')) {
        storagePath = '$_eventPosterPath/$storagePath';
      }

      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();

      print('✅ Event poster URL generated: $url');
      return url;
    } on FirebaseException catch (e) {
      print('📁 ❌ FirebaseException for event poster: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('📁 ❌ Error getting event poster URL: $e');
      return null;
    }
  }

  /// Get all events as stream
  Stream<List<Event>> getAllEvents() {
    try {
      return _db
          .collection('events')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );
        // 转换 poster 为下载 URL
        return await _convertPostersToDownloadUrls(events);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }


  /// Build Event object with contained Location objects
  Future<Event> _buildEventWithLocation(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    if (data == null) return Event.empty();

    try {
      Location location = Location.empty();

      if (data.containsKey('location') && data['location'] != null) {
        final locationData = data['location'] as Map<String, dynamic>;
        location = Location.fromJson(locationData);
      }

      return Event(
        eventId: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        contactPhoneNo: data['contactPhoneNo'] ?? '',
        location: location,
        poster: data['poster'] ?? '',
        startDateTime:
        (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDateTime:
        (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        registrationDeadline:
        (data['registrationDeadline'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 0,
        registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
        createdAt:
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isPublish: data['isPublish'] ?? false,
        status: data['status'] ?? 'active',
        eventRegistrations: [],
      );
    } catch (e) {
      print('Error building event ${doc.id}: $e');
      return Event.empty();
    }
  }

  /// Get event by ID as stream
  Stream<Event> getEventById(String eventId) {
    try {
      return _db
          .collection('events')
          .doc(eventId)
          .snapshots()
          .asyncMap((snapshot) async {
        final event = await _buildEventWithLocation(snapshot);
        return await _convertPosterToDownloadUrl(event);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get event by ID (future)
  Future<Event> getEventByIdFuture(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      final event = await _buildEventWithLocation(doc);
      return await _convertPosterToDownloadUrl(event);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status) async {
    try {
      await _db.collection('events').doc(eventId).update({'status': status});
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to update event status: $e';
    }
  }

  /// Toggle event publish status
  Future<void> togglePublishStatus(String eventId, bool isPublish) async {
    try {
      await _db.collection('events').doc(eventId).update({'isPublish': isPublish});
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to toggle publish status: $e';
    }
  }

  /// Update event registered count
  Future<void> updateEventRegisteredCount(String eventId, int increment) async {
    try {
      await _db.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(increment),
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get events by status
  Stream<List<Event>> getEventsByStatus(String status) {
    try {
      return _db
          .collection('events')
          .where('status', isEqualTo: 'active')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );

        List<Event> filtered;
        switch (status) {
          case 'Open':
            filtered = events.where((event) {
              return event.isRegistrationOpen &&
                  !event.isFullyBooked &&
                  !event.hasEnded;
            }).toList();
            break;

          case 'Full':
            filtered = events.where((event) {
              return event.isFullyBooked &&
                  !event.isRegistrationClosed &&
                  !event.hasEnded;
            }).toList();
            break;

          case 'Closed':
            filtered = events.where((event) {
              return event.isRegistrationClosed && !event.hasEnded;
            }).toList();
            break;

          default:
            filtered = events.where((event) => !event.hasEnded).toList();
            break;
        }

        // 在返回前批量转换 poster
        return await _convertPostersToDownloadUrls(filtered);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Filter events by date range
  Stream<List<Event>> getEventsByDateRange(
      DateTime startDate, DateTime endDate) {
    try {
      return _db
          .collection('events')
          .where('startDateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDateTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );
        final upcoming = events.where((event) => !event.hasEnded).toList();
        return await _convertPostersToDownloadUrls(upcoming);
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Check if event poster exists
  Future<bool> eventPosterExists(String posterFileName) async {
    try {
      if (posterFileName.isEmpty) return false;

      final path = '$_eventPosterPath/$posterFileName';
      final ref = _storage.ref().child(path);

      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to get location for a specific event
  Future<Location> getEventLocation(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      final data = doc.data();

      if (data == null || !data.containsKey('location')) {
        return Location.empty();
      }

      final locationData = data['location'] as Map<String, dynamic>;
      return Location.fromJson(locationData);
    } catch (e) {
      print('Error getting event location: $e');
      return Location.empty();
    }
  }

  /// 将单个 Event 的 poster 文件名转换为下载 URL
  Future<Event> _convertPosterToDownloadUrl(Event event) async {
    try {
      // 已经是完整 URL 或为空时，直接返回
      if (event.poster.isEmpty || event.poster.startsWith('http')) {
        return event;
      }

      // 生成下载 URL
      final downloadUrl = await getEventPosterUrl(event.poster);
      if (downloadUrl == null || downloadUrl.isEmpty) {
        return event;
      }

      return event.copyWith(poster: downloadUrl);
    } catch (e) {
      print('❌ Failed to convert poster to download URL for event ${event.eventId}: $e');
      return event;
    }
  }

  /// 批量转换 Event 列表的 poster 为下载 URL
  Future<List<Event>> _convertPostersToDownloadUrls(List<Event> events) async {
    final List<Event> result = [];
    for (final event in events) {
      try {
        final updatedEvent = await _convertPosterToDownloadUrl(event);
        result.add(updatedEvent);
      } catch (e) {
        print('❌ Failed to convert poster for event ${event.eventId}: $e');
        result.add(event);
      }
    }
    return result;
  }

}