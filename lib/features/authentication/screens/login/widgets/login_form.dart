import 'package:flutter/material.dart';
import 'package:fyp/features/authentication/controllers/login/login_controller.dart';
import 'package:fyp/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:fyp/features/authentication/screens/signup/signup.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';

class FLoginForm extends StatelessWidget {
  const FLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FSizes.spaceBtwSections),
        child: Column(
          children: [
            /// Email
            TextFormField(
              controller: controller.email,
              validator: (value) => FValidator.validateEmail(value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.direct_right),
                  labelText: FTexts.email),
            ),
            const SizedBox(height: FSizes.spaceBtwInputFields),

            /// Password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) =>
                    FValidator.validateEmptyText('Password', value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  labelText: FTexts.password,
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value =
                        !controller.hidePassword.value,
                    icon: Icon(controller.hidePassword.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye),
                  ),
                ),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwInputFields / 2),

            /// Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// Forget Password
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: const Text(
                    FTexts.forgetPassword,
                    style: TextStyle(color: FColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            /// Sign In Button
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => controller.emailAndPasswordSignIn(),
                    child: const Text(FTexts.signIn))),
            const SizedBox(height: FSizes.spaceBtwItems),

            /// Create Account Button
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => Get.to(const SignupScreen()),
                    child: Text(
                      FTexts.createAccount,
                      style: TextStyle(color: FColors.primary),
                    ))),
          ],
        ),
      ),
    );
  }
}
