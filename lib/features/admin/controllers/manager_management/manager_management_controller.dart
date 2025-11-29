import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/user/manager_repository.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/admin_model.dart';

enum ManagerFilter { active, inactive, banned }

class ManagerManagementController extends GetxController {
  static ManagerManagementController get instance => Get.find();

  final ManagerRepository _managerRepository = Get.put(ManagerRepository());
  final TextEditingController searchController = TextEditingController();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Observables
  final RxList<AdminModel> allManagers = <AdminModel>[].obs;
  final RxList<AdminModel> filteredManagers = <AdminModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<ManagerFilter> currentFilter = ManagerFilter.active.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxBool isLoading = true.obs;

  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'role': null,
    'isVerified': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadManagers();

    debounce(searchQuery, (_) => applyFiltersAndSearch(),
        time: const Duration(milliseconds: 500));

    ever(activeFilters, (_) => applyFiltersAndSearch());
    ever(currentFilter, (_) => applyFiltersAndSearch());
  }

  void loadManagers() {
    isLoading.value = true;

    _managerRepository.getManagersStream().listen((managers) {
      allManagers.value = managers;
      applyFiltersAndSearch();
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load managers: $error',
      );
    });
  }

  void changeFilter(ManagerFilter filter) {
    currentFilter.value = filter;
  }

  void applyFiltersAndSearch() {
    List<AdminModel> result = List.from(allManagers);

    // Apply filter based on active/inactive/banned
    switch (currentFilter.value) {
      case ManagerFilter.active:
        result = result
            .where((manager) => manager.isActive && !manager.isBanned)
            .toList();
        break;
      case ManagerFilter.inactive:
        result = result
            .where((manager) => !manager.isActive && !manager.isBanned)
            .toList();
        break;
      case ManagerFilter.banned:
        result = result.where((manager) => manager.isBanned).toList();
        break;
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((manager) {
        return manager.username
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()) ||
            manager.email
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            manager.userId
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            (manager.phoneNo
                ?.toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ??
                false);
      }).toList();
    }

    // Apply role filter
    if (activeFilters['role'] != null) {
      result = result
          .where((manager) => manager.role == activeFilters['role'])
          .toList();
    }

    // Apply verification filter
    if (activeFilters['isVerified'] != null) {
      result = result
          .where((manager) => manager.isVerified == activeFilters['isVerified'])
          .toList();
    }

    filteredManagers.value = result;
    currentPage.value = 1;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  bool get hasActiveFilters {
    return activeFilters['role'] != null || activeFilters['isVerified'] != null;
  }

  void sortManagers(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    final sortedManagers = List<AdminModel>.from(filteredManagers);

    sortedManagers.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Username
          aValue = a.username.toLowerCase();
          bValue = b.username.toLowerCase();
          break;
        case 1: // User ID
          aValue = a.userId.toLowerCase();
          bValue = b.userId.toLowerCase();
          break;
        case 2: // Email
          aValue = a.email.toLowerCase();
          bValue = b.email.toLowerCase();
          break;
        case 3: // Phone
          aValue = a.phoneNo?.toLowerCase() ?? '';
          bValue = b.phoneNo?.toLowerCase() ?? '';
          break;
        case 4: // Role
          aValue = a.role.toLowerCase();
          bValue = b.role.toLowerCase();
          break;
        case 5: // Verified
          aValue = a.isVerified ? 1 : 0;
          bValue = b.isVerified ? 1 : 0;
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });

    filteredManagers.value = sortedManagers;
  }

  // Pagination
  List<AdminModel> get paginatedManagers {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex =
    (startIndex + itemsPerPage.value).clamp(0, filteredManagers.length);

    if (startIndex >= filteredManagers.length) {
      return [];
    }

    return filteredManagers.sublist(startIndex, endIndex);
  }

  int get totalManagers => filteredManagers.length;
  int get totalPages => (totalManagers / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalManagers);

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

  // Manager Actions
  Future<void> createManager({
    required String username,
    required String email,
    required String role,
  }) async {
    try {
      FLoaders.showLoading('Creating manager...');

      final HttpsCallable callable = _functions.httpsCallable(
        'createStaffManager',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );

      final result = await callable.call(<String, dynamic>{
        'username': username,
        'email': email,
        'role': role,
      });

      final responseData = result.data;

      FLoaders.stopLoading();

      if (responseData['success'] == true) {
        if (responseData['emailSent'] == true) {
          FLoaders.successSnackBar(
            title: 'Success',
            message: 'Manager created successfully. Password reset email sent.',
          );
        } else {
          FLoaders.warningSnackBar(
            title: 'Manager Created',
            message: 'Manager account created but password reset email failed to send. ${responseData['emailError'] ?? ''}',
          );
        }

        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: responseData['message'] ?? 'Failed to create manager',
        );
      }

    } catch (e) {
      FLoaders.stopLoading();

      String errorMessage = 'Failed to create manager: $e';

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
        errorMessage = 'You do not have permission to create manager accounts';
      }

      FLoaders.errorSnackBar(
        title: 'Error',
        message: errorMessage,
      );
    }
  }

  // 发送密码重置链接 (使用 Cloud Function)
  Future<void> sendPasswordResetLink(AdminModel manager) async {
    try {
      // 检查是否可以发送
      if (!canSendResetLink(manager)) {
        FLoaders.warningSnackBar(
          title: 'Wait Required',
          message: 'Please wait 10 minutes before sending another reset link.',
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
        'userId': manager.userId,
        'email': manager.email,
      });

      final responseData = result.data;

      FLoaders.stopLoading();

      if (responseData['success'] == true) {
        FLoaders.successSnackBar(
          title: 'Success',
          message: 'Password reset link has been sent to ${manager.email}',
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
        // 提取等待分钟数
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

  // 检查是否可以发送重置链接（10分钟限制）
  bool canSendResetLink(AdminModel manager) {
    final lastResetTime = manager.lastPasswordResetTime;
    if (lastResetTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastResetTime);
    return difference.inMinutes >= 10;
  }

  // Manager Actions with Email Notifications
  Future<void> banManager(AdminModel manager) async {
    try {
      FLoaders.showLoading('Banning manager...');
      await _managerRepository.banManager(manager);
      FLoaders.stopLoading();
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to ban manager: $e',
      );
    }
  }

  Future<void> recoverManager(AdminModel manager) async {
    try {
      FLoaders.showLoading('Recovering manager...');
      await _managerRepository.recoverManager(manager);
      FLoaders.stopLoading();
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to recover manager: $e',
      );
    }
  }

  Future<void> updateManager(
      AdminModel manager,
      Uint8List? pendingImageBytes,
      bool pendingDeleteImage
      ) async {
    try {
      FLoaders.showLoading('Updating manager...');

      AdminModel updatedManager = manager;

      if (pendingDeleteImage && manager.profileImg != null && manager.profileImg!.isNotEmpty) {
        await _managerRepository.deleteProfileImage(manager.profileImg!);
        updatedManager = manager.copyWith(profileImg: '');
      } else if (pendingImageBytes != null) {
        final fileName = await _managerRepository.uploadProfileImageWeb(
          pendingImageBytes,
          manager.userId,
          manager.profileImg,
        );

        if (fileName != null) {
          updatedManager = manager.copyWith(profileImg: fileName);
        }
      }

      await _managerRepository.updateManagerDetails(updatedManager);

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
          title: 'Success',
          message: 'Manager updated successfully'
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to update manager: $e'
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}