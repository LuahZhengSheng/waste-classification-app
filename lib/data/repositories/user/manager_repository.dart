import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

import '../../../features/admin/models/admin_model.dart';

class ManagerRepository extends GetxController {
  static ManagerRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  /// Get managers stream (community_manager, event_manager, reward_manager)
  Stream<List<AdminModel>> getManagersStream() {
    return _db
        .collection(_usersCollection)
        .where('role', whereIn: ['community_manager', 'event_manager', 'reward_manager'])
        .orderBy('username')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AdminModel.fromSnapshot(doc))
        .toList())
        .handleError((error) {
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
        return AdminModel.fromSnapshot(docSnapshot);
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
}