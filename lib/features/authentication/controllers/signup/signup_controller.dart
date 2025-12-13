import 'package:flutter/cupertino.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/features/authentication/screens/signup/verify_email.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables
  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  /// 🆕 Repository instance
  final _userRepository = Get.put(UserRepository());

  /// -- SIGNUP
  void signup() async {
    try {
      // Start Loading
      FFullScreenLoader.openLoadingDialog(
          'We are processing your information...',
          FImages.docerAnimation
      );

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
      if (!signupFormKey.currentState!.validate()) {
        FFullScreenLoader.stopLoading();
        return;
      }

      // Password Confirmation
      if (password.text != confirmPassword.text) {
        FLoaders.warningSnackBar(
          title: 'Passwords Do Not Match',
          message: 'Please make sure your passwords match.',
        );
        FFullScreenLoader.stopLoading();
        return;
      }

      // Privacy Policy Check
      if (!privacyPolicy.value) {
        FLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message: 'In order to create account, you must have to read and accept the Privacy Policy & Terms of Use.',
        );
        FFullScreenLoader.stopLoading();
        return;
      }

      // Check if username already exists
      final isUsernameAvailable = await _checkUsernameAvailability(username.text.trim());

      if (!isUsernameAvailable) {
        FFullScreenLoader.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Username Taken',
          message: 'This username is already in use. Please choose a different username.',
        );
        return;
      }

      // Register user in the Firebase Authentication
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Save Authenticated user data in the Firebase Firestore
      final newUser = UserModel(
        userId: userCredential.user!.uid,
        username: username.text.trim(),
        email: email.text.trim(),
        role: 'user', // Default role for new users
        isVerified: false,
        isActive: true,
        isBanned: false,
        joinDate: DateTime.now(),
        rewardPoint: 0,
        monthlyRewardPoint: 0,
        totalRewardPoint: 0,
        totalWeightRecycled: 0.0,
        totalRecyclingActivities: 0,
        totalEmissionReduced: 0.0,
        notifications: [],
      );

      await _userRepository.saveUserRecord(newUser);

      // Show Success Message
      FLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your account has been created! Verify email to continue.',
      );

      FFullScreenLoader.stopLoading();

      // Move to Verify Email Screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim()));

    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(title: 'Signup Failed', message: e.toString());
    }
  }

  /// Check if username is available
  Future<bool> _checkUsernameAvailability(String username) async {
    try {
      // Use empty string as currentUserId since this is a new user
      final isUnique = await _userRepository.isUsernameAvailable(username);
      return isUnique;
    } catch (e) {
      print('Error checking username availability: $e');
      // If check fails, assume username is available to not block signup
      return true;
    }
  }

  /// Check username availability in real-time (for UI feedback)
  Future<bool> checkUsernameAvailabilityRealtime(String username) async {
    if (username.isEmpty || username.length < 3) {
      return true; // Don't check if username is too short
    }

    try {
      final isUnique = await _userRepository.isUsernameUnique(username, '');
      return isUnique;
    } catch (e) {
      print('Error checking username availability: $e');
      return true;
    }
  }
}
