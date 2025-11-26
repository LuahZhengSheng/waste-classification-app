import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/achievement/user_achievement_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/data/repositories/achievement/achievement_repostory.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../authentication/models/user_model.dart';
import '../../../leaderboard_achievement/models/achievement_level_model.dart';
import '../../../leaderboard_achievement/models/achievement_model.dart';
import '../../../leaderboard_achievement/models/user_achievement_model.dart';
import '../../screens/achievement_management/edit_achievement/edit_achievement.dart';

class AchievementDetailsController extends GetxController {
  // Repositories
  final _achievementRepo = Get.put(AchievementRepository());
  final _userAchievementRepo = Get.put(UserAchievementRepository());
  final _userRepo = Get.put(UserRepository());

  // Observables
  final RxBool isLoading = false.obs;
  final Rx<Achievement?> achievement = Rx<Achievement?>(null);
  final RxList<UserAchievement> userAchievements = <UserAchievement>[].obs;
  final RxMap<int, List<UserModel>> levelUsers = <int, List<UserModel>>{}.obs;
  final RxMap<int, int> levelUserCounts = <int, int>{}.obs;
  final RxInt totalUsersWithAchievement = 0.obs;

  // Stream subscriptions
  StreamSubscription? _achievementSubscription;
  StreamSubscription? _userAchievementsSubscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Achievement) {
      loadAchievementDetails(args);
    }
  }

  void loadAchievementDetails(Achievement achievementModel) async {
    try {
      isLoading.value = true;
      achievement.value = achievementModel;

      // Preload badge images
      await preloadBadgeImages(achievementModel.achievementLevels);

      // Listen to achievement changes (real-time)
      _achievementSubscription?.cancel();
      _achievementSubscription = _achievementRepo
          .getAchievementStream(achievementModel.achievementId)
          .listen(
            (updatedAchievement) async {
          achievement.value = updatedAchievement;

          // Reload user achievement data when achievement changes
          await loadUserAchievementData();
        },
        onError: (error) {
          print('Error in achievement stream: $error');
        },
      );

      // Load user achievement data
      await loadUserAchievementData();

    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load achievement details: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserAchievementData() async {
    try {
      if (achievement.value == null) return;

      // Get all user achievements for this achievement
      final achievements = await _userAchievementRepo
          .getUserAchievementsByAchievementId(achievement.value!.achievementId);

      userAchievements.value = achievements;

      // Calculate level statistics
      await calculateLevelStatistics();
    } catch (e) {
      print('Error loading user achievement data: $e');
    }
  }

  Future<void> calculateLevelStatistics() async {
    levelUsers.clear();
    levelUserCounts.clear();

    // Group users by achievement level
    final userIdsByLevel = <int, Set<String>>{};

    for (var userAchievement in userAchievements) {
      final level = userAchievement.currentLevel;

      if (level > 0) { // Only count users who have unlocked at least level 1
        if (!userIdsByLevel.containsKey(level)) {
          userIdsByLevel[level] = {};
        }
        userIdsByLevel[level]!.add(userAchievement.userId);
      }
    }

    // Fetch user details for each level
    for (var entry in userIdsByLevel.entries) {
      final level = entry.key;
      final userIds = entry.value.toList();

      if (userIds.isEmpty) continue;

      try {
        // Fetch users in batches to avoid overwhelming Firestore
        final users = <UserModel>[];

        for (var i = 0; i < userIds.length; i += 10) {
          final batchIds = userIds.skip(i).take(10).toList();

          for (var userId in batchIds) {
            try {
              final user = await _userRepo.fetchOtherUserDetails(userId);
              if (user != UserModel.empty()) {
                users.add(user);

                // Preload profile image
                if (user.profileImg != null && user.profileImg!.isNotEmpty) {
                  await _userRepo.getProfileImageUrl(user.profileImg!);
                }
              }
            } catch (e) {
              print('Error fetching user $userId: $e');
            }
          }
        }

        // Sort by reward points (descending)
        users.sort((a, b) => b.totalRewardPoint.compareTo(a.totalRewardPoint));

        levelUsers[level] = users;
        levelUserCounts[level] = users.length;
      } catch (e) {
        print('Error fetching users for level $level: $e');
      }
    }

    // Calculate total unique users
    final allUserIds = <String>{};
    for (var userAchievement in userAchievements) {
      if (userAchievement.currentLevel > 0) {
        allUserIds.add(userAchievement.userId);
      }
    }
    totalUsersWithAchievement.value = allUserIds.length;
  }

  double getLevelCompletionPercentage(int level) {
    if (totalUsersWithAchievement.value == 0) return 0.0;

    final levelCount = levelUserCounts[level] ?? 0;
    return levelCount / totalUsersWithAchievement.value;
  }

  List<UserModel> getUsersForLevel(int level) {
    return levelUsers[level] ?? [];
  }

  int getUserCountForLevel(int level) {
    return levelUserCounts[level] ?? 0;
  }

  /// Get top users by progress (highest progress first)
  Future<List<UserModel>> getTopUsersByProgressDirect() async {
    try {
      if (achievement.value == null) return [];

      // Get all user achievements for this achievement
      final userAchievements = await _userAchievementRepo
          .getUserAchievementsByAchievementId(achievement.value!.achievementId);

      if (userAchievements.isEmpty) return [];

      // Sort by level (descending) and then by progress (descending)
      userAchievements.sort((a, b) {
        final levelComparison = b.currentLevel.compareTo(a.currentLevel);
        if (levelComparison != 0) return levelComparison;
        return b.progress.compareTo(a.progress);
      });

      // Take top 10 user achievements
      final topUserAchievements = userAchievements.take(10).toList();

      // Fetch user details directly from Firestore
      final topUsers = <UserModel>[];
      for (final userAchievement in topUserAchievements) {
        try {
          final user = await _userRepo.fetchOtherUserDetails(userAchievement.userId);
          if (user != UserModel.empty()) {
            topUsers.add(user);
          }
        } catch (e) {
          print('Error fetching user ${userAchievement.userId}: $e');
        }
      }

      return topUsers;
    } catch (e) {
      print('Error getting top users by progress: $e');
      return [];
    }
  }

  /// Get user achievement for a specific user
  UserAchievement? getUserAchievementForUser(String userId) {
    return userAchievements.firstWhereOrNull((ua) => ua.userId == userId);
  }

  String getAchievementStatus() {
    final achievementModel = achievement.value;
    if (achievementModel == null) return 'unknown';
    return achievementModel.status;
  }

  Color getStatusColor(bool dark) {
    final status = getAchievementStatus();
    switch (status) {
      case 'active':
        return dark ? const Color(0xFF4FD69C) : const Color(0xFF2DCE89);
      case 'inactive':
        return dark ? const Color(0xFF64748B) : const Color(0xFF8898AA);
      default:
        return dark ? const Color(0xFF94A3B8) : const Color(0xFFADB5BD);
    }
  }

  Future<void> refreshData() async {
    if (achievement.value != null) {
      await loadUserAchievementData();
    }
  }

  void editAchievement() {
    if (achievement.value == null) return;

    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      EditAchievementDialog(dark: dark),
      arguments: achievement.value,
      barrierDismissible: false,
    ).then((_) {
      // Reload data after dialog closes
      refreshData();
    });
  }

  Future<void> toggleAchievementStatus() async {
    final achievementModel = achievement.value;
    if (achievementModel == null) return;

    final currentStatus = getAchievementStatus();
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Get.isDarkMode ? const Color(0xFF111B2B) : Colors.white,
        title: Text(
          '${newStatus == 'active' ? 'Activate' : 'Deactivate'} Achievement',
          style: TextStyle(
            color: Get.isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF32325D),
          ),
        ),
        content: Text(
          newStatus == 'active'
              ? 'Are you sure you want to activate "${achievementModel.title}"? Users will be able to unlock this achievement and its levels.'
              : 'Are you sure you want to deactivate "${achievementModel.title}"? Users will no longer be able to unlock new levels for this achievement.',
          style: TextStyle(
            color: Get.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF8898AA),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Get.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF8898AA),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'active'
                  ? (Get.isDarkMode ? const Color(0xFF4FD69C) : const Color(0xFF2DCE89))
                  : (Get.isDarkMode ? const Color(0xFFFC7C8A) : const Color(0xFFF5365C)),
            ),
            child: Text(
              newStatus == 'active' ? 'Activate' : 'Deactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateAchievementStatus(newStatus);
    }
  }

  Future<void> _updateAchievementStatus(String newStatus) async {
    try {
      FLoaders.showLoading('Updating achievement status...');

      await _achievementRepo.updateAchievementStatus(
        achievement.value!.achievementId,
        newStatus,
      );

      FLoaders.stopLoading();

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: 'Achievement ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update achievement status: $e',
      );
    }
  }

  // New methods for badge image handling
  Future<void> preloadBadgeImages(List<AchievementLevel> levels) async {
    await _achievementRepo.preloadBadgeImages(levels);
  }

  String? getCachedBadgeImageUrl(String badgeImage) {
    return _achievementRepo.getCachedBadgeImageUrl(badgeImage);
  }

  // New methods for user profile image handling
  String? getCachedProfileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return null;
    return _userRepo.getCachedProfileImageUrl(profileImage);
  }

  @override
  void onClose() {
    _achievementSubscription?.cancel();
    _userAchievementsSubscription?.cancel();
    super.onClose();
  }
}