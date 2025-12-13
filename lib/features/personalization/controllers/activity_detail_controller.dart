import 'package:get/get.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/features/waste_classification/models/waste_category_model.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/recycling_center/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/repositories/user/center_staff_repository.dart';
import '../../recycling_center/models/recycling_center_staff_model.dart';

class ActivityDetailController extends GetxController {
  final Rx<RecyclingActivity?> activity = Rx<RecyclingActivity?>(null);
  final Rx<WasteCategory?> wasteCategory = Rx<WasteCategory?>(null);
  final Rx<PartnerRecyclingCenter?> recyclingCenter = Rx<PartnerRecyclingCenter?>(null);
  final Rx<RecyclingCenterStaff?> staffUser = Rx<RecyclingCenterStaff?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isDeleting = false.obs;

  // Repositories
  final _activityRepo = Get.put(RecyclingActivityRepository());
  final _categoryRepo = Get.put(WasteCategoryRepository());
  final _centerRepo = Get.put(RecyclingCenterRepository());
  final _staffRepo = Get.put(RecyclingCenterStaffRepository());

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
        _loadRecyclingCenter(),
        _loadStaffUser(),
      ]);

      print('=== Activity Data Load Status ===');
      print('Waste Category: ${wasteCategory.value != null ? "Loaded" : "Failed"}');
      print('Recycling Center: ${recyclingCenter.value != null ? "Loaded" : "Failed"}');
      print('Staff User: ${staffUser.value != null ? "Loaded" : "Failed"}');
      print('Activity ID: ${activity.value?.activityId}');
      print('Center Staff ID: ${activity.value?.centerStaffId}');
      print('Waste Category ID: ${activity.value?.wasteCategoryId}');
      print('Center image: ${recyclingCenter.value?.image}');

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

  /// Load recycling center
  Future<void> _loadRecyclingCenter() async {
    if (activity.value == null) return;

    try {
      final center = await _centerRepo.getCenterByStaffId(activity.value!.centerStaffId);
      recyclingCenter.value = center;
      print('✅ Recycling center loaded: ${center?.name}');
    } catch (e) {
      print('❌ Failed to load recycling center: $e');
      recyclingCenter.value = null;
    }
  }

  /// Load staff user information
  Future<void> _loadStaffUser() async {
    if (activity.value == null) return;

    try {
      print('🔄 Loading staff user with ID: ${activity.value!.centerStaffId}');

      final staff = await _staffRepo.getStaffById(activity.value!.centerStaffId);

      if (staff != null && staff.userId.isNotEmpty) {
        staffUser.value = staff;
        print('✅ Staff user loaded successfully: ${staff.username}');
        print('Staff details - Email: ${staff.email}, Center ID: ${staff.centerId}');
      } else {
        print('❌ Staff user data is empty or invalid');
        staffUser.value = null;
      }
    } catch (e) {
      print('❌ Failed to load staff user: $e');
      staffUser.value = null;
    }
  }

  /// Get waste category
  WasteCategory? getWasteCategory() {
    return wasteCategory.value;
  }

  /// Open navigation
  Future<void> openGoogleMapsNavigation(PartnerRecyclingCenter center) async {
    try {
      await FLoaders.showMapNavigationDialog(
        onConfirm: () async {
          final url = 'https://www.google.com/maps/dir/?api=1&destination=${center.centerLocation.geoPoint.latitude},${center.centerLocation.geoPoint.longitude}&travelmode=driving';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            FLoaders.errorSnackBar(
              title: 'Error',
              message: 'Could not open Google Maps',
            );
          }
        },
      );
    } catch (e) {
      print('❌ Error opening navigation: $e');
    }
  }

  /// Get activity age text
  String get activityAgeText {
    if (activity.value == null) return '';

    final age = activity.value!.ageInHours;
    if (age < 1) {
      // ✅ 计算分钟数
      final minutes = (age * 60).floor();
      if (minutes < 1) {
        return 'Just now'; // 刚刚
      }
      return '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else if (age < 24) {
      return '$age hour${age > 1 ? 's' : ''} ago';
    } else {
      final days = (age / 24).floor();
      return '$days day${days > 1 ? 's' : ''} ago';
    }
  }

  /// Delete activity
  Future<void> deleteActivity() async {
    if (activity.value == null || !activity.value!.canDelete) return;

    try {
      isDeleting.value = true;

      await _activityRepo.deleteActivity(activity.value!.activityId);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Activity deleted successfully',
      );

      Get.back(result: true);
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity: ${e.toString()}',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  /// Check if all data is loaded
  bool get isDataLoaded {
    return wasteCategory.value != null &&
        recyclingCenter.value != null &&
        staffUser.value != null;
  }
}