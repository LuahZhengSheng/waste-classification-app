import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

import '../../../features/admin/models/admin_model.dart';

class ManagerRepository extends GetxController {
  static ManagerRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // 获取 UserRepository 实例来共享缓存
  final UserRepository _userRepo = Get.find<UserRepository>();

  /// Get managers stream (community_manager, event_manager, reward_manager)
  Stream<List<AdminModel>> getManagersStream() {
    return _db
        .collection(_usersCollection)
        .where('role', whereIn: ['community_manager', 'event_manager', 'reward_manager'])
        .orderBy('username')
        .snapshots()
        .asyncMap((snapshot) async {
      final managers = snapshot.docs
          .map((doc) => AdminModel.fromSnapshot(doc))
          .toList();

      // 加载所有管理员的头像URL
      await _loadProfileImagesForManagers(managers);
      return managers;
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in managers stream: $error');
      }
      return <AdminModel>[];
    });
  }

  /// Get manager by ID
  Future<AdminModel?> getManagerById(String managerId) async {
    try {
      final docSnapshot = await _db.collection(_usersCollection).doc(managerId).get();

      if (docSnapshot.exists) {
        final manager = AdminModel.fromSnapshot(docSnapshot);
        // 加载管理员的头像URL
        if (manager.profileImg != null && manager.profileImg!.isNotEmpty) {
          await _loadProfileImage(manager.profileImg!);
        }
        return manager;
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to get manager: $e';
    }
  }

  /// Update manager details and return old data
  Future<AdminModel?> updateManagerDetails(AdminModel manager) async {
    try {
      // Get old data before update
      final oldManager = await getManagerById(manager.userId);

      await _db
          .collection(_usersCollection)
          .doc(manager.userId)
          .update(manager.toJson());

      return oldManager;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to update manager: $e';
    }
  }

  Future<void> updateLastPasswordResetTime(String managerId) async {
    try {
      await _db.collection(_usersCollection).doc(managerId).update({
        'lastPasswordResetTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update password reset time: $e';
    }
  }

  /// Ban manager
  Future<void> banManager(AdminModel manager) async {
    try {
      await _db.collection(_usersCollection).doc(manager.userId).update({
        'isBanned': true,
        'isActive': false,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to ban manager: $e';
    }
  }

  /// Recover manager
  Future<void> recoverManager(AdminModel manager) async {
    try {
      await _db.collection(_usersCollection).doc(manager.userId).update({
        'isBanned': false,
        'isActive': true,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to recover manager: $e';
    }
  }

  /// Check if username is unique
  Future<bool> isUsernameUnique(String username, String currentUserId) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check username: $e';
    }
  }

  /// Check if email is unique
  Future<bool> isEmailUnique(String email) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check email: $e';
    }
  }

  /// Create manager account
  Future<void> createManager(AdminModel manager) async {
    try {
      await _db
          .collection(_usersCollection)
          .doc(manager.userId)
          .set(manager.toJson());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to create manager: $e';
    }
  }

  // ========== 头像缓存相关方法 ==========

  /// 为管理员列表加载头像
  Future<void> _loadProfileImagesForManagers(List<AdminModel> managers) async {
    print("==> Start loading profile images for managers. Total managers: ${managers.length}");

    for (final manager in managers) {
      print("Processing manager: ${manager.userId}, profileImg: ${manager.profileImg}");

      if (manager.profileImg != null && manager.profileImg!.isNotEmpty) {
        print("Loading profile image for manager: ${manager.userId} -> ${manager.profileImg}");
        await _loadProfileImage(manager.profileImg!);
      } else {
        print("Manager ${manager.userId} has no profileImg, skipping.");
      }
    }

    print("==> Finished loading profile images for managers.");
  }

  /// 加载单个头像到缓存 - 使用 UserRepository 的缓存
  Future<void> _loadProfileImage(String fileName) async {
    print("ManagerRepository: Attempting to load profile image: $fileName");

    // 使用 UserRepository 的缓存系统
    if (_userRepo.profileImageCache.containsKey(fileName)) {
      print("ManagerRepository: Image already cached in UserRepository: $fileName");
      return;
    }

    try {
      // 使用 UserRepository 的方法获取头像URL
      final downloadUrl = await _userRepo.getProfileImageUrl(fileName);

      print("ManagerRepository: Successfully loaded image: $fileName -> $downloadUrl");

    } catch (e) {
      if (kDebugMode) {
        print('ManagerRepository: Failed to load profile image $fileName: $e');
      }
    }
  }

  /// 获取缓存的头像URL - 使用 UserRepository 的缓存
  String? getCachedProfileImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;
    return _userRepo.getCachedProfileImageUrl(fileName);
  }

  /// 上传管理员头像 - 使用 UserRepository 的方法
  Future<String> uploadProfileImageWeb(Uint8List imageBytes, String userId, String? oldFileName) async {
    try {
      return await _userRepo.uploadProfileImageWeb(imageBytes, userId, oldFileName);
    } catch (e) {
      throw 'Failed to upload manager profile image: $e';
    }
  }

  /// 删除管理员头像 - 使用 UserRepository 的方法
  Future<void> deleteProfileImage(String fileName) async {
    try {
      await _userRepo.deleteProfileImage(fileName);
    } catch (e) {
      throw 'Failed to delete manager profile image: $e';
    }
  }
}