import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../../data/repositories/user/manager_repository.dart';
import '../../../../data/services/email/email_service.dart';
import '../../models/admin_model.dart';

enum ManagerFilter { active, inactive, banned }

class ManagerManagementController extends GetxController {
  static ManagerManagementController get instance => Get.find();

  final ManagerRepository _managerRepository = Get.put(ManagerRepository());
  final UserRepository _userRepository = Get.put(UserRepository());
  final AuthenticationRepository _authRepository =
  Get.put(AuthenticationRepository());
  final EmailService _emailService = EmailService();
  final TextEditingController searchController = TextEditingController();

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

    // 使用 List.from 创建新列表以避免直接修改原列表
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

    // 更新 filteredManagers
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
    required String password,
    required String role,
  }) async {
    try {
      FLoaders.showLoading('Creating manager...');
      print('🔄 Starting manager creation process...');

      final currentUserId = _authRepository.authUser?.uid;

      // Check username uniqueness
      final isUsernameUnique =
      await _managerRepository.isUsernameUnique(username, currentUserId!);
      if (!isUsernameUnique) {
        FLoaders.stopLoading();
        print('❌ Username already taken: $username');
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Username is already taken',
        );
        return;
      }

      // Check email uniqueness
      final isEmailUnique = await _managerRepository.isEmailUnique(email);
      if (!isEmailUnique) {
        FLoaders.stopLoading();
        print('❌ Email already registered: $email');
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Email is already registered',
        );
        return;
      }

      print('✅ Username and email validation passed');

      // Create auth account
      final userCredential =
      await _authRepository.registerWithEmailAndPassword(email, password);
      print('✅ Firebase auth account created: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        throw 'Failed to create manager account - no user returned';
      }

      // Create manager record in Firestore
      final manager = AdminModel(
        userId: userCredential.user!.uid,
        username: username,
        email: email,
        role: role,
        isVerified: false,
        isActive: true,
        isBanned: false,
        loginAttemptCount: 0,
      );

      await _managerRepository.createManager(manager);
      print('✅ Manager record created in Firestore');

      // Send verification email
      await _authRepository.sendPasswordResetEmail(email);
      print('✅ Verification email sent');

      FLoaders.stopLoading();
      print('✅ Manager creation completed successfully');

      // Show success message first
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Manager created successfully. Verification email sent.',
      );

      // Then close the dialog after a short delay to allow SnackBar to show
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      FLoaders.stopLoading();
      print('❌ Manager creation failed: $e');
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create manager: $e',
      );
      // Don't close the dialog on error so user can see the error message
    }
  }

  // Manager Actions with Email Notifications
  Future<void> banManager(AdminModel manager) async {
    try {
      FLoaders.showLoading('Banning manager...');

      await _managerRepository.banManager(manager);

      // Send email notification using the new EmailService
      // final emailResult = await _emailService.sendManagerNotification(
      //   toEmail: manager.email,
      //   subject: 'Account Suspension Notice - SaveEarth',
      //   message: ManagerEmailTemplates.getBanNotification(manager.username),
      //   managerName: manager.username,
      //   actionType: 'account_suspension',
      // );

      FLoaders.stopLoading();

      // if (emailResult.success) {
      //   FLoaders.successSnackBar(
      //     title: 'Success',
      //     message: 'Manager has been banned successfully. Notification sent.',
      //   );
      // } else if (emailResult.shouldRetry) {
      //   FLoaders.warningSnackBar(
      //     title: 'Warning',
      //     message: 'Manager banned but email notification failed. Will retry.',
      //   );
      // } else {
      //   FLoaders.warningSnackBar(
      //     title: 'Warning',
      //     message: 'Manager banned but email notification failed: ${emailResult.error}',
      //   );
      // }

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

      // Send email notification using the new EmailService
      // final emailResult = await _emailService.sendManagerNotification(
      //   toEmail: manager.email,
      //   subject: 'Account Recovery Notice - SaveEarth',
      //   message: ManagerEmailTemplates.getRecoverNotification(manager.username),
      //   managerName: manager.username,
      //   actionType: 'account_recovery',
      // );

      FLoaders.stopLoading();

      // if (emailResult.success) {
      //   FLoaders.successSnackBar(
      //     title: 'Success',
      //     message: 'Manager has been recovered successfully. Notification sent.',
      //   );
      // } else if (emailResult.shouldRetry) {
      //   FLoaders.warningSnackBar(
      //     title: 'Warning',
      //     message: 'Manager recovered but email notification failed. Will retry.',
      //   );
      // } else {
      //   FLoaders.warningSnackBar(
      //     title: 'Warning',
      //     message: 'Manager recovered but email notification failed: ${emailResult.error}',
      //   );
      // }

    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to recover manager: $e',
      );
    }
  }

  Future<void> updateManager(AdminModel manager, File? newProfileImage) async {
    try {
      FLoaders.showLoading('Updating manager...');

      // Get old manager data for comparison
      final oldManager = await _managerRepository.getManagerById(manager.userId);

      if (newProfileImage != null) {
        final imageUrl = await _userRepository.uploadProfileImage(
          newProfileImage,
          manager.userId,
          manager.profileImg,
        );
        manager = manager.copyWith(profileImg: imageUrl);
      }

      await _managerRepository.updateManagerDetails(manager);

      // Send email notification if there were significant changes
      // if (oldManager != null) {
      //   final changes = _getChangedFields(oldManager, manager);
      //   if (changes.isNotEmpty) {
      //     final emailResult = await _emailService.sendManagerNotification(
      //       toEmail: manager.email,
      //       subject: 'Account Updated - SaveEarth',
      //       message: ManagerEmailTemplates.getUpdateNotification(manager.username, changes),
      //       managerName: manager.username,
      //       actionType: 'account_updated',
      //     );
      //
      //     if (!emailResult.success && !emailResult.shouldRetry) {
      //       print('⚠️ Update notification failed: ${emailResult.error}');
      //     }
      //   }
      // }

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Manager updated successfully.',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update manager: $e',
      );
    }
  }

  List<String> _getChangedFields(AdminModel oldManager, AdminModel newManager) {
    final changes = <String>[];

    if (oldManager.username != newManager.username) {
      changes.add('- Username: ${oldManager.username} → ${newManager.username}');
    }
    if (oldManager.email != newManager.email) {
      changes.add('- Email: ${oldManager.email} → ${newManager.email}');
    }
    if (oldManager.role != newManager.role) {
      changes.add('- Role: ${oldManager.role} → ${newManager.role}');
    }
    if (oldManager.phoneNo != newManager.phoneNo) {
      changes.add('- Phone: ${oldManager.phoneNo ?? 'Not set'} → ${newManager.phoneNo ?? 'Not set'}');
    }
    if (oldManager.isActive != newManager.isActive) {
      changes.add('- Status: ${oldManager.isActive ? 'Active' : 'Inactive'} → ${newManager.isActive ? 'Active' : 'Inactive'}');
    }

    return changes;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}