import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/features/leaderboard_achievement/models/achievement_model.dart';

import '../../../../data/repositories/achievement/achievement_repostory.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/admin_loaders.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/achievement_management/achievement_management/widgets/achievement_filter_dialog.dart';
import '../../screens/achievement_management/edit_achievement/edit_achievement.dart';

class AchievementManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Repository
  final _achievementRepo = Get.put(AchievementRepository());

  // Observables
  final RxList<Achievement> allAchievements = <Achievement>[].obs;
  final RxList<Achievement> filteredAchievements = <Achievement>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'active'.obs; // 'active' or 'inactive'
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'category': null,
    'maxLevelRange': null,
  }.obs;

  // Stream subscription
  StreamSubscription<List<Achievement>>? _achievementsSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupAchievementsStream();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(), time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
    ever(selectedStatusFilter, (_) => _setupAchievementsStream());
  }

  /// Set up achievements stream based on current filter
  void _setupAchievementsStream() {
    // Cancel existing subscription
    _achievementsSubscription?.cancel();

    // Show loading state immediately when switching tabs
    isLoading.value = true;
    filteredAchievements.clear();

    // Set up new stream based on status filter
    Stream<List<Achievement>> stream;
    if (selectedStatusFilter.value == 'all') {
      stream = _achievementRepo.getAllAchievementsStream();
    } else {
      // For specific status, we need to filter the all achievements stream
      stream = _achievementRepo.getAllAchievementsStream().map((achievements) {
        return achievements.where((achievement) => achievement.status == selectedStatusFilter.value).toList();
      });
    }

    _achievementsSubscription = stream.listen(
          (achievements) {
        allAchievements.value = achievements;
        applyFiltersAndSearch();
        isLoading.value = false;
      },
      onError: (error) {
        print('Error in achievements stream: $error');
        FAdminLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load achievements: $error',
        );
        isLoading.value = false;
      },
    );
  }

  /// Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<Achievement> result = List.from(allAchievements);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((achievement) {
        return achievement.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            achievement.category.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            achievement.achievementId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            achievement.maxLevel.toString().contains(searchQuery.value);
      }).toList();
    }

    // Apply filters
    if (activeFilters['category'] != null) {
      result = result.where((achievement) =>
      achievement.category == activeFilters['category']).toList();
    }

    if (activeFilters['maxLevelRange'] != null) {
      result = result.where((achievement) {
        switch (activeFilters['maxLevelRange']) {
          case 'low':
            return achievement.maxLevel >= 1 && achievement.maxLevel <= 3;
          case 'medium':
            return achievement.maxLevel >= 4 && achievement.maxLevel <= 6;
          case 'high':
            return achievement.maxLevel >= 7;
          default:
            return true;
        }
      }).toList();
    }

    filteredAchievements.value = result;
    currentPage.value = 1; // Reset to first page after filtering
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['category'] != null ||
        activeFilters['maxLevelRange'] != null;
  }

  /// Sorting functionality
  void sortAchievements(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredAchievements.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Achievement ID
          aValue = a.achievementId;
          bValue = b.achievementId;
          break;
        case 1: // Title
          aValue = a.title;
          bValue = b.title;
          break;
        case 2: // Category
          aValue = a.category;
          bValue = b.category;
          break;
        case 3: // Max Level
          aValue = a.maxLevel;
          bValue = b.maxLevel;
          break;
        case 4: // Created At
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });
  }

  /// Achievement actions
  Future<void> toggleAchievementStatus(Achievement achievement) async {
    try {
      final newStatus = achievement.status == 'active' ? 'inactive' : 'active';

      FLoaders.showLoading('Updating achievement status...');

      await _achievementRepo.updateAchievementStatus(achievement.achievementId, newStatus);

      FLoaders.stopLoading();

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: 'Achievement ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully',
      );

      // No need to reload achievements manually - stream will update automatically
    } catch (e) {
      print('$e');
      FLoaders.stopLoading();
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update achievement status: $e',
      );
    }
  }

  void viewAchievement(Achievement achievement) {
    // Navigation handled in UI
  }

  void editAchievement(Achievement achievement) {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      EditAchievementDialog(dark: dark),
      arguments: achievement,
      barrierDismissible: false,
    ).then((_) {
      // No need to reload achievements manually - stream will update automatically
    });
  }

  /// Pagination functionality
  List<Achievement> get paginatedAchievements {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredAchievements.length);

    if (startIndex >= filteredAchievements.length) {
      return [];
    }

    return filteredAchievements.sublist(startIndex, endIndex);
  }

  int get totalAchievements => filteredAchievements.length;
  int get totalPages => (totalAchievements / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalAchievements);

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => currentPage.value < totalPages;

  void previousPage() {
    if (canGoPreviousPage) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (canGoNextPage) {
      currentPage.value++;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1; // Reset to first page
    }
  }

  void showFilters() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      AchievementFilterDialog(
        dark: dark,
        currentFilters: Map.from(activeFilters),
        onApplyFilters: (newFilters) {
          activeFilters.assignAll(newFilters);
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    _achievementsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}