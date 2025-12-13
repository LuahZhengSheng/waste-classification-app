// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:fyp/features/recycling_center/models/recycling_center_staff_model.dart';
// import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
// import 'package:fyp/utils/exceptions/format_exceptions.dart';
// import 'package:fyp/utils/exceptions/platform_exceptions.dart';
//
// class RecyclingCenterStaffRepository extends GetxController {
//   static RecyclingCenterStaffRepository get instance => Get.find();
//
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final String _usersCollection = 'users';
//
//   /// Get staff by ID
//   Future<RecyclingCenterStaff?> getStaffById(String staffId) async {
//     try {
//       if (staffId.isEmpty) return null;
//
//       final docSnapshot = await _db
//           .collection(_usersCollection)
//           .doc(staffId)
//           .get();
//
//       if (docSnapshot.exists) {
//         return RecyclingCenterStaff.fromSnapshot(docSnapshot);
//       } else {
//         return null;
//       }
//     } on FirebaseException catch (e) {
//       print('Firebase error getting staff by ID: $e');
//       throw FFirebaseException(e.code).message;
//     } on FormatException catch (_) {
//       throw const FFormatException();
//     } on FPlatformException catch (e) {
//       throw FPlatformException(e.code).message;
//     } catch (e) {
//       print('Unexpected error getting staff by ID: $e');
//       return null;
//     }
//   }
//
//   /// Get staff by center ID
//   Future<List<RecyclingCenterStaff>> getStaffByCenterId(String centerId) async {
//     try {
//       final querySnapshot = await _db
//           .collection(_usersCollection)
//           .where('centerId', isEqualTo: centerId)
//           .where('role', isEqualTo: 'center_staff')
//           .get();
//
//       return querySnapshot.docs
//           .map((doc) => RecyclingCenterStaff.fromSnapshot(doc))
//           .toList();
//     } catch (e) {
//       print('Error getting staff by center ID: $e');
//       return [];
//     }
//   }
//
//   /// Get staff by center ID with stream
//   Stream<List<RecyclingCenterStaff>> getStaffByCenterIdStream(String centerId) {
//     return _db
//         .collection(_usersCollection)
//         .where('centerId', isEqualTo: centerId)
//         .where('role', isEqualTo: 'center_staff')
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => RecyclingCenterStaff.fromSnapshot(doc))
//         .toList());
//   }
//
//   /// Create new staff member
//   Future<void> createStaff(RecyclingCenterStaff staff) async {
//     try {
//       await _db
//           .collection(_usersCollection)
//           .doc(staff.userId)
//           .set(staff.toJson());
//     } on FirebaseException catch (e) {
//       throw FFirebaseException(e.code).message;
//     } catch (e) {
//       throw 'Failed to create staff: $e';
//     }
//   }
//
//   /// Update staff member
//   Future<void> updateStaff(RecyclingCenterStaff staff) async {
//     try {
//       await _db
//           .collection(_usersCollection)
//           .doc(staff.userId)
//           .update(staff.toJson());
//     } on FirebaseException catch (e) {
//       throw FFirebaseException(e.code).message;
//     } catch (e) {
//       throw 'Failed to update staff: $e';
//     }
//   }
//
//   /// Delete staff member
//   Future<void> deleteStaff(String staffId) async {
//     try {
//       await _db
//           .collection(_usersCollection)
//           .doc(staffId)
//           .delete();
//     } on FirebaseException catch (e) {
//       throw FFirebaseException(e.code).message;
//     } catch (e) {
//       throw 'Failed to delete staff: $e';
//     }
//   }
//
//   /// Ban staff member
//   Future<void> banStaff(String staffId) async {
//     try {
//       await _db
//           .collection(_usersCollection)
//           .doc(staffId)
//           .update({
//         'isBanned': true,
//         'isActive': false,
//       });
//     } on FirebaseException catch (e) {
//       throw FFirebaseException(e.code).message;
//     } catch (e) {
//       throw 'Failed to ban staff: $e';
//     }
//   }
//
//   /// Unban staff member
//   Future<void> unbanStaff(String staffId) async {
//     try {
//       await _db
//           .collection(_usersCollection)
//           .doc(staffId)
//           .update({
//         'isBanned': false,
//         'isActive': true,
//       });
//     } on FirebaseException catch (e) {
//       throw FFirebaseException(e.code).message;
//     } catch (e) {
//       throw 'Failed to unban staff: $e';
//     }
//   }
// }