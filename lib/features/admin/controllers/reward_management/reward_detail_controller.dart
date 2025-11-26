import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/reward_redemption/redemption_repository.dart';
import '../../../../data/repositories/reward_redemption/reward_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/popups/admin_loaders.dart';
import '../../../reward_redemption/models/redemption_model.dart';
import '../../../reward_redemption/models/reward_model.dart';

class RewardDetailsController extends GetxController {
  final RewardModel initialReward;

  RewardDetailsController({required RewardModel reward})
      : initialReward = reward;

  // Repositories
  final _rewardRepo = Get.put(RewardRepository());
  final _redemptionRepo = Get.put(RedemptionRepository());

  // Stream subscriptions
  StreamSubscription<RewardModel>? _rewardSubscription;
  StreamSubscription<int>? _redemptionCountSubscription;

  // Observables
  late Rx<RewardModel> reward;
  final RxList<RedemptionModel> redemptions = <RedemptionModel>[].obs;
  final RxBool isLoadingRedemptions = false.obs;
  final RxInt currentRedemptionCount = 0.obs;
  final RxBool showNewRedemptionNotification = false.obs;

  @override
  void onInit() {
    super.onInit();
    reward = initialReward.obs;
    _listenToReward();
    _listenToRedemptionCount();
    loadRedemptions();
  }

  @override
  void onClose() {
    _rewardSubscription?.cancel();
    _redemptionCountSubscription?.cancel();
    super.onClose();
  }

  /// Listen to reward updates
  void _listenToReward() {
    _rewardSubscription =
        _rewardRepo.getRewardByIdStream(initialReward.rewardId).listen(
              (updatedReward) {
            reward.value = updatedReward;
          },
          onError: (error) {
            print('Error listening to reward: $error');
          },
        );
  }

  /// Listen to redemption count changes
  void _listenToRedemptionCount() {
    _redemptionCountSubscription = _redemptionRepo
        .getRedemptionCountByRewardIdStream(initialReward.rewardId)
        .listen(
          (count) {
        // 只在有变化且不是初始加载时显示通知
        if (count != currentRedemptionCount.value && currentRedemptionCount.value > 0) {
          showNewRedemptionNotification.value = true;

          if (count > currentRedemptionCount.value) {
            print('🆕 New redemption added: ${currentRedemptionCount.value} -> $count');
          } else {
            print('🗑️ Redemption removed: ${currentRedemptionCount.value} -> $count');
          }
        }
        currentRedemptionCount.value = count;
      },
      onError: (error) {
        print('Error listening to redemption count: $error');
      },
    );
  }

  /// Load redemptions (future get)
  Future<void> loadRedemptions() async {
    try {
      isLoadingRedemptions.value = true;
      final redemptionList = await _redemptionRepo
          .getRedemptionsByRewardId(initialReward.rewardId);
      redemptions.assignAll(redemptionList);
      currentRedemptionCount.value = redemptionList.length;
    } catch (e) {
      print('$e');
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load redemptions: ${e.toString()}',
      );
    } finally {
      isLoadingRedemptions.value = false;
    }
  }

  /// Refresh redemptions
  Future<void> refreshRedemptions() async {
    showNewRedemptionNotification.value = false;
    await loadRedemptions();
    FAdminLoaders.successSnackBar(
      title: 'Refreshed',
      message: 'Redemptions updated successfully',
    );
  }

  /// Get computed status
  String getComputedStatus() {
    if (reward.value.status == 'inactive') {
      return 'inactive';
    }

    if (reward.value.isExpired) {
      return 'expired';
    }

    if (reward.value.remainingQuantity <= 0) {
      return 'out_of_stock';
    }

    return 'active';
  }

  /// Toggle reward status
  Future<void> toggleRewardStatus() async {
    try {
      print('Toggle status called - current status: ${reward.value.status}');
      final newStatus = reward.value.status == 'active' ? 'inactive' : 'active';
      print('Attempting to change to: $newStatus');

      // If activating, check constraints
      if (newStatus == 'active') {
        print('Checking activation constraints...');
        final canActivate = _canActivateReward();
        print('Can activate: $canActivate');

        if (!canActivate) {
          print('Activation blocked due to constraints');
          return;
        }
      }

      print('Proceeding with status update...');
      await _rewardRepo.updateRewardStatus(reward.value.rewardId, newStatus);

      final message = newStatus == 'active'
          ? 'Reward activated successfully'
          : 'Reward deactivated successfully';
      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: message,
      );
      print('Status update completed successfully');
    } catch (e) {
      print('Error during status update: $e');
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update reward status: ${e.toString()}',
      );
    }
  }

  /// Check if reward can be activated
  bool _canActivateReward() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (reward.value.remainingQuantity <= 0) {
      print('❌ Activation failed: remaining quantity is 0');

      // 先关闭可能存在的 snackbar
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      // 添加延迟确保关闭完成
      Future.delayed(Duration.zero, () {
        FAdminLoaders.warningSnackBar(
          title: 'Cannot Activate Reward',
          message: 'Reward cannot be activated because remaining quantity is 0. Please update the quantity first.',
        );
      });

      return false;
    }

    if (reward.value.validUntil.isBefore(tomorrow)) {
      print('❌ Activation failed: valid until date is too soon');

      // 先关闭可能存在的 snackbar
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      // 添加延迟确保关闭完成
      Future.delayed(Duration.zero, () {
        FAdminLoaders.warningSnackBar(
          title: 'Cannot Activate Reward',
          message: 'Reward cannot be activated because the valid until date must be at least 1 day from now. Please update the expiry date first.',
        );
      });

      return false;
    }

    print('✅ Activation constraints passed');
    return true;
  }

  /// Edit reward
  void editReward() {
    // Navigate to edit reward screen
    print('Edit reward: ${reward.value.title}');
  }

  /// Get stock status color
  Color getStockStatusColor(bool dark) {
    final remaining = reward.value.remainingQuantity;

    if (remaining == 0) {
      return dark ? FColors.adminDarkError : FColors.adminLightError;
    } else if (remaining <= 10) {
      return dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
    } else {
      return dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
    }
  }
}