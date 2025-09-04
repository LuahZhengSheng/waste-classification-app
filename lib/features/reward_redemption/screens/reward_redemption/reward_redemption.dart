import 'package:flutter/material.dart';
import 'package:fyp/features/reward_redemption/screens/my_reward/my_reward.dart';
import 'package:fyp/features/reward_redemption/screens/reward_detail/reward_detail.dart';
import 'package:fyp/utils/loaders/circular_loader.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/reward_redemption/controllers/reward_controller.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class RewardRedemptionScreen extends StatelessWidget {
  const RewardRedemptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
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
      body: RefreshIndicator(
        onRefresh: () => controller.refreshRewards(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Points Card
                _buildPointsCard(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),

                /// Rewards Grid
                _buildRewardsSection(controller, dark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build points card widget
  Widget _buildPointsCard(RewardController controller, bool dark) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FColors.primary.withOpacity(0.8),
            FColors.accent.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Reward Points',
                style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  color: FColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.to(MyRewardsScreen()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  backgroundColor: FColors.white.withOpacity(0.2),
                  foregroundColor: FColors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                  side: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                child: Text(
                  'My Rewards',
                  style: Theme.of(Get.context!).textTheme.labelMedium?.copyWith(
                    color: FColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            '${controller.userPoints.value.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},'
            )} Points',
            style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
              color: FColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ));
  }

  /// Build rewards section
  Widget _buildRewardsSection(RewardController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem Your Rewards',
          style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
            color: dark ? FColors.white : FColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
        Obx(() {
          if (controller.isLoading.value && controller.rewards.isEmpty) {
            return const Center(
              child: FCircularLoader(),
            );
          }

          if (controller.rewards.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(
                    Iconsax.gift,
                    size: 64,
                    color: dark ? FColors.darkGrey : FColors.grey,
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'No rewards available',
                    style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: FSizes.gridViewSpacing,
              mainAxisSpacing: FSizes.gridViewSpacing,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.rewards.length,
            itemBuilder: (context, index) {
              final reward = controller.rewards[index];
              return _buildRewardCard(reward, controller, dark);
            },
          );
        }),
      ],
    );
  }

  /// Build individual reward card
  Widget _buildRewardCard(RewardModel reward, RewardController controller, bool dark) {
    final canRedeem = controller.canRedeemReward(reward);
    final userRedemption = controller.getUserRedemption(reward);
    final isRedeemed = userRedemption != null;

    return GestureDetector(
      onTap: () => Get.to(() => RewardDetailScreen(reward: reward)),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Reward Image
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FSizes.cardRadiusLg),
                  topRight: Radius.circular(FSizes.cardRadiusLg),
                ),
                gradient: LinearGradient(
                  colors: [
                    FColors.primary.withOpacity(0.3),
                    FColors.accent.withOpacity(0.3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Iconsax.gift,
                      size: 48,
                      color: FColors.primary,
                    ),
                  ),
                  if (isRedeemed)
                    Positioned(
                      top: FSizes.sm,
                      right: FSizes.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.sm,
                          vertical: FSizes.xs,
                        ),
                        decoration: BoxDecoration(
                          color: FColors.success,
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                        ),
                        child: Text(
                          'Redeemed',
                          style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                            color: FColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// Reward Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(FSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                        color: dark ? FColors.white : FColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Iconsax.star1,
                          size: 16,
                          color: canRedeem ? FColors.primary : FColors.darkGrey,
                        ),
                        const SizedBox(width: FSizes.xs),
                        Text(
                          '${reward.pointsNeeded}',
                          style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                            color: canRedeem
                                ? FColors.primary
                                : (dark ? FColors.darkGrey : FColors.darkerGrey),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (!canRedeem && !isRedeemed)
                          Icon(
                            Iconsax.lock_1,
                            size: 16,
                            color: FColors.darkGrey,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}