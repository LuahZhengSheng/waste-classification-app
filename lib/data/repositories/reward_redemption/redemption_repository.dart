import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:get/get.dart';

import '../../../features/reward_redemption/models/reward_model.dart';

class RedemptionRepository extends GetxController {
  static RedemptionRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _redemptionsCollection = 'redemptions';

  /// Create a new redemption
  Future<RedemptionModel> createRedemption(RedemptionModel redemption) async {
    try {
      final docRef =
      await _db.collection(_redemptionsCollection).add(redemption.toJson());

      await docRef.update({'redemptionId': docRef.id});

      final snapshot = await docRef.get();
      return RedemptionModel.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to create redemption: $e';
    }
  }

  /// 统一事务：创建 redemption、扣用户积分、更新 reward 数量和状态
  Future<RedemptionModel> createRedemptionWithSideEffects({
    required RedemptionModel redemption,
    required String rewardId,
    required String userId,
    required int points,
  }) async {
    final db = _db;
    return await db.runTransaction<RedemptionModel>((txn) async {
      final rewardRef = db.collection('rewards').doc(rewardId);
      final userRef = db.collection('users').doc(userId);
      final redemptionRef = db.collection(_redemptionsCollection).doc();

      final rewardSnap = await txn.get(rewardRef);
      final userSnap = await txn.get(userRef);

      if (!rewardSnap.exists) throw 'Reward not found';
      if (!userSnap.exists) throw 'User not found';

      final reward = RewardModel.fromSnapshot(rewardSnap);
      final userPoints = (userSnap.data()?['rewardPoint'] ?? 0) as int;

      if (userPoints < points) throw 'Insufficient points';
      if (!reward.validUntil.isAfter(DateTime.now())) throw 'Reward expired';
      if (reward.remainingQuantity <= 0) throw 'Reward out of stock';
      if (reward.status != 'active') throw 'Reward inactive';

      // 更新用户积分
      txn.update(userRef, {
        'rewardPoint': userPoints - points,
      });

      // 计算新的 redemptionCount 和剩余数量
      final newRedemptionCount = reward.redemptionCount + 1;
      final newRemaining = reward.quantity - newRedemptionCount;

      // 更新 reward，若新剩余量 <= 0，则设为 inactive
      txn.update(rewardRef, {
        'redemptionCount': newRedemptionCount,
        if (newRemaining <= 0) 'status': 'inactive',
      });

      // 创建 redemption
      final data = redemption.toJson();
      data['redemptionId'] = redemptionRef.id;
      txn.set(redemptionRef, data);

      return redemption.copyWith(redemptionId: redemptionRef.id);
    });
  }


  /// 更新 redemption 的状态
  Future<void> updateRedemptionStatus(
      String redemptionId, String status) async {
    try {
      await _db
          .collection(_redemptionsCollection)
          .doc(redemptionId)
          .update({'status': status});
    } catch (e) {
      throw 'Failed to update redemption status: $e';
    }
  }

  /// Get redemptions by reward ID (future)
  Future<List<RedemptionModel>> getRedemptionsByRewardId(
      String rewardId) async {
    try {
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('rewardId', isEqualTo: rewardId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RedemptionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch redemptions: $e';
    }
  }

  /// Get redemption count by reward ID (stream)
  Stream<int> getRedemptionCountByRewardIdStream(String rewardId) {
    return _db
        .collection(_redemptionsCollection)
        .where('rewardId', isEqualTo: rewardId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get all redemptions for a user
  Future<List<RedemptionModel>> getUserRedemptions(String userId) async {
    try {
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RedemptionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch user redemptions: $e';
    }
  }

  /// Get active redemptions (not expired)
  Future<List<RedemptionModel>> getActiveRedemptions(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RedemptionModel.fromSnapshot(doc))
          .where((redemption) {
        final daysSinceRedemption =
            now.difference(redemption.createdAt).inDays;
        return daysSinceRedemption < 30;
      }).toList();
    } catch (e) {
      throw 'Failed to fetch active redemptions: $e';
    }
  }

  /// Get expired redemptions
  Future<List<RedemptionModel>> getExpiredRedemptions(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RedemptionModel.fromSnapshot(doc))
          .where((redemption) {
        final daysSinceRedemption =
            now.difference(redemption.createdAt).inDays;
        return daysSinceRedemption >= 30;
      }).toList();
    } catch (e) {
      throw 'Failed to fetch expired redemptions: $e';
    }
  }

  /// Get redemption by ID
  Future<RedemptionModel> getRedemptionById(String redemptionId) async {
    try {
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .doc(redemptionId)
          .get();
      if (!snapshot.exists) {
        throw 'Redemption not found';
      }
      return RedemptionModel.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to fetch redemption: $e';
    }
  }

  /// Stream of user redemptions
  Stream<List<RedemptionModel>> getUserRedemptionsStream(String userId) {
    return _db
        .collection(_redemptionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RedemptionModel.fromSnapshot(doc))
        .toList());
  }

  /// Check if user has already redeemed a specific reward
  Future<bool> hasUserRedeemedReward(String userId, String rewardId) async {
    try {
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .where('rewardId', isEqualTo: rewardId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Failed to check redemption status: $e';
    }
  }

  /// Get redemption details by ID as stream
  Stream<RedemptionModel> getRedemptionStream(String redemptionId) {
    return _db
        .collection(_redemptionsCollection)
        .doc(redemptionId)
        .snapshots()
        .map((snapshot) => RedemptionModel.fromSnapshot(snapshot));
  }
}