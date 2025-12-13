import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/features/recycling_center/models/recycling_center_staff_model.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';

class RecyclingCenterStaffRepository extends GetxController {
  static RecyclingCenterStaffRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  final String _usersCollection = 'users';
  final String _profileImagesFolder = "profile_images";

  /// Get staff stream (center_staff role) with profile images
  Stream<List<RecyclingCenterStaff>> getStaffStream() {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'center_staff')
        .orderBy('username')
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return <RecyclingCenterStaff>[];
      }

      final staffList = snapshot.docs
          .map((doc) => RecyclingCenterStaff.fromSnapshot(doc))
          .toList();

      // 使用 UserRepository 加载头像
      final userRepo = Get.find<UserRepository>();
      await userRepo.loadProfileImagesForUsers(staffList.map((staff) => UserModel(
        userId: staff.userId,
        username: staff.username,
        email: staff.email,
        profileImg: staff.profileImg,
        role: 'center_staff',
        isActive: staff.isActive,
        isVerified: staff.isVerified,
        isBanned: staff.isBanned,
        joinDate: staff.joinDate,
        phoneNo: staff.phoneNo,
        gender: staff.gender,
        rewardPoint: 0,
        monthlyRewardPoint: 0,
        totalRewardPoint: 0,
      )).toList());

      return staffList;
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in staff stream: $error');
      }
      return <RecyclingCenterStaff>[];
    });
  }

  /// Get staff by ID
  Future<RecyclingCenterStaff?> getStaffById(String staffId) async {
    try {
      final docSnapshot = await _db.collection(_usersCollection).doc(staffId).get();

      if (docSnapshot.exists) {
        return RecyclingCenterStaff.fromSnapshot(docSnapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to get staff: $e';
    }
  }

  /// Update staff details
  Future<void> updateStaffDetails(RecyclingCenterStaff updatedStaff) async {
    try {
      Map<String, dynamic> userData = updatedStaff.toJson();

      await _db.collection(_usersCollection).doc(updatedStaff.userId).update(userData);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update last password reset time
  Future<void> updateLastPasswordResetTime(String staffId) async {
    try {
      await _db.collection(_usersCollection).doc(staffId).update({
        'lastPasswordResetTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update password reset time: $e';
    }
  }

  /// Ban staff
  Future<void> banStaff(RecyclingCenterStaff staff) async {
    try {
      await _db.collection(_usersCollection).doc(staff.userId).update({
        'isBanned': true,
        'isActive': false,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to ban staff: $e';
    }
  }

  /// Recover staff
  Future<void> recoverStaff(RecyclingCenterStaff staff) async {
    try {
      await _db.collection(_usersCollection).doc(staff.userId).update({
        'isBanned': false,
        'isActive': true,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to recover staff: $e';
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

  /// Create staff account
  Future<void> createStaff(RecyclingCenterStaff staff) async {
    try {
      await _db
          .collection(_usersCollection)
          .doc(staff.userId)
          .set(staff.toJson());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to create staff: $e';
    }
  }

  /// 上传头像到 Firebase Storage
  Future<String> uploadProfileImageWeb(Uint8List imageBytes, String userId, String? oldFileName) async {
    try {
      final fileName = '${_uuid.v4()}.webp';
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      if (oldFileName != null && oldFileName.isNotEmpty) {
        await deleteProfileImage(oldFileName);
      }

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

      await _db.collection(_usersCollection).doc(userId).update({
        'profileImg': fileName,
      });

      // 更新 UserRepository 的缓存
      final userRepo = Get.find<UserRepository>();
      userRepo.profileImageCache[fileName] = downloadUrl;

      return fileName;
    } on FirebaseException catch (e) {
      throw 'Failed to upload image: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// 从头像存储中删除图片
  Future<void> deleteProfileImage(String fileName) async {
    try {
      if (fileName.isEmpty) return;

      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      await ref.delete();

      // 从 UserRepository 缓存中移除
      final userRepo = Get.find<UserRepository>();
      userRepo.profileImageCache.remove(fileName);
    } on FirebaseException catch (e) {
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

  /// Get staff by center ID with stream
  Stream<List<RecyclingCenterStaff>> getStaffByCenterIdStream(String centerId) {
    return _db
        .collection(_usersCollection)
        .where('centerId', isEqualTo: centerId)
        .where('role', isEqualTo: 'center_staff')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingCenterStaff.fromSnapshot(doc))
        .toList());
  }
}