import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/models/user_model.dart';
import '../../../event/models/address_model.dart';
import '../../../event/models/geopoint_model.dart';
import '../../../event/models/location_model.dart';
import '../../../personalization/models/recycle_activity_model.dart';
import '../../../recycling_center/models/partner_recycling_center_model.dart';
import '../../../recycling_center/models/recycling_center_staff_model.dart';

class RecyclingCenterDetailsController extends GetxController {
  final String centerId;
  RecyclingCenterDetailsController({required this.centerId});

  // Observables
  final Rx<PartnerRecyclingCenter?> center = Rx<PartnerRecyclingCenter?>(null);
  final RxList<RecyclingCenterStaffModel> allStaff = <RecyclingCenterStaffModel>[].obs;
  final RxList<RecyclingActivity> allActivities = <RecyclingActivity>[].obs;
  final RxList<RecyclingActivity> filteredActivities = <RecyclingActivity>[].obs;
  final RxMap<String, UserModel> users = <String, UserModel>{}.obs;
  final RxMap<String, int> staffActivityCounts = <String, int>{}.obs;

  // Filter and Sort
  final RxString selectedStaffFilter = 'all'.obs;
  final RxString sortBy = 'newest'.obs; // newest, oldest
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCenterDetails();

    // Listen to filter/sort changes
    ever(selectedStaffFilter, (_) => applyFilters());
    ever(sortBy, (_) => applySorting());
  }

  void loadCenterDetails() async {
    try {
      isLoading.value = true;

      // Load center details
      center.value = _getMockCenter();

      // Load staff
      allStaff.value = _getMockStaff();

      // Load activities
      allActivities.value = _getMockActivities();
      filteredActivities.value = List.from(allActivities);

      // Load users
      users.value = _getMockUsers();

      // Calculate staff activity counts
      _calculateStaffActivityCounts();

      // Apply initial sorting
      applySorting();

    } catch (e) {
      FHelperFunctions.showSnackBar('Error loading center details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  PartnerRecyclingCenter _getMockCenter() {
    // Mock center data - replace with actual API call
    return PartnerRecyclingCenter(
      centerId: centerId,
      name: 'EcoCenter Kuala Lumpur',
      email: 'contact@ecocenter-kl.com',
      phoneNo: '0123456789',
      website: 'https://ecocenter-kl.com',
      centerLocation: Location(
        address: const Address(
          unitNo: 'Block A, Lot 123',
          area: 'Taman Eco',
          postcode: '50100',
          city: 'Kuala Lumpur',
          state: 'Selangor',
        ),
        geoPoint: const GeoPointModel(latitude: 3.1390, longitude: 101.6869),
      ),
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      operatingHours: {
        'monday': {'open': DateTime(2024, 1, 1, 8, 0), 'close': DateTime(2024, 1, 1, 18, 0)},
        'tuesday': {'open': DateTime(2024, 1, 1, 8, 0), 'close': DateTime(2024, 1, 1, 18, 0)},
        'wednesday': {'open': DateTime(2024, 1, 1, 8, 0), 'close': DateTime(2024, 1, 1, 18, 0)},
        'thursday': {'open': DateTime(2024, 1, 1, 8, 0), 'close': DateTime(2024, 1, 1, 18, 0)},
        'friday': {'open': DateTime(2024, 1, 1, 8, 0), 'close': DateTime(2024, 1, 1, 18, 0)},
        'saturday': {'open': DateTime(2024, 1, 1, 9, 0), 'close': DateTime(2024, 1, 1, 15, 0)},
        'sunday': {'open': DateTime(2024, 1, 1, 9, 0), 'close': DateTime(2024, 1, 1, 15, 0)},
      },
      numberOfStaff: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      status: 'active',
    );
  }

  List<RecyclingCenterStaffModel> _getMockStaff() {
    final now = DateTime.now();
    return [
      RecyclingCenterStaffModel(
        userId: 'staff1',
        username: 'Ahmad Rahman',
        email: 'ahmad@ecocenter-kl.com',
        phoneNo: '0123456701',
        profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        loginAttemptCount: 0,
        role: 'staff',
        isVerified: true,
        isActive: true,
        centerId: centerId,
        gender: 'male',
        joinDate: now.subtract(const Duration(days: 90)),
      ),
      RecyclingCenterStaffModel(
        userId: 'staff2',
        username: 'Siti Nurhaliza',
        email: 'siti@ecocenter-kl.com',
        phoneNo: '0123456702',
        profileImage: 'https://images.unsplash.com/photo-1494790108755-2616b60c1859?w=150',
        loginAttemptCount: 0,
        role: 'staff',
        isVerified: true,
        isActive: true,
        centerId: centerId,
        gender: 'female',
        joinDate: now.subtract(const Duration(days: 75)),
      ),
      RecyclingCenterStaffModel(
        userId: 'staff3',
        username: 'Wong Wei Ming',
        email: 'wong@ecocenter-kl.com',
        phoneNo: '0123456703',
        profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        loginAttemptCount: 0,
        role: 'staff',
        isVerified: true,
        isActive: true,
        centerId: centerId,
        gender: 'male',
        joinDate: now.subtract(const Duration(days: 60)),
      ),
      RecyclingCenterStaffModel(
        userId: 'staff4',
        username: 'Priya Sharma',
        email: 'priya@ecocenter-kl.com',
        phoneNo: '0123456704',
        profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        loginAttemptCount: 0,
        role: 'supervisor',
        isVerified: true,
        isActive: true,
        centerId: centerId,
        gender: 'female',
        joinDate: now.subtract(const Duration(days: 100)),
      ),
    ];
  }

  List<RecyclingActivity> _getMockActivities() {
    final now = DateTime.now();
    return [
      RecyclingActivity(
        activityId: 'activity1',
        userId: 'user1',
        centerStaffId: 'staff1',
        wasteObject: 'Plastic Bottles',
        wasteCategoryId: 'plastic',
        weight: 5.2,
        supportImage: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=300',
        pointsEarned: 42,
        createdAt: now.subtract(const Duration(hours: 2)),
        status: 'completed',
      ),
      RecyclingActivity(
        activityId: 'activity2',
        userId: 'user2',
        centerStaffId: 'staff2',
        wasteObject: 'Paper',
        wasteCategoryId: 'paper',
        weight: 8.5,
        supportImage: 'https://images.unsplash.com/photo-1594736797933-d0301ba2fe65?w=300',
        pointsEarned: 77,
        createdAt: now.subtract(const Duration(hours: 5)),
        status: 'approved',
      ),
      RecyclingActivity(
        activityId: 'activity3',
        userId: 'user3',
        centerStaffId: 'staff1',
        wasteObject: 'Electronics',
        wasteCategoryId: 'electronics',
        weight: 3.2,
        supportImage: 'https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=300',
        pointsEarned: 48,
        createdAt: now.subtract(const Duration(hours: 8)),
        status: 'completed',
      ),
      RecyclingActivity(
        activityId: 'activity4',
        userId: 'user4',
        centerStaffId: 'staff3',
        wasteObject: 'Glass Bottles',
        wasteCategoryId: 'glass',
        weight: 4.8,
        supportImage: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=300',
        pointsEarned: 58,
        createdAt: now.subtract(const Duration(hours: 12)),
        status: 'pending',
      ),
      RecyclingActivity(
        activityId: 'activity5',
        userId: 'user1',
        centerStaffId: 'staff2',
        wasteObject: 'Metal Cans',
        wasteCategoryId: 'metal',
        weight: 2.1,
        supportImage: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=300',
        pointsEarned: 27,
        createdAt: now.subtract(const Duration(days: 1)),
        status: 'completed',
      ),
      RecyclingActivity(
        activityId: 'activity6',
        userId: 'user2',
        centerStaffId: 'staff4',
        wasteObject: 'Cardboard',
        wasteCategoryId: 'paper',
        weight: 12.3,
        supportImage: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300',
        pointsEarned: 111,
        createdAt: now.subtract(const Duration(days: 2)),
        status: 'approved',
      ),
    ];
  }

  Map<String, UserModel> _getMockUsers() {
    final now = DateTime.now();
    return {
      'user1': UserModel(
        userId: 'user1',
        username: 'Alex Johnson',
        email: 'alex@example.com',
        profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: true,
        joinDate: now.subtract(const Duration(days: 200)),
        rewardPoint: 156,
      ),
      'user2': UserModel(
        userId: 'user2',
        username: 'Sarah Chen',
        email: 'sarah@example.com',
        profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: true,
        joinDate: now.subtract(const Duration(days: 150)),
        rewardPoint: 243,
      ),
      'user3': UserModel(
        userId: 'user3',
        username: 'Michael Brown',
        email: 'michael@example.com',
        profileImage: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: true,
        joinDate: now.subtract(const Duration(days: 180)),
        rewardPoint: 89,
      ),
      'user4': UserModel(
        userId: 'user4',
        username: 'Lisa Wang',
        email: 'lisa@example.com',
        profileImage: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: true,
        joinDate: now.subtract(const Duration(days: 120)),
        rewardPoint: 312,
      ),
    };
  }

  void _calculateStaffActivityCounts() {
    staffActivityCounts.clear();
    for (final staff in allStaff) {
      final count = allActivities.where((activity) =>
      activity.centerStaffId == staff.userId).length;
      staffActivityCounts[staff.userId] = count;
    }
  }

  void applyFilters() {
    List<RecyclingActivity> result = List.from(allActivities);

    if (selectedStaffFilter.value != 'all') {
      result = result.where((activity) =>
      activity.centerStaffId == selectedStaffFilter.value).toList();
    }

    filteredActivities.value = result;
    applySorting();
  }

  void applySorting() {
    List<RecyclingActivity> result = List.from(filteredActivities);

    switch (sortBy.value) {
      case 'newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    filteredActivities.value = result;
  }

  void changeStaffFilter(String staffId) {
    selectedStaffFilter.value = staffId;
  }

  void changeSorting(String sorting) {
    sortBy.value = sorting;
  }

  void showCenterImage() {
    if (center.value?.image != null) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: Get.width * 0.9,
                      maxHeight: Get.height * 0.8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        center.value!.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 300,
                          width: 300,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image, size: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      center.value?.name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void editCenter() {
    // Navigate to edit center screen
    print('Navigate to edit center: ${center.value?.name}');
  }

  RecyclingCenterStaffModel? getStaffById(String staffId) {
    try {
      return allStaff.firstWhere((staff) => staff.userId == staffId);
    } catch (e) {
      return null;
    }
  }

  UserModel? getUserById(String userId) {
    return users[userId];
  }

  String get centerStatusText {
    if (center.value == null) return 'Unknown';
    return center.value!.status == 'active' ? 'Active' : 'Inactive';
  }

  Color getCenterStatusColor(bool isDark) {
    if (center.value == null) return Colors.grey;

    if (center.value!.status == 'active') {
      return isDark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
    } else {
      return isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
    }
  }

  String formatOperatingHours(String day) {
    if (center.value?.operatingHours[day] == null) return 'Closed';

    final times = center.value!.operatingHours[day]!;
    final open = times['open'];
    final close = times['close'];

    if (open == null || close == null) return 'Closed';

    return '${_formatTime(open)} - ${_formatTime(close)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get totalActivitiesToday {
    final today = DateTime.now();
    final todayActivities = allActivities.where((activity) =>
    activity.createdAt.year == today.year &&
        activity.createdAt.month == today.month &&
        activity.createdAt.day == today.day).length;

    return todayActivities.toString();
  }

  String get totalActivitiesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekActivities = allActivities.where((activity) =>
    activity.createdAt.isAfter(weekStart) &&
        activity.createdAt.isBefore(weekEnd.add(const Duration(days: 1)))).length;

    return weekActivities.toString();
  }

  String get totalWeightProcessed {
    final totalWeight = allActivities.fold<double>(
        0.0,
            (sum, activity) => sum + activity.weight
    );
    return '${totalWeight.toStringAsFixed(1)} kg';
  }
}