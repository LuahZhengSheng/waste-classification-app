import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

class ChangePasswordController extends GetxController {
  static ChangePasswordController get instance => Get.find();

  final AuthenticationRepository _authRepository = Get.find<AuthenticationRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final RxBool isLoading = false.obs;

  Future<bool> verifyCurrentPassword(String currentPassword) async {
    try {
      isLoading.value = true;
      FLoaders.showLoading('Verifying password...');

      final user = _authRepository.authUser;
      if (user == null) {
        FLoaders.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not authenticated',
        );
        return false;
      }

      // Re-authenticate user with current password
      await _authRepository.reAuthenticateWithEmailAndPassword(
        user.email!,
        currentPassword,
      );

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Password verified successfully',
      );
      return true;
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Verification Failed',
        message: 'Current password is incorrect',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      FLoaders.showLoading('Changing password...');

      final user = _authRepository.authUser;
      if (user == null) {
        FLoaders.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not authenticated',
        );
        return false;
      }

      // Re-authenticate user before changing password
      await _authRepository.reAuthenticateWithEmailAndPassword(
        user.email!,
        currentPassword,
      );

      // Change password
      await user.updatePassword(newPassword);

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Password changed successfully',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      FLoaders.stopLoading();

      String errorMessage = 'Failed to change password';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again before changing password';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      FLoaders.errorSnackBar(
        title: 'Error',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to change password: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}