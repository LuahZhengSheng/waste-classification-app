import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/features/recycling_center/models/recycling_center_staff_model.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/data/repositories/personalization/recycling_activity_repository.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_staff_repository.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../waste_classification/models/waste_category_model.dart';

class RecyclingCenterDetailsController extends GetxController {
  final String centerId;

  RecyclingCenterDetailsController({required this.centerId});

  // Repositories
  final _centerRepo = Get.put(RecyclingCenterRepository());
  final _staffRepo = Get.put(RecyclingCenterStaffRepository());
  final _activityRepo = Get.put(RecyclingActivityRepository());
  final _userRepo = Get.put(UserRepository());
  final _wasteCategoryRepo = Get.put(WasteCategoryRepository());

  // Data
  final Rx<PartnerRecyclingCenter?> center = Rx<PartnerRecyclingCenter?>(null);
  final RxList<RecyclingCenterStaff> allStaff = <RecyclingCenterStaff>[].obs;
  final RxList<RecyclingActivity> allActivities = <RecyclingActivity>[].obs;
  final RxList<RecyclingActivity> filteredActivities = <RecyclingActivity>[].obs;
  final RxMap<String, UserModel> usersMap = <String, UserModel>{}.obs;
  final RxMap<String, int> staffActivityCounts = <String, int>{}.obs;
  final RxMap<String, WasteCategory> wasteCategories = <String, WasteCategory>{}.obs;

  // Image URL caches
  final RxMap<String, String> userImageUrls = <String, String>{}.obs;
  final RxMap<String, String> staffImageUrls = <String, String>{}.obs;
  final RxMap<String, String> activityImageUrls = <String, String>{}.obs;

  // Loading states
  final RxBool isLoading = false.obs;

  // Activity filters
  final RxString selectedStaffFilter = 'all'.obs;
  final RxString sortBy = 'newest'.obs;

  // Activity count tracking
  StreamSubscription<List<RecyclingActivity>>? _activitySubscription;
  final RxInt initialActivityCount = 0.obs;
  final RxInt currentActivityCount = 0.obs;
  final RxBool showNewActivityNotification = false.obs;
  final RxBool isInitialLoad = true.obs;

