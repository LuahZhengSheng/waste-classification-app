import 'package:get/get.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/features/waste_classification/models/waste_category_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../data/repositories/recycling_center/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/repositories/user/user_repository.dart';

class StaffActivityDetailController extends GetxController {
  final Rx<RecyclingActivity?> activity = Rx<RecyclingActivity?>(null);
  final Rx<WasteCategory?> wasteCategory = Rx<WasteCategory?>(null);
  final Rx<UserModel?> processedUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;

  // Repositories
  final _activityRepo = Get.put(RecyclingActivityRepository());
  final _categoryRepo = Get.put(WasteCategoryRepository());
  final _userRepo = Get.put(UserRepository());

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as RecyclingActivity?;
    if (args != null) {
      activity.value = args;
      _loadActivityData();
    } else {
      isLoading.value = false;
    }
  }

  /// Load all activity related data
  Future<void> _loadActivityData() async {
    if (activity.value == null) return;

    try {
      isLoading.value = true;

      // Load all data in parallel for better performance
      await Future.wait([
        _loadWasteCategory(),
        _loadProcessedUser(),
      ]);

      print('=== Activity Data Load Status ===');
      print('Waste Category: ${wasteCategory.value != null ? "Loaded" : "Failed"}');
      print('Processed User: ${processedUser.value != null ? "Loaded" : "Failed"}');
      print('Activity ID: ${activity.value?.activityId}');
      print('User ID: ${activity.value?.userId}');
      print('Waste Category ID: ${activity.value?.wasteCategoryId}');

    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load activity data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load waste category
  Future<void> _loadWasteCategory() async {
    if (activity.value == null) return;

    try {
      final category = await _categoryRepo.getCategoryById(activity.value!.wasteCategoryId);
      wasteCategory.value = category;
      print('✅ Waste category loaded: ${category?.name}');
    } catch (e) {
      print('❌ Failed to load waste category: $e');
      wasteCategory.value = null;
    }
  }

  /// Load processed user information
  Future<void> _loadProcessedUser() async {
    if (activity.value == null) return;

    try {
      print('🔄 Loading user with ID: ${activity.value!.userId}');

      final user = await _userRepo.fetchOtherUserDetails(activity.value!.userId);

      if (user.userId.isNotEmpty) {
        processedUser.value = user;
        print('✅ User loaded successfully: ${user.username}');
        print('User details - Email: ${user.email}');
      } else {
        print('❌ User data is empty or invalid');
        processedUser.value = null;
      }
    } catch (e) {
      print('❌ Failed to load user: $e');
      processedUser.value = null;
    }
  }

  /// Get waste category
  WasteCategory? getWasteCategory() {
    return wasteCategory.value;
  }

  /// Get activity age text
  String get activityAgeText {
    if (activity.value == null) return '';

    final age = activity.value!.ageInHours;
    if (age < 1) {
      return 'Less than an hour ago';
    } else if (age < 24) {
      return '$age hour${age > 1 ? 's' : ''} ago';
    } else {
      final days = (age / 24).floor();
      return '$days day${days > 1 ? 's' : ''} ago';
    }
  }

  /// Check if all data is loaded
  bool get isDataLoaded {
    return wasteCategory.value != null && processedUser.value != null;
  }
}