import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:fyp/features/personalization/screens/profile/widgets/re_authenticate_user_login_form.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;

  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  /// Fetch user record
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user record from any Registration Provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials != null) {
        // Map data to UserModel
        final user = UserModel(
          userId: userCredentials.user!.uid,
          username: userCredentials.user!.displayName ?? '',
          email: userCredentials.user!.email ?? '',
          phoneNo: userCredentials.user!.phoneNumber ?? '',
          profileImg: userCredentials.user!.photoURL ?? '',
          isActive: true,
          isVerified: userCredentials.user!.emailVerified,
          isBanned: false,
          joinDate: DateTime.now(),
          notifications: [],
          rewardPoint: 0,
          monthlyRewardPoint: 0,
          totalRewardPoint: 0,
          role: 'user',
        );

        // Save user data
        await userRepository.saveUserRecord(user);
      }
    } catch (e) {
      FLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  /// Delete Account Warning
  void deleteAccountWarningPopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.danger,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: FSizes.md),

              // Title
              Text(
                'Delete Account',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: FSizes.sm),

              // Warning Message
              Text(
                'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
                style: Get.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.xs),

              Text(
                'You will need to verify your password to proceed.',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.lg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        deleteUserAccount(); // Proceed to delete
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Delete User Account
  void deleteUserAccount() async {
    try {
      FFullScreenLoader.openLoadingDialog('Processing', FImages.docerAnimation);

      /// First re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;

      if (provider.isNotEmpty) {
        // Re Verify Auth Email
        if (provider == 'google.com') {
          // For Google users, re-authenticate directly
          await auth.signInWithGoogle();
          FFullScreenLoader.stopLoading();
          await _proceedToDelete();
        } else if (provider == 'password') {
          // For email/password users, show re-auth form
          FFullScreenLoader.stopLoading();
          Get.to(
                () => ReAuthLoginForm(
              onVerifySuccess: _proceedToDelete,
            ),
          );
        }
      }
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Proceed to delete account after successful re-authentication
  Future<void> _proceedToDelete() async {
    try {
      FFullScreenLoader.openLoadingDialog(
        'Deleting account...',
        FImages.docerAnimation,
      );

      // Delete account
      await AuthenticationRepository.instance.deleteAccount();

      FFullScreenLoader.stopLoading();

      // Show success message
      FLoaders.successSnackBar(
        title: 'Account Deleted',
        message: 'Your account has been permanently deleted.',
      );

      // Wait a bit for user to see the message
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to login screen
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete account: $e',
      );
    }
  }

  @override
  void onClose() {
    verifyEmail.dispose();
    verifyPassword.dispose();
    super.onClose();
  }
}
