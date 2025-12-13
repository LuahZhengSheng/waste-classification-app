import 'package:get/get.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/features/waste_classification/models/waste_category_model.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/recycling_center/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../authentication/models/user_model.dart';

class RecycleActivityController extends GetxController {
  static RecycleActivityController get instance => Get.find();

  // Repositories
  final _activityRepo = Get.put(RecyclingActivityRepository());
  final _categoryRepo = Get.put(WasteCategoryRepository());
  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  // Observable variables
  final RxList<RecyclingActivity> activities = <RecyclingActivity>[].obs;
  final RxList<RecyclingActivity> filteredActivities = <RecyclingActivity>[].obs;
  final RxList<WasteCategory> wasteCategories = <WasteCategory>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<TimeFilter> selectedTimeFilter = TimeFilter.allTime.obs;
  final RxBool isRefreshing = false.obs;

  // Chart category selection
  final Rx<WasteCategory?> selectedCategoryForChart = Rx<WasteCategory?>(null);

  // 🆕 User statistics from User Collection
  final Rx<UserModel> currentUser = UserModel.empty().obs;

  @override
  void onInit() {
    super.onInit();
    _loadWasteCategories();
    _loadActivities();
    _loadUserData();
  }

  /// Load waste categories from repository
  void _loadWasteCategories() {
    _categoryRepo.getWasteCategoriesStream().listen((categories) {
      wasteCategories.assignAll(categories);
    });
  }

  /// 🆕 Load user data to get statistics from User Collection
  void _loadUserData() {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) return;

