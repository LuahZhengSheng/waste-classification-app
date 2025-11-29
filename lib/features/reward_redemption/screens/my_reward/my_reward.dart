import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../controllers/my_reward_controller.dart';
import '../../models/redemption_model.dart';
import '../../models/reward_model.dart';
import '../reward_detail/reward_detail.dart';

class MyRewardsScreen extends StatefulWidget {
  const MyRewardsScreen({super.key});

  @override
  State<MyRewardsScreen> createState() => _MyRewardsScreenState();
}

class _MyRewardsScreenState extends State<MyRewardsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MyRewardsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MyRewardsController());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.communityDarkBackground : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('My Rewards'),
      ),
      body: Column(
        children: [
          _buildTabBar(dark),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: FColors.primary,
                  ),
                );
              }
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveList(dark),
                  _buildExpiredList(dark),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.defaultSpace,
        vertical: 12,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
          dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: FColors.white,
          unselectedLabelColor:
          dark ? FColors.darkGrey : FColors.textSecondary,
          // 关键：indicator 占满整个 tab 区域
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: FColors.primary,            // 整块 primary
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: FColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveList(bool dark) {
    final list = controller.activeRedemptions;
    if (list.isEmpty) {
      return _buildEmpty(
        dark,
        icon: Iconsax.ticket,
        title: 'No Active Rewards',
        message: 'Redeem a reward to see it listed here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final r = list[index];
        final reward = controller.getRewardById(r.rewardId);
        if (reward == null) return const SizedBox.shrink();
        return _buildRewardRow(
          dark: dark,
          redemption: r,
          reward: reward,
          isExpired: false,
        );
      },
    );
  }

  Widget _buildExpiredList(bool dark) {
    final list = controller.expiredRedemptions;
    if (list.isEmpty) {
      return _buildEmpty(
        dark,
        icon: Iconsax.clock,
        title: 'No Expired Rewards',
        message: 'Expired rewards will appear here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final r = list[index];
        final reward = controller.getRewardById(r.rewardId);
        if (reward == null) return const SizedBox.shrink();
        return Opacity(
          opacity: 0.7,
          child: _buildRewardRow(
            dark: dark,
            redemption: r,
            reward: reward,
            isExpired: true,
          ),
        );
      },
    );
  }

  // 左图右文的 reward 行
  Widget _buildRewardRow({
    required bool dark,
    required RedemptionModel redemption,
    required RewardModel reward,
    required bool isExpired,
  }) {
    final redeemedText = 'Redeemed ${redemption.formattedCreatedAt}';
    final validText = isExpired
        ? 'Expired ${FFormatter.formatDate(redemption.validUntil)}'
        : 'Valid until ${FFormatter.formatDate(redemption.validUntil)}';

    return InkWell(
      onTap: () {
        Get.to(
              () => RewardDetailScreen(
            rewardId: reward.rewardId,
            redemption: redemption,
            isFromMyRewards: true,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.lightContainer,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(
          //   color: dark
          //       ? FColors.darkDivider
          //       : FColors.borderSecondary,
          // ),
        ),
        child: Row(
          children: [
            // 左侧图片
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: FColors.grey.withOpacity(0.1),
                child: reward.rewardImage.isNotEmpty
                    ? Image.network(
                  reward.rewardImage,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Iconsax.gift,
                  size: 32,
                  color: FColors.primary.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(width: FSizes.md),

            // 右侧文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dark ? FColors.white : FColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    redeemedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: dark
                          ? FColors.darkTextSecondary
                          : FColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    validText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpired
                          ? FColors.error
                          : FColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: FSizes.sm),

            Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color:
              dark ? FColors.darkTextSecondary : FColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(
      bool dark, {
        required IconData icon,
        required String title,
        required String message,
      }) {
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
                icon,
                size: 64,
                color: FColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: dark
                    ? FColors.darkGrey
                    : FColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
