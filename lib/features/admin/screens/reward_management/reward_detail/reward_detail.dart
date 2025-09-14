import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../reward_redemption/models/redemption_model.dart';
import '../../../../reward_redemption/models/reward_model.dart';
import '../../../controllers/reward_management/reward_detail_controller.dart';

class AdminRewardDetailScreen extends StatelessWidget {
  final RewardModel reward;

  const AdminRewardDetailScreen({
    super.key,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardDetailsController(reward: reward));
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Reward Details',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Status Toggle Button
          Obx(() => Container(
            margin: const EdgeInsets.only(right: FSizes.md),
            child: _buildStatusToggleButton(controller, dark),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reward Overview Card
            _buildOverviewCard(controller, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Statistics Row
            _buildStatisticsRow(controller, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Redemptions Section
            _buildRedemptionsSection(controller, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggleButton(RewardDetailsController controller, bool dark) {
    final computedStatus = controller.getComputedStatus();
    final isActive = controller.reward.value.status == 'active';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        gradient: LinearGradient(
          colors: isActive
              ? [
            dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
            (dark ? FColors.adminDarkWarning : FColors.adminLightWarning).withOpacity(0.8),
          ]
              : [
            dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
            (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive
                ? (dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
            ).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          onTap: () => _showStatusToggleDialog(controller, dark),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.lg,
              vertical: FSizes.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Iconsax.pause_circle : Iconsax.play_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  isActive ? 'Deactivate' : 'Activate',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(RewardDetailsController controller, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status Badge
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(FSizes.cardRadiusLg),
                topRight: Radius.circular(FSizes.cardRadiusLg),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.reward.value.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: FSizes.sm),
                      Text(
                        'Reward ID: ${controller.reward.value.rewardId}',
                        style: TextStyle(
                          color: dark
                              ? FColors.adminDarkTextMuted
                              : FColors.adminLightTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(controller.getComputedStatus(), dark),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (controller.reward.value.description.isNotEmpty) ...[
                  _buildDetailSection(
                    'Description',
                    controller.reward.value.description,
                    dark,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                ],

                // Points and Dates Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Points Required',
                        '${controller.reward.value.pointsNeeded}',
                        Iconsax.star,
                        dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        dark,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: _buildInfoCard(
                        'Valid Until',
                        _formatDate(controller.reward.value.validUntil),
                        Iconsax.calendar,
                        controller.reward.value.isExpired
                            ? (dark ? FColors.adminDarkError : FColors.adminLightError)
                            : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                        dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.spaceBtwItems),

                // Terms and Conditions
                if (controller.reward.value.termsConditions.isNotEmpty) ...[
                  _buildDetailSection(
                    'Terms & Conditions',
                    controller.reward.value.termsConditions,
                    dark,
                  ),
                ],
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildStatisticsRow(RewardDetailsController controller, bool dark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Quantity',
            controller.reward.value.quantity.toString(),
            Iconsax.box,
            dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            'Remaining',
            controller.reward.value.remainingQuantity.toString(),
            Iconsax.box_tick,
            controller.reward.value.remainingQuantity == 0
                ? (dark ? FColors.adminDarkError : FColors.adminLightError)
                : controller.reward.value.remainingQuantity <= 10
                ? (dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
            dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            'Total Redeemed',
            controller.reward.value.redemptionCount.toString(),
            Iconsax.gift,
            dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
            dark,
          ),
        ),
      ],
    );
  }

  Widget _buildRedemptionsSection(RewardDetailsController controller, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(FSizes.cardRadiusLg),
                topRight: Radius.circular(FSizes.cardRadiusLg),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.receipt_item,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Redemptions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ],
            ),
          ),

          // Redemptions List
          Obx(() {
            if (controller.isLoadingRedemptions.value) {
              return const Padding(
                padding: EdgeInsets.all(FSizes.xl),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.redemptions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(FSizes.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.box_remove,
                        size: 48,
                        color: dark
                            ? FColors.adminDarkTextMuted
                            : FColors.adminLightTextMuted,
                      ),
                      const SizedBox(height: FSizes.md),
                      Text(
                        'No redemptions yet',
                        style: TextStyle(
                          color: dark
                              ? FColors.adminDarkTextMuted
                              : FColors.adminLightTextMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.redemptions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: (dark ? FColors.adminDarkDivider : FColors.adminLightDivider)
                    .withOpacity(0.3),
              ),
              itemBuilder: (context, index) {
                final redemption = controller.redemptions[index];
                return _buildRedemptionItem(redemption, dark);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRedemptionItem(RedemptionModel redemption, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Row(
        children: [
          // User Avatar Placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dark
                  ? FColors.adminDarkPrimary.withOpacity(0.1)
                  : FColors.adminLightPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            ),
            child: Icon(
              Iconsax.user,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: FSizes.md),

          // User Info and PIN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ID: ${redemption.userId}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Row(
                  children: [
                    Text(
                      'PIN: ',
                      style: TextStyle(
                        color: dark
                            ? FColors.adminDarkTextSecondary
                            : FColors.adminLightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.sm,
                        vertical: FSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? FColors.adminDarkSurfaceVariant
                            : FColors.adminLightSurfaceVariant,
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                      ),
                      child: Text(
                        redemption.formattedPinCode,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(redemption.createdAt),
                style: TextStyle(
                  color: dark
                      ? FColors.adminDarkTextSecondary
                      : FColors.adminLightTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: FSizes.xs),
              Text(
                _formatTime(redemption.createdAt),
                style: TextStyle(
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool dark) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;
    IconData icon;

    switch (status) {
      case 'active':
        backgroundColor = dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Active';
        icon = Iconsax.tick_circle;
        break;
      case 'inactive':
        backgroundColor = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = 'Inactive';
        icon = Iconsax.pause_circle;
        break;
      case 'expired':
        backgroundColor = dark ? FColors.adminDarkError : FColors.adminLightError;
        displayText = 'Expired';
        icon = Iconsax.clock;
        break;
      case 'out_of_stock':
        backgroundColor = dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        displayText = 'Out of Stock';
        icon = Iconsax.box_remove;
        break;
      default:
        backgroundColor = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = status;
        icon = Iconsax.info_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: FSizes.xs),
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkSurfaceVariant
                : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkTextMuted
                        : FColors.adminLightTextMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: FSizes.md),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            title,
            style: TextStyle(
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showStatusToggleDialog(RewardDetailsController controller, bool dark) {
    final isActivating = controller.reward.value.status != 'active';

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        title: Text(
          isActivating ? 'Activate Reward' : 'Deactivate Reward',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          isActivating
              ? 'Are you sure you want to activate "${controller.reward.value.title}"? It will be available for users to redeem.'
              : 'Are you sure you want to deactivate "${controller.reward.value.title}"? Users will no longer be able to redeem this reward.',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
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
            onPressed: () {
              controller.toggleRewardStatus();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActivating
                  ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                  : (dark ? FColors.adminDarkWarning : FColors.adminLightWarning),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
            ),
            child: Text(
              isActivating ? 'Activate' : 'Deactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}