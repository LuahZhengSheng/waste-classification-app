import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';

import '../../controllers/reward_controller.dart';
import '../../models/reward_model.dart';
import '../my_reward/my_reward.dart';
import '../reward_detail/reward_detail.dart';
import 'widgets/reward_card.dart';

class RewardRedemptionScreen extends StatelessWidget {
  const RewardRedemptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Rewards'),
        centerTitle: false,
        showBackArrow: true,
        actionButtonText: 'My Rewards',
        actionButtonIcon: Iconsax.ticket,
        onActionButtonPressed: () =>
            Get.to(() => const MyRewardsScreen()),
      ),
      body: RefreshIndicator(
        color: FColors.primary,
        onRefresh: controller.refreshRewards,
        child: CustomScrollView(
          slivers: [
            // 顶部积分卡
            SliverToBoxAdapter(
              child: Container(
                color: dark ? FColors.dark : FColors.white,
                padding: const EdgeInsets.all(FSizes.defaultSpace),
                child: _buildPointsCard(controller),
              ),
            ),

            // 分隔
            SliverToBoxAdapter(
              child: Container(
                height: 8,
                color: dark
                    ? FColors.black
                    : FColors.grey.withOpacity(0.05),
              ),
            ),

            // 标题 + 排序
            SliverToBoxAdapter(
              child: Container(
                color: dark ? FColors.dark : FColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.defaultSpace,
                  vertical: FSizes.md,
                ),
                child: Row(
                  children: [
                    Text(
                      'Redeem Your Rewards',
                      style: TextStyle(
                        color: dark ? FColors.white : FColors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildSortButton(controller, dark),
                  ],
                ),
              ),
            ),

            // Reward Grid
            Obx(() {
              if (controller.isLoading.value &&
                  controller.rewards.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: FColors.primary,
                    ),
                  ),
                );
              }

              final items = controller.sortedRewards
                  .where((r) => r.status == 'active')
                  .toList();

              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context, dark),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  FSizes.defaultSpace,
                  FSizes.sm,
                  FSizes.defaultSpace,
                  FSizes.defaultSpace,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: FSizes.gridViewSpacing,
                    mainAxisSpacing: FSizes.gridViewSpacing,
                    childAspectRatio: 0.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final reward = items[index];
                      return RewardCard(
                        reward: reward,
                        mode: RewardCardMode.redemption,
                        subtitleText:
                        'Valid until ${reward.formattedValidUntil}',
                        onTap: () => Get.to(
                              () => RewardDetailScreen(
                            rewardId: reward.rewardId,
                          ),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(RewardController controller) {
    return Obx(
          () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              FColors.primary,
              FColors.accent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: FColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: FColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.medal,
                    color: FColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Text(
                  'My Reward Points',
                  style: TextStyle(
                    color: FColors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),
            Text(
              controller.userPoints.value.toString(),
              style: const TextStyle(
                color: FColors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Points Available',
              style: TextStyle(
                color: FColors.white.withOpacity(0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(
      RewardController controller, bool dark) {
    return Obx(
          () {
        final type = controller.sortType.value;
        final label = type == RewardSortType.highestToLowest
            ? 'High → Low'
            : 'Low → High';

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => _showSortBottomSheet(controller, dark),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.xs,
            ),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.darkerGrey
                  : FColors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.filter,
                  size: 18,
                  color: dark
                      ? FColors.white
                      : FColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: dark
                        ? FColors.white
                        : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortBottomSheet(
      RewardController controller, bool dark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          FSizes.defaultSpace,
          FSizes.defaultSpace,
          FSizes.defaultSpace,
          FSizes.defaultSpace + 16,
        ),
        decoration: BoxDecoration(
          color: dark ? FColors.dark : FColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: FColors.darkGrey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort by points',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                    dark ? FColors.white : FColors.black,
                  ),
                ),
              ),
              const SizedBox(height: FSizes.md),
              Obx(
                    () => Column(
                  children: [
                    _buildSortOptionTile(
                      title: 'Highest to lowest',
                      value: RewardSortType.highestToLowest,
                      groupValue: controller.sortType.value,
                      onChanged: (v) {
                        controller.changeSortType(v);
                        Get.back();
                      },
                      dark: dark,
                    ),
                    const SizedBox(height: 4),
                    _buildSortOptionTile(
                      title: 'Lowest to highest',
                      value: RewardSortType.lowestToHighest,
                      groupValue: controller.sortType.value,
                      onChanged: (v) {
                        controller.changeSortType(v);
                        Get.back();
                      },
                      dark: dark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptionTile({
    required String title,
    required RewardSortType value,
    required RewardSortType groupValue,
    required ValueChanged<RewardSortType> onChanged,
    required bool dark,
  }) {
    final selected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? FColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Iconsax.tick_circle : Iconsax.sort,
              size: 18,
              color: selected
                  ? FColors.primary
                  : FColors.darkGrey,
            ),
            const SizedBox(width: FSizes.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? FColors.primary
                    : (dark
                    ? FColors.white
                    : FColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.defaultSpace * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.gift,
                size: 64,
                color: FColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              'No rewards available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Check back later for more exciting rewards.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark
                    ? FColors.darkGrey
                    : FColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
