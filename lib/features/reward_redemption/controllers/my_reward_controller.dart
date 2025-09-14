import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

class MyRewardsController extends GetxController with GetSingleTickerProviderStateMixin {
  static MyRewardsController get instance => Get.find();

  // Tab Controller
  late TabController tabController;

  // Observable variables
  final RxList<RedemptionModel> userRedemptions = <RedemptionModel>[].obs;
  final RxList<RewardModel> availableRewards = <RewardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    currentUserId.value = 'current_user_id'; // In real app, get from auth service
    loadUserRedemptions();
    loadAvailableRewards();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Load user's redemptions from database
  Future<void> loadUserRedemptions() async {
    try {
      isLoading.value = true;

      // Mock data - In real app, fetch from Firebase
      final mockRedemptions = [
        RedemptionModel(
          redemptionId: '1',
          userId: currentUserId.value,
          rewardId: '1',
          pinCode: '123456',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          status: 'pending',
        ),
        RedemptionModel(
          redemptionId: '2',
          userId: currentUserId.value,
          rewardId: '2',
          pinCode: '789012',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          status: 'used',
        ),
        RedemptionModel(
          redemptionId: '3',
          userId: currentUserId.value,
          rewardId: '3',
          pinCode: '345678',
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          status: 'expired',
        ),
        RedemptionModel(
          redemptionId: '4',
          userId: currentUserId.value,
          rewardId: '4',
          pinCode: '901234',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          status: 'pending',
        ),
        RedemptionModel(
          redemptionId: '5',
          userId: currentUserId.value,
          rewardId: '1',
          pinCode: '567890',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          status: 'used',
        ),
      ];

      userRedemptions.assignAll(mockRedemptions);
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load redemptions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load available rewards to get reward details
  Future<void> loadAvailableRewards() async {
    try {
      // Mock data - In real app, fetch from Firebase
      final mockRewards = [
        RewardModel(
          rewardId: '1',
          title: 'Shopee RM 30 Voucher',
          description: 'Get RM 30 off your next Shopee purchase. Valid for 30 days from redemption.',
          termsConditions: '1. Valid for 30 days from redemption\n2. Cannot be combined with other offers\n3. Minimum purchase of RM 50 required\n4. Valid for selected categories only',
          rewardImage: 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Shopee+Voucher',
          pointsNeeded: 1000,
          quantity: 100,
          validUntil: DateTime.now().add(const Duration(days: 90)),
          redemptionCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          status: 'active',
        ),
        RewardModel(
          rewardId: '2',
          title: 'Lazada RM 60 Voucher',
          description: 'Enjoy RM 60 discount on Lazada shopping. Perfect for electronics and fashion.',
          termsConditions: '1. Valid for 45 days from redemption\n2. Minimum spend RM 100\n3. Applicable to all categories\n4. One-time use only',
          rewardImage: 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Lazada+Voucher',
          pointsNeeded: 2000,
          quantity: 50,
          validUntil: DateTime.now().add(const Duration(days: 120)),
          redemptionCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          status: 'active',
        ),
        RewardModel(
          rewardId: '3',
          title: 'Grab Food RM 15 Voucher',
          description: 'Free delivery and RM 15 off on your favorite meals through Grab Food.',
          termsConditions: '1. Valid for 14 days from redemption\n2. Free delivery included\n3. Minimum order RM 25\n4. Available in selected areas only',
          rewardImage: 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Grab+Food',
          pointsNeeded: 500,
          quantity: 200,
          validUntil: DateTime.now().add(const Duration(days: 60)),
          redemptionCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          status: 'active',
        ),
        RewardModel(
          rewardId: '4',
          title: 'Cinema Discount 50%',
          description: 'Enjoy 50% discount on movie tickets at participating cinemas nationwide.',
          termsConditions: '1. Valid for 60 days from redemption\n2. Maximum 2 tickets per redemption\n3. Not valid on public holidays\n4. Subject to seat availability',
          rewardImage: 'https://via.placeholder.com/300x200/F7931E/FFFFFF?text=Cinema+Ticket',
          pointsNeeded: 1500,
          quantity: 30,
          validUntil: DateTime.now().add(const Duration(days: 180)),
          redemptionCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          status: 'active',
        ),
      ];

      availableRewards.assignAll(mockRewards);
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load rewards data: $e');
    }
  }

  /// Get reward details by ID
  RewardModel? getRewardById(String rewardId) {
    try {
      return availableRewards.firstWhere((reward) => reward.rewardId == rewardId);
    } catch (e) {
      return null;
    }
  }

  /// Get active redemptions (pending status and not expired)
  List<RedemptionModel> get activeRedemptions {
    return userRedemptions.where((redemption) {
      // Check if redemption is pending and within validity period (30 days default)
      final isWithinValidityPeriod = DateTime.now().difference(redemption.createdAt).inDays < 30;
      return redemption.isPending && isWithinValidityPeriod;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
  }

  /// Get past redemptions (expired or used)
  List<RedemptionModel> get pastRedemptions {
    return userRedemptions.where((redemption) {
      final isExpired = DateTime.now().difference(redemption.createdAt).inDays >= 30;
      return redemption.isUsed || redemption.isExpired || (redemption.isPending && isExpired);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
  }

  /// Get all redemptions for transaction history
  List<RedemptionModel> get transactionHistory {
    return List.from(userRedemptions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadUserRedemptions(),
      loadAvailableRewards(),
    ]);
  }

  /// Mark redemption as used
  Future<void> markRedemptionAsUsed(String redemptionId) async {
    try {
      final index = userRedemptions.indexWhere((r) => r.redemptionId == redemptionId);
      if (index != -1) {
        userRedemptions[index].markAsUsed();
        userRedemptions.refresh();

        // In real app, update in Firebase
        FLoaders.successSnackBar(
          title: 'Success',
          message: 'Redemption marked as used',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update redemption: $e',
      );
    }
  }

  /// Get redemption summary for dashboard
  Map<String, int> get redemptionSummary {
    return {
      'active': activeRedemptions.length,
      'used': userRedemptions.where((r) => r.isUsed).length,
      'expired': userRedemptions.where((r) => r.isExpired).length,
      'total': userRedemptions.length,
    };
  }

  /// Check if redemption is about to expire (within 7 days)
  bool isRedemptionNearExpiry(RedemptionModel redemption) {
    if (!redemption.isPending) return false;

    final expiryDate = redemption.createdAt.add(const Duration(days: 30));
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
  }

  /// Get days until redemption expires
  int getDaysUntilExpiry(RedemptionModel redemption) {
    final expiryDate = redemption.createdAt.add(const Duration(days: 30));
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry;
  }

  /// Auto-expire pending redemptions that are past their validity period
  void autoExpireRedemptions() {
    for (var redemption in userRedemptions) {
      if (redemption.shouldExpire()) {
        redemption.autoExpireIfNeeded();
      }
    }
    userRedemptions.refresh();
  }
}