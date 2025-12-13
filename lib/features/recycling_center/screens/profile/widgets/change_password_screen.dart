import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final hideNewPassword = true.obs;
    final hideConfirmPassword = true.obs;
    final formKey = GlobalKey<FormState>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.communityDarkBackground : FColors.light,
      appBar: FAppBar(
        title: const Text('Change Password'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: FColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    border: Border.all(
                      color: FColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(FSizes.sm),
                        decoration: BoxDecoration(
                          color: FColors.primary,
                          borderRadius:
                              BorderRadius.circular(FSizes.cardRadiusSm),
                        ),
                        child: const Icon(
                          Iconsax.security_safe,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: FSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Your Account',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: FColors.primary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose a strong password with at least 8 characters',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        dark ? FColors.grey : FColors.darkGrey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // New Password Label
                Text(
                  'New Password',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: FSizes.sm),

                // New Password Field
                Obx(
                  () => TextFormField(
                    controller: newPasswordController,
                    obscureText: hideNewPassword.value,
                    validator: (value) => FValidator.validatePassword(value),
                    decoration: InputDecoration(
                      labelText: 'Enter new password',
                      prefixIcon: const Icon(Iconsax.lock),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            hideNewPassword.value = !hideNewPassword.value,
                        icon: Icon(
                          hideNewPassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwInputFields),

                // Confirm Password Label
                Text(
                  'Confirm New Password',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: FSizes.sm),

                // Confirm Password Field
                Obx(
                  () => TextFormField(
                    controller: confirmPasswordController,
                    obscureText: hideConfirmPassword.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Re-enter new password',
                      prefixIcon: const Icon(Iconsax.lock_1),
                      suffixIcon: IconButton(
                        onPressed: () => hideConfirmPassword.value =
                            !hideConfirmPassword.value,
                        icon: Icon(
                          hideConfirmPassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.darkContainer
                        : FColors.light.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: FSizes.sm),
                      _buildRequirement('At least 8 characters'),
                      _buildRequirement('Contains uppercase and lowercase'),
                      _buildRequirement('Contains numbers'),
                      _buildRequirement('Contains special characters'),
                    ],
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updatePassword(
                      formKey,
                      newPasswordController,
                      confirmPasswordController,
                    ),
                    child: const Text('Change Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Iconsax.tick_circle,
            size: 16,
            color: FColors.success,
          ),
          const SizedBox(width: FSizes.xs),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePassword(
    GlobalKey<FormState> formKey,
    TextEditingController newPasswordController,
    TextEditingController confirmPasswordController,
  ) async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) return;

      // Show loading
      FFullScreenLoader.openLoadingDialog(
        'Updating password...',
        FImages.docerAnimation,
      );

      // Check internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.stopLoading();
        return;
      }

      // Get current user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        FFullScreenLoader.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'No user is currently logged in',
        );
        return;
      }

      // Update password
      await firebaseUser.updatePassword(newPasswordController.text.trim());

      FFullScreenLoader.stopLoading();

      // Clear form
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.back();

      // Show success message
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Your password has been changed successfully',
      );
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }
}
