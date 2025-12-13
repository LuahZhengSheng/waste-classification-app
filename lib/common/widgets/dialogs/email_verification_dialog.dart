// lib/common/widgets/dialogs/email_verification_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

class EmailVerificationDialog {
  static Future<bool?> show({
    required BuildContext context,
    required VoidCallback onResend,
  }) async {
    return await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: _EmailVerificationDialogContent(onResend: onResend),
      ),
      barrierDismissible: true,
    );
  }
}

class _EmailVerificationDialogContent extends StatelessWidget {
  final VoidCallback onResend;

  const _EmailVerificationDialogContent({
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: dark ? FColors.darkSurface : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon
          _buildHeader(context, dark),

          // Content
          _buildContent(context, dark),

          // Action buttons
          _buildActions(context, dark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool dark) {
    return Container(
      width: double.infinity, // 🆕 占满整个宽度
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
            FColors.primary.withOpacity(0.8),
            FColors.primary,
          ]
              : [
            FColors.primary,
            FColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(FSizes.borderRadiusLg),
          topRight: Radius.circular(FSizes.borderRadiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🆕 确保不会拉伸高度
        crossAxisAlignment: CrossAxisAlignment.center, // 🆕 内容居中
        children: [
          // Icon container with animation
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.sms,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Title
          Text(
            'Email Not Verified',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool dark) {
    return Padding(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      child: Column(
        children: [
          // Message
          Text(
            'Please verify your email address to continue.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: dark ? FColors.darkText : FColors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Info box
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.info.withOpacity(0.1)
                  : FColors.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              border: Border.all(
                color: FColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: FColors.info,
                  size: 20,
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: Text(
                    'Check your inbox for the verification link.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? FColors.darkText : FColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark
            ? FColors.darkContainer.withOpacity(0.3)
            : FColors.lightContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(FSizes.borderRadiusLg),
          bottomRight: Radius.circular(FSizes.borderRadiusLg),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(result: false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dark ? FColors.darkText : FColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.spaceBtwItems),

          // Resend button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                onResend();
                Get.back(result: true);
              },
              label: const Text('Resend Email'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                backgroundColor: FColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
