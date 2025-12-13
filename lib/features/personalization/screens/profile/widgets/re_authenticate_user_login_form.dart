import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/popups/loaders.dart';

class ReAuthLoginForm extends StatelessWidget {
  const ReAuthLoginForm({
    super.key,
    required this.onVerifySuccess,
  });

  final VoidCallback onVerifySuccess;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    final passwordController = TextEditingController();
    final hidePassword = true.obs;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: dark ? FColors.communityDarkBackground : FColors.light,
      appBar: FAppBar(
        title: const Text('Verify Your Identity'),
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
                // Info Message
                Container(
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.info_circle,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Text(
                          'Please enter your current password to continue.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                /// Password Field
                Obx(
                      () => TextFormField(
                    controller: passwordController,
                    validator: (value) =>
                        FValidator.validateEmptyText('Password', value),
                    obscureText: hidePassword.value,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed: () =>
                        hidePassword.value = !hidePassword.value,
                        icon: Icon(
                          hidePassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                /// Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await _verifyPassword(
                          passwordController.text.trim(),
                          onVerifySuccess,
                        );
                      }
                    },
                    child: const Text('Verify'),
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwItems),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPassword(
      String password,
      VoidCallback onSuccess,
      ) async {
    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get current user email
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        Get.back(); // Close loading
        FLoaders.errorSnackBar(title: 'Error', message: 'User not found');
        return;
      }

      // Re-authenticate with password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Close loading
      Get.back();

      // Close this form
      Get.back();

      // Execute success callback
      onSuccess();
    } catch (e) {
      // Close loading
      Get.back();
      FLoaders.errorSnackBar(title: 'Authentication Failed', message: 'Invalid password. Please try again.');
    }
  }
}
