import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/user/center_staff_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../recycling_center/models/recycling_center_staff_model.dart';

enum StaffFilter { active, inactive, banned }

class StaffManagementController extends GetxController {
  static StaffManagementController get instance => Get.find();

  final RecyclingCenterStaffRepository _staffRepository = Get.put(RecyclingCenterStaffRepository());
  final UserRepository _userRepository = Get.put(UserRepository());
  final TextEditingController searchController = TextEditingController();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Observables
  final RxList<RecyclingCenterStaff> allStaff = <RecyclingCenterStaff>[].obs;
  final RxList<RecyclingCenterStaff> filteredStaff = <RecyclingCenterStaff>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<StaffFilter> currentFilter = StaffFilter.active.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxBool isLoading = true.obs;

  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'gender': null,
    'centerId': null,
    'isVerified': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadStaff();

    debounce(searchQuery, (_) => applyFiltersAndSearch(),
        time: const Duration(milliseconds: 500));

    ever(activeFilters, (_) => applyFiltersAndSearch());
    ever(currentFilter, (_) => applyFiltersAndSearch());
  }

  void loadStaff() {
    isLoading.value = true;

    _staffRepository.getStaffStream().listen((staff) {
      allStaff.value = staff;
      applyFiltersAndSearch();
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load staff: $error',
      );
    });
  }

  void changeFilter(StaffFilter filter) {
    currentFilter.value = filter;
  }

  void applyFiltersAndSearch() {
    List<RecyclingCenterStaff> result = List.from(allStaff);

    switch (currentFilter.value) {
      case StaffFilter.active:
        result = result.where((staff) => staff.isActive && !staff.isBanned).toList();
        break;
      case StaffFilter.inactive:
        result = result.where((staff) => !staff.isActive && !staff.isBanned).toList();
        break;
      case StaffFilter.banned:
        result = result.where((staff) => staff.isBanned).toList();
        break;
    }

    if (searchQuery.value.isNotEmpty) {
      result = result.where((staff) {
        return staff.username.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            staff.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            staff.userId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            staff.centerId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (staff.phoneNo?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      }).toList();
    }

    if (activeFilters['gender'] != null) {
      result = result.where((staff) => staff.gender == activeFilters['gender']).toList();
    }

    if (activeFilters['centerId'] != null && activeFilters['centerId'].isNotEmpty) {
      result = result.where((staff) => staff.centerId == activeFilters['centerId']).toList();
    }

    if (activeFilters['isVerified'] != null) {
      result = result.where((staff) => staff.isVerified == activeFilters['isVerified']).toList();
    }

    filteredStaff.value = result;
    currentPage.value = 1;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  bool get hasActiveFilters {
    return activeFilters['gender'] != null ||
        activeFilters['centerId'] != null ||
        activeFilters['isVerified'] != null;
  }

  void sortStaff(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    final sortedStaff = List<RecyclingCenterStaff>.from(filteredStaff);

    sortedStaff.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0:
          aValue = a.username.toLowerCase();
          bValue = b.username.toLowerCase();
          break;
        case 1:
          aValue = a.userId.toLowerCase();
          bValue = b.userId.toLowerCase();
          break;
        case 2:
          aValue = a.centerId.toLowerCase();
          bValue = b.centerId.toLowerCase();
          break;
        case 3:
          aValue = a.email.toLowerCase();
          bValue = b.email.toLowerCase();
          break;
        case 4:
          aValue = a.phoneNo?.toLowerCase() ?? '';
          bValue = b.phoneNo?.toLowerCase() ?? '';
          break;
        case 5:
          aValue = a.gender?.toLowerCase() ?? '';
          bValue = b.gender?.toLowerCase() ?? '';
          break;
        case 6:
          aValue = a.joinDate;
          bValue = b.joinDate;
          break;
        case 7:
          aValue = a.isVerified ? 1 : 0;
          bValue = b.isVerified ? 1 : 0;
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });

    filteredStaff.value = sortedStaff;
  }

  // Pagination
  List<RecyclingCenterStaff> get paginatedStaff {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredStaff.length);

    if (startIndex >= filteredStaff.length) {
      return [];
    }

    return filteredStaff.sublist(startIndex, endIndex);
  }

  int get totalStaff => filteredStaff.length;
  int get totalPages => (totalStaff / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalStaff);

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => currentPage.value < totalPages;

  void previousPage() {
    if (canGoPreviousPage) currentPage.value--;
  }

  void nextPage() {
    if (canGoNextPage) currentPage.value++;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1;
    }
  }

  // Staff Actions
  Future<void> createStaff({
    required String centerId,
    required String username,
    required String email,
  }) async {
    try {
      FLoaders.showLoading('Creating staff...');

      final HttpsCallable callable = _functions.httpsCallable(
        'createStaffManager',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final result = await callable.call(<String, dynamic>{
        'centerId': centerId,
        'username': username,
        'email': email,
        'role': 'center_staff',
      });

      final responseData = result.data;

      FLoaders.stopLoading();

      if (responseData['success'] == true) {
        if (responseData['emailSent'] == true) {
          FLoaders.successSnackBar(
            title: 'Success',
            message: 'Staff created successfully. Password reset email sent.',
          );
        } else {
          FLoaders.warningSnackBar(
            title: 'Staff Created',
            message: 'Staff account created but password reset email failed to send. ${responseData['emailError'] ?? ''}',
          );
        }

        loadStaff();
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: responseData['message'] ?? 'Failed to create staff',
        );
      }

    } catch (e) {
      FLoaders.stopLoading();

      String errorMessage = 'Failed to create staff: $e';

      if (e.toString().contains('already-exists')) {
        if (e.toString().contains('Email')) {
          errorMessage = 'Email is already registered';
        } else if (e.toString().contains('Username')) {
          errorMessage = 'Username is already taken';
        }
      } else if (e.toString().contains('invalid-argument')) {
        errorMessage = 'Invalid input data. Please check all fields.';
      } else if (e.toString().contains('unauthenticated')) {
        errorMessage = 'Authentication required. Please log in again.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'You do not have permission to create staff accounts';
      }

      FLoaders.errorSnackBar(
        title: 'Error',
        message: errorMessage,
      );
    }
  }

  // Send password reset link (using Cloud Function)
  Future<void> sendPasswordResetLink(RecyclingCenterStaff staff) async {
    try {
      // Check if can send
      if (!canSendResetLink(staff)) {
        FLoaders.warningSnackBar(
          title: 'Wait Required',
          message: 'Please wait ${staff.getFormattedRemainingResetTime()} before sending another reset link.',
        );
        return;
      }

      FLoaders.showLoading('Sending password reset link...');

      final HttpsCallable callable = _functions.httpsCallable(
        'resendPasswordReset',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      final result = await callable.call(<String, dynamic>{
        'userId': staff.userId,
        'email': staff.email,
      });

      final responseData = result.data;

      FLoaders.stopLoading();

      if (responseData['success'] == true) {
        FLoaders.successSnackBar(
          title: 'Success',
          message: 'Password reset link has been sent to ${staff.email}',
        );
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: responseData['message'] ?? 'Failed to send password reset link',
        );
      }

    } catch (e) {
      FLoaders.stopLoading();

      String errorMessage = e.toString();
      if (errorMessage.contains('wait')) {
        FLoaders.warningSnackBar(
          title: 'Please Wait',
          message: errorMessage,
        );
      } else if (errorMessage.contains('verified')) {
        FLoaders.warningSnackBar(
          title: 'Already Verified',
          message: 'Cannot send password reset to verified users',
        );
      } else if (errorMessage.contains('inactive') || errorMessage.contains('banned')) {
        FLoaders.errorSnackBar(
          title: 'Account Inactive',
          message: 'Cannot send password reset to inactive or banned users',
        );
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to send password reset link: $errorMessage',
        );
      }
    }
  }

  // Check if can send reset link (10 minutes cooldown)
  bool canSendResetLink(RecyclingCenterStaff staff) {
    final lastResetTime = staff.lastPasswordResetTime;
    if (lastResetTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastResetTime);
    return difference.inMinutes >= 10;
  }

  Future<void> banStaff(RecyclingCenterStaff staff) async {
    try {
      FLoaders.showLoading('Banning staff...');
      await _staffRepository.banStaff(staff);
      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Staff has been banned successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to ban staff: $e',
      );
    }
  }

  Future<void> recoverStaff(RecyclingCenterStaff staff) async {
    try {
      FLoaders.showLoading('Recovering staff...');
      await _staffRepository.recoverStaff(staff);
      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Staff has been recovered successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to recover staff: $e',
      );
    }
  }

  Future<void> updateStaff(
      RecyclingCenterStaff staff,
      Uint8List? pendingImageBytes,
      bool pendingDeleteImage
      ) async {
    try {
      FLoaders.showLoading('Updating staff...');

      RecyclingCenterStaff updatedStaff = staff;

      if (pendingDeleteImage && staff.profileImg != null && staff.profileImg!.isNotEmpty) {
        await _staffRepository.deleteProfileImage(staff.profileImg!);
        updatedStaff = staff.copyWith(profileImg: '');
      } else if (pendingImageBytes != null) {
        final fileName = await _staffRepository.uploadProfileImageWeb(
          pendingImageBytes,
          staff.userId,
          staff.profileImg,
        );

        if (fileName != null) {
          updatedStaff = staff.copyWith(profileImg: fileName);
        }
      }

      await _staffRepository.updateStaffDetails(updatedStaff);

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
          title: 'Success',
          message: 'Staff updated successfully'
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to update staff: $e'
      );
    }
  }

  String? getCachedProfileImageUrl(String? fileName) {
    return _userRepository.getCachedProfileImageUrl(fileName);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}