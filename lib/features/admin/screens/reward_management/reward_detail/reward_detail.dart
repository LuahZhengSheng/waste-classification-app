import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';

import '../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../common/widgets/admin/badge.dart';
import '../../../../../common/widgets/admin/small_profile_image.dart';
import '../../../../../data/repositories/user/user_repository.dart';
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
      backgroundColor:
          dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor:
            dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
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
          // Edit Button
          IconButton(
            onPressed: controller.editReward,
            icon: Icon(
              Iconsax.edit,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
            tooltip: 'Edit Reward',
          ),
          // Activate/Deactivate Button
          Obx(() {
            final status = controller.getComputedStatus();
            print('🔄 UI Status Update: $status'); // 添加调试信息

            return IconButton(
              onPressed: () {
                print('🎯 Button Pressed - Current Status: $status'); // 添加调试信息
                controller.toggleRewardStatus();
              },
              icon: Icon(
                status == 'active' ? Iconsax.close_circle : Iconsax.tick_circle,
                color: status == 'active'
                    ? (dark ? FColors.adminDarkError : FColors.adminLightError)
                    : (dark
                        ? FColors.adminDarkSuccess
                        : FColors.adminLightSuccess),
              ),
              tooltip:
                  status == 'active' ? 'Deactivate Reward' : 'Activate Reward',
            );
          }),

          const SizedBox(width: FSizes.sm),
        ],
      ),
      body: Column(
        children: [
          // New Redemption Notification
          Obx(() {
            if (!controller.showNewRedemptionNotification.value) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.md),
              margin: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.information, color: Colors.white),
                  const SizedBox(width: FSizes.md),
                  const Expanded(
                    child: Text(
                      'New redemptions detected',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.refreshRedemptions,
                    child: const Text(
                      'Refresh',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FSizes.lg),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCard(controller, dark),
                      const SizedBox(height: FSizes.spaceBtwSections),
                      _buildStatisticsRow(controller, dark),
                      const SizedBox(height: FSizes.spaceBtwSections),
                      _buildRedemptionsSection(controller, dark),
                    ],
                  )),
            ),
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image
          GestureDetector(
            onTap: () {
              Get.dialog(
                ImageLightbox(
                  imageUrl: controller.reward.value.rewardImage,
                  title: controller.reward.value.title,
                ),
                barrierDismissible: true,
              );
            },
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FSizes.cardRadiusLg),
                  topRight: Radius.circular(FSizes.cardRadiusLg),
                ),
                image: DecorationImage(
                  image: NetworkImage(controller.reward.value.rewardImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(FSizes.cardRadiusLg),
                        topRight: Radius.circular(FSizes.cardRadiusLg),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: FSizes.md,
                    right: FSizes.md,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius:
                            BorderRadius.circular(FSizes.cardRadiusSm),
                      ),
                      child: IconButton(
                        onPressed: () => ImageLightbox(
                            imageUrl: controller.reward.value.rewardImage,
                            title: controller.reward.value.title),
                        icon:
                            const Icon(Iconsax.maximize_4, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: FSizes.md,
                    left: FSizes.md,
                    right: FSizes.md,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.reward.value.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: FSizes.xs),
                              _buildStatusBadge(controller.getComputedStatus(),
                                  controller.reward.value, dark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section - 添加这部分
          _buildOverviewCardContent(controller, dark),
        ],
      ),
    );
  }

  // Continuation of _buildOverviewCard content section
  Widget _buildOverviewCardContent(
      RewardDetailsController controller, bool dark) {
    return Padding(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reward ID and Created At
          Row(
            children: [
              Expanded(
                child: _buildDetailSection(
                  'Reward ID',
                  controller.reward.value.rewardId,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: _buildDetailSection(
                  'Created At',
                  FFormatter.formatDate(controller.reward.value.createdAt),
                  dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

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
                      ? (dark
                          ? FColors.adminDarkError
                          : FColors.adminLightError)
                      : (dark
                          ? FColors.adminDarkSuccess
                          : FColors.adminLightSuccess),
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
            controller.getStockStatusColor(dark),
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

  Widget _buildRedemptionsSection(
      RewardDetailsController controller, bool dark) {
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
                    color:
                        dark ? FColors.adminDarkText : FColors.adminLightText,
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
                color: (dark
                        ? FColors.adminDarkDivider
                        : FColors.adminLightDivider)
                    .withOpacity(0.3),
              ),
              itemBuilder: (context, index) {
                final redemption = controller.redemptions[index];
                return FutureBuilder(
                  future: Get.find<UserRepository>()
                      .fetchOtherUserDetails(redemption.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildRedemptionItemLoading(dark);
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return _buildRedemptionItem(redemption, null, dark);
                    }
                    return _buildRedemptionItem(
                        redemption, snapshot.data, dark);
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRedemptionItemLoading(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkSurfaceVariant
                        : FColors.adminLightSurfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkSurfaceVariant
                        : FColors.adminLightSurfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionItem(
      RedemptionModel redemption, dynamic user, bool dark) {
    final now = DateTime.now();
    final isExpired = now.isAfter(redemption.validUntil);

    // 过期用红色，未过期用青色
    final expiryColor = isExpired
        ? (dark ? FColors.adminDarkError : FColors.adminLightError)
        : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess);

    final expiryTextPrefix = isExpired ? 'Expired on ' : 'Valid until ';

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Row(
        children: [
          // User Avatar：SmallProfileImage
          SmallProfileImage(
            profileImg: user?.profileImg,
            username: user?.username ?? 'Unknown User',
            dark: dark,
            radius: 20,
          ),
          const SizedBox(width: FSizes.md),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.username ?? 'Unknown User',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                    dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  user?.email ?? 'No email',
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Points: ${redemption.points}',
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Time and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Redeemed date
              Row(
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
                  const SizedBox(width: FSizes.xs),
                  Text(
                    FFormatter.formatTimeAgo(redemption.createdAt),
                    style: TextStyle(
                      color: dark
                          ? FColors.adminDarkTextMuted
                          : FColors.adminLightTextMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.xs),
              // Valid / Expired 文本，按状态换颜色
              Text(
                '$expiryTextPrefix${_formatDate(redemption.validUntil)}',
                style: TextStyle(
                  color: expiryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              CommonBadge(
                text: redemption.status.toUpperCase(),
                color: _getStatusColor(redemption.status, dark),
                icon: Iconsax.info_circle,
                iconSize: 12,
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                borderRadius: 4,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                borderColor: Colors.transparent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 添加状态颜色方法
  Color _getStatusColor(String status, bool dark) {
    switch (status.toLowerCase()) {
      case 'used':
        return dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
      case 'expired':
        return dark ? FColors.adminDarkError : FColors.adminLightError;
      case 'cancelled':
        return dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
      default: // pending
        return dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
    }
  }

  Widget _buildStatusBadge(String status, RewardModel reward, bool dark) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;
    IconData icon;

    switch (status) {
      case 'active':
        backgroundColor =
            dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Active';
        icon = Iconsax.tick_circle;
        break;
      case 'inactive':
        backgroundColor =
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = 'Inactive';
        icon = Iconsax.pause_circle;
        break;
      case 'expired':
        backgroundColor =
            dark ? FColors.adminDarkError : FColors.adminLightError;
        displayText = 'Expired';
        icon = Iconsax.clock;
        break;
      case 'out_of_stock':
        backgroundColor =
            dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        displayText = 'Out of Stock';
        icon = Iconsax.box_remove;
        break;
      default:
        backgroundColor =
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
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

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color, bool dark) {
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
                    color:
                        dark ? FColors.adminDarkText : FColors.adminLightText,
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool dark) {
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
        backgroundColor:
            dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
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
            color: dark
                ? FColors.adminDarkTextSecondary
                : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
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
                  ? (dark
                      ? FColors.adminDarkSuccess
                      : FColors.adminLightSuccess)
                  : (dark ? FColors.adminDarkError : FColors.adminLightError),
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