      _userRepo.getUserDetailsStream(userId).listen((user) {
        currentUser.value = user;
        print('📊 User stats loaded:');
        print('  Weight: ${user.totalWeightRecycled} kg');
        print('  Activities: ${user.totalRecyclingActivities}');
        print('  Emission: ${user.totalEmissionReduced} kg CO2e');
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Load activities from repository using stream
  void _loadActivities() {
    try {
      isLoading.value = true;
      final userId = _authRepo.authUser?.uid;
      if (userId == null) {
        FLoaders.errorSnackBar(title: 'Error', message: 'User not authenticated');
        return;
      }

      _activityRepo.getUserApprovedActivitiesStream(userId).listen((activityList) {
        activities.assignAll(activityList);
        applyFilters();
        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load activities: ${e.toString()}',
      );
    }
  }

  /// Refresh activities
  Future<void> refreshActivities() async {
    isRefreshing.value = true;
    // Stream will automatically update
    await Future.delayed(const Duration(milliseconds: 500));
    isRefreshing.value = false;
    FLoaders.successSnackBar(
      title: 'Refreshed',
      message: 'Activities list has been updated',
    );
  }

  /// Apply filters
  void applyFilters() {
    List<RecyclingActivity> filtered = List.from(activities);

    // Apply category filter from chart selection
    if (selectedCategoryForChart.value != null) {
      filtered = filtered
          .where((activity) =>
      activity.wasteCategoryId == selectedCategoryForChart.value!.categoryId)
          .toList();
    }

    // Apply time filter
    if (selectedTimeFilter.value != TimeFilter.allTime) {
      final now = DateTime.now();
      DateTime? filterStartDate;
      DateTime? filterEndDate;

      switch (selectedTimeFilter.value) {
        case TimeFilter.today:
          filterStartDate = DateTime(now.year, now.month, now.day);
          filterEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case TimeFilter.thisWeek:
          final weekday = now.weekday;
          filterStartDate = DateTime(now.year, now.month, now.day - weekday + 1);
          filterEndDate = DateTime(now.year, now.month, now.day + (7 - weekday), 23, 59, 59);
          break;
        case TimeFilter.thisMonth:
          filterStartDate = DateTime(now.year, now.month, 1);
          filterEndDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case TimeFilter.thisYear:
          filterStartDate = DateTime(now.year, 1, 1);
          filterEndDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        default:
          break;
      }

      if (filterStartDate != null && filterEndDate != null) {
        filtered = filtered.where((activity) {
          return activity.createdAt.isAfter(filterStartDate!) &&
              activity.createdAt.isBefore(filterEndDate!);
        }).toList();
      }
    }

    filteredActivities.assignAll(filtered);
  }

  /// Set time filter
  void setTimeFilter(TimeFilter filter) {
    selectedTimeFilter.value = filter;
    applyFilters();
  }

  /// Clear all filters
  void clearAllFilters() {
    selectedTimeFilter.value = TimeFilter.allTime;
    selectedCategoryForChart.value = null;
    applyFilters();
  }

  /// Clear category filter
  void clearCategoryFilter() {
    selectedCategoryForChart.value = null;
    applyFilters();
  }

  /// Check if there are any active filters
  bool get hasActiveFilters {
    return selectedTimeFilter.value != TimeFilter.allTime ||
        selectedCategoryForChart.value != null;
  }

  /// 🆕 Get total points earned from User Collection
  int get totalPointsEarned {
    return currentUser.value.totalRewardPoint;
  }

  /// 🆕 Get total weight recycled from User Collection
  double get totalWeightRecycled {
    return currentUser.value.totalWeightRecycled;
  }

  /// 🆕 Get total CO2 reduced from User Collection
  double get totalCO2Reduced {
    return currentUser.value.totalEmissionReduced;
  }

  /// Get waste category distribution for chart
  List<WasteCategory> getCategoryDistribution() {
    final categoryWeights = <String, double>{};

    for (final activity in activities) {
      categoryWeights[activity.wasteCategoryId] =
          (categoryWeights[activity.wasteCategoryId] ?? 0) + activity.weight;
    }

    return wasteCategories
        .where((category) => categoryWeights.containsKey(category.categoryId))
        .toList();
  }

  /// Get percentage for a specific category
  double getCategoryPercentage(WasteCategory category) {
    final totalWeight = activities.fold<double>(0, (sum, activity) => sum + activity.weight);
    final categoryWeight = activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold<double>(0, (sum, activity) => sum + activity.weight);

    return totalWeight > 0 ? (categoryWeight / totalWeight) * 100 : 0.0;
  }

  /// Select category for chart
  void selectCategoryForChart(WasteCategory category) {
    if (selectedCategoryForChart.value == category) {
      selectedCategoryForChart.value = null;
    } else {
      selectedCategoryForChart.value = category;
    }
    applyFilters();
  }

  /// Get category-specific points
  int getCategoryPoints(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold(0, (sum, activity) => sum + activity.pointsEarned);
  }

  /// Get category-specific weight
  double getCategoryWeight(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold(0.0, (sum, activity) => sum + activity.weight);
  }

  /// Get category-specific activity count
  int getCategoryActivityCount(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .length;
  }

  /// Get category-specific CO2 reduced
  double getCategoryCO2Reduced(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold(0.0, (sum, activity) => sum + activity.emissionReduced);
  }

  /// Get waste category by ID
  WasteCategory getWasteCategoryById(String categoryId) {
    try {
      return wasteCategories.firstWhere(
            (category) => category.categoryId == categoryId,
      );
    } catch (e) {
      return WasteCategory.empty();
    }
  }

  /// Delete activity
  Future<void> deleteActivity(RecyclingActivity activity) async {
    try {
      if (!activity.canDelete) {
        FLoaders.warningSnackBar(
          title: 'Cannot Delete',
          message: 'Only pending or rejected activities can be deleted',
        );
        return;
      }

      isLoading.value = true;
      await _activityRepo.deleteActivity(activity.activityId);

      FLoaders.successSnackBar(
        title: 'Deleted',
        message: 'Activity has been deleted successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🆕 Group activities by date
  Map<String, List<RecyclingActivity>> getActivitiesGroupedByDate() {
    final Map<String, List<RecyclingActivity>> grouped = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final activity in filteredActivities) {
      final dateKey = dateFormat.format(activity.createdAt);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(activity);
    }

    // Sort by date descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Map.fromEntries(
        sortedKeys.map((key) => MapEntry(key, grouped[key]!))
    );
  }

  /// 🆕 Get formatted date for display
  String getFormattedDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, d MMM yyyy').format(date);
    }
  }

  /// 🆕 Get date summary for a group
  Map<String, dynamic> getDateSummary(List<RecyclingActivity> activities) {
    final totalWeight = activities.fold<double>(0.0, (sum, act) => sum + act.weight);
    final totalPoints = activities.fold<int>(0, (sum, act) => sum + act.pointsEarned);
    final totalEmission = activities.fold<double>(0.0, (sum, act) => sum + act.emissionReduced);

    return {
      'count': activities.length,
      'weight': totalWeight,
      'points': totalPoints,
      'emission': totalEmission,
    };
  }
}