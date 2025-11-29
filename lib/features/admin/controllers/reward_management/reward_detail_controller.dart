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
        _rewardRepo.getRewardStream(initialReward.rewardId).listen(
              (updatedReward) {
            print('📡 listenToReward -> incoming status: ${updatedReward.status}, hash: ${updatedReward.hashCode}');
            print('📡 listenToReward -> before assign, local status: ${reward.value.status}, hash: ${reward.value.hashCode}');
            print('📡 listenToReward -> identical(reward.value, updatedReward): ${identical(reward.value, updatedReward)}');

            reward.value = updatedReward;

            print('📡 listenToReward -> after assign, local status: ${reward.value.status}, hash: ${reward.value.hashCode}');
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
    final currentStatus = reward.value.status;
    final computedStatus = _computeStatus(currentStatus);

    print('🔍 getComputedStatus():');
    print('   📝 Raw Status: $currentStatus');
    print('   🧮 Computed Status: $computedStatus');
    print('   📦 Remaining Quantity: ${reward.value.remainingQuantity}');
    print('   📅 Is Expired: ${reward.value.isExpired}');
    print('   ⏰ Valid Until: ${reward.value.validUntil}');
    print('   🕒 Now: ${DateTime.now()}');
    print('   🔑 reward.hash: ${reward.value.hashCode}');

    return computedStatus;
  }

  String _computeStatus(String rawStatus) {
    if (rawStatus == 'inactive') {
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
    final currentStatus = reward.value.status;
    final isActivating = currentStatus != 'active';

    print('🎯 Toggle Reward Status:');
    print('   📝 Current Status: $currentStatus');
    print('   🔄 Is Activating: $isActivating');
    print('   🏷️ Reward Title: ${reward.value.title}');

    // 使用 FAdminLoaders 显示确认对话框
    FAdminLoaders.showStatusToggleConfirmationDialog(
      title: isActivating ? 'Activate Reward' : 'Deactivate Reward',
      message: isActivating
          ? 'Are you sure you want to activate "${reward.value.title}"? It will be available for users to redeem.'
          : 'Are you sure you want to deactivate "${reward.value.title}"? Users will no longer be able to redeem this reward.',
      confirmButtonText: isActivating ? 'Activate' : 'Deactivate',
      onConfirm: () async {
        print('✅ Dialog confirmed, proceeding with status toggle...');
        await _performStatusToggle(isActivating);
      },
      isActivating: isActivating,
      itemName: reward.value.title,
    );
  }

  /// 执行状态切换的实际逻辑
  Future<void> _performStatusToggle(bool isActivating) async {
    try {
      final newStatus = isActivating ? 'active' : 'inactive';

      print('🔄 Updating reward status to: $newStatus');

      // 临时暂停流监听
      _rewardSubscription?.pause();

      // 创建新的实例并更新本地状态
      final updatedReward = reward.value.copyWith(status: newStatus);
      reward.value = updatedReward;

      print('✅ Local state updated to: ${reward.value.status}');

      // 强制UI更新
      update();

      // 等待UI更新完成
      await Future.delayed(const Duration(milliseconds: 50));

      // 更新到 Firestore
      print('🔥 Updating Firestore...');
      await _rewardRepo.updateRewardStatus(reward.value.rewardId, newStatus);

      print('✅ Firestore update completed');

      // 恢复流监听
      _rewardSubscription?.resume();

      final message = isActivating
          ? 'Reward activated successfully'
          : 'Reward deactivated successfully';

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: message,
      );

      print('🎉 Status toggle completed successfully');

    } catch (e) {
      print('❌ Error during status update: $e');

      // 恢复流监听
      _rewardSubscription?.resume();

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

    print('🔍 _canActivateReward() Check:');
    print('   📦 Remaining Quantity: ${reward.value.remainingQuantity}');
    print('   📅 Valid Until: ${reward.value.validUntil}');
    print('   🕒 Tomorrow: $tomorrow');
    print('   ✅ Valid Until is after tomorrow: ${reward.value.validUntil.isAfter(tomorrow)}');

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

    if (!reward.value.validUntil.isAfter(tomorrow)) {
      print('❌ Activation failed: valid until date is too soon');
      print('   📅 Valid Until: ${reward.value.validUntil}');
      print('   🕒 Tomorrow: $tomorrow');
      print('   ⏰ Difference: ${reward.value.validUntil.difference(tomorrow)}');

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