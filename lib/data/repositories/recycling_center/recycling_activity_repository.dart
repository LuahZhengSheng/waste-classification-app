import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/config/emission_config/recycling_waste.dart';

import '../../../utils/helpers/activity_image.dart';

class RecyclingActivityRepository extends GetxController {
  static RecyclingActivityRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  final String _activitiesCollection = 'recyclingActivities';
  final String _activityImagesFolder = 'recycling_activities';
  final String _usersCollection = 'users';

  /// Get user's approved activities stream
  Stream<List<RecyclingActivity>> getUserApprovedActivitiesStream(String userId) {
    return _db
        .collection(_activitiesCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingActivity.fromSnapshot(doc))
        .toList())
        .handleError((error) {
      print('Error in activities stream: $error');
      return <RecyclingActivity>[];
    });
  }

  /// Get all user's activities (including pending, approved, rejected)
  Stream<List<RecyclingActivity>> getAllUserActivitiesStream(String userId) {
    return _db
        .collection(_activitiesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingActivity.fromSnapshot(doc))
        .toList())
        .handleError((error) {
      print('Error in all activities stream: $error');
      return <RecyclingActivity>[];
    });
  }

  Stream<List<RecyclingActivity>> getStaffActivitiesStream(String centerStaffId) {
    return _db
        .collection(_activitiesCollection)
        .where('centerStaffId', isEqualTo: centerStaffId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingActivity.fromSnapshot(doc))
        .toList())
        .handleError((error) {
      print('Error in all activities stream: $error');
      return <RecyclingActivity>[];
    });
  }

  /// Get activity by ID
  Future<RecyclingActivity> getActivityById(String activityId) async {
    try {
      final doc = await _db.collection(_activitiesCollection).doc(activityId).get();

      if (!doc.exists) {
        throw 'Activity not found';
      }

      return RecyclingActivity.fromSnapshot(doc);
    } catch (e) {
      throw 'Failed to fetch activity: $e';
    }
  }

  /// Create new activity
  Future<String> createActivity(RecyclingActivity activity) async {
    try {
      final docRef = await _db.collection(_activitiesCollection).add(activity.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create activity: $e';
    }
  }

  /// Update activity
  Future<void> updateActivity(RecyclingActivity activity) async {
    try {
      await _db
          .collection(_activitiesCollection)
          .doc(activity.activityId)
          .update(activity.toJson());
    } catch (e) {
      throw 'Failed to update activity: $e';
    }
  }

  /// Delete activity
  Future<void> deleteActivity(String activityId) async {
    try {
      // Get activity data first to delete image
      final activityDoc = await _db.collection(_activitiesCollection).doc(activityId).get();

      if (activityDoc.exists) {
        final data = activityDoc.data();
        final supportImage = data?['supportImage'] as String?;
        final userId = data?['userId'] as String?;

        // Delete support image if exists
        if (supportImage != null && supportImage.isNotEmpty && userId != null) {
          await deleteActivityImage(userId, supportImage);
        }
      }

      // Delete activity document
      await _db.collection(_activitiesCollection).doc(activityId).delete();
    } catch (e) {
      throw 'Failed to delete activity: $e';
    }
  }

  /// Upload activity support image
  Future<String> uploadActivityImage(File imageFile, String userId) async {
    try {
      // Generate unique filename
      final fileName = '${_uuid.v4()}.webp';

      // Storage path: recycling_activities/{userId}/{fileName}
      final path = '$_activityImagesFolder/$userId/$fileName';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/webp',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'activity_image',
          },
        ),
      );

      await uploadTask;

      print('Activity image uploaded: $path');

      // Return only the filename (not the full URL)
      return fileName;
    } catch (e) {
      throw 'Failed to upload activity image: $e';
    }
  }

  /// Delete activity image
  Future<void> deleteActivityImage(String userId, String fileName) async {
    try {
      if (fileName.isEmpty) return;

      final path = '$_activityImagesFolder/$userId/$fileName';
      final ref = _storage.ref().child(path);

      await ref.delete();
      print('Deleted activity image: $path');
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        print('Activity image not found, skipping deletion');
      } else {
        print('Error deleting activity image: $e');
      }
    }
  }

  /// Get activities by status
  Future<List<RecyclingActivity>> getActivitiesByStatus(String status) async {
    try {
      final snapshot = await _db
          .collection(_activitiesCollection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RecyclingActivity.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch activities by status: $e';
    }
  }

  /// Get activities by date range
  Future<List<RecyclingActivity>> getActivitiesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final snapshot = await _db
          .collection(_activitiesCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RecyclingActivity.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch activities by date range: $e';
    }
  }

  /// Get activities count by category
  Future<Map<String, int>> getActivitiesCountByCategory(String userId) async {
    try {
      final snapshot = await _db
          .collection(_activitiesCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      final Map<String, int> categoryCounts = {};

      for (final doc in snapshot.docs) {
        final categoryId = doc.data()['wasteCategoryId'] as String;
        categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
      }

      return categoryCounts;
    } catch (e) {
      throw 'Failed to get category counts: $e';
    }
  }

  /// Get single activity stream by ID (for real-time updates)
  Stream<RecyclingActivity> getActivityStream(String activityId) {
    return _db
        .collection(_activitiesCollection)
        .doc(activityId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return RecyclingActivity.fromSnapshot(snapshot);
      }
      return RecyclingActivity.empty();
    }).handleError((error) {
      print('Error in activity stream: $error');
      return RecyclingActivity.empty();
    });
  }

  /// Submit multiple activities with their images and update user stats
  /// This method calculates emission before saving and updates all user statistics
  Future<void> submitActivitiesWithImages(
      List<ActivityWithImage> activitiesWithImages,
      String userId,
      ) async {
    try {
      print('🚀 Starting submission of ${activitiesWithImages.length} activities');

      final batch = _db.batch();
      final List<Map<String, dynamic>> activityData = [];

      // Step 1: Upload all images first
      print('📤 Step 1: Uploading images...');
      for (int i = 0; i < activitiesWithImages.length; i++) {
        final item = activitiesWithImages[i];
        print('Processing activity ${i + 1}/${activitiesWithImages.length}');

        String finalImageFileName;

        if (item.imageFile != null) {
          print('  ↗️ Uploading image for activity ${i + 1}');
          finalImageFileName = await uploadActivityImage(item.imageFile!, userId);
          print('  ✅ Image uploaded: $finalImageFileName');
        } else {
          print('  ⚠️ No image file for activity ${i + 1}');
          finalImageFileName = item.activity.supportImage;
        }

        // 🆕 Calculate emission before saving
        final emissionReduced = RecyclingWasteEmissionConfig.calculateEmissionReduced(
          item.activity.wasteCategoryId,
          item.activity.weight,
        );

        print('  📊 Emission calculated: ${emissionReduced.toStringAsFixed(2)} kg CO2e');

        // Store activity data with uploaded image filename and emission
        activityData.add({
          'activity': item.activity,
          'imageFileName': finalImageFileName,
          'emissionReduced': emissionReduced,
        });
      }

      print('✅ All images uploaded successfully');

      // Step 2: Create Firestore documents in batch
      print('📝 Step 2: Creating Firestore documents...');
      int totalPoints = 0;
      double totalWeight = 0.0;
      double totalEmission = 0.0;
      int activityCount = activityData.length;

      for (int i = 0; i < activityData.length; i++) {
        final data = activityData[i];
        final activity = data['activity'] as RecyclingActivity;
        final imageFileName = data['imageFileName'] as String;
        final emissionReduced = data['emissionReduced'] as double;

        print('Creating document ${i + 1}/${activityData.length}');

        // 🆕 Use Firestore-generated ID
        final docRef = _db.collection(_activitiesCollection).doc();

        final updatedActivity = activity.copyWith(
          activityId: docRef.id,
          supportImage: imageFileName,
          status: 'completed',
          emissionReduced: emissionReduced, // Set calculated emission
        );

        batch.set(docRef, updatedActivity.toJson());

        totalPoints += updatedActivity.pointsEarned;
        totalWeight += updatedActivity.weight;
        totalEmission += emissionReduced;

        print('  Document ${i + 1} prepared with ID: ${docRef.id}');
        print('  Weight: ${updatedActivity.weight} kg, Emission: ${emissionReduced.toStringAsFixed(2)} kg CO2e');
      }

      print('✅ All documents prepared');

      // Step 3: 🆕 Update user statistics (points, weight, activities count, emission)
      print('💰 Step 3: Updating user statistics...');
      print('  Total Points: $totalPoints');
      print('  Total Weight: ${totalWeight.toStringAsFixed(2)} kg');
      print('  Total Activities: $activityCount');
      print('  Total Emission: ${totalEmission.toStringAsFixed(2)} kg CO2e');

      final userRef = _db.collection(_usersCollection).doc(userId);

      batch.update(userRef, {
        // Points
        'rewardPoint': FieldValue.increment(totalPoints),
        'monthlyRewardPoint': FieldValue.increment(totalPoints),
        'totalRewardPoint': FieldValue.increment(totalPoints),

        // 🆕 Recycling Statistics
        'totalWeightRecycled': FieldValue.increment(totalWeight),
        'totalRecyclingActivities': FieldValue.increment(activityCount),
        'totalEmissionReduced': FieldValue.increment(totalEmission),
      });

      // Step 4: Commit batch
      print('💾 Step 4: Committing batch...');
      await batch.commit();

      print('✅ Batch committed successfully!');
      print('🎉 Submission complete:');
      print('  - ${activityData.length} activities');
      print('  - $totalPoints points');
      print('  - ${totalWeight.toStringAsFixed(2)} kg recycled');
      print('  - ${totalEmission.toStringAsFixed(2)} kg CO2e reduced');
    } catch (e, stackTrace) {
      print('❌ Error in submitActivitiesWithImages: $e');
      print('Stack trace: $stackTrace');
      throw 'Failed to submit activities: $e';
    }
  }

  /// Get pending activities for staff review
  Stream<List<RecyclingActivity>> getPendingActivitiesStream() {
    return _db
        .collection(_activitiesCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingActivity.fromSnapshot(doc))
        .toList())
        .handleError((error) {
      print('Error in pending activities stream: $error');
      return <RecyclingActivity>[];
    });
  }

  /// Get activities by center ID
  Future<List<RecyclingActivity>> getActivitiesByCenterId(String centerId) async {
    try {
      // First get all staff IDs of this center
      final staffSnapshot = await _db
          .collection(_usersCollection)
          .where('centerId', isEqualTo: centerId)
          .where('role', isEqualTo: 'center_staff')
          .get();

      final staffIds = staffSnapshot.docs.map((doc) => doc.id).toList();

      if (staffIds.isEmpty) return [];

      // Then get activities where centerStaffId is in staffIds
      final activitiesSnapshot = await _db
          .collection(_activitiesCollection)
          .where('centerStaffId', whereIn: staffIds)
          .orderBy('createdAt', descending: true)
          .get();

      return activitiesSnapshot.docs
          .map((doc) => RecyclingActivity.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch activities by center ID: $e';
    }
  }

  /// Get activities by center ID stream
  Stream<List<RecyclingActivity>> getActivitiesByCenterIdStream(String centerId) async* {
    try {
      // First get all staff IDs of this center
      final staffSnapshot = await _db
          .collection(_usersCollection)
          .where('centerId', isEqualTo: centerId)
          .where('role', isEqualTo: 'center_staff')
          .get();

      final staffIds = staffSnapshot.docs.map((doc) => doc.id).toList();

      if (staffIds.isEmpty) {
        yield [];
        return;
      }

      // Stream activities where centerStaffId is in staffIds
      yield* _db
          .collection(_activitiesCollection)
          .where('centerStaffId', whereIn: staffIds)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => RecyclingActivity.fromSnapshot(doc))
          .toList());
    } catch (e) {
      print('Error in activities stream: $e');
      yield [];
    }
  }
}