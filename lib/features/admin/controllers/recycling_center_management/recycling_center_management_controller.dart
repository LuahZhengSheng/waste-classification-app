import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';

import '../../../../data/repositories/user/center_staff_repository.dart';
import '../../screens/recycling_center_management/add_recycling_center/add_recycling_center.dart';
import '../../screens/recycling_center_management/edit_recycling_center/edit_recycling_center.dart';
import '../../screens/recycling_center_management/recycling_center_detail/recycling_center_detail.dart';
import '../../screens/recycling_center_management/recycling_center_management/widgets/center_filter_dialog.dart';

class PartnerCenterManagementController extends GetxController {
  static PartnerCenterManagementController get instance => Get.find();

  // Repositories
  final _centerRepo = Get.put(RecyclingCenterRepository());
  final _staffRepo = Get.put(StaffRepository());

  // Search and Filter
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'active'.obs; // active or disabled
  final RxMap<String, dynamic> filters = <String, dynamic>{}.obs;

  // Data
  final RxList<PartnerRecyclingCenter> allCenters = <PartnerRecyclingCenter>[].obs;
  final RxList<PartnerRecyclingCenter> filteredCenters = <PartnerRecyclingCenter>[].obs;
  final RxBool isLoading = false.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalCenters = 0.obs;

  // Sorting
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCenters();

    // Listen to search changes with debounce
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Fetch all centers from Firestore
  Future<void> fetchCenters() async {
    try {
      isLoading.value = true;

      final centers = await _centerRepo.getAllCenters();
      allCenters.assignAll(centers);

      applyFilters();
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load centers: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply search and filters
  void applyFilters() {
    List<PartnerRecyclingCenter> result = allCenters;

    // Apply status filter
    result = result.where((center) {
      return center.status == selectedStatusFilter.value;
    }).toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((center) {
        return center.name.toLowerCase().contains(query) ||
            center.email.toLowerCase().contains(query) ||
            center.phoneNo.toLowerCase().contains(query) ||
            center.centerLocation.address.city.toLowerCase().contains(query) ||
            center.centerLocation.address.state.toLowerCase().contains(query);
      }).toList();
    }

    // Apply additional filters
    if (filters['city'] != null) {
      result = result.where((c) => c.centerLocation.address.city == filters['city']).toList();
    }
    if (filters['state'] != null) {
      result = result.where((c) => c.centerLocation.address.state == filters['state']).toList();
    }
    if (filters['staffRange'] != null) {
      result = result.where((c) {
        switch (filters['staffRange']) {
          case 'small':
            return c.numberOfStaff <= 10;
          case 'medium':
            return c.numberOfStaff > 10 && c.numberOfStaff <= 30;
          case 'large':
            return c.numberOfStaff > 30;
          default:
            return true;
        }
      }).toList();
    }

    filteredCenters.assignAll(result);
    totalCenters.value = result.length;
    currentPage.value = 1; // Reset to first page
  }

  /// Change status filter tab
  void changeStatusFilter(String status) {
    selectedStatusFilter.value = status;
    applyFilters();
  }

  /// Search handler
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  /// Show filters dialog
  void showFilters() {
    final availableCities = allCenters
        .map((c) => c.centerLocation.address.city)
        .toSet()
        .toList()..sort();

    final availableStates = allCenters
        .map((c) => c.centerLocation.address.state)
        .toSet()
        .toList()..sort();

    Get.dialog(
      PartnerCenterFilterDialog(
        dark: Get.isDarkMode,
        currentFilters: filters,
        availableCities: availableCities,
        availableStates: availableStates,
        onApplyFilters: (newFilters) {
          filters.assignAll(newFilters);
          applyFilters();
        },
      ),
    );
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return filters.values.any((value) => value != null);
  }

  /// Pagination
  List<PartnerRecyclingCenter> get paginatedCenters {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;

    if (startIndex >= filteredCenters.length) return [];

    return filteredCenters.sublist(
      startIndex,
      endIndex > filteredCenters.length ? filteredCenters.length : endIndex,
    );
  }

  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex {
    final end = startIndex + itemsPerPage.value;
    return end > totalCenters.value ? totalCenters.value : end;
  }

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => endIndex < totalCenters.value;

  void previousPage() {
    if (canGoPreviousPage) currentPage.value--;
  }

  void nextPage() {
    if (canGoNextPage) currentPage.value++;
  }

  void goToPage(int page) {
    currentPage.value = page;
  }

  void changeItemsPerPage(int? value) {
    if (value != null) {
      itemsPerPage.value = value;
      currentPage.value = 1;
    }
  }

  /// Sorting
  void sortCenters(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredCenters.sort((a, b) {
      int result;
      switch (columnIndex) {
        case 0: // Name
          result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 1: // Contact (Email)
          result = a.email.toLowerCase().compareTo(b.email.toLowerCase());
          break;
        case 2: // Location (City, State)
        // 首先比较 city，如果相同则比较 state
          result = a.centerLocation.address.city.toLowerCase()
              .compareTo(b.centerLocation.address.city.toLowerCase());
          if (result == 0) {
            result = a.centerLocation.address.state.toLowerCase()
                .compareTo(b.centerLocation.address.state.toLowerCase());
          }
          break;
        case 3: // Staff Count
          result = a.numberOfStaff.compareTo(b.numberOfStaff);
          break;
        case 4: // Created Date
          result = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          result = 0;
      }
      return ascending ? result : -result;
    });

    // 排序后重置到第一页
    currentPage.value = 1;
  }

  /// Disable center
  Future<void> disableCenter(PartnerRecyclingCenter center) async {
    try {
      FAdminLoaders.customToast(message: 'Disabling center...');

      // Update center status to disabled
      await _centerRepo.updateCenterStatus(center.centerId, 'disabled');

      // Ban all staff of this center
      await _centerRepo.banAllStaffOfCenter(center.centerId);

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: 'Center disabled and all staff banned successfully',
      );

      // Refresh centers list
      await fetchCenters();
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to disable center: ${e.toString()}',
      );
    }
  }

  /// Recover center
  Future<void> recoverCenter(PartnerRecyclingCenter center) async {
    try {
      FAdminLoaders.customToast(message: 'Recovering center...');

      // Update center status to active
      await _centerRepo.updateCenterStatus(center.centerId, 'active');

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: 'Center recovered successfully. Staff accounts remain banned.',
      );

      // Refresh centers list
      await fetchCenters();
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to recover center: ${e.toString()}',
      );
    }
  }

  /// Navigate to center details
  void viewCenter(PartnerRecyclingCenter center) {
    Get.to(() => RecyclingCenterDetailsScreen(centerId: center.centerId,));
  }

  /// Navigate to edit center
  void editCenter(PartnerRecyclingCenter center) {
    Get.to(() => EditPartnerCenterScreen(centerId: center.centerId,));
  }

  /// Add new center
  void addCenter() {
    Get.to(() => AddPartnerCenterScreen());
  }
}