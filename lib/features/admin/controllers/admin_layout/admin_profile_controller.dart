import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/data/services/profile_image/profile_image_service.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

import 'topbar_controller.dart';

class AdminProfileController extends GetxController {
  static AdminProfileController get instance => Get.find();

  final UserRepository _userRepository = Get.find<UserRepository>();
  final RxBool isLoading = false.obs;

  Future<void> updateProfile(
      UserModel user,
      Uint8List? pendingImageBytes,
      bool pendingDeleteImage,
      ) async {
    try {
      isLoading.value = true;
      FLoaders.showLoading('Updating profile...');

      UserModel updatedUser = user;

      // Handle image deletion
      if (pendingDeleteImage && user.profileImg != null && user.profileImg!.isNotEmpty) {
        await ProfileImageService.deleteProfileImage(
          userId: user.userId,
          profileImg: user.profileImg,
        );
        updatedUser = user.copyWith(profileImg: '');
      }
      // Handle image upload
      else if (pendingImageBytes != null) {
        final fileName = await ProfileImageService.uploadProfileImage(
          imageBytes: pendingImageBytes,
          userId: user.userId,
          currentProfileImg: user.profileImg,
        );

        if (fileName != null) {
          updatedUser = user.copyWith(profileImg: fileName);
        }
      }

      // Update user profile
      await _userRepository.updateUserDetails(updatedUser);

      // Refresh topbar data
      final topBarController = Get.find<AdminTopBarController>();
      await topBarController.refreshUserData();

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Profile updated successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update profile: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }
}

