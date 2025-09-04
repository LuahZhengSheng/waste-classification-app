import 'package:flutter/material.dart';
import 'package:fyp/features/authentication/controllers/signup/signup_controller.dart';
import 'package:fyp/features/authentication/screens/signup/widgets/terms_conditions_checkbox.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FSignupForm extends StatelessWidget {
  const FSignupForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          // Row(
          //   children: [
          //     Expanded(
          //       child: TextFormField(
          //         controller: controller.firstName,
          //         validator: (value) => FValidator.validateEmptyText('First name', value),
          //         expands: false,
          //         decoration: const InputDecoration(
          //           labelText: FTexts.firstName,
          //           prefixIcon: Icon(Iconsax.user),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: FSizes.spaceBtwInputFields),
          //     Expanded(
          //       child: TextFormField(
          //         controller: controller.lastName,
          //         validator: (value) => FValidator.validateEmptyText('Last name', value),
          //         expands: false,
          //         decoration: const InputDecoration(
          //           labelText: FTexts.lastName,
          //           prefixIcon: Icon(Iconsax.user),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: FSizes.spaceBtwInputFields),

          /// Username
          TextFormField(
            controller: controller.username,
            validator: (value) => FValidator.validateEmptyText('Username', value),
            decoration: const InputDecoration(
              labelText: FTexts.username,
              prefixIcon: Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          /// Email
          TextFormField(
            controller: controller.email,
            validator: (value) => FValidator.validateEmail(value),
            decoration: const InputDecoration(
              labelText: FTexts.email,
              prefixIcon: Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // /// Phone Number
          // TextFormField(
          //   controller: controller.phoneNumber,
          //   validator: (value) => FValidator.validatePhoneNumber(value),
          //   decoration: const InputDecoration(
          //     labelText: FTexts.phoneNo,
          //     prefixIcon: Icon(Iconsax.call),
          //   ),
          // ),
          // const SizedBox(height: FSizes.spaceBtwInputFields),

          /// Password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) => FValidator.validatePassword(value),
              obscureText: controller.hidePassword.value,
              expands: false,
              decoration: InputDecoration(
                labelText: FTexts.password,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                  icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                ),
              ),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          /// Password
          Obx(
                () => TextFormField(
              controller: controller.password,
              validator: (value) => FValidator.validatePassword(value),
              obscureText: controller.hidePassword.value,
              expands: false,
              decoration: InputDecoration(
                labelText: FTexts.confirmPassword,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                  icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                ),
              ),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          /// Terms&Conditions Checkbox
          const FTermsAndConditionCheckbox(),
          const SizedBox(height: FSizes.spaceBtwSections),

          /// Sign Up Button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => controller.signup(),
                  child: const Text(FTexts.createAccount))),
        ],
      ),
    );
  }
}

