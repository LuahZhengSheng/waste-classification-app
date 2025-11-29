import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../data/repositories/reward_redemption/redemption_repository.dart';
import '../../../data/repositories/reward_redemption/reward_repository.dart';
import '../../../data/repositories/user/user_repository.dart';

enum RewardSortType {
  highestToLowest,
  lowestToHighest,
}

class RewardController extends GetxController {
  static RewardController get instance => Get.find<RewardController>();

  final RewardRepository rewardRepository = Get.put(RewardRepository());
  final RedemptionRepository redemptionRepository =
  Get.put(RedemptionRepository());
  final UserRepository userRepository = Get.put(UserRepository());

  // Observable variables
  final RxList<RewardModel> rewards = <RewardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt userPoints = 0.obs;
  final RxString currentUserId = ''.obs;

  // 排序类型
  final Rx<RewardSortType> sortType =
      RewardSortType.lowestToHighest.obs; // 默认从小到大

  // 暴露一个排序后的列表给 UI 使用
  List<RewardModel> get sortedRewards {
    final list = List<RewardModel>.from(rewards);
    list.sort((a, b) {
      if (sortType.value == RewardSortType.highestToLowest) {
        return b.pointsNeeded.compareTo(a.pointsNeeded);
      } else {
        return a.pointsNeeded.compareTo(b.pointsNeeded);
      }
    });
    return list;
  }

  void changeSortType(RewardSortType type) {
    sortType.value = type;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
    _subscribeToRewardsStream();
  }

  /// Initialize user data
  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
      _subscribeToUserPoints();
    }
  }

  /// Subscribe to user points stream
  void _subscribeToUserPoints() {
    userRepository.getUserPointsStream(currentUserId.value).listen(
          (points) => userPoints.value = points,
      onError: (error) => FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to sync points: $error',
      ),
    );
  }

  /// Subscribe to rewards stream（只拿可用的 active reward）
  void _subscribeToRewardsStream() {
    isLoading.value = true;
    rewardRepository.getAvailableRewardsStream().listen(
          (fetchedRewards) {
        try {
          rewards.assignAll(fetchedRewards);
        } catch (e) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to process rewards: $e',
          );
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load rewards: $error',
        );
      },
    );
  }

  /// 按 ID 获取 Reward 的 Stream（详情页用）
  Stream<RewardModel> getRewardStream(String rewardId) {
    return rewardRepository.getRewardStream(rewardId);
  }

  /// 检查是否可以兑换（前端快速判断，实际兑换时还会再用事务校验一次）
  bool canRedeemReward(RewardModel reward) {
    final now = DateTime.now();
    final stillValid = reward.validUntil.isAfter(now);
    final hasQty = reward.remainingQuantity > 0;
    final active = reward.status == 'active';
    final enoughPoints = userPoints.value >= reward.pointsNeeded;
    return stillValid && hasQty && active && enoughPoints;
  }

  /// 兑换 Reward：会做所有校验，并使用事务同时创建 redemption、扣积分、更新 reward 数量和状态
  Future<bool> redeemReward(RewardModel reward) async {
    try {
      final now = DateTime.now();

      if (!canRedeemReward(reward)) {
        if (userPoints.value < reward.pointsNeeded) {
          FLoaders.errorSnackBar(
            title: 'Insufficient points',
            message:
            'You need ${reward.pointsNeeded - userPoints.value} more points to redeem this reward.',
          );
        } else if (reward.remainingQuantity <= 0) {
          FLoaders.errorSnackBar(
            title: 'Out of stock',
            message: 'This reward is fully redeemed.',
          );
        } else if (!reward.validUntil.isAfter(now)) {
          FLoaders.errorSnackBar(
            title: 'Expired',
            message: 'This reward has expired.',
          );
        } else if (reward.status != 'active') {
          FLoaders.errorSnackBar(
            title: 'Unavailable',
            message: 'This reward is currently inactive.',
          );
        }
        return false;
      }

      // 再从后端校验一次可用性
      final isAvailable =
      await rewardRepository.isRewardAvailable(reward.rewardId);
      if (!isAvailable) {
        FLoaders.errorSnackBar(
          title: 'Unavailable',
          message: 'This reward is no longer available.',
        );
        return false;
      }

      isLoading.value = true;
      FLoaders.showLoading('Redeeming reward...');

      // Redemption 的 validUntil = 领取日期 + 30 天
      final redemptionValidUntil = now.add(const Duration(days: 30));

      final redemption = RedemptionModel.createNew(
        userId: currentUserId.value,
        rewardId: reward.rewardId,
        points: reward.pointsNeeded,
        validUntil: redemptionValidUntil,
      );

      final createdRedemption =
      await redemptionRepository.createRedemptionWithSideEffects(
        redemption: redemption,
        rewardId: reward.rewardId,
        userId: currentUserId.value,
        points: reward.pointsNeeded,
      );

      FLoaders.stopLoading();
      isLoading.value = false;

      _showRedemptionSuccessDialog(createdRedemption, reward);
      return true;
    } catch (e) {
      FLoaders.stopLoading();
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to redeem reward: $e',
      );
      return false;
    }
  }

  /// 刷新（其实只做一个小 delay，因为真正数据由 stream 驱动）
  Future<void> refreshRewards() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    isLoading.value = false;
  }

  /// 通过 ID 在内存中找 Reward（可空）
  RewardModel? getRewardById(String rewardId) {
    try {
      return rewards.firstWhere((r) => r.rewardId == rewardId);
    } catch (_) {
      return null;
    }
  }

  /// 兑换成功弹窗（显示 PIN）
  void _showRedemptionSuccessDialog(
      RedemptionModel redemption, RewardModel reward) {
    print('Redemtion pin: ${redemption.pinCode}');

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor:
          Get.isDarkMode ? FColors.dark : FColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(FSizes.defaultSpace),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: FColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  color: FColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'Redemption Successful!',
                style: Get.textTheme.titleLarge?.copyWith(
                  color: Get.isDarkMode
                      ? FColors.white
                      : FColors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: FSizes.spaceBtwItems),

              // PIN Code 区域：与详情页样式一致
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? FColors.darkContainer
                      : FColors.lightContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Get.isDarkMode
                        ? FColors.darkGrey
                        : FColors.borderPrimary,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        redemption.formattedPinCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: Get.isDarkMode
                              ? FColors.white
                              : FColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: redemption.pinCode),
                        );
                        FLoaders.customToast(
                          message: 'Promo code copied',
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Iconsax.copy,
                          size: 18,
                          color: FColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FSizes.md),
              Text(
                'Present this PIN to the merchant.\nValid for 30 days from redemption date.',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.isDarkMode
                      ? FColors.darkGrey
                      : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    foregroundColor: FColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: FSizes.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
