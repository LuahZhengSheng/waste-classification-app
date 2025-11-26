import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Dialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300, // 设置最大宽度为300
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                Iconsax.logout,
                size: 48,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
              const SizedBox(height: FSizes.md),

              // Title
              Text(
                'Confirm Logout',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: FSizes.sm),

              // Message
              Text(
                'Are you sure you want to logout from the admin panel?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
              const SizedBox(height: FSizes.lg),

              // Logout Button (在上面)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FSizes.sm),

              // Cancel Button (在下面)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: dark ? FColors.adminDarkText : FColors.adminLightText,
                    side: BorderSide(
                      color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}