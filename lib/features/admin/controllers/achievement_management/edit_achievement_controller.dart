import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import 'package:fyp/utils/popups/loaders.dart';
import '../../../../data/repositories/achievement/achievement_repository.dart';
import '../../../leaderboard_achievement/models/achievement_level_model.dart';
import '../../../leaderboard_achievement/models/achievement_model.dart';

class EditAchievementController extends GetxController {
  final _achievementRepo = Get.put(AchievementRepository());

  // Observables
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final Rx<Achievement?> achievement = Rx<Achievement?>(null);
  final RxList<AchievementLevel> editedLevels = <AchievementLevel>[].obs;
  final RxBool hasChanges = false.obs;
  final RxBool canSave = false.obs;

  // 🆕 Error messages for each level and field
  final RxMap<String, String> validationErrors = <String, String>{}.obs;

  // Stream subscription
  StreamSubscription<Achievement?>? _achievementSubscription;

  @override
  void onInit() {
    super.onInit();
    print('🚀 EditAchievementController onInit called');

    final args = Get.arguments;
    print('📦 Arguments received: $args (type: ${args.runtimeType})');

    if (args != null && args is String) {
      print('✅ Valid achievement ID received: $args');
      _setupAchievementStream(args);
    } else {
      print('❌ Invalid arguments - expected String, got: ${args.runtimeType}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FAdminLoaders.errorSnackBar(
          title: 'Error',
          message: 'Invalid achievement ID',
        );
        Get.back();
      });
    }

    // Monitor changes
    ever(editedLevels, (_) => _validateChanges());

    print('✅ EditAchievementController onInit completed');
  }

  void _setupAchievementStream(String achievementId) {
    print('🔄 Setting up stream for: $achievementId');
    _achievementSubscription?.cancel();

    _achievementSubscription = _achievementRepo
        .getAchievementStream(achievementId)
        .listen(
          (updatedAchievement) {
        print('📥 Stream received data: ${updatedAchievement?.achievementId ?? "null"}');

        if (updatedAchievement != null && updatedAchievement.achievementId.isNotEmpty) {
          if (achievement.value == null) {
            print('✅ First load, setting achievement');
            achievement.value = updatedAchievement;
            _initializeLevels();
            isLoading.value = false;
          } else if (!hasChanges.value) {
            print('🔄 Updating achievement (no unsaved changes)');
            achievement.value = updatedAchievement;
            _initializeLevels();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              FAdminLoaders.customToast(
                message: 'Achievement updated',
              );
            });
          } else {
            print('⚠️ Has unsaved changes, not updating');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FAdminLoaders.customToast(
                message: 'Achievement has been updated. Your changes will override.',
              );
            });
          }
        } else {
          print('❌ Achievement not found or empty');
          isLoading.value = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FAdminLoaders.errorSnackBar(
              title: 'Error',
              message: 'Achievement not found',
            );
            Get.back();
          });
        }
      },
      onError: (error) {
        print('❌ Error in achievement stream: $error');
        isLoading.value = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          FAdminLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to load achievement: $error',
          );
        });
      },
    );
  }

  void _initializeLevels() {
    if (achievement.value == null) return;

    editedLevels.value = achievement.value!.achievementLevels
        .map((level) => level.copyWith())
        .toList();

    hasChanges.value = false;
    validationErrors.clear(); // 🆕 清除错误
  }

  /// 🆕 Get error message for a specific field
  String? getFieldError(int index, String field) {
    final key = 'level_${index}_$field';
    return validationErrors[key];
  }

  /// 🆕 Set error message for a specific field
  void setFieldError(int index, String field, String? error) {
    final key = 'level_${index}_$field';
    if (error != null) {
      validationErrors[key] = error;
    } else {
      validationErrors.remove(key);
    }
  }

  /// 🆕 Clear all errors
  void clearErrors() {
    validationErrors.clear();
  }

  /// Get minimum reward points for a level
  int getMinimumRewardPoints(int index) {
    if (index == 0) return 1;
    final previousLevel = editedLevels[index - 1];
    return (previousLevel.rewardPoints * 1.25).ceil();
  }

  /// Get minimum unlock criteria for a level
  int getMinimumUnlockCriteria(int index) {
    if (index == 0) return 1;
    final previousLevel = editedLevels[index - 1];
    return (previousLevel.unlockCriteria * 1.25).ceil();
  }

  /// Update a specific field of a level
  void updateLevelField(int index, String field, dynamic value) {
    if (index < 0 || index >= editedLevels.length) return;

    final level = editedLevels[index];
    switch (field) {
      case 'badgeImage':
        editedLevels[index] = level.copyWith(badgeImage: value as String);
        break;
      case 'title':
        editedLevels[index] = level.copyWith(title: value as String);
        break;
      case 'description':
        editedLevels[index] = level.copyWith(description: value as String);
        break;
      case 'unlockCriteria':
        editedLevels[index] = level.copyWith(unlockCriteria: value as int);
        break;
      case 'rewardPoints':
        editedLevels[index] = level.copyWith(rewardPoints: value as int);
        break;
    }

    _validateChanges();
  }

  /// Add a new level
  void addLevel() {
    if (editedLevels.length >= 7) {
      FAdminLoaders.warningSnackBar(
        title: 'Maximum Levels Reached',
        message: 'You can only have a maximum of 7 levels.',
      );
      return;
    }

    final newLevelNumber = editedLevels.length + 1;
    final previousLevel = editedLevels.isNotEmpty ? editedLevels.last : null;

    final minUnlockCriteria = previousLevel != null
        ? (previousLevel.unlockCriteria * 1.25).ceil()
        : 10;

    final minRewardPoints = previousLevel != null
        ? (previousLevel.rewardPoints * 1.25).ceil()
        : 10;

    final newLevel = AchievementLevel(
      achievementLevelId: '',
      level: newLevelNumber,
      unlockCriteria: minUnlockCriteria,
      title: 'Level $newLevelNumber',
      description: 'Complete this level to progress further',
      badgeImage: '🏆',
      rewardPoints: minRewardPoints,
    );

    editedLevels.add(newLevel);
    _validateChanges();
  }

  /// Remove a level
  void removeLevel(int index) {
    if (index < 3) {
      FAdminLoaders.warningSnackBar(
        title: 'Cannot Remove Level',
        message: 'You can only remove Level 4 and above. The first 3 levels are required.',
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF111B2B)
            : Colors.white,
        title: Text(
          'Remove Level ${editedLevels[index].level}?',
          style: TextStyle(
            color: Get.isDarkMode
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF32325D),
          ),
        ),
        content: Text(
          'Are you sure you want to remove this level? All subsequent levels will be renumbered.',
          style: TextStyle(
            color: Get.isDarkMode
                ? const Color(0xFF94A3B8)
                : const Color(0xFF8898AA),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Get.isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF8898AA),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performRemoveLevel(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.isDarkMode
                  ? const Color(0xFFFC7C8A)
                  : const Color(0xFFF5365C),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _performRemoveLevel(int index) {
    editedLevels.removeAt(index);

    List<AchievementLevel> renumberedLevels = [];
    for (int i = 0; i < editedLevels.length; i++) {
      renumberedLevels.add(editedLevels[i].copyWith(level: i + 1));
    }

    editedLevels.value = renumberedLevels;
    _validateChanges();
  }

  /// Validate all changes
  void _validateChanges() {
    clearErrors(); // 🆕 清除所有旧错误
    bool isValid = true;

    // Check minimum levels
    if (editedLevels.length < 3) {
      isValid = false;
    }

    // Check each level
    for (int i = 0; i < editedLevels.length; i++) {
      final level = editedLevels[i];

      // Check badge emoji is not empty
      if (level.badgeImage.trim().isEmpty) {
        setFieldError(i, 'badgeImage', 'Badge emoji is required');
        isValid = false;
      }

      // Check title is not empty
      if (level.title.trim().isEmpty) {
        setFieldError(i, 'title', 'Title is required');
        isValid = false;
      }

      // Check description is not empty
      if (level.description.trim().isEmpty) {
        setFieldError(i, 'description', 'Description is required');
        isValid = false;
      }

      // Check unlock criteria
      if (level.unlockCriteria <= 0) {
        setFieldError(i, 'unlockCriteria', 'Must be greater than 0');
        isValid = false;
      } else if (i > 0) {
        final previousLevel = editedLevels[i - 1];
        final minCriteria = (previousLevel.unlockCriteria * 1.25).ceil();
        if (level.unlockCriteria < minCriteria) {
          setFieldError(i, 'unlockCriteria', 'Must be at least $minCriteria (25% more than previous level)');
          isValid = false;
        }
      }

      // Check reward points
      if (level.rewardPoints <= 0) {
        setFieldError(i, 'rewardPoints', 'Must be greater than 0');
        isValid = false;
      } else if (i > 0) {
        final previousLevel = editedLevels[i - 1];
        final minPoints = (previousLevel.rewardPoints * 1.25).ceil();
        if (level.rewardPoints < minPoints) {
          setFieldError(i, 'rewardPoints', 'Must be at least $minPoints (25% more than previous level)');
          isValid = false;
        }
      }
    }

    // 检查是否真的有变化
    bool actuallyChanged = _hasActualChanges();

    // 只有在有效且真的有变化时才能保存
    canSave.value = isValid && actuallyChanged;
  }

  /// 检查是否真的有变化（深度比较）
  bool _hasActualChanges() {
    if (achievement.value == null) return false;

    final originalLevels = achievement.value!.achievementLevels;
    final currentLevels = editedLevels;

    if (originalLevels.length != currentLevels.length) {
      return true;
    }

    for (int i = 0; i < originalLevels.length; i++) {
      final original = originalLevels[i];
      final current = currentLevels[i];

      if (original.title != current.title ||
          original.description != current.description ||
          original.badgeImage != current.badgeImage ||
          original.unlockCriteria != current.unlockCriteria ||
          original.rewardPoints != current.rewardPoints) {
        return true;
      }
    }

    return false;
  }

  /// Save changes to Firestore
  Future<void> saveChanges() async {
    if (!canSave.value || achievement.value == null) return;

    FAdminLoaders.showAchievementUpdateDialog(
      changedFields: _getChangedFields(),
      onConfirm: () async {
        try {
          isSaving.value = true;
          FLoaders.showLoading('Saving changes...');

          await _achievementRepo.updateAchievementWithLevels(
            achievementId: achievement.value!.achievementId,
            levels: editedLevels,
          );

          FLoaders.stopLoading();

          FAdminLoaders.successSnackBar(
            title: 'Success',
            message: 'Achievement updated successfully',
          );

          hasChanges.value = false;
        } catch (e) {
          print('$e');
          FLoaders.stopLoading();
          FAdminLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to update achievement: $e',
          );
        } finally {
          isSaving.value = false;
        }
      },
    );
  }

  /// 获取更改的字段列表
  List<String> _getChangedFields() {
    if (achievement.value == null) return [];

    final List<String> changes = [];

    if (editedLevels.length != achievement.value!.achievementLevels.length) {
      changes.add('Number of levels (${achievement.value!.achievementLevels.length} → ${editedLevels.length})');
    }

    for (int i = 0; i < editedLevels.length; i++) {
      final editedLevel = editedLevels[i];
      final originalLevel = i < achievement.value!.achievementLevels.length
          ? achievement.value!.achievementLevels[i]
          : null;

      if (originalLevel == null) {
        changes.add('Added Level ${editedLevel.level}');
        continue;
      }

      if (editedLevel.title != originalLevel.title) {
        changes.add('Level ${editedLevel.level} title');
      }

      if (editedLevel.description != originalLevel.description) {
        changes.add('Level ${editedLevel.level} description');
      }

      if (editedLevel.badgeImage != originalLevel.badgeImage) {
        changes.add('Level ${editedLevel.level} badge');
      }

      if (editedLevel.unlockCriteria != originalLevel.unlockCriteria) {
        changes.add('Level ${editedLevel.level} unlock criteria (${originalLevel.unlockCriteria} → ${editedLevel.unlockCriteria})');
      }

      if (editedLevel.rewardPoints != originalLevel.rewardPoints) {
        changes.add('Level ${editedLevel.level} reward points (${originalLevel.rewardPoints} → ${editedLevel.rewardPoints})');
      }
    }

    return changes;
  }

  @override
  void onClose() {
    _achievementSubscription?.cancel();
    super.onClose();
  }
}
