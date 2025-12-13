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
      isLoading.value = true; // ✅ 只用这个
      // FLoaders.showLoading('Verifying password...'); // ❌ 移除

      final user = _authRepository.authUser;
      if (user == null) {
        // FLoaders.stopLoading(); // ❌ 移除
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not authenticated',
        );
        return false;
      }

      await _authRepository.reAuthenticateWithEmailAndPassword(
        user.email!,
        currentPassword,
      );

      // FLoaders.stopLoading(); // ❌ 移除
      return true;
    } catch (e) {
      // FLoaders.stopLoading(); // ❌ 移除
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
      isLoading.value = true; // ✅ 只用这个
      // FLoaders.showLoading('Changing password...'); // ❌ 移除

      final user = _authRepository.authUser;
      if (user == null) {
        // FLoaders.stopLoading(); // ❌ 移除
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not authenticated',
        );
        return false;
      }

      await _authRepository.reAuthenticateWithEmailAndPassword(
        user.email!,
        currentPassword,
      );

      await user.updatePassword(newPassword);

      Get.back();

      // FLoaders.stopLoading(); // ❌ 移除
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Password changed successfully',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      // FLoaders.stopLoading(); // ❌ 移除

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
      // FLoaders.stopLoading(); // ❌ 移除
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