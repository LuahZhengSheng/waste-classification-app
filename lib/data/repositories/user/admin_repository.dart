import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';
import 'package:get/get.dart';

import '../../../features/admin/models/admin_model.dart';

class AdminRepository extends GetxController {
  static AdminRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final String _usersCollection = "users";

  Future<bool?> getAuthEmailVerifiedStatus(String email) async {
    try {
      final docRef = await _db.collection('adminAuthQueries').add({
        'email': email.toLowerCase(),
        'type': 'getEmailVerifiedStatus',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 等待 Cloud Function 处理完成
      bool isProcessed = false;
      int attempts = 0;
      const maxAttempts = 30; // 最多等待30次
      const delay = Duration(milliseconds: 500);

      while (!isProcessed && attempts < maxAttempts) {
        await Future.delayed(delay);
        final snapshot = await docRef.get();
        final data = snapshot.data();

        isProcessed = data?['processed'] == true;
        attempts++;

        if (isProcessed) {
          return data?['emailVerified'] as bool?;
        }
      }

      // 超时未处理完成
      if (kDebugMode) {
        print('Cloud Function processing timeout');
      }
      return null;

    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth email verified status: $e');
      }
      return null;
    }
  }

  /// Get admin user by email with auth verification status
  Future<AdminModel?> getAdminByEmail(String email) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final admin = AdminModel.fromSnapshot(doc);

      // 获取 Auth 中的 emailVerified 状态
      final authEmailVerified = await getAuthEmailVerifiedStatus(email);

      print('auth: $authEmailVerified');

      // 如果获取到 Auth 状态，更新 admin 对象
      if (authEmailVerified != null) {
        return admin.copyWith(isVerified: authEmailVerified);
      }

      return admin;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting admin by email: $e');
      }
      throw 'Failed to get admin user: $e';
    }
  }

  /// Get admin user by ID with auth verification status
  Future<AdminModel?> getAdminById(String userId) async {
    try {
      final documentSnapshot = await _db
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!documentSnapshot.exists) {
        return null;
      }

      final admin = AdminModel.fromSnapshot(documentSnapshot);

      // 获取 Auth 中的 emailVerified 状态
      final authEmailVerified = await getAuthEmailVerifiedStatus(admin.email);

      // 如果获取到 Auth 状态，更新 admin 对象
      if (authEmailVerified != null) {
        return admin.copyWith(isVerified: authEmailVerified);
      }

      return admin;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting admin by ID: $e');
      }
      throw 'Failed to get admin user: $e';
    }
  }

  /// Update login attempt count and timestamp
  Future<void> updateLoginAttempt(
      String userId,
      int attemptCount,
      DateTime timestamp,
      ) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        'loginAttemptCount': attemptCount,
        'lastFailedLogin': Timestamp.fromDate(timestamp),
      });

      if (kDebugMode) {
        print('Updated login attempts for user $userId: $attemptCount');
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating login attempt: $e');
      }
      throw 'Failed to update login attempt: $e';
    }
  }

  /// Reset login attempts to 0
  Future<void> resetLoginAttempts(String userId) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        'loginAttemptCount': 0,
        'lastFailedLogin': null,
      });

      if (kDebugMode) {
        print('Reset login attempts for user $userId');
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting login attempts: $e');
      }
      throw 'Failed to reset login attempts: $e';
    }
  }

  /// Check if user has admin privileges
  Future<bool> hasAdminPrivileges(String userId) async {
    try {
      final admin = await getAdminById(userId);
      if (admin == null) return false;

      const validRoles = ['admin', 'community_manager', 'reward_manager', 'event_manager'];
      return validRoles.contains(admin.role) &&
          admin.isActive &&
          admin.isVerified &&
          !admin.isBanned;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking admin privileges: $e');
      }
      return false;
    }
  }

  /// Stream of admin user data
  Stream<AdminModel?> getAdminStream(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return AdminModel.fromSnapshot(doc);
      }
      return null;
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in admin stream: $error');
      }
      return null;
    });
  }

  /// Update admin profile
  Future<void> updateAdminProfile(AdminModel admin) async {
    try {
      await _db
          .collection(_usersCollection)
          .doc(admin.userId)
          .update(admin.toJson());

      if (kDebugMode) {
        print('Updated admin profile for user ${admin.userId}');
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating admin profile: $e');
      }
      throw 'Failed to update admin profile: $e';
    }
  }

  /// Ban/Unban admin user
  Future<void> updateBanStatus(String userId, bool isBanned) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        'isBanned': isBanned,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Updated ban status for user $userId: $isBanned');
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating ban status: $e');
      }
      throw 'Failed to update ban status: $e';
    }
  }

  /// Activate/Deactivate admin user
  Future<void> updateActiveStatus(String userId, bool isActive) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Updated active status for user $userId: $isActive');
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating active status: $e');
      }
      throw 'Failed to update active status: $e';
    }
  }
}