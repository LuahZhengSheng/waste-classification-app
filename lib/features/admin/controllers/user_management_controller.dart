import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/helpers/helper_functions.dart';
import '../../authentication/models/user_model.dart';
import '../screens/user_management/user_management.dart';

class UserManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'gender': null,
    'joinDateRange': null,
    'isVerified': null,
    'isActive': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(), time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
  }

  void loadUsers() {
    // Mock data - replace with actual API call
    allUsers.value = _generateMockUsers();
    filteredUsers.value = List.from(allUsers);
  }

  List<UserModel> _generateMockUsers() {
    return [
      UserModel(
        userId: '1',
        username: 'john_doe',
        email: 'john@example.com',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: true,
        phoneNo: '123-456-7890',
        gender: 'Male',
        joinDate: DateTime(2024, 8, 15),
        rewardPoint: 150,
      ),
      UserModel(
        userId: '2',
        username: 'jane_smith',
        email: 'jane@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: true,
        isActive: true,
        phoneNo: '098-765-4321',
        gender: 'Female',
        joinDate: DateTime(2024, 7, 20),
        rewardPoint: 89,
      ),
      UserModel(
        userId: '3',
        username: 'mike_wilson',
        email: 'mike@example.com',
        loginAttemptCount: 3,
        role: 'user',
        isVerified: false,
        isActive: true,
        phoneNo: '555-123-4567',
        gender: 'Male',
        joinDate: DateTime(2024, 6, 10),
        rewardPoint: 234,
      ),
      UserModel(
        userId: '4',
        username: 'sarah_jones',
        email: 'sarah@example.com',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: false,
        phoneNo: '444-987-6543',
        gender: 'Female',
        joinDate: DateTime(2024, 1, 5),
        rewardPoint: 567,
      ),
      UserModel(
        userId: '5',
        username: 'david_brown',
        email: 'david@example.com',
        loginAttemptCount: 2,
        role: 'user',
        isVerified: true,
        isActive: true,
        phoneNo: '777-111-2222',
        gender: 'Male',
        joinDate: DateTime(2023, 12, 12),
        rewardPoint: 45,
      ),
      UserModel(
        userId: '6',
        username: 'lisa_davis',
        email: 'lisa@example.com',
        loginAttemptCount: 5,
        role: 'user',
        isVerified: false,
        isActive: true,
        phoneNo: '888-333-4444',
        gender: 'Female',
        joinDate: DateTime(2024, 8, 28),
        rewardPoint: 123,
      ),
      UserModel(
        userId: '7',
        username: 'alex_chen',
        email: 'alex@example.com',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: true,
        phoneNo: '999-555-1111',
        gender: 'Male',
        joinDate: DateTime(2024, 5, 3),
        rewardPoint: 789,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
      UserModel(
        userId: '8',
        username: 'emma_watson',
        email: 'emma@example.com',
        loginAttemptCount: 1,
        role: 'user',
        isVerified: false,
        isActive: false,
        phoneNo: '111-222-3333',
        gender: 'Female',
        joinDate: DateTime(2024, 3, 15),
        rewardPoint: 34,
      ),
    ];
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<UserModel> result = List.from(allUsers);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((user) {
        return user.username.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            user.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (user.phoneNo?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply filters
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

    if (activeFilters['isActive'] != null) {
      result = result.where((user) => user.isActive == activeFilters['isActive']).toList();
    }

    filteredUsers.value = result;
    currentPage.value = 1; // Reset to first page after filtering
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['gender'] != null ||
        activeFilters['joinDateRange'] != null ||
        activeFilters['isVerified'] != null ||
        activeFilters['isActive'] != null;
  }

  // Sorting functionality
  void sortUsers(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredUsers.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Username
          aValue = a.username;
          bValue = b.username;
          break;
        case 1: // Email
          aValue = a.email;
          bValue = b.email;
          break;
        case 2: // Phone
          aValue = a.phoneNo ?? '';
          bValue = b.phoneNo ?? '';
          break;
        case 3: // Gender
          aValue = a.gender ?? '';
          bValue = b.gender ?? '';
          break;
        case 4: // Join Date
          aValue = a.joinDate;
          bValue = b.joinDate;
          break;
        case 5: // Points
          aValue = a.rewardPoint;
          bValue = b.rewardPoint;
          break;
        case 6: // Verified
          aValue = a.isVerified ? 1 : 0;
          bValue = b.isVerified ? 1 : 0;
          break;
        case 7: // Login Attempts
          aValue = a.loginAttemptCount;
          bValue = b.loginAttemptCount;
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });
  }

  // Pagination functionality
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
    if (canGoPreviousPage) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (canGoNextPage) {
      currentPage.value++;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1; // Reset to first page
    }
  }

  void showFilters() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      FilterDialog(
        dark: dark,
        currentFilters: Map.from(activeFilters),
        onApplyFilters: (newFilters) {
          activeFilters.assignAll(newFilters);
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}