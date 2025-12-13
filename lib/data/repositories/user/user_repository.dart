import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

import '../../../utils/formatters/formatter.dart';
import '../achievement/achievement_repository.dart';
import '../achievement/user_achievement_repository.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _uuid = const Uuid();

  // Declare Users as a variable
  final String _usersCollection = "users";
  final String _profileImagesFolder = "profile_images";

  // 头像缓存 - 改为公共访问
  final Map<String, String> profileImageCache = {};

  AchievementRepository get _achievementRepository {
    try {
      return Get.find<AchievementRepository>();
    } catch (e) {
      // 如果找不到，就创建一个
      return Get.put(AchievementRepository());
    }
  }

  UserAchievementRepository get _userAchievementRepository {
    try {
      return Get.find<UserAchievementRepository>();
    } catch (e) {
      // 如果找不到，就创建一个
      return Get.put(UserAchievementRepository());
    }
  }

  // ========== 排行榜相关方法 ==========

  /// 获取月度排行榜用户流（包含完整头像URL）
  Stream<List<UserModel>> getMonthlyLeaderboardUsersStream() {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'user')
        .where('monthlyRewardPoint', isGreaterThan: 0)
        .orderBy('monthlyRewardPoint', descending: true)
        .limit(20)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();

      return await _convertUsersProfileImgToUrl(users);
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in monthly leaderboard stream: $error');
      }
      return <UserModel>[];
    });
  }

  /// 获取总排行榜用户流（包含完整头像URL）
  Stream<List<UserModel>> getAllTimeLeaderboardUsersStream() {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'user')
        .where('totalRewardPoint', isGreaterThan: 0)
        .orderBy('totalRewardPoint', descending: true)
        .limit(20)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      // 【修改】使用新方法转换
      return await _convertUsersProfileImgToUrl(users);
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in all-time leaderboard stream: $error');
      }
      return <UserModel>[];
    });
  }

  /// 获取按字段排序的用户流（通用方法，包含完整头像URL）
  Stream<List<UserModel>> getUsersSortedByField({
    required String field,
    int limit = 20,
    bool descending = true,
    int minValue = 0,
  }) {
    final query = _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'user')
        .orderBy(field, descending: descending)
        .limit(limit);

    return query
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return <UserModel>[];
      }

      final users = snapshot.docs.map((doc) {
        return UserModel.fromSnapshot(doc);
      }).toList();

      // 【修改】使用新方法转换
      return await _convertUsersProfileImgToUrl(users);
    }).handleError((error) {
      if (error is FirebaseException) {
        print('🔥 Firebase 错误详情:');
        print('   - code: ${error.code}');
        print('   - message: ${error.message}');
      }

      if (kDebugMode) {
        print('Error in users sorted by $field stream: $error');
      }

      return <UserModel>[];
    });
  }

  /// 获取当前用户流（包含完整头像URL）
  Stream<UserModel> getCurrentUserStream(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((documentSnapshot) async {
      if (documentSnapshot.exists) {
        final user = UserModel.fromSnapshot(documentSnapshot);
        // 【修改】使用新方法转换
        return await _convertProfileImgToUrl(user);
      } else {
        return UserModel.empty();
      }
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in current user stream: $error');
      }
      return UserModel.empty();
    });
  }

  /// 为任意用户列表加载头像（支持 Staff 和 User）
  Future<void> loadProfileImagesForUsers(List<UserModel> users) async {
    for (final user in users) {
      if (user.profileImg != null && user.profileImg!.isNotEmpty) {
        await _loadProfileImage(user.profileImg!);
      }
    }
  }

  /// 加载单个头像到缓存 - 私有方法
  Future<void> _loadProfileImage(String fileName) async {
    print("Attempting to load profile image: $fileName");

    // Check if already cached
    if (profileImageCache.containsKey(fileName)) {
      print("Image already cached: $fileName");
      return;
    }

    try {
      final path = '$_profileImagesFolder/$fileName';
      print("Fetching download URL from path: $path");

      final ref = _storage.ref().child(path);
      final downloadUrl = await ref.getDownloadURL();

      profileImageCache[fileName] = downloadUrl;
      print("Successfully cached image: $fileName -> $downloadUrl");

    } catch (e) {
      if (kDebugMode) {
        print('Failed to load profile image $fileName: $e');
      }
    }
  }

  /// 获取头像URL - 公共方法，优先从缓存获取
  Future<String?> getProfileImageUrl(String fileName) async {
    try {
      if (fileName.isEmpty) {
        return null;
      }

      // 【新增】如果已经是完整 URL，直接返回
      if (fileName.startsWith('http')) {
        return fileName;
      }

      // 先检查缓存
      if (profileImageCache.containsKey(fileName)) {
        return profileImageCache[fileName];
      }

      // 缓存中没有，从存储加载
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);
      final downloadUrl = await ref.getDownloadURL();

      // 存入缓存
      profileImageCache[fileName] = downloadUrl;

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        if (kDebugMode) {
          print('Profile image not found: $fileName, using default');
        }
        // 【修改】返回 null 而不是抛出异常
        return null;
      }
      // 【修改】其他 Firebase 错误也返回 null
      if (kDebugMode) {
        print('Firebase error getting profile image: ${e.message ?? e.code}');
      }
      return null;
    } catch (e) {
      // 【修改】捕获所有其他错误，返回 null
      if (kDebugMode) {
        print('Error getting profile image URL: $e');
      }
      return null;
    }
  }

  /// 从缓存获取头像URL（同步方法）
  String? getCachedProfileImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;

    // 【新增】如果已经是完整 URL，直接返回
    if (fileName.startsWith('http')) {
      return fileName;
    }

    return profileImageCache[fileName];
  }


  // ========== 用户管理方法 ==========

  /// Get username and profile image URL for a user
  Future<UserModel> getUserProfileData(String userId) async {
    try {
      final documentSnapshot = await _db
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        final user = UserModel.fromSnapshot(documentSnapshot);
        // 【修改】使用新方法转换
        return await _convertProfileImgToUrl(user);
      } else {
        return UserModel.empty()..copyWith(userId: userId);
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to get user profile data: $e';
    }
  }

  /// Get batch user profile data for multiple users
  Future<Map<String, UserModel>> getUsersProfileData(Set<String> userIds) async {
    try {
      print('=== START: Getting Users Profile Data ===');
      print('Requested user IDs count: ${userIds.length}');

      if (userIds.isEmpty) {
        return {};
      }

      final querySnapshot = await _db
          .collection(_usersCollection)
          .where(FieldPath.documentId, whereIn: userIds.toList())
          .get();

      print('Firestore query completed, found ${querySnapshot.docs.length} users');

      final Map<String, UserModel> result = {};

      for (final doc in querySnapshot.docs) {
        print('Processing user: ${doc.id}');
        final user = UserModel.fromSnapshot(doc);

        final convertedUser = await _convertProfileImgToUrl(user);
        result[doc.id] = convertedUser;

        print('✅ User ${doc.id} added with profileImg: ${convertedUser.profileImg}');
      }

      // Add default data for missing users
      final missingUsers = userIds.where((userId) => !result.containsKey(userId)).toList();
      for (final userId in missingUsers) {
        result[userId] = UserModel.empty()..copyWith(userId: userId);
      }

      return result;
    } on FirebaseException catch (e) {
      print('❌ FirebaseException: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack trace: $stackTrace');
      throw 'Failed to get users profile data: $e';
    }
  }

  /// Save user record to Firestore
  Future<void> saveUserRecord(UserModel user) async {
    try {
      print('📝 Saving user record for: ${user.userId}');

      // 🆕 Get FCM token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          print('🔔 FCM Token obtained: ${fcmToken.substring(0, 20)}...');
        }
      } catch (e) {
        print('⚠️ Failed to get FCM token: $e');
      }

      // Prepare user data
      Map<String, dynamic> userData = user.toJson();

      // 🆕 Include fcmTokens in initial data
      if (fcmToken != null) {
        userData['fcmTokens'] = [fcmToken];
        print('✅ FCM token included in user data');
      }

      userData['createdAt'] = FieldValue.serverTimestamp();

      // Save user to Firestore (complete record with fcmTokens)
      await _db.collection(_usersCollection).doc(user.userId).set(userData);
      print('✅ User record saved to Firestore');

      // Initialize user achievements for new users
      await _initializeUserAchievements(user.userId);
      print('✅ User achievements initialized');

    } on FirebaseException catch (e) {
      print('❌ Firebase error saving user record: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      print('❌ Error saving user record: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Initialize all user achievements for a new user
  /// Creates user achievement records for ALL achievements (including inactive)
  Future<void> _initializeUserAchievements(String userId) async {
    try {
      print('🎯 Initializing user achievements for user: $userId');

      // Get ALL achievements (including inactive) - don't filter by status
      final allAchievements = await _achievementRepository.getAllAchievements();

      print('📊 Found ${allAchievements.length} achievements to initialize');

      await _userAchievementRepository.batchCreateUserAchievements(
        userId: userId,
        achievements: allAchievements,
      );
    } catch (e) {
      // Don't throw error - let user creation succeed even if achievements fail
      print('⚠️ Warning: Failed to initialize user achievements: $e');
      if (kDebugMode) {
        print('Stack trace: ${StackTrace.current}');
      }
    }
  }

  /// Fetch user details from Firestore
  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db
          .collection(_usersCollection)
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .get();

      if (documentSnapshot.exists) {
        final user = UserModel.fromSnapshot(documentSnapshot);
        // 【修改】使用新方法转换
        return await _convertProfileImgToUrl(user);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Stream of user details - 实时更新
  Stream<UserModel> getUserDetailsStream(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((documentSnapshot) async {
      if (documentSnapshot.exists) {
        final user = UserModel.fromSnapshot(documentSnapshot);
        // 使用新方法转换
        return await _convertProfileImgToUrl(user);
      } else {
        return UserModel.empty();
      }
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in user stream: $error');
      }
      return UserModel.empty();
    });
  }

  /// Update user details in Firestore
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      print('phone number: ${updatedUser.phoneNo}');

      Map<String, dynamic> userData = updatedUser.toJson();

      await _db.collection(_usersCollection).doc(updatedUser.userId).update(userData);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update single field in Firestore
  Future<void> updateStringField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection(_usersCollection)
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
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

  /// Check if username is available for new users (simpler query)
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      // If docs is empty, username is available
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking username availability: $e');
      }
      throw 'Failed to check username availability: $e';
    }
  }

  /// Check if phone number is unique
  Future<bool> isPhoneNumberUnique(String phoneNumber, String currentUserId) async {
    try {
      // 🆕 先转换为国际格式再查询
      final internationalPhoneNo = FFormatter.formatPhoneToInternational(phoneNumber);

      if (kDebugMode) {
        print('🔍 Checking phone number uniqueness:');
        print('   - Input: $phoneNumber');
        print('   - International format: $internationalPhoneNo');
        print('   - Current user ID: $currentUserId');
      }

      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('phoneNo', isEqualTo: internationalPhoneNo) // 使用国际格式查询
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .limit(1)
          .get();

      final isUnique = querySnapshot.docs.isEmpty;

      if (kDebugMode) {
        print('   - Is unique: $isUnique');
        if (!isUnique) {
          print('   - Conflicting user: ${querySnapshot.docs.first.id}');
        }
      }

      return isUnique;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking phone number uniqueness: $e');
      }
      throw 'Failed to check phone number: $e';
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _db.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        return false;
      }

      // 🆕 Check if user document has essential fields (not just fcmTokens)
      final data = doc.data();
      final hasEssentialFields = data != null &&
          data.containsKey('username') &&
          data.containsKey('email') &&
          data.containsKey('role');

      if (kDebugMode) {
        print('📊 User document exists: ${doc.exists}');
        print('📊 Has essential fields: $hasEssentialFields');
        if (data != null) {
          print('📊 Document keys: ${data.keys.toList()}');
        }
      }

      return hasEssentialFields;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Error checking if user exists: ${e.message}');
      }
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if user exists: $e');
      }
      throw 'Failed to check if user exists: $e';
    }
  }

  /// Update user's email verification status in Firestore
  Future<void> updateEmailVerificationStatus(String userId, bool isVerified) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        'isVerified': isVerified,
      });

      if (kDebugMode) {
        print('✅ Updated email verification status for user $userId: $isVerified');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ Error updating email verification status: ${e.message}');
      }
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating email verification status: $e');
      }
      throw 'Failed to update email verification status: $e';
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(File imageFile, String userId, String? oldFileName) async {
    try {
      // 生成唯一的文件名
      final fileName = '${_uuid.v4()}.webp';

      // 存储路径：profile_images/{fileName}
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      // 删除旧的头像（如果不是默认头像）
      if (oldFileName != null && oldFileName.isNotEmpty) {
        await deleteProfileImage(oldFileName);
      }

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/webp',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'profile_image',
            'fileName': fileName,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 更新用户记录中的图片文件名
      await _db.collection(_usersCollection).doc(userId).update({
        'profileImg': fileName, // 只存储文件名
      });

      // 更新缓存
      profileImageCache[fileName] = downloadUrl;

      if (kDebugMode) {
        print('Profile image uploaded successfully:');
        print('File Name: $fileName');
        print('Storage Path: $path');
        print('Download URL: $downloadUrl');
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw 'Failed to upload image: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImageWeb(Uint8List imageBytes, String userId, String? oldFileName) async {
    try {
      // 生成唯一的文件名
      final fileName = '${_uuid.v4()}.webp';

      // 存储路径：profile_images/{fileName}
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      // 删除旧的头像
      if (oldFileName != null && oldFileName.isNotEmpty) {
        await deleteProfileImage(oldFileName);
      }

      // 使用 putData 上传字节数据
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/webp',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'profile_image',
            'fileName': fileName,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 更新用户记录中的图片文件名
      await _db.collection(_usersCollection).doc(userId).update({
        'profileImg': fileName,
      });

      // 更新缓存
      profileImageCache[fileName] = downloadUrl;

      return fileName;
    } on FirebaseException catch (e) {
      throw 'Failed to upload image: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String fileName) async {
    try {
      if (fileName.isEmpty) return;

      // 构建完整的存储路径
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      await ref.delete();

      // 从缓存中移除
      profileImageCache.remove(fileName);

      if (kDebugMode) {
        print('Deleted profile image: $path');
      }
    } on FirebaseException catch (e) {
      // If file doesn't exist, ignore the error
      if (e.code == 'object-not-found') {
        if (kDebugMode) {
          print('Profile image not found, skipping deletion');
        }
      } else {
        if (kDebugMode) {
          print('Failed to delete profile image: ${e.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting profile image: $e');
      }
    }
  }

  /// Remove user record from Firestore
  Future<void> removeUserRecord(String userId) async {
    try {
      // Get user data first to delete profile image
      final userDoc = await _db.collection(_usersCollection).doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final profileImage = userData?['profileImg'] as String?;

        if (profileImage != null && profileImage.isNotEmpty) {
          await deleteProfileImage(profileImage);
        }
      }

      // Delete user document
      await _db.collection(_usersCollection).doc(userId).delete();
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get user's current reward points
  Future<int> getUserPoints(String userId) async {
    try {
      final snapshot = await _db.collection(_usersCollection).doc(userId).get();
      if (!snapshot.exists) {
        throw 'User not found';
      }
      return snapshot.data()?['rewardPoint'] ?? 0;
    } catch (e) {
      throw 'Failed to fetch user points: $e';
    }
  }

  /// Deduct points from user
  Future<void> deductPoints(String userId, int points) async {
    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection(_usersCollection).doc(userId);
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw 'User not found';
        }

        final currentPoints = snapshot.data()?['rewardPoint'] ?? 0;

        if (currentPoints < points) {
          throw 'Insufficient points';
        }

        transaction.update(userRef, {
          'rewardPoint': FieldValue.increment(-points),
          'updatedAt': FieldValue.serverTimestamp(), // 添加更新时间戳
        });
      });
    } catch (e) {
      throw 'Failed to deduct points: $e';
    }
  }

  /// Add points to user
  Future<void> addPoints(String userId, int points) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        'rewardPoint': FieldValue.increment(points),
        'totalRewardPoint': FieldValue.increment(points),
      });
    } catch (e) {
      throw 'Failed to add points: $e';
    }
  }

  /// Stream of user's reward points
  Stream<int> getUserPointsStream(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['rewardPoint'] ?? 0);
  }

  /// Check if user has sufficient points
  Future<bool> hasSufficientPoints(String userId, int requiredPoints) async {
    try {
      final currentPoints = await getUserPoints(userId);
      return currentPoints >= requiredPoints;
    } catch (e) {
      throw 'Failed to check user points: $e';
    }
  }

  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .where('role', isEqualTo: 'user')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final user = UserModel.fromSnapshot(querySnapshot.docs.first);
      // 【修改】使用新方法转换
      return await _convertProfileImgToUrl(user);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to get user by username: $e';
    }
  }

  /// Get user by ID (different from fetchUserDetails which uses auth user)
  Future<UserModel> fetchOtherUserDetails(String userId) async {
    try {
      final documentSnapshot = await _db
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        final user = UserModel.fromSnapshot(documentSnapshot);
        // 【修改】使用新方法转换
        return await _convertProfileImgToUrl(user);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to fetch user details: $e';
    }
  }

  /// Search users by username (partial match)
  Future<List<UserModel>> searchUsersByUsername(String query) async {
    try {
      if (query.isEmpty) return [];

      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('role', isEqualTo: 'user')
          .orderBy('username')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(10)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList();

      // 【修改】使用新方法转换
      return await _convertUsersProfileImgToUrl(users);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to search users: $e';
    }
  }

  /// 【新增】将用户的 profileImg 从文件名转换为完整 URL
  Future<UserModel> _convertProfileImgToUrl(UserModel user) async {
    if (user.profileImg == null || user.profileImg!.isEmpty) {
      return user;
    }

    // 如果已经是完整 URL，直接返回
    if (user.profileImg!.startsWith('http')) {
      return user;
    }

    // 获取完整 URL
    final url = await getProfileImageUrl(user.profileImg!);

    // 返回更新后的用户对象
    return user.copyWith(profileImg: url ?? user.profileImg);
  }

  /// 【新增】批量转换用户列表的 profileImg
  Future<List<UserModel>> _convertUsersProfileImgToUrl(List<UserModel> users) async {
    final List<UserModel> result = [];

    for (final user in users) {
      final convertedUser = await _convertProfileImgToUrl(user);
      result.add(convertedUser);
    }

    return result;
  }
}