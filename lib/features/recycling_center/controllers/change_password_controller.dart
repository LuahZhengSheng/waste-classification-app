import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  static ChangePasswordController get instance => Get.find();

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final hideCurrentPassword = true.obs;
  final hideNewPassword = true.obs;
  final hideConfirmPassword = true.obs;

  final authRepository = Get.find<AuthenticationRepository>();

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Change Password with re-authentication
  Future<void> changePassword() async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) return;

      // Check internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection',
        );
        return;
      }

      // Show loading
      FFullScreenLoader.openLoadingDialog(
        'Changing your password...',
        FImages.docerAnimation,
      );

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        FFullScreenLoader.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'No user is currently logged in',
        );
        return;
      }

      // Get user email
      final email = user.email;
      if (email == null || email.isEmpty) {
        FFullScreenLoader.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User email not found',
        );
        return;
      }

      // Step 1: Re-authenticate with current password
      try {
        await authRepository.reAuthenticateWithEmailAndPassword(
          email,
          currentPasswordController.text.trim(),
        );
      } catch (e) {
        FFullScreenLoader.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Authentication Failed',
          message: 'Current password is incorrect',
        );
        return;
      }

      // Step 2: Update to new password
      await user.updatePassword(newPasswordController.text.trim());

      // Stop loading
      FFullScreenLoader.stopLoading();

      // Show success message
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Your password has been changed successfully',
      );

      // Clear form and go back
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.back();
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }
}
