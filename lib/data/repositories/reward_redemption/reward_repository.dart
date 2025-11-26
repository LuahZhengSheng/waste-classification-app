import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:get/get.dart';

class RewardRepository extends GetxController {
  static RewardRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String _rewardImagesPath = 'rewards';

  /// Get all active rewards
  Future<List<RewardModel>> getAllRewards() async {
    try {
      final snapshot = await _db
          .collection('rewards')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RewardModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch rewards: $e';
    }
  }

  /// Get reward by ID
  Future<RewardModel> getRewardById(String rewardId) async {
    try {
      final snapshot = await _db.collection('rewards').doc(rewardId).get();
      if (!snapshot.exists) {
        throw 'Reward not found';
      }
      return RewardModel.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to fetch reward: $e';
    }
  }

  /// Create new reward
  Future<void> createReward(RewardModel reward) async {
    try {
      // 简化处理，直接使用 toJson()
      final json = reward.toJson();

      final docRef = await _db.collection('rewards').add(json);
      await docRef.update({'rewardId': docRef.id});
    } catch (e) {
      throw 'Failed to create reward: $e';
    }
  }

  /// Update existing reward
  Future<void> updateReward(RewardModel reward) async {
    try {
      final json = reward.toJson();
      await _db.collection('rewards').doc(reward.rewardId).update(json);
    } catch (e) {
      throw 'Failed to update reward: $e';
    }
  }

  /// Check if reward is still available
  Future<bool> isRewardAvailable(String rewardId) async {
    try {
      final reward = await getRewardById(rewardId);
      return reward.isAvailable;
    } catch (e) {
      throw 'Failed to check reward availability: $e';
    }
  }

  /// Stream of all active rewards
  Stream<List<RewardModel>> getRewardsStream() {
    return _db
        .collection('rewards')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RewardModel.fromSnapshot(doc))
        .toList());
  }

  /// Stream of single reward
  Stream<RewardModel> getRewardStream(String rewardId) {
    return _db
        .collection('rewards')
        .doc(rewardId)
        .snapshots()
        .map((snapshot) => RewardModel.fromSnapshot(snapshot));
  }

  /// Get all rewards by status (stream)
  Stream<List<RewardModel>> getRewardsByStatusStream(String status) {
    return _db
        .collection('rewards')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RewardModel.fromSnapshot(doc))
        .toList());
  }

  /// Get all rewards (stream)
  Stream<List<RewardModel>> getAllRewardsStream() {
    return _db
        .collection('rewards')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RewardModel.fromSnapshot(doc))
        .toList());
  }

  /// Get reward by ID (stream)
  Stream<RewardModel> getRewardByIdStream(String rewardId) {
    return _db
        .collection('rewards')
        .doc(rewardId)
        .snapshots()
        .map((snapshot) => RewardModel.fromSnapshot(snapshot));
  }

  /// Update reward status
  Future<void> updateRewardStatus(String rewardId, String status) async {
    try {
      await _db.collection('rewards').doc(rewardId).update({
        'status': status,
      });
    } catch (e) {
      throw 'Failed to update reward status: $e';
    }
  }

  /// Get available rewards stream (active, not expired, has quantity)
  Stream<List<RewardModel>> getAvailableRewardsStream() {
    return _db
        .collection('rewards')
        .where('status', isEqualTo: 'active')
        .where('validUntil', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('validUntil')
        .orderBy('pointsNeeded')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RewardModel.fromSnapshot(doc))
        .where((reward) => reward.quantity > 0)
        .toList());
  }

  /// Update reward quantity after redemption
  Future<void> updateRewardQuantity(String rewardId, int newQuantity) async {
    try {
      await _db.collection('rewards').doc(rewardId).update({
        'quantity': newQuantity,
        'redemptionCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to update reward quantity: $e';
    }
  }

  /// Upload reward image
  Future<String> uploadRewardImage(Uint8List imageBytes, String fileName) async {
    try {
      final ref = _storage.ref().child('$_rewardImagesPath/$fileName');
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/webp'),
      );

      await uploadTask;
      return fileName;
    } catch (e) {
      throw 'Failed to upload reward image: $e';
    }
  }

  /// Delete reward image
  Future<void> deleteRewardImage(String fileName) async {
    try {
      if (fileName.isEmpty) return;
      final ref = _storage.ref().child('$_rewardImagesPath/$fileName');
      await ref.delete();
    } catch (e) {
      print('Failed to delete reward image: $e');
    }
  }

  /// Get reward image URL from Firebase Storage
  Future<String?> getRewardImageUrl(String fileName) async {
    try {
      if (fileName.isEmpty) return null;
      final ref = _storage.ref().child('$_rewardImagesPath/$fileName');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Failed to get reward image URL: $e');
      return null;
    }
  }
}