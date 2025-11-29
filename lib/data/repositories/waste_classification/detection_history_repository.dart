import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../features/waste_classification/models/detection_history_model.dart';

class DetectionHistoryRepository extends GetxController {
  static DetectionHistoryRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String _collectionName = 'detectionHistory';
  final String _storagePath = 'detection_history';

  /// Save detection history with image
  Future<void> saveDetectionHistory({
    required File imageFile,
    required int detectionCount,
    required List<String> detectedItems,
  }) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;

      // 获取文件名（使用 ImageCompressor 生成的 UUID.webp）
      final fileName = imageFile.path.split('/').last;
      print('📁 Uploading image with filename: $fileName');

      // Upload image to Firebase Storage
      final storageRef = _storage.ref().child('$_storagePath/$userId/$fileName');

      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      // Create history model
      final history = DetectionHistoryModel(
        historyId: '', // Will be set by Firestore
        userId: userId,
        imageUrl: imageUrl,
        detectionCount: detectionCount,
        detectedItems: detectedItems,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _db.collection(_collectionName).add(history.toJson());

      print('✅ Detection history saved successfully with image: $fileName');
    } catch (e) {
      print('❌ Failed to save detection history: $e');
      throw 'Failed to save detection history';
    }
  }

  /// Get all detection history for current user
  Future<List<DetectionHistoryModel>> getUserDetectionHistory() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;

      final snapshot = await _db
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DetectionHistoryModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('❌ Failed to fetch detection history: $e');
      throw 'Failed to load detection history';
    }
  }

  /// Get detection history stream for real-time updates
  Stream<List<DetectionHistoryModel>> getDetectionHistoryStream() {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;

      return _db
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => DetectionHistoryModel.fromSnapshot(doc))
          .toList());
    } catch (e) {
      print('❌ Failed to get detection history stream: $e');
      throw 'Failed to load detection history';
    }
  }

  /// Delete detection history
  Future<void> deleteDetectionHistory(String historyId, String imageUrl) async {
    try {
      // Delete from Firestore
      await _db.collection(_collectionName).doc(historyId).delete();

      // Delete image from Storage
      try {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      } catch (e) {
        print('⚠️ Failed to delete image from storage: $e');
      }

      print('✅ Detection history deleted successfully');
    } catch (e) {
      print('❌ Failed to delete detection history: $e');
      throw 'Failed to delete detection history';
    }
  }

  /// Delete all detection history for current user
  Future<void> clearAllHistory() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;

      final snapshot = await _db
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      // Delete all documents and their images
      for (var doc in snapshot.docs) {
        final history = DetectionHistoryModel.fromSnapshot(doc);
        await deleteDetectionHistory(history.historyId, history.imageUrl);
      }

      print('✅ All detection history cleared');
    } catch (e) {
      print('❌ Failed to clear detection history: $e');
      throw 'Failed to clear detection history';
    }
  }
}