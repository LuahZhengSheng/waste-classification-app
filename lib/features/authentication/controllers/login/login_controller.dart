import 'package:flutter/cupertino.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/features/personalization/controllers/user_controller.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/widgets/dialogs/email_verification_dialog.dart';
import '../../../../data/repositories/user/user_repository.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// Variables
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());
  final _userRepository = Get.put(UserRepository());

  /// -- Email and Password SignIn
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      FFullScreenLoader.openLoadingDialog('Logging you in...', FImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.stopLoading();
        FLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection.',
        );
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        FFullScreenLoader.stopLoading();
        return;
      }

      // Check user status (banned/inactive) BEFORE login
      final statusCheck = await AuthenticationRepository.instance.checkUserStatus(email.text.trim());

      if (!statusCheck['canLogin']) {
        FFullScreenLoader.stopLoading();

        String title = 'Login Failed';
        if (statusCheck['reason'] == 'banned') {
          title = 'Account Suspended';
        } else if (statusCheck['reason'] == 'inactive') {
          title = 'Account Inactive';
        }

        FLoaders.errorSnackBar(
          title: title,
          message: statusCheck['message'],
        );
        return;
      }

      // Login user using Email & Password Authentication
      final userCredentials = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Check email verification using Firebase Auth
      final isVerified = userCredentials.user?.emailVerified ?? false;

      if (!isVerified) {
        FFullScreenLoader.stopLoading();

        // Show verification warning with option to resend
        await EmailVerificationDialog.show(
          context: Get.context!,
          onResend: () async {
            try {
              await AuthenticationRepository.instance.sendEmailVerification();
              FLoaders.successSnackBar(
                title: 'Email Sent',
                message: 'Verification email has been sent. Please check your inbox.',
              );
            } catch (e) {
              FLoaders.errorSnackBar(
                title: 'Error',
                message: 'Failed to send verification email: ${e.toString()}',
              );
            }
          },
        );

        // Logout user since they can't proceed
        await AuthenticationRepository.instance.logout();
        return;
      }

      // Update Firestore isVerified field if email is verified
      if (isVerified && userCredentials.user != null) {
        try {
          await _userRepository.updateEmailVerificationStatus(
            userCredentials.user!.uid,
            true,
          );
        } catch (e) {
          // Don't block login if Firestore update fails
          print('⚠️ Warning: Failed to update Firestore verification status: $e');
        }
      }

      // Remove Loader
      FFullScreenLoader.stopLoading();

      // Redirect to appropriate screen
      AuthenticationRepository.instance.screenRedirect();

      FLoaders.successSnackBar(
        title: 'Welcome Back!',
        message: 'You have successfully logged in.',
      );

    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(title: 'Login Failed', message: e.toString());
    }
  }

  /// -- Google SignIn Authentication
  Future<void> googleSignIn() async {
    try {
      // Start Loading
      FFullScreenLoader.openLoadingDialog('Logging you in...', FImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.stopLoading();
        FLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection.',
        );
        return;
      }

      // Google Authentication
      final userCredentials = await AuthenticationRepository.instance.signInWithGoogle();

      if (userCredentials == null) {
        FFullScreenLoader.stopLoading();
        return;
      }

      final user = userCredentials.user!;

      // Check if user exists in Firestore
      final userExists = await _userRepository.userExists(user.uid);

      print('userExist1: $userExists');

      if (!userExists) {
        // New user - Save user record to Firestore directly (no status check needed)
        await userController.saveUserRecord(userCredentials);
        print('userExist2: $userExists');
      } else {
        print('🔍 Existing Google user, checking status...');

        // Existing user - Check status first
        final statusCheck = await AuthenticationRepository.instance.checkUserStatus(user.email!);

        print('🔍 Existing Google user, checking status...2');

        if (!statusCheck['canLogin']) {
          // Logout immediately if banned/inactive
          await AuthenticationRepository.instance.logout();

          FFullScreenLoader.stopLoading();

          String title = 'Login Failed';
          if (statusCheck['reason'] == 'banned') {
            title = 'Account Suspended';
          } else if (statusCheck['reason'] == 'inactive') {
            title = 'Account Inactive';
          }

          FLoaders.errorSnackBar(
            title: title,
            message: statusCheck['message'],
          );
          return;
        }

        // Update isVerified if needed
        try {
          await _userRepository.updateEmailVerificationStatus(user.uid, true);
        } catch (e) {
          print('⚠️ Warning: Failed to update Firestore verification status: $e');
        }
      }

      FFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();

      FLoaders.successSnackBar(
        title: !userExists ? 'Welcome!' : 'Welcome Back!',
        message: !userExists
            ? 'Your account has been created! Welcome to our app.'
            : 'You have successfully logged in with Google.',
      );

    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(title: 'Google Sign-In Failed', message: e.toString());
    }
  }

  /// -- Facebook SignIn Authentication
  Future<void> facebookSignIn() async {
    try {
      print('🔵 Starting Facebook Sign-In...');

      FFullScreenLoader.openLoadingDialog('Logging you in...', FImages.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.stopLoading();
        print('🔴 No internet connection');
        FLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection.',
        );
        return;
      }

      final userCredentials = await AuthenticationRepository.instance.signInWithFacebook();

      if (userCredentials == null) {
        FFullScreenLoader.stopLoading();
        print('🔴 Facebook sign-in returned null');
        FLoaders.warningSnackBar(
          title: 'Login Cancelled',
          message: 'Facebook sign-in was cancelled.',
        );
        return;
      }

      print('✅ Facebook Sign-In successful!');

      final user = userCredentials.user!;

      // Check if user exists in Firestore
      final userExists = await _userRepository.userExists(user.uid);

      if (!userExists) {
        // New user - Save user record to Firestore directly (no status check needed)
        await userController.saveUserRecord(userCredentials);

      } else {
        // Existing user - Check status first
        final statusCheck = await AuthenticationRepository.instance.checkUserStatus(user.email!);

        if (!statusCheck['canLogin']) {
          // Logout immediately if banned/inactive
          await AuthenticationRepository.instance.logout();

          FFullScreenLoader.stopLoading();

          String title = 'Login Failed';
          if (statusCheck['reason'] == 'banned') {
            title = 'Account Suspended';
          } else if (statusCheck['reason'] == 'inactive') {
            title = 'Account Inactive';
          }

          FLoaders.errorSnackBar(
            title: title,
            message: statusCheck['message'],
          );
          return;
        }

        // Update isVerified if needed
        try {
          await _userRepository.updateEmailVerificationStatus(user.uid, true);
        } catch (e) {
          print('⚠️ Warning: Failed to update Firestore verification status: $e');
        }
      }

      FFullScreenLoader.stopLoading();

      AuthenticationRepository.instance.screenRedirect();

      FLoaders.successSnackBar(
        title: !userExists ? 'Welcome!' : 'Welcome Back!',
        message: !userExists
            ? 'Your account has been created! Welcome to our app.'
            : 'You have successfully logged in with Facebook.',
      );

    } catch (e) {
      FFullScreenLoader.stopLoading();
      print('🔴 Error: $e');
      FLoaders.errorSnackBar(title: 'Facebook Sign-In Failed', message: e.toString());
    }
  }
}
