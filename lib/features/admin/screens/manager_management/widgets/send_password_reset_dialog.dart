import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../controllers/manager_management/manager_management_controller.dart';
import '../../../models/admin_model.dart';

class SendPasswordResetDialog extends StatelessWidget {
  final AdminModel manager;

  const SendPasswordResetDialog({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return AlertDialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkInfo : FColors.adminLightInfo).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.send_2,
              color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
              size: 24,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Text(
            'Send Password Reset',
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send password reset link to this manager?',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Username:', manager.username, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Email:', manager.email, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Role:', _formatRole(manager.role), dark),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkInfo : FColors.adminLightInfo).withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                  size: 20,
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password reset link will be sent to manager\'s email.',
                        style: TextStyle(
                          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        'Cooldown: 10 minutes between requests.',
                        style: TextStyle(
                          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            final controller = ManagerManagementController.instance;
            await controller.sendPasswordResetLink(manager);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
          ),
          child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: FSizes.xs),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'community_manager':
        return 'Community Manager';
      case 'event_manager':
        return 'Event Manager';
      case 'reward_manager':
        return 'Reward Manager';
      default:
        return role;
    }
  }
}