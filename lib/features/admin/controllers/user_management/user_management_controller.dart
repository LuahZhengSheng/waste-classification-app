import 'dart:convert';
import 'dart:math' as Math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../../data/services/profile_image/profile_image_service.dart';

enum UserFilter { active, inactive, banned }

class UserManagementController extends GetxController {
  static UserManagementController get instance => Get.find();

  final UserRepository _userRepository = Get.put(UserRepository());
  final AuthenticationRepository _authRepository = Get.put(AuthenticationRepository());
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<UserFilter> currentFilter = UserFilter.active.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxBool isLoading = true.obs;

  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'gender': null,
    'joinDateRange': null,
    'isVerified': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _checkRoleAndRedirect();
    loadUsers();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(),
        time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
    ever(currentFilter, (_) => applyFiltersAndSearch());
  }

  void _checkRoleAndRedirect() async {
    final currentUser = _authRepository.authUser?.uid;

    if (currentUser == null) {
      print('❌ User not logged in, redirecting to login page');
      await _authRepository.logout();
      return;
    }

    try {
      // Get role from user data
      final user = await _userRepository.fetchUserDetails();

      if (user.role != 'admin') {
        print('❌ Insufficient permissions: User role ${user.role} cannot access user management');
        FLoaders.errorSnackBar(
            title: 'Insufficient Permissions',
            message: 'You do not have permission to access this page'
        );
        await _authRepository.logout();
      } else {
        print('✅ Permission verification passed, starting to load user data');
        loadUsers(); // Only load data when permission is granted
      }
    } catch (error) {
      print('❌ Failed to get user information: $error');
      await _authRepository.logout();
    }
  }

  void loadUsers() {
    isLoading.value = true;

    // Stream all users with role = 'user'
    _userRepository.getUsersSortedByField(
      field: 'joinDate',
      descending: true,
      limit: 1000,
      minValue: 0,
    ).listen((users) {
      if (users.isNotEmpty) {
        for (int i = 0; i < Math.min(3, users.length); i++) {
          final user = users[i];
          print('   ${i + 1}. ${user.username} (ID: ${user.userId}), 加入时间: ${user.joinDate}');
        }
      } else {
        print('⚠️ 用户列表为空，可能没有符合条件的用户');
      }

      allUsers.value = users;

      isLoading.value = false;
      print('📱 UI状态: isLoading = false (隐藏加载动画)');
      print('🎉 [UserManagementController] loadUsers() 执行完成');

    }, onError: (error) {
      print('❌ [UserManagementController] 加载用户数据时发生错误');
      print('🔴 错误详情: $error');

      isLoading.value = false;
      print('📱 UI状态: isLoading = false (隐藏加载动画)');

      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load users: $error',
      );
      print('📢 已显示错误提示 SnackBar');
    });

    print('📡 [UserManagementController] 已建立数据流监听');
  }

  void changeFilter(UserFilter filter) {
    currentFilter.value = filter;
  }

  void applyFiltersAndSearch() {
    List<UserModel> result = List.from(allUsers);

    // Apply filter based on active/inactive/banned
    switch (currentFilter.value) {
      case UserFilter.active:
        result = result.where((user) => user.isActive && !user.isBanned).toList();
        break;
      case UserFilter.inactive:
        result = result.where((user) => !user.isActive && !user.isBanned).toList();
        break;
      case UserFilter.banned:
        result = result.where((user) => user.isBanned).toList();
        break;
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((user) {
        return user.username.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            user.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            user.userId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (user.phoneNo?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply additional filters
    if (activeFilters['gender'] != null) {
      result = result.where((user) => user.gender == activeFilters['gender']).toList();
    }

    if (activeFilters['joinDateRange'] != null) {
      final now = DateTime.now();
      DateTime? startDate;

      switch (activeFilters['joinDateRange']) {
        case 'last7days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'last30days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'last90days':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'thisYear':
          startDate = DateTime(now.year, 1, 1);
          break;
      }

      if (startDate != null) {
        result = result.where((user) => user.joinDate.isAfter(startDate!)).toList();
      }
    }

    if (activeFilters['isVerified'] != null) {
      result = result.where((user) => user.isVerified == activeFilters['isVerified']).toList();
    }

    filteredUsers.value = result;
    currentPage.value = 1;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  bool get hasActiveFilters {
    return activeFilters['gender'] != null ||
        activeFilters['joinDateRange'] != null ||
        activeFilters['isVerified'] != null;
  }

  void sortUsers(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    // 使用 List.from 创建新列表以避免直接修改原列表
    final sortedUsers = List<UserModel>.from(filteredUsers);

    sortedUsers.sort((a, b) {
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
        case 4: // Gender
          aValue = a.gender?.toLowerCase() ?? '';
          bValue = b.gender?.toLowerCase() ?? '';
          break;
        case 5: // DOB
          aValue = a.dob ?? DateTime(1900);
          bValue = b.dob ?? DateTime(1900);
          break;
        case 6: // Points
          aValue = a.rewardPoint;
          bValue = b.rewardPoint;
          break;
        case 7: // Join Date
          aValue = a.joinDate;
          bValue = b.joinDate;
          break;
        case 8: // Verified
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

    // 更新 filteredUsers
    filteredUsers.value = sortedUsers;
  }

  // Pagination
  List<UserModel> get paginatedUsers {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredUsers.length);

    if (startIndex >= filteredUsers.length) {
      return [];
    }

    return filteredUsers.sublist(startIndex, endIndex);
  }

  int get totalUsers => filteredUsers.length;
  int get totalPages => (totalUsers / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalUsers);

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

  // User Actions
  Future<void> banUser(UserModel user) async {
    try {
      FLoaders.showLoading('Banning user...');

      await _userRepository.updateUserDetails(
        user.copyWith(isBanned: true, isActive: false),
      );

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'User has been banned successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to ban user: $e',
      );
    }
  }

  Future<void> recoverUser(UserModel user) async {
    try {
      FLoaders.showLoading('Recovering user...');

      await _userRepository.updateUserDetails(
        user.copyWith(isBanned: false, isActive: true),
      );

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'User has been recovered successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to recover user: $e',
      );
    }
  }

  Future<void> updateUser(
      UserModel user,
      Uint8List? pendingImageBytes,
      bool pendingDeleteImage
      ) async {
    try {
      FLoaders.showLoading('Updating user...');

      UserModel updatedUser = user;

      // 处理图片删除
      if (pendingDeleteImage && user.profileImg != null && user.profileImg!.isNotEmpty) {
        await ProfileImageService.deleteProfileImage(
          userId: user.userId,
          profileImg: user.profileImg,
        );
        updatedUser = user.copyWith(profileImg: '');
      }
      // 处理图片上传
      else if (pendingImageBytes != null) {
        final fileName = await ProfileImageService.uploadProfileImage(
          imageBytes: pendingImageBytes,
          userId: user.userId,
          currentProfileImg: user.profileImg,
        );

        if (fileName != null) {
          updatedUser = user.copyWith(profileImg: fileName);
        }
      }

      await _userRepository.updateUserDetails(updatedUser);

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
          title: 'Success',
          message: 'User updated successfully'
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to update user: $e'
      );
    }
  }

  Future<String> _createTempImageUrl(Uint8List imageBytes) async {
    // 对于Web环境，我们可以使用Blob URL或者直接使用base64
    // 这里使用base64数据URL作为临时解决方案
    final base64String = base64Encode(imageBytes);
    return 'data:image/webp;base64,$base64String';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}