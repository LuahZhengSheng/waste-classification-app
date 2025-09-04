import 'package:flutter/material.dart';
import 'package:fyp/features/reward_redemption/controllers/my_reward_controller.dart';
import 'package:fyp/features/reward_redemption/screens/reward_detail/reward_detail.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/loaders/circular_loader.dart';

class MyRewardsScreen extends StatelessWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyRewardsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rewards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? FColors.white : FColors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.refreshData(),
            icon: Icon(
              Iconsax.refresh,
              color: dark ? FColors.white : FColors.black,
            ),
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: FColors.primary,
          unselectedLabelColor: dark ? FColors.darkGrey : FColors.darkerGrey,
          indicatorColor: FColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        child: TabBarView(
          controller: controller.tabController,
          children: [
            /// Active Tab
            _buildActiveTab(controller, dark),

            /// Past Tab
            _buildPastTab(controller, dark),

            /// Transaction History Tab
            _buildHistoryTab(controller, dark),
          ],
        ),
      ),
    );
  }

  /// Build Active Rewards Tab
  Widget _buildActiveTab(MyRewardsController controller, bool dark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: FCircularLoader());
      }

      final activeRedemptions = controller.activeRedemptions;

      if (activeRedemptions.isEmpty) {
        return _buildEmptyState(
          icon: Iconsax.gift,
          title: 'No Active Rewards',
          message: 'You don\'t have any active rewards at the moment.\nRedeem some rewards to see them here!',
          dark: dark,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        itemCount: activeRedemptions.length,
        itemBuilder: (context, index) {
          final redemption = activeRedemptions[index];
          final reward = controller.getRewardById(redemption.rewardId);
          return _buildActiveRedemptionCard(redemption, reward, controller, dark);
        },
      );
    });
  }

  /// Build Past Rewards Tab
  Widget _buildPastTab(MyRewardsController controller, bool dark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: FCircularLoader());
      }

      final pastRedemptions = controller.pastRedemptions;

      if (pastRedemptions.isEmpty) {
        return _buildEmptyState(
          icon: Iconsax.clock,
          title: 'No Past Rewards',
          message: 'Your expired and used rewards will appear here.',
          dark: dark,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        itemCount: pastRedemptions.length,
        itemBuilder: (context, index) {
          final redemption = pastRedemptions[index];
          final reward = controller.getRewardById(redemption.rewardId);
          return _buildPastRedemptionCard(redemption, reward, controller, dark);
        },
      );
    });
  }

  /// Build Transaction History Tab
  Widget _buildHistoryTab(MyRewardsController controller, bool dark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: FCircularLoader());
      }

      final transactions = controller.transactionHistory;

      if (transactions.isEmpty) {
        return _buildEmptyState(
          icon: Iconsax.receipt_2,
          title: 'No Transaction History',
          message: 'Your reward redemption history will appear here.',
          dark: dark,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final reward = controller.getRewardById(transaction.rewardId);
          return _buildTransactionCard(transaction, reward, controller, dark);
        },
      );
    });
  }

  /// Build Active Redemption Card
  Widget _buildActiveRedemptionCard(
      RedemptionModel redemption,
      RewardModel? reward,
      MyRewardsController controller,
      bool dark,
      ) {
    final isNearExpiry = controller.isRedemptionNearExpiry(redemption);
    final daysUntilExpiry = controller.getDaysUntilExpiry(redemption);

    return GestureDetector(
      onTap: () {
        if (reward != null) {
          Get.to(() => RewardDetailScreen(
            reward: reward,
            redemption: redemption, // Pass the redemption data
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: isNearExpiry
              ? Border.all(color: FColors.warning, width: 2)
              : Border.all(color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary),
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
          children: [
            /// Header with reward info
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FColors.primary.withOpacity(0.1),
                    FColors.accent.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FSizes.cardRadiusLg),
                  topRight: Radius.circular(FSizes.cardRadiusLg),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: FColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                    ),
                    child: Icon(
                      Iconsax.gift,
                      color: FColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward?.title ?? 'Unknown Reward',
                          style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                            color: dark ? FColors.white : FColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Redeemed ${redemption.formattedCreatedAt}',
                          style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.darkerGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.sm,
                      vertical: FSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: FColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                      border: Border.all(color: FColors.success, width: 1),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                        color: FColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
            /// Body with PIN and expiry info
            Padding(
              padding: const EdgeInsets.all(FSizes.md),
              child: Column(
                children: [
                  /// PIN Code Section
                  Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? FColors.dark : FColors.lightContainer,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                      border: Border.all(
                        color: FColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PIN Code',
                              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                                color: dark ? FColors.darkGrey : FColors.darkerGrey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showPinCodeDialog(redemption, reward, dark),
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.eye,
                                    size: 16,
                                    color: FColors.primary,
                                  ),
                                  const SizedBox(width: FSizes.xs),
                                  Text(
                                    'View',
                                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                      color: FColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FSizes.sm),
                        Text(
                          '● ● ● ● ● ●',
                          style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                            color: dark ? FColors.white : FColors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: FSizes.md),
      
                  /// Expiry Warning (if near expiry)
                  if (isNearExpiry)
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: FColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                        border: Border.all(color: FColors.warning, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.warning_2,
                            color: FColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text(
                              daysUntilExpiry > 0
                                  ? 'Expires in $daysUntilExpiry day${daysUntilExpiry > 1 ? 's' : ''}'
                                  : 'Expires today',
                              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                color: FColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      
                  /// Use Now Button
                  const SizedBox(height: FSizes.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showUseConfirmationDialog(redemption, reward, controller, dark),
                      icon: const Icon(Iconsax.tick_circle),
                      label: const Text('Mark as Used'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primary,
                        foregroundColor: FColors.white,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Past Redemption Card
  Widget _buildPastRedemptionCard(
      RedemptionModel redemption,
      RewardModel? reward,
      MyRewardsController controller,
      bool dark,
      ) {
    final statusColor = _getStatusColor(redemption.status);

    return GestureDetector(
      onTap: () {
        if (reward != null) {
          Get.to(() => RewardDetailScreen(
            reward: reward,
            redemption: redemption, // Pass the redemption data
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: Border.all(
            color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Icon(
                _getStatusIcon(redemption.status),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward?.title ?? 'Unknown Reward',
                    style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                      color: dark ? FColors.white : FColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'PIN: ${redemption.formattedPinCode}',
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.darkerGrey,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Redeemed ${redemption.formattedCreatedAt}',
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.darkerGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.sm,
                vertical: FSizes.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Text(
                redemption.statusDisplayText.toUpperCase(),
                style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Transaction Card
  Widget _buildTransactionCard(
      RedemptionModel transaction,
      RewardModel? reward,
      MyRewardsController controller,
      bool dark,
      ) {
    final statusColor = _getStatusColor(transaction.status);

    return GestureDetector(
      onTap: () {
        if (reward != null) {
          Get.to(() => RewardDetailScreen(
            reward: reward,
            redemption: transaction, // Pass the transaction data
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: Border.all(
            color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                  ),
                  child: Icon(
                    _getStatusIcon(transaction.status),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward?.title ?? 'Unknown Reward',
                        style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                          color: dark ? FColors.white : FColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        'Redeemed ${transaction.formattedCreatedAt}',
                        style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.darkerGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.sm,
                    vertical: FSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    transaction.statusDisplayText.toUpperCase(),
                    style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.sm),
            const Divider(),
            const SizedBox(height: FSizes.sm),
            Row(
              children: [
                Icon(
                  Iconsax.code,
                  size: 16,
                  color: dark ? FColors.darkGrey : FColors.darkerGrey,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'PIN: ${transaction.formattedPinCode}',
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.white : FColors.black,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (reward != null) ...[
                  Icon(
                    Iconsax.star1,
                    size: 16,
                    color: FColors.primary,
                  ),
                  const SizedBox(width: FSizes.xs),
                  Text(
                    '${reward.pointsNeeded} pts',
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: FColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build Empty State Widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required bool dark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.xl),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.darkContainer
                    : FColors.lightContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: dark ? FColors.darkGrey : FColors.grey,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                color: dark ? FColors.white : FColors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              message,
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.darkerGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show PIN Code Dialog
  void _showPinCodeDialog(RedemptionModel redemption, RewardModel? reward, bool dark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.dark : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Icon(
                Iconsax.code,
                color: FColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Text(
                'PIN Code',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                  color: dark ? FColors.white : FColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
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
                    reward?.title ?? 'Reward',
                    style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                      color: dark ? FColors.white : FColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    redemption.formattedPinCode,
                    style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                      color: FColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'Show this PIN to the merchant',
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.darkerGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
              child: const Text('Got It'),
            ),
          ),
        ],
      ),
    );
  }

  /// Show Use Confirmation Dialog
  void _showUseConfirmationDialog(
      RedemptionModel redemption,
      RewardModel? reward,
      MyRewardsController controller,
      bool dark,
      ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.dark : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.tick_circle,
              color: FColors.success,
              size: 24,
            ),
            const SizedBox(width: FSizes.sm),
            Text(
              'Mark as Used',
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
              'Have you used this reward? This action cannot be undone.',
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
                    reward?.title ?? 'Unknown Reward',
                    style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                      color: dark ? FColors.white : FColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'PIN: ${redemption.formattedPinCode}',
                    style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.darkerGrey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: dark ? FColors.darkGrey : FColors.darkerGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.markRedemptionAsUsed(redemption.redemptionId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.success,
                    foregroundColor: FColors.white,
                  ),
                  child: const Text('Mark Used'),
                ),
              ),
            ],
          ),
        ],
      ),
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

  /// Get status icon based on redemption status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Iconsax.clock;
      case 'used':
        return Iconsax.tick_circle;
      case 'expired':
        return Iconsax.close_circle;
      case 'cancelled':
        return Iconsax.slash;
      default:
        return Iconsax.info_circle;
    }
  }
}