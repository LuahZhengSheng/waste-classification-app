import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/reward_redemption/controllers/reward_controller.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';

class RewardDetailScreen extends StatelessWidget {
  final RewardModel reward;
  final RedemptionModel? redemption; // Optional redemption data if coming from My Rewards

  const RewardDetailScreen({
    super.key,
    required this.reward,
    this.redemption,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RewardController>();
    final dark = FHelperFunctions.isDarkMode(context);

    // Check if reward is redeemed (either passed redemption or found in controller)
    final userRedemption = redemption ?? controller.getUserRedemption(reward);
    final isRedeemed = userRedemption != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? FColors.white : FColors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Reward Image
                  _buildRewardImage(dark),

                  /// Reward Content
                  Padding(
                    padding: const EdgeInsets.all(FSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title and Points
                        _buildTitleSection(dark),
                        const SizedBox(height: FSizes.spaceBtwItems),

                        /// Status and Availability
                        _buildStatusSection(controller, dark),
                        const SizedBox(height: FSizes.spaceBtwItems),

                        /// Description
                        _buildDescriptionSection(dark),
                        const SizedBox(height: FSizes.spaceBtwItems),

                        /// Terms and Conditions
                        _buildTermsSection(dark),
                        const SizedBox(height: FSizes.spaceBtwItems),

                        /// Redemption Info (if redeemed)
                        if (isRedeemed) _buildRedemptionInfo(userRedemption!, dark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom Button - Only show if not redeemed
          if (!isRedeemed) _buildBottomButton(controller, dark),
        ],
      ),
    );
  }

  /// Build reward image section
  Widget _buildRewardImage(bool dark) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FColors.primary.withOpacity(0.3),
            FColors.accent.withOpacity(0.4),
            FColors.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gift,
              size: 80,
              color: FColors.primary,
            ),
            const SizedBox(height: FSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              decoration: BoxDecoration(
                color: FColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Text(
                reward.title,
                style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  color: FColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build title and points section
  Widget _buildTitleSection(bool dark) {
    final userRedemption = redemption ?? Get.find<RewardController>().getUserRedemption(reward);
    final isRedeemed = userRedemption != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reward.title,
          style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
            color: dark ? FColors.white : FColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Row(
          children: [
            Icon(
              Iconsax.star1,
              color: FColors.primary,
              size: 20,
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              '${reward.pointsNeeded} Points',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                color: FColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.sm,
                vertical: FSizes.xs,
              ),
              decoration: BoxDecoration(
                color: isRedeemed
                    ? FColors.success.withOpacity(0.1)
                    : reward.isAvailable
                    ? FColors.success.withOpacity(0.1)
                    : FColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                border: Border.all(
                  color: isRedeemed
                      ? FColors.success
                      : reward.isAvailable
                      ? FColors.success
                      : FColors.error,
                  width: 1,
                ),
              ),
              child: Text(
                isRedeemed ? 'REDEEMED' : reward.statusDisplayText,
                style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                  color: isRedeemed
                      ? FColors.success
                      : reward.isAvailable
                      ? FColors.success
                      : FColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build status section
  Widget _buildStatusSection(RewardController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.calendar,
                size: 16,
                color: dark ? FColors.darkGrey : FColors.darkerGrey,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Valid Until',
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.darkerGrey,
                ),
              ),
              const Spacer(),
              Text(
                reward.formattedValidUntil,
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.white : FColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Row(
            children: [
              Icon(
                Iconsax.box,
                size: 16,
                color: dark ? FColors.darkGrey : FColors.darkerGrey,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Available Quantity',
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.darkerGrey,
                ),
              ),
              const Spacer(),
              Text(
                '${reward.remainingQuantity}',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.white : FColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Obx(() {
            final userPoints = controller.userPoints.value;
            final canAfford = userPoints >= reward.pointsNeeded;

            return Row(
              children: [
                Icon(
                  Iconsax.wallet_3,
                  size: 16,
                  color: dark ? FColors.darkGrey : FColors.darkerGrey,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Your Points',
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.darkerGrey,
                  ),
                ),
                const Spacer(),
                Text(
                  '$userPoints',
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: canAfford
                        ? FColors.success
                        : (dark ? FColors.white : FColors.black),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (canAfford) ...[
                  const SizedBox(width: FSizes.xs),
                  Icon(
                    Iconsax.tick_circle,
                    size: 16,
                    color: FColors.success,
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Build description section
  Widget _buildDescriptionSection(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
            color: dark ? FColors.white : FColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Text(
          reward.description,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
            color: dark ? FColors.darkGrey : FColors.darkerGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Build terms and conditions section
  Widget _buildTermsSection(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terms & Conditions',
          style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
            color: dark ? FColors.white : FColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Container(
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.lightContainer,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            border: Border.all(
              color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
              width: 1,
            ),
          ),
          child: Text(
            reward.termsConditions,
            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkGrey : FColors.darkerGrey,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Build redemption info section
  Widget _buildRedemptionInfo(RedemptionModel userRedemption, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FColors.success.withOpacity(0.1),
            FColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: FColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.tick_circle,
                color: FColors.success,
                size: 20,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Successfully Redeemed',
                style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  color: FColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'PIN Code:',
                      style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.darkerGrey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.md,
                        vertical: FSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: FColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            userRedemption.formattedPinCode,
                            style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                              color: FColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          GestureDetector(
                            onTap: () => _copyPinCode(userRedemption.pinCode),
                            child: Icon(
                              Iconsax.copy,
                              size: 18,
                              color: FColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),
                Row(
                  children: [
                    Text(
                      'Redeemed Date:',
                      style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.darkerGrey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      userRedemption.formattedCreatedAt,
                      style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                        color: dark ? FColors.white : FColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),
                Row(
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.darkerGrey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.sm,
                        vertical: FSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(userRedemption.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                        border: Border.all(
                          color: _getStatusColor(userRedemption.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        userRedemption.statusDisplayText,
                        style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(userRedemption.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom redeem button
  Widget _buildBottomButton(RewardController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.dark : FColors.white,
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final canRedeem = controller.canRedeemReward(reward);
          final isLoading = controller.isLoading.value;

          return SizedBox(
            width: double.infinity,
            height: FSizes.buttonHeight + 32,
            child: ElevatedButton(
              onPressed: canRedeem && !isLoading
                  ? () => _showRedeemConfirmationDialog(controller)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canRedeem ? FColors.primary : FColors.buttonDisabled,
                foregroundColor: FColors.white,
                disabledBackgroundColor: FColors.buttonDisabled,
                disabledForegroundColor: FColors.white.withOpacity(0.7),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(FColors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canRedeem ? Iconsax.gift : Iconsax.lock_1,
                    size: 20,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    canRedeem
                        ? 'Redeem Now'
                        : controller.userPoints.value < reward.pointsNeeded
                        ? 'Insufficient Points'
                        : 'Unavailable',
                    style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                      color: FColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Copy PIN code to clipboard
  void _copyPinCode(String pinCode) {
    Clipboard.setData(ClipboardData(text: pinCode));
    FLoaders.customToast(message: 'PIN code copied to clipboard');
  }

  /// Show redeem confirmation dialog
  void _showRedeemConfirmationDialog(RewardController controller) {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.dark : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.gift,
              color: FColors.primary,
              size: 24,
            ),
            const SizedBox(width: FSizes.sm),
            Text(
              'Confirm Redemption',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                color: dark ? FColors.white : FColors.black,
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
              'Are you sure you want to redeem this reward?',
              style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                color: dark ? FColors.darkGrey : FColors.darkerGrey,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark ? FColors.darkContainer : FColors.lightContainer,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                      color: dark ? FColors.white : FColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Row(
                    children: [
                      Text(
                        'Points Required:',
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.darkerGrey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${reward.pointsNeeded}',
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          color: FColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Your Balance:',
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.darkerGrey,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Text(
                        '${controller.userPoints.value}',
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          color: dark ? FColors.white : FColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Text(
                        'After Redemption:',
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.darkerGrey,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Text(
                        '${controller.userPoints.value - reward.pointsNeeded}',
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          color: FColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
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
                color: dark ? FColors.darkGrey : FColors.darkerGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final success = await controller.redeemReward(reward);
              if (success) {
                // Show success message with PIN code
                final userRedemption = controller.getUserRedemption(reward);
                if (userRedemption != null) {
                  _showRedemptionSuccessDialog(userRedemption);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.primary,
              foregroundColor: FColors.white,
            ),
            child: const Text('Confirm Redeem'),
          ),
        ],
      ),
    );
  }

  /// Show redemption success dialog
  void _showRedemptionSuccessDialog(RedemptionModel redemption) {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.dark : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: FColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.tick_circle,
                color: FColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Redemption Successful!',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                color: dark ? FColors.white : FColors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your reward has been redeemed successfully. Please save your PIN code:',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.darkerGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.md),
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FColors.primary.withOpacity(0.1),
                    FColors.accent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(
                  color: FColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Your PIN Code',
                    style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.darkerGrey,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        redemption.formattedPinCode,
                        style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                          color: FColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(width: FSizes.md),
                      GestureDetector(
                        onTap: () => _copyPinCode(redemption.pinCode),
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.sm),
                          decoration: BoxDecoration(
                            color: FColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                          child: Icon(
                            Iconsax.copy,
                            color: FColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Present this PIN code to redeem your reward at the merchant.',
              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                color: dark ? FColors.darkGrey : FColors.darkerGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
                foregroundColor: FColors.white,
              ),
              child: const Text('Got It!'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Get status color based on redemption status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FColors.warning;
      case 'used':
        return FColors.success;
      case 'expired':
        return FColors.error;
      case 'cancelled':
        return FColors.darkGrey;
      default:
        return FColors.darkGrey;
    }
  }
}