  // Category statistics
  final RxMap<String, Map<String, dynamic>> categoryStats = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCenterDetails();
    _listenToActivities();
    _fetchWasteCategories();
  }

  @override
  void onClose() {
    _activitySubscription?.cancel();
    super.onClose();
  }

  /// Fetch center details
  Future<void> fetchCenterDetails() async {
    try {
      isLoading.value = true;

      // Fetch center data
      final centerData = await _centerRepo.getCenterById(centerId);

      // 确保图片URL被正确转换
      final centerWithImageUrl = await _centerRepo.convertImageToDownloadUrl(centerData);
      center.value = centerWithImageUrl;

      // Fetch staff data (stream)
      _fetchStaffData();

      // Fetch activities (one-time)
      await _fetchActivitiesData();

    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load center details: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取所有废物分类数据
  Future<void> _fetchWasteCategories() async {
    try {
      final categories = await _wasteCategoryRepo.getAllWasteCategories();
      for (var category in categories) {
        wasteCategories[category.categoryId] = category;
      }
    } catch (e) {
      print('Error fetching waste categories: $e');
    }
  }

  /// Fetch staff data with stream
  void _fetchStaffData() {
    _staffRepo.getStaffByCenterIdStream(centerId).listen((staffList) async {
      allStaff.assignAll(staffList);

      // Load staff profile images
      for (final staff in staffList) {
        if (staff.profileImg != null && staff.profileImg!.isNotEmpty) {
          try {
            final url = await _userRepo.getProfileImageUrl(staff.profileImg!);
            if (url != null) {
              staffImageUrls[staff.userId] = url;
            }
          } catch (e) {
            print('Error loading staff image: $e');
          }
        }
      }

      _calculateStaffActivityCounts();
    });
  }

  /// Fetch activities data (one-time)
  Future<void> _fetchActivitiesData() async {
    try {
      final activities = await _activityRepo.getActivitiesByCenterId(centerId);
      allActivities.assignAll(activities);
      filteredActivities.assignAll(activities);

      // Set initial count
      initialActivityCount.value = activities.length;
      currentActivityCount.value = activities.length;

      // Fetch user data and images for activities
      await _fetchUsersData();
      await _loadActivityImages();

      // Calculate statistics
      _calculateStaffActivityCounts();
      _calculateCategoryStatistics();

      // Apply initial filters
      applyActivityFilters();

      // Mark initial load as complete
      isInitialLoad.value = false;
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  /// Listen to activities for new entries (stream)
  void _listenToActivities() {
    _activitySubscription = _activityRepo
        .getActivitiesByCenterIdStream(centerId)
        .listen((activities) {
      // Only show notification if not initial load and count increased
      if (!isInitialLoad.value && activities.length > currentActivityCount.value) {
        showNewActivityNotification.value = true;
      }
    });
  }

  /// Load activity support images
  Future<void> _loadActivityImages() async {
    for (final activity in allActivities) {
      if (activity.supportImage.isNotEmpty && activity.userId.isNotEmpty) {
        try {
          final url = await activity.getSupportImageUrl(activity.userId);
          if (url.isNotEmpty) {
            activityImageUrls[activity.activityId] = url;
          }
        } catch (e) {
          print('Error loading activity image: $e');
        }
      }
    }
  }

  /// Refresh activities when user clicks notification
  Future<void> refreshActivities() async {
    showNewActivityNotification.value = false;
    await _fetchActivitiesData();
    FAdminLoaders.successSnackBar(
      title: 'Refreshed',
      message: 'Activities updated successfully',
    );
  }

  /// Fetch users data
  Future<void> _fetchUsersData() async {
    try {
      final userIds = allActivities.map((a) => a.userId).toSet();
      if (userIds.isEmpty) return;

      final users = await _userRepo.getUsersProfileData(userIds);
      usersMap.assignAll(users);

      // Load user profile images
      for (final userId in userIds) {
        final user = users[userId];
        if (user != null && user.profileImg != null && user.profileImg!.isNotEmpty) {
          try {
            final url = await _userRepo.getProfileImageUrl(user.profileImg!);
            if (url != null) {
              userImageUrls[userId] = url;
            }
          } catch (e) {
            print('Error loading user image: $e');
          }
        }
      }
    } catch (e) {
      print('Error fetching users data: $e');
    }
  }

  /// Calculate staff activity counts
  void _calculateStaffActivityCounts() {
    final counts = <String, int>{};
    for (final activity in allActivities) {
      counts[activity.centerStaffId] = (counts[activity.centerStaffId] ?? 0) + 1;
    }
    staffActivityCounts.assignAll(counts);
  }

  /// 获取分类名称
  String getCategoryName(String categoryId) {
    final category = wasteCategories[categoryId];
    return category?.name ?? 'Unknown Category';
  }

  /// 获取分类图标
  IconData getCategoryIcon(String categoryId) {
    final category = wasteCategories[categoryId];
    return category?.icon ?? Iconsax.category;
  }

  /// 获取分类颜色
  Color getCategoryColor(String categoryId) {
    final category = wasteCategories[categoryId];
    return category?.color ?? Colors.grey;
  }

  /// Calculate category statistics
  void _calculateCategoryStatistics() {
    final stats = <String, Map<String, dynamic>>{};

    for (final activity in allActivities) {
      final categoryId = activity.wasteCategoryId;

      if (!stats.containsKey(categoryId)) {
        // 使用分类名称而不是 wasteObject
        stats[categoryId] = {
          'name': getCategoryName(categoryId),
          'icon': getCategoryIcon(categoryId),
          'color': getCategoryColor(categoryId),
          'count': 0,
          'weight': 0.0,
          'points': 0,
        };
      }

      stats[categoryId]!['count'] = (stats[categoryId]!['count'] as int) + 1;
      stats[categoryId]!['weight'] = (stats[categoryId]!['weight'] as double) + activity.weight;
      stats[categoryId]!['points'] = (stats[categoryId]!['points'] as int) + activity.pointsEarned;
    }

    categoryStats.assignAll(stats);
  }

  /// Apply activity filters
  void applyActivityFilters() {
    List<RecyclingActivity> result = allActivities;

    // Filter by staff
    if (selectedStaffFilter.value != 'all') {
      result = result.where((a) => a.centerStaffId == selectedStaffFilter.value).toList();
    }

    // Sort
    if (sortBy.value == 'newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    filteredActivities.assignAll(result);
  }

  /// Change staff filter
  void changeStaffFilter(String staffId) {
    selectedStaffFilter.value = staffId;
    applyActivityFilters();
  }

  /// Change sorting
  void changeSorting(String sort) {
    sortBy.value = sort;
    applyActivityFilters();
  }

  /// Get staff by ID
  RecyclingCenterStaff? getStaffById(String staffId) {
    try {
      return allStaff.firstWhere((s) => s.userId == staffId);
    } catch (e) {
      return null;
    }
  }

  /// Get user by ID
  UserModel? getUserById(String userId) {
    return usersMap[userId];
  }

  /// Get user image URL
  String? getUserImageUrl(String userId) {
    final user = getUserById(userId);
    if (user == null || user.profileImg == null || user.profileImg!.isEmpty) {
      return null;
    }

    // 如果已经是完整URL，直接返回
    if (user.profileImg!.startsWith('http')) {
      return user.profileImg;
    }

    // 否则从缓存中获取
    return userImageUrls[userId];
  }

  /// Get staff image URL
  String? getStaffImageUrl(String staffId) {
    return staffImageUrls[staffId];
  }

  /// Get activity image URL
  String? getActivityImageUrl(String activityId) {
    return activityImageUrls[activityId];
  }

  /// Statistics getters
  String get totalActivitiesToday {
    final today = DateTime.now();
    final todayActivities = allActivities.where((a) {
      return a.createdAt.year == today.year &&
          a.createdAt.month == today.month &&
          a.createdAt.day == today.day;
    }).length;
    return todayActivities.toString();
  }

  String get totalActivitiesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekActivities = allActivities.where((a) {
      return a.createdAt.isAfter(weekStart);
    }).length;
    return weekActivities.toString();
  }

  String get totalWeightProcessed {
    final totalWeight = allActivities.fold<double>(
      0.0,
          (sum, activity) => sum + activity.weight,
    );
    return '${totalWeight.toStringAsFixed(2)} kg';
  }

  String get totalActivitiesCount {
    return allActivities.length.toString();
  }

  String get totalPointsAssigned {
    final totalPoints = allActivities.fold<int>(
      0,
          (sum, activity) => sum + activity.pointsEarned,
    );
    return totalPoints.toString();
  }

  /// Get center status color
  Color getCenterStatusColor(bool dark) {
    if (center.value == null) {
      return dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
    }

    switch (center.value!.status) {
      case 'active':
        return dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
      case 'disabled':
        return dark ? FColors.adminDarkError : FColors.adminLightError;
      default:
        return dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
    }
  }

  /// Get center status text
  String get centerStatusText {
    if (center.value == null) return 'Unknown';

    switch (center.value!.status) {
      case 'active':
        return 'Active';
      case 'disabled':
        return 'Disabled';
      default:
        return 'Unknown';
    }
  }

  /// Format opening hours
  String formatOpeningHours(String day) {
    if (center.value?.openingHours == null) return 'Closed';

    final openingHours = center.value!.openingHours!;

    // 直接根据日期键获取营业时间
    final dayData = openingHours[day.toLowerCase()] as Map<String, dynamic>?;

    if (dayData != null) {
      final openTime = dayData['open']?.toString();
      final closeTime = dayData['close']?.toString();

      if (openTime != null && closeTime != null) {
        return '${_formatTime(openTime)} - ${_formatTime(closeTime)}';
      }
    }

    return 'Closed';
  }

  String _formatTime(String time) {
    if (time.length != 4) {
      // 如果时间格式已经是 HH:MM，直接返回
      if (time.contains(':')) return time;
      return time; // 返回原始值
    }

    try {
      final hour = int.parse(time.substring(0, 2));
      final minute = time.substring(2, 4);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time; // 如果解析失败，返回原始时间
    }
  }

  /// Show center image lightbox
  void showCenterImage() {
    if (center.value == null) {
      print('❌ Center data is null');
      return;
    }

    if (center.value!.image.isEmpty) {
      print('❌ Center image URL is empty');
      return;
    }

    Get.dialog(
      ImageLightbox(
        imageUrl: center.value!.image,
        title: center.value!.name,
      ),
      barrierDismissible: true,
    );
  }

  /// Show activity image lightbox
  void showActivityImage(String activityId, String title) {
    final imageUrl = getActivityImageUrl(activityId);
    if (imageUrl == null || imageUrl.isEmpty) return;

    Get.dialog(
      ImageLightbox(
        imageUrl: imageUrl,
        title: title,
      ),
      barrierDismissible: true,
    );
  }

  /// Show user/staff image lightbox
  void showProfileImage(String imageUrl, String title) {
    if (imageUrl.isEmpty) return;

    Get.dialog(
      ImageLightbox(
        imageUrl: imageUrl,
        title: title,
      ),
      barrierDismissible: true,
    );
  }

  /// Disable center
  Future<void> disableCenter() async {
    try {
      FAdminLoaders.customToast(message: 'Disabling center...');

      await _centerRepo.updateCenterStatus(centerId, 'disabled');
      await _centerRepo.banAllStaffOfCenter(centerId);

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: 'Center disabled successfully',
      );

      await fetchCenterDetails();
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to disable center: ${e.toString()}',
      );
    }
  }

  /// Edit center
  void editCenter() {
    Get.toNamed('/admin/edit-recycling-center', arguments: center.value);
  }
}