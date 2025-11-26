import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/admin_login/admin_login_controller.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminLoginController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                _buildLogoSection(dark),

                // Login Form Card
                Container(
                  padding: const EdgeInsets.all(FSizes.xl),
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: controller.adminLoginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Text
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          ),
                        ),
                        const SizedBox(height: FSizes.xs),
                        Text(
                          'Sign in to admin dashboard',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: FSizes.spaceBtwSections),

                        // Email Field
                        _buildEmailField(controller, dark, context),
                        const SizedBox(height: FSizes.spaceBtwInputFields),

                        // Password Field
                        _buildPasswordField(controller, dark, context),
                        const SizedBox(height: FSizes.spaceBtwSections),

                        // Block Status or Sign In Button
                        Obx(() {
                          if (controller.isBlocked.value) {
                            return _buildBlockedStatus(controller, dark);
                          } else {
                            return _buildSignInButton(controller, dark);
                          }
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool dark) {
    return Column(
      children: [
        // Logo with gradient background
        Image.asset(
          dark ? FImages.darkAppLogo : FImages.lightAppLogo,
          height: 220,
          width: 220,
        ),
      ],
    );
  }

  Widget _buildEmailField(AdminLoginController controller, bool dark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        TextFormField(
          controller: controller.email,
          validator: FValidator.validateEmail,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: dark
                ? FColors.adminDarkSurfaceVariant
                : FColors.adminLightSurfaceVariant,
            prefixIcon: Icon(
              Iconsax.sms,
              color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon,
            ),
            hintText: 'admin@example.com',
            hintStyle: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(AdminLoginController controller, bool dark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Obx(() => TextFormField(
          controller: controller.password,
          validator: (value) => FValidator.validateEmptyText('Password', value),
          obscureText: controller.hidePassword.value,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: dark
                ? FColors.adminDarkSurfaceVariant
                : FColors.adminLightSurfaceVariant,
            prefixIcon: Icon(
              Iconsax.lock,
              color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye,
                color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon,
              ),
              onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
            ),
            hintText: 'Enter your password',
            hintStyle: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 2,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSignInButton(AdminLoginController controller, bool dark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => controller.adminLogin(),
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedStatus(AdminLoginController controller, bool dark) {
    return Container(
      child: Obx(() => Text(
        'Your account is blocked. Try again in ${controller.remainingBlockTime.value}.',
        style: TextStyle(
          fontSize: 14,
          color: dark ? FColors.adminDarkError : FColors.adminLightError,
        ),
        textAlign: TextAlign.center,
      )),
    );
  }
}