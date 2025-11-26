import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';

class UpdateConfirmationDialog extends StatelessWidget {
  final bool dark;
  final List<String> changeDetails;
  final int registeredCount;

  const UpdateConfirmationDialog({
    super.key,
    required this.dark,
    required this.changeDetails,
    required this.registeredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Iconsax.notification,
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Confirm Event Update',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: FSizes.lg),

            // 修改内容
            Text(
              'Changes made:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),

            Wrap(
              spacing: FSizes.xs,
              children: changeDetails.map((change) => Chip(
                label: Text(change),
                backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              )).toList(),
            ),

            const SizedBox(height: FSizes.lg),

            // 通知选项
            Text(
              'Do you want to send update notifications to $registeredCount registered users?',
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),

            const SizedBox(height: FSizes.lg),

            // 按钮
            Row(
              children: [
                // 不发送通知
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dark ? FColors.adminDarkText : FColors.adminLightText,
                      side: BorderSide(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                    ),
                    child: Text('Update Only'),
                  ),
                ),
                const SizedBox(width: FSizes.md),

                // 发送通知
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.notification, size: 16),
                        const SizedBox(width: FSizes.xs),
                        Text('Send Notifications'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}