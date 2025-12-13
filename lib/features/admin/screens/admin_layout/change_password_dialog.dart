import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/validators/validation.dart';

import '../../../../utils/popups/loaders.dart';
import '../../controllers/admin_layout/change_password_controller.dart';


class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _controller = Get.put(ChangePasswordController());

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isVerificationStep = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Dialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.lock,
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Divider(color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Content
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isVerificationStep) ...[
                    // Verification Step
                    Text(
                      'Verify Current Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Please enter your current password to proceed with changing your password.',
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: FSizes.spaceBtwItems),

                    // Current Password Field
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: !_isCurrentPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        labelStyle: TextStyle(
                          color: dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                        ),
                        prefixIcon: Icon(
                          Iconsax.lock,
                          color: dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isCurrentPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                            color: dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      validator: (value) => FValidator.validateEmptyText('Current Password', value),
                    ),
                  ] else ...[
                    // Change Password Step
                    Text(
                      'Set New Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Please enter your new password. Make sure it is strong and secure.',
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: FSizes.spaceBtwItems),

                    // New Password Field
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(
                          color: dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                        ),
                        prefixIcon: Icon(
                          Iconsax.lock,
                          color: dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                            color: dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      validator: (value) => FValidator.validatePassword(value),
                    ),
                    const SizedBox(height: FSizes.spaceBtwItems),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: TextStyle(
                          color: dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                        ),
                        prefixIcon: Icon(
                          Iconsax.lock,
                          color: dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                            color: dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      validator: (value) => FValidator.validateConfirmPassword(
                        value,
                        _newPasswordController.text,
                      ),
                    ),
                    const SizedBox(height: FSizes.spaceBtwItems),

                    // Password Requirements
                    Container(
                      padding: const EdgeInsets.all(FSizes.md),
                      decoration: BoxDecoration(
                        color: (dark ? FColors.adminDarkInfo : FColors.adminLightInfo)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        border: Border.all(
                          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                                size: 18,
                              ),
                              const SizedBox(width: FSizes.sm),
                              Text(
                                'Password Requirements:',
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: FSizes.xs),
                          _buildRequirement('At least 8 characters', dark),
                          _buildRequirement('At least one uppercase letter', dark),
                          _buildRequirement('At least one lowercase letter', dark),
                          _buildRequirement('At least one number', dark),
                          _buildRequirement('At least one special character', dark),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (!_isVerificationStep) {
                        setState(() {
                          _isVerificationStep = true;
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        });
                      } else {
                        Get.back();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: Text(
                      _isVerificationStep ? 'Cancel' : 'Back',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      _isVerificationStep ? 'Verify' : 'Change Password',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(left: FSizes.md, top: FSizes.xs),
      child: Row(
        children: [
          Icon(
            Iconsax.tick_circle,
            size: 14,
            color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
          ),
          const SizedBox(width: FSizes.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isVerificationStep) {
      // Verify current password
      final isValid = await _controller.verifyCurrentPassword(
        _currentPasswordController.text,
      );

      if (isValid && mounted) {
        setState(() {
          _isVerificationStep = false;
        });
      }
    } else {
      // Change password
      final success = await _controller.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      // ✅ 先检查 mounted，再关闭 Dialog，最后显示 SnackBar
      if (success) {
        if (!mounted) return;

        // ✅ 先关闭 Dialog
        Get.back();

        // ✅ 延迟一下再显示 SnackBar，确保 Dialog 已关闭
        // await Future.delayed(const Duration(milliseconds: 300));

        FLoaders.successSnackBar(
          title: 'Success',
          message: 'Password changed successfully',
        );
      }
    }
  }
}