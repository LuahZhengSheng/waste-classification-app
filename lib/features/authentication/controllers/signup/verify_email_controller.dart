import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/common/widgets/success_screen/success_screen.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/user/user_repository.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  /// Send Email Whenever Verify Screen appears & Set Timer for data redirect.
  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  /// Send Email Verification Link
  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      FLoaders.successSnackBar(
          title: 'Email Send',
          message: 'Please check your inbox and verify your email.');
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update user's isVerified field in Firestore when email is verified
  Future<void> _updateUserVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        // 获取 UserRepository
        final userRepository = Get.find<UserRepository>();

        // 更新用户的 isVerified 字段
        await userRepository.updateStringField({
          'isVerified': true,
        });

        print('✅ User verification status updated in Firestore');
      }
    } catch (e) {
      print('❌ Failed to update user verification status: $e');
      // 不抛出异常，因为验证状态更新失败不应该阻止用户继续
    }
  }

  /// Timer to automatically redirect on Email Verification
  void setTimerForAutoRedirect() {
    Timer.periodic(
      const Duration(seconds: 1),
        (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) {
          // 更新 Firestore 中的 isVerified 字段
          await _updateUserVerificationStatus();

          timer.cancel();
          Get.off(
            () => SuccessScreen(
              image: FImages.successfullyRegisterAnimation,
              title: FTexts.yourAccountCreatedTitle,
              subTitle: FTexts.yourAccountCreatedSubTitle,
              onPressed: () => AuthenticationRepository.instance.screenRedirect(),
            ),
          );
        }
      },
    );
  }

  /// Manually Check if Email Verified
  Future<void> checkEmailVerificationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      Get.off(
        () => SuccessScreen(
          image: FImages.successfullyRegisterAnimation,
          title: FTexts.yourAccountCreatedTitle,
          subTitle: FTexts.yourAccountCreatedSubTitle,
          onPressed: () => AuthenticationRepository.instance.screenRedirect(),
        ),
      );
    }
  }
}
