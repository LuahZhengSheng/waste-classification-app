import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../reward_redemption/models/reward_model.dart';
import '../../../reward_redemption/models/redemption_model.dart';

class RewardDetailsController extends GetxController {
  final RewardModel initialReward;

  // Constructor to receive the reward
  RewardDetailsController({required RewardModel reward}) : initialReward = reward;

  // Observables
  late Rx<RewardModel> reward;
  final RxList<RedemptionModel> redemptions = <RedemptionModel>[].obs;
  final RxBool isLoadingRedemptions = false.obs;

  @override
  void onInit() {
    super.onInit();
    reward = initialReward.obs;
    loadRedemptions();
  }

  /// Get the computed status of the reward based on various conditions
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

  /// Load redemptions for this specific reward
  Future<void> loadRedemptions() async {
    try {
      isLoadingRedemptions.value = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock redemptions for this reward
      redemptions.value = _generateMockRedemptions();

    } catch (e) {
      FHelperFunctions.showSnackBar('Error loading redemptions: ${e.toString()}');
    } finally {
      isLoadingRedemptions.value = false;
    }
  }

  /// Generate mock redemption data
  List<RedemptionModel> _generateMockRedemptions() {
    final now = DateTime.now();
    final List<RedemptionModel> mockRedemptions = [];

    // Generate redemptions based on the reward's redemption count
    for (int i = 0; i < reward.value.redemptionCount; i++) {
      final createdAt = now.subtract(Duration(days: (i * 2) + 1, hours: i * 3));

      mockRedemptions.add(
        RedemptionModel(
          redemptionId: 'redemption_${reward.value.rewardId}_$i',
          userId: 'user_${1000 + i}',
          rewardId: reward.value.rewardId,
          pinCode: _generatePinCode(),
          createdAt: createdAt,
          status: _getRandomRedemptionStatus(),
        ),
      );
    }

    // Sort by creation date (newest first)
    mockRedemptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return mockRedemptions;
  }

  /// Generate a random 6-digit PIN code
  String _generatePinCode() {
    final codes = ['123456', '789012', '345678', '901234', '567890', '234567', '678901', '890123'];
    return codes[(DateTime.now().millisecond % codes.length)];
  }

  /// Get a random redemption status for mock data
  String _getRandomRedemptionStatus() {
    final statuses = ['pending', 'used', 'expired'];
    return statuses[DateTime.now().millisecond % statuses.length];
  }

  /// Toggle the reward status between active and inactive
  Future<void> toggleRewardStatus() async {
    try {
      final newStatus = reward.value.status == 'active' ? 'inactive' : 'active';

      // If activating, check constraints
      if (newStatus == 'active') {
        if (!_canActivateReward()) {
          return;
        }
      }

      // Update the reward status
      reward.value = reward.value.copyWith(status: newStatus);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Show success message
      final message = newStatus == 'active'
          ? 'Reward activated successfully'
          : 'Reward deactivated successfully';
      FHelperFunctions.showSnackBar(message);

    } catch (e) {
      FHelperFunctions.showSnackBar('Error updating reward status: ${e.toString()}');
    }
  }

  /// Check if the reward can be activated
  bool _canActivateReward() {
    final now = DateTime.now();

    // Check if quantity is available
    if (reward.value.quantity <= 0) {
      FHelperFunctions.showAlert(
        'Cannot Activate Reward',
        'Reward cannot be activated because quantity is 0. Please update the quantity first.',
      );
      return false;
    }

    // Check if reward hasn't expired
    if (reward.value.validUntil.isBefore(now)) {
      FHelperFunctions.showAlert(
        'Cannot Activate Reward',
        'Reward cannot be activated because the valid until date has passed. Please update the expiry date first.',
      );
      return false;
    }

    return true;
  }

  /// Refresh reward data
  Future<void> refreshReward() async {
    try {
      // Simulate API call to get updated reward data
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, you would fetch the updated reward from the API
      // For now, we'll just reload the redemptions
      await loadRedemptions();

      FHelperFunctions.showSnackBar('Reward data refreshed');

    } catch (e) {
      FHelperFunctions.showSnackBar('Error refreshing reward data: ${e.toString()}');
    }
  }

  /// Get reward availability text
  String getAvailabilityText() {
    final computedStatus = getComputedStatus();

    switch (computedStatus) {
      case 'active':
        return 'Available for redemption';
      case 'inactive':
        return 'Not available for redemption';
      case 'expired':
        return 'Expired and no longer available';
      case 'out_of_stock':
        return 'Out of stock';
      default:
        return 'Status unknown';
    }
  }

  /// Get the percentage of stock remaining
  double getStockPercentage() {
    if (reward.value.quantity == 0) return 0.0;
    return (reward.value.remainingQuantity / reward.value.quantity).clamp(0.0, 1.0);
  }

  /// Get stock status color based on remaining quantity
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

  /// Get time until expiry
  String getTimeUntilExpiry() {
    final now = DateTime.now();
    final validUntil = reward.value.validUntil;

    if (validUntil.isBefore(now)) {
      return 'Expired';
    }

    final difference = validUntil.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours remaining';
    } else {
      return 'Expires soon';
    }
  }

  /// Filter redemptions by status
  List<RedemptionModel> getRedemptionsByStatus(String status) {
    return redemptions.where((redemption) => redemption.status == status).toList();
  }

  /// Get pending redemptions count
  int get pendingRedemptionsCount {
    return redemptions.where((r) => r.status == 'pending').length;
  }

  /// Get used redemptions count
  int get usedRedemptionsCount {
    return redemptions.where((r) => r.status == 'used').length;
  }

  /// Get expired redemptions count
  int get expiredRedemptionsCount {
    return redemptions.where((r) => r.status == 'expired').length;
  }

  /// Export redemption data (for future implementation)
  Future<void> exportRedemptionData() async {
    try {
      // TODO: Implement export functionality
      FHelperFunctions.showSnackBar('Export functionality will be implemented soon');
    } catch (e) {
      FHelperFunctions.showSnackBar('Error exporting data: ${e.toString()}');
    }
  }

  /// Get redemption statistics
  Map<String, dynamic> getRedemptionStatistics() {
    return {
      'total': redemptions.length,
      'pending': pendingRedemptionsCount,
      'used': usedRedemptionsCount,
      'expired': expiredRedemptionsCount,
      'redemptionRate': reward.value.quantity > 0
          ? (redemptions.length / reward.value.quantity * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  /// Check if reward needs attention (low stock, expiring soon, etc.)
  bool get needsAttention {
    final now = DateTime.now();
    final daysUntilExpiry = reward.value.validUntil.difference(now).inDays;

    return reward.value.remainingQuantity <= 10 ||
        (daysUntilExpiry <= 7 && daysUntilExpiry > 0) ||
        reward.value.status == 'inactive';
  }

  /// Get attention message for the reward
  String? getAttentionMessage() {
    if (!needsAttention) return null;

    final now = DateTime.now();
    final daysUntilExpiry = reward.value.validUntil.difference(now).inDays;

    if (reward.value.status == 'inactive') {
      return 'This reward is currently inactive';
    }

    if (reward.value.remainingQuantity <= 10) {
      return 'Low stock: Only ${reward.value.remainingQuantity} items remaining';
    }

    if (daysUntilExpiry <= 7 && daysUntilExpiry > 0) {
      return 'Expiring soon: $daysUntilExpiry days remaining';
    }

    return null;
  }

  @override
  void onClose() {
    // Clean up any resources if needed
    super.onClose();
  }
}