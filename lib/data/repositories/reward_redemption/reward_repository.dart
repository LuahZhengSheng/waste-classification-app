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
  static const String _rewardImagesFolder = 'rewards';

  /// Get all active rewards
  Future<List<RewardModel>> getAllRewards() async {
    try {
      final snapshot = await _db
          .collection('rewards')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      final rewards = snapshot.docs
          .map((doc) => RewardModel.fromSnapshot(doc))
          .toList();

      // 批量转换图片为可用的下载 URL（仅用于展示）
      return await _convertImagesToDownloadUrls(rewards);
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
      final reward = RewardModel.fromSnapshot(snapshot);
      // 转换图片为下载 URL（仅返回给前端用）
      return await convertImageToDownloadUrl(reward);
    } catch (e) {
      throw 'Failed to fetch reward: $e';
    }
  }

  /// Get reward stream by ID
  Stream<RewardModel> getRewardStream(String rewardId) {
    print('🎯 Getting reward stream for ID: $rewardId');

    return _db
        .collection('rewards')
        .doc(rewardId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) {
        print('❌ Reward document does not exist: $rewardId');
        throw 'Reward not found';
      }

      print('✅ Reward document found, processing...');
      final reward = RewardModel.fromSnapshot(snapshot);
      print('📝 Reward title: ${reward.title}');

      final rewardWithImage = await convertImageToDownloadUrl(reward);
      print('🖼️ Reward image URL: ${rewardWithImage.rewardImage}');

      return rewardWithImage;
    }).handleError((error) {
      print('❌ Error in reward stream: $error');
      throw error;
    });
  }

  /// Get all active rewards stream
  Stream<List<RewardModel>> getActiveRewardsStream() {
    return _db
        .collection('rewards')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final rewards = snapshot.docs
          .map((doc) => RewardModel.fromSnapshot(doc))
          .toList();
      return await _convertImagesToDownloadUrls(rewards);
    });
  }

  /// Get all rewards by status (stream)
  Stream<List<RewardModel>> getRewardsByStatusStream(String status) {
    return _db
        .collection('rewards')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final rewards = snapshot.docs
          .map((doc) => RewardModel.fromSnapshot(doc))
          .toList();
      return await _convertImagesToDownloadUrls(rewards);
    });
  }

  /// Get all rewards (stream)
  Stream<List<RewardModel>> getAllRewardsStream() {
    return _db
        .collection('rewards')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final rewards = snapshot.docs
          .map((doc) => RewardModel.fromSnapshot(doc))
          .toList();
      return await _convertImagesToDownloadUrls(rewards);
    });
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
        .asyncMap((snapshot) async {
      final rewards = snapshot.docs
          .map((doc) => RewardModel.fromSnapshot(doc))
          .where((reward) => reward.quantity > 0)
          .toList();
      return await _convertImagesToDownloadUrls(rewards);
    });
  }

  /// 将单个奖励的图片“文件名”转换为下载 URL（仅用于返回给前端）
  Future<RewardModel> convertImageToDownloadUrl(RewardModel reward) async {
    try {
      // 如果已经是完整 URL，则不再处理
      if (reward.rewardImage.startsWith('http')) {
        return reward;
      }

      // 如果是空的，原样返回
      if (reward.rewardImage.isEmpty) {
        return reward;
      }

      // 从文件名构建下载 URL
      final downloadUrl = await _getImageDownloadUrl(reward.rewardImage);
      return reward.copyWith(rewardImage: downloadUrl);
    } catch (e) {
      print('❌ Failed to convert image to download URL for reward ${reward.title}: $e');
      return reward;
    }
  }

  /// 批量转换奖励图片为下载 URL（仅用于展示）
  Future<List<RewardModel>> _convertImagesToDownloadUrls(List<RewardModel> rewards) async {
    final List<RewardModel> result = [];

    for (final reward in rewards) {
      try {
        final updatedReward = await convertImageToDownloadUrl(reward);
        result.add(updatedReward);
      } catch (e) {
        print('❌ Failed to convert image for reward ${reward.title}: $e');
        result.add(reward);
      }
    }

    return result;
  }

  /// 获取图片下载 URL（入参是纯文件名）
  Future<String> _getImageDownloadUrl(String fileName) async {
    try {
      if (fileName.isEmpty) return '';

      // 构建存储路径：rewards/文件名
      final path = '$_rewardImagesFolder/$fileName';
      print('path: $path');
      final ref = _storage.ref().child(path);

      final downloadUrl = await ref.getDownloadURL();
      print('✅ Generated download URL for reward image $fileName: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('❌ Reward image not found in storage: $fileName');
      }
      throw 'Failed to get reward image download URL: ${e.message}';
    } catch (e) {
      throw 'Failed to get reward image download URL: $e';
    }
  }

  /// 创建新奖励（reward.rewardImage 必须是“文件名”，不是 URL）
  Future<void> createReward(RewardModel reward) async {
    try {
      final json = reward.toJson();
      // 这里的 json['rewardImage'] 应该是纯文件名
      final docRef = await _db.collection('rewards').add(json);
      await docRef.update({'rewardId': docRef.id});
    } catch (e) {
      throw 'Failed to create reward: $e';
    }
  }

  /// 更新已有奖励（reward.rewardImage 必须是“文件名”）
  Future<void> updateReward(RewardModel reward) async {
    try {
      final json = reward.toJson();
      // json['rewardImage'] 这里也应该是纯文件名
      await _db.collection('rewards').doc(reward.rewardId).update(json);
    } catch (e) {
      throw 'Failed to update reward: $e';
    }
  }

  /// 检查奖励是否仍可用
  Future<bool> isRewardAvailable(String rewardId) async {
    try {
      final reward = await getRewardById(rewardId);
      return reward.isAvailable;
    } catch (e) {
      throw 'Failed to check reward availability: $e';
    }
  }

  /// 更新奖励状态
  Future<void> updateRewardStatus(String rewardId, String status) async {
    try {
      await _db.collection('rewards').doc(rewardId).update({
        'status': status,
      });
    } catch (e) {
      throw 'Failed to update reward status: $e';
    }
  }

  /// 兑换后更新奖励数量
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

  /// 上传奖励图片到 Firebase Storage（返回“文件名”）
  Future<String> uploadRewardImage(Uint8List imageBytes, String fileName) async {
    try {
      print('Storage - Starting reward image upload: $_rewardImagesFolder/$fileName');
      print('Storage - File size: ${imageBytes.length} bytes');

      final ref = _storage.ref().child('$_rewardImagesFolder/$fileName');
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/webp'),
      );

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        print('Storage - Upload progress: ${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes}');
      });

      final taskSnapshot = await uploadTask;
      print('Storage - Reward image upload completed: ${taskSnapshot.totalBytes} bytes');

      // 返回纯文件名，供 Firestore 使用
      return fileName;
    } on FirebaseException catch (e) {
      print('Storage - FirebaseException: ${e.code} - ${e.message}');
      throw 'Firebase Storage error (${e.code}): ${e.message}';
    } catch (e) {
      print('Storage - Unexpected error: $e');
      throw 'Failed to upload reward image: $e';
    }
  }

  /// 从 Firebase Storage 删除奖励图片（入参是文件名）
  Future<void> deleteRewardImage(String fileName) async {
    try {
      if (fileName.isEmpty) return;

      final ref = _storage.ref().child('$_rewardImagesFolder/$fileName');
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw 'Failed to delete reward image: ${e.message}';
      }
    } catch (e) {
      print('Failed to delete reward image: $e');
    }
  }

  /// ✅ 直接获取奖励图片下载URL（公共方法）
  Future<String?> getRewardImageUrl(String fileName) async {
    try {
      print('📁 getRewardImageUrl called with: "$fileName"');
      print('📁 File name length: ${fileName.length}');

      if (fileName.isEmpty) {
        print('📁 File name is empty');
        return null;
      }

      // 清理文件名（移除前后空格等）
      final cleanFileName = fileName.trim();
      print('📁 Cleaned file name: "$cleanFileName"');

      final path = '$_rewardImagesFolder/$cleanFileName';
      print('📁 Storage path: $path');

      final ref = _storage.ref().child(path);
      print('📁 Storage reference created');

      final downloadUrl = await ref.getDownloadURL();
      print('📁 ✅ Successfully retrieved reward image download URL: $downloadUrl');
      return downloadUrl;

    } on FirebaseException catch (e) {
      print('📁 ❌ FirebaseException: ${e.code} - ${e.message}');
      print('📁 Stack trace: ${e.stackTrace}');

      if (e.code == 'object-not-found') {
        print('📁 Reward image not found in storage: $fileName');
        return null;
      }
      throw 'Failed to get reward image URL: ${e.message ?? e.code}';
    } catch (e) {
      print('📁 ❌ Unexpected error: $e');
      print('📁 Stack trace: ${StackTrace.current}');
      throw 'Failed to get reward image URL: $e';
    }
  }
}
