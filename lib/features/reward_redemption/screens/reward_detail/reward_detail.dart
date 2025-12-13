import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../controllers/reward_controller.dart';
import '../../models/reward_model.dart';
import '../../models/redemption_model.dart';

class RewardDetailScreen extends StatelessWidget {
  final String rewardId;
  final RedemptionModel? redemption;
  final bool isFromMyRewards;

  const RewardDetailScreen({
    super.key,
    required this.rewardId,
    this.redemption,
    this.isFromMyRewards = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = RewardController.instance;
    final dark = FHelperFunctions.isDarkMode(context);

    return StreamBuilder<RewardModel>(
      stream: controller.getRewardStream(rewardId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: dark ? FColors.dark : FColors.light,
            body: const Center(
              child: CircularProgressIndicator(color: FColors.primary),
            ),
          );
        }

        final reward = snapshot.data!;

        return Scaffold(
          backgroundColor: dark ? FColors.communityDarkBackground : FColors.light,
          appBar: FAppBar(
            title: const Text('Reward Details'),
            showBackArrow: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(reward),
                _buildContentSection(reward, controller, dark),
              ],
            ),
          ),
          bottomNavigationBar: isFromMyRewards
              ? null
              : _buildBottomRedeemBar(reward, controller, dark),
        );
      },
    );
  }

  Widget _buildImageSection(RewardModel reward) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: FColors.grey.withOpacity(0.1),
          ),
          child: reward.rewardImage.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: reward.rewardImage,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => const Center(
                    child: CircularProgressIndicator(
                      color: FColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (c, u, e) => Center(
                    child: Icon(
                      Iconsax.gift,
                      size: 64,
                      color: FColors.primary.withOpacity(0.5),
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    Iconsax.gift,
                    size: 64,
                    color: FColors.primary.withOpacity(0.5),
                  ),
                ),
        ),
        // // Logo overlay (top left)
        // Positioned(
        //   top: 16,
        //   left: 16,
        //   child: Container(
        //     width: 80,
        //     height: 80,
        //     decoration: BoxDecoration(
        //       color: FColors.white,
        //       borderRadius: BorderRadius.circular(12),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.1),
        //           blurRadius: 8,
        //           offset: const Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     child: reward.rewardImage.isNotEmpty
        //         ? ClipRRect(
        //             borderRadius: BorderRadius.circular(12),
        //             child: CachedNetworkImage(
        //               imageUrl: reward.rewardImage,
        //               fit: BoxFit.cover,
        //             ),
        //           )
        //         : const Icon(
        //             Iconsax.gift,
        //             size: 40,
        //             color: FColors.primary,
        //           ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildContentSection(
      RewardModel reward, RewardController controller, bool dark) {
    return Container(
      color: dark ? FColors.dark : FColors.white,
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            reward.title,
            style: TextStyle(
              color: dark ? FColors.white : FColors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: FSizes.sm),

          // Expires text
          Row(
            children: [
              Icon(
                Iconsax.calendar,
                size: 16,
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Expires in 30 days',
                style: TextStyle(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Points
          Text(
            '${reward.pointsNeeded} points',
            style: TextStyle(
              color: dark ? FColors.primary : FColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          // Voucher Promo Code Section
          _buildPromoCodeSection(dark),
          const SizedBox(height: FSizes.spaceBtwSections),

          // Where to use
          _buildSectionTitle('Where to use?', dark),
          const SizedBox(height: FSizes.sm),
          Text(
            reward.description,
            style: TextStyle(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          // How does it work
          _buildSectionTitle('Terms and Conditions', dark),
          const SizedBox(height: FSizes.sm),
          Text(
            reward.termsConditions,
            style: TextStyle(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          // If from my rewards, show redemption info
          if (isFromMyRewards && redemption != null) ...[
            _buildRedemptionInfo(redemption!, dark),
            const SizedBox(height: FSizes.spaceBtwSections),
          ],

          // Subtotal section (only if not from my rewards)
          // if (!isFromMyRewards) _buildSubtotalSection(reward, controller, dark),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voucher Promo Code',
                  style: TextStyle(
                    color: dark ? FColors.white : FColors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isFromMyRewards && redemption != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md,
                      vertical: FSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dark ? FColors.darkGrey : FColors.borderPrimary,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          redemption!.formattedPinCode,
                          style: TextStyle(
                            color: dark ? FColors.white : FColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: redemption!.pinCode),
                            );
                            FLoaders.customToast(
                              message: 'Promo code copied',
                            );
                          },
                          child: Icon(
                            Iconsax.copy,
                            size: 18,
                            color: dark ? FColors.white : FColors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Promo Code given upon claim',
                    style: TextStyle(
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool dark) {
    return Text(
      title,
      style: TextStyle(
        color: dark ? FColors.white : FColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRedemptionInfo(RedemptionModel redemption, bool dark) {
    final now = DateTime.now();
    final isExpired = redemption.validUntil.isBefore(now);

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: isExpired
            ? FColors.error.withOpacity(0.1)
            : FColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? FColors.error.withOpacity(0.3)
              : FColors.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired ? Iconsax.close_circle : Iconsax.tick_circle,
                color: isExpired ? FColors.error : FColors.success,
                size: 20,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                isExpired ? 'Expired' : 'Redeemed successfully',
                style: TextStyle(
                  color: isExpired ? FColors.error : FColors.success,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          _buildInfoRow(
            'Redeemed on:',
            redemption.formattedCreatedAt,
            dark,
          ),
          const SizedBox(height: FSizes.sm),
          _buildInfoRow(
            'Valid until:',
            FFormatter.formatDate(redemption.validUntil),
            dark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: dark ? FColors.darkGrey : FColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: dark ? FColors.white : FColors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Widget _buildSubtotalSection(
  //     RewardModel reward, RewardController controller, bool dark) {
  //   return Obx(() {
  //     final userPoints = controller.userPoints.value;
  //     final canRedeem = controller.canRedeemReward(reward);
  //
  //     return Column(
  //       children: [
  //         const Divider(height: 32),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Subtotal',
  //               style: TextStyle(
  //                 color: dark ? FColors.white : FColors.black,
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             Text(
  //               '${reward.pointsNeeded} points',
  //               style: TextStyle(
  //                 color: dark ? FColors.white : FColors.primary,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: FSizes.sm),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Points available:',
  //               style: TextStyle(
  //                 color: canRedeem ? FColors.error : FColors.success,
  //                 fontSize: 13,
  //               ),
  //             ),
  //             Text(
  //               '$userPoints',
  //               style: TextStyle(
  //                 color: canRedeem ? FColors.error : FColors.success,
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     );
  //   });
  // }

  Widget _buildBottomRedeemBar(
    RewardModel reward,
    RewardController controller,
    bool dark,
  ) {
    final bgColor = dark ? FColors.dark : FColors.white;
    final dividerColor = dark ? FColors.darkDivider : FColors.borderSecondary;
    final subtotalLabelColor =
        dark ? FColors.darkTextSecondary : FColors.textSecondary;
    final availableLabelColor = FColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.defaultSpace,
        vertical: FSizes.md,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final canRedeem = controller.canRedeemReward(reward);
          final loading = controller.isLoading.value;
          final userPoints = controller.userPoints.value;

          return Row(
            children: [
              // 左侧 subtotal 区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subtotalLabelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reward.pointsNeeded} points',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Points available: $userPoints',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: availableLabelColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: FSizes.md),

              // 右侧 Redeem 按钮
              SizedBox(
                width: 140,
                height: 55,
                child: ElevatedButton(
                  onPressed: (!canRedeem || loading)
                      ? null
                      : () => _confirmRedeem(reward, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canRedeem ? FColors.primary : FColors.buttonDisabled,
                    foregroundColor: FColors.white,
                    disabledBackgroundColor: FColors.buttonDisabled,
                    disabledForegroundColor: FColors.white.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(FColors.white),
                          ),
                        )
                      : const Text(
                          'Redeem',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _confirmRedeem(RewardModel reward, RewardController controller) {
    FLoaders.showRewardRedemptionDialog(
      rewardTitle: reward.title,
      pointsRequired: reward.pointsNeeded,
      currentPoints: controller.userPoints.value,
      onConfirm: () async {
        final ok = await controller.redeemReward(reward);
        if (ok) {
          FLoaders.successSnackBar(
            title: 'Success',
            message: 'Reward redeemed successfully.',
          );
        }
      },
    );
  }
}
