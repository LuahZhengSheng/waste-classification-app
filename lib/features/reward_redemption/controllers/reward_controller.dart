import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';

class RewardController extends GetxController {
  static RewardController get instance => Get.find();

  // Observable variables
  final RxList<RewardModel> rewards = <RewardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt userPoints = 1200.obs; // Current user points
  final RxString currentUserId = ''.obs; // Current user ID

  @override
  void onInit() {
    super.onInit();
    loadRewards();
    // In real app, get current user ID from auth service
    currentUserId.value = 'current_user_id';
  }

  /// Load all available rewards
  Future<void> loadRewards() async {
    try {
      isLoading.value = true;

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
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          status: 'active',
        ),
      ];

      rewards.assignAll(mockRewards);
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load rewards: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user can redeem a reward
  bool canRedeemReward(RewardModel reward) {
    return userPoints.value >= reward.pointsNeeded &&
        reward.isAvailable &&
        !reward.hasUserRedeemed(currentUserId.value);
  }

  /// Get insufficient points message
  String getInsufficientPointsMessage(RewardModel reward) {
    final pointsNeeded = reward.pointsNeeded - userPoints.value;
    return 'You need $pointsNeeded more points to redeem this reward';
  }

  /// Redeem a reward
  Future<bool> redeemReward(RewardModel reward) async {
    try {
      if (!canRedeemReward(reward)) {
        if (userPoints.value < reward.pointsNeeded) {
          FLoaders.errorSnackBar(
            title: 'Insufficient Points',
            message: getInsufficientPointsMessage(reward),
          );
        } else if (reward.hasUserRedeemed(currentUserId.value)) {
          FLoaders.errorSnackBar(
            title: 'Already Redeemed',
            message: 'You have already redeemed this reward',
          );
        } else {
          FLoaders.errorSnackBar(
            title: 'Unavailable',
            message: 'This reward is currently unavailable',
          );
        }
        return false;
      }

      isLoading.value = true;

      // Create redemption
      final redemption = RedemptionModel.createNew(
        userId: currentUserId.value,
        rewardId: reward.rewardId,
      );

      // In real app, save to Firebase and deduct points
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Add redemption to reward
      reward.addRedemption(redemption);

      // Deduct points
      userPoints.value -= reward.pointsNeeded;

      // Update rewards list
      final index = rewards.indexWhere((r) => r.rewardId == reward.rewardId);
      if (index != -1) {
        rewards[index] = reward;
      }

      FLoaders.successSnackBar(
        title: 'Success!',
        message: 'Reward redeemed successfully! PIN: ${redemption.formattedPinCode}',
      );

      return true;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to redeem reward: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get user's redemption for a specific reward
  RedemptionModel? getUserRedemption(RewardModel reward) {
    return reward.getUserRedemption(currentUserId.value);
  }

  /// Get reward by ID
  RewardModel? getRewardById(String rewardId) {
    try {
      return rewards.firstWhere((reward) => reward.rewardId == rewardId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh rewards list
  Future<void> refreshRewards() async {
    await loadRewards();
  }

  /// Filter available rewards
  List<RewardModel> get availableRewards {
    return rewards.where((reward) => reward.isAvailable).toList();
  }

  /// Filter rewards by points requirement
  List<RewardModel> getRewardsByPointsRange(int minPoints, int maxPoints) {
    return rewards.where((reward) =>
    reward.pointsNeeded >= minPoints && reward.pointsNeeded <= maxPoints
    ).toList();
  }

  /// Get affordable rewards for current user
  List<RewardModel> get affordableRewards {
    return rewards.where((reward) =>
    reward.pointsNeeded <= userPoints.value && reward.isAvailable
    ).toList();
  }
}