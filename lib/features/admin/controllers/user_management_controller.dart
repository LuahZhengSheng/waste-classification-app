import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SortColumn {
  username,
  email,
  role,
  joinDate,
  rewardPoint,
  isActive,
  isVerified
}

enum SortDirection { ascending, descending }

class UserManagementController extends GetxController {
  // Observable variables
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUsers = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedRole = 'All'.obs;
  final RxString _selectedStatus = 'All'.obs;
  final RxString _selectedVerificationStatus = 'All'.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _itemsPerPage = 10.obs;
  final Rx<SortColumn> _sortColumn = SortColumn.username.obs;
  final Rx<SortDirection> _sortDirection = SortDirection.ascending.obs;

  // Getters
  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedRole => _selectedRole.value;
  String get selectedStatus => _selectedStatus.value;
  String get selectedVerificationStatus => _selectedVerificationStatus.value;
  int get currentPage => _currentPage.value;
  int get itemsPerPage => _itemsPerPage.value;
  SortColumn get sortColumn => _sortColumn.value;
  SortDirection get sortDirection => _sortDirection.value;

  // Pagination
  int get totalPages => (filteredUsers.length / itemsPerPage).ceil();
  int get startIndex => (currentPage - 1) * itemsPerPage;
  int get endIndex => (startIndex + itemsPerPage).clamp(0, filteredUsers.length);
  List<UserModel> get paginatedUsers => filteredUsers.sublist(startIndex, endIndex);

  // Filter options
  final List<String> roleOptions = ['All', 'User', 'Admin', 'Manager'];
  final List<String> statusOptions = ['All', 'Active', 'Inactive'];
  final List<String> verificationOptions = ['All', 'Verified', 'Unverified'];

  @override
  void onInit() {
    super.onInit();
    loadUsers();

    // Listen to search query changes
    debounce(_searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> loadUsers() async {
    try {
      _isLoading.value = true;

      // Mock data for demonstration
      // Replace with actual Firestore query
      final mockUsers = _generateMockUsers();
      _users.assignAll(mockUsers);

      _applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void updateRoleFilter(String role) {
    _selectedRole.value = role;
    _applyFilters();
  }

  void updateStatusFilter(String status) {
    _selectedStatus.value = status;
    _applyFilters();
  }

  void updateVerificationFilter(String verification) {
    _selectedVerificationStatus.value = verification;
    _applyFilters();
  }

  void updateItemsPerPage(int items) {
    _itemsPerPage.value = items;
    _currentPage.value = 1;
    _applyFilters();
  }

  void goToPage(int page) {
    _currentPage.value = page.clamp(1, totalPages);
  }

  void nextPage() {
    if (currentPage < totalPages) {
      _currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      _currentPage.value--;
    }
  }

  void sortBy(SortColumn column) {
    if (_sortColumn.value == column) {
      _sortDirection.value = _sortDirection.value == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending;
    } else {
      _sortColumn.value = column;
      _sortDirection.value = SortDirection.ascending;
    }
    _applyFilters();
  }

  void _applyFilters() {
    List<UserModel> filtered = List.from(_users);

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.username.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
            (user.phoneNo?.toLowerCase().contains(_searchQuery.value.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply role filter
    if (_selectedRole.value != 'All') {
      filtered = filtered.where((user) => user.role == _selectedRole.value).toList();
    }

    // Apply status filter
    if (_selectedStatus.value != 'All') {
      bool isActive = _selectedStatus.value == 'Active';
      filtered = filtered.where((user) => user.isActive == isActive).toList();
    }

    // Apply verification filter
    if (_selectedVerificationStatus.value != 'All') {
      bool isVerified = _selectedVerificationStatus.value == 'Verified';
      filtered = filtered.where((user) => user.isVerified == isVerified).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      dynamic aValue, bValue;

      switch (_sortColumn.value) {
        case SortColumn.username:
          aValue = a.username.toLowerCase();
          bValue = b.username.toLowerCase();
          break;
        case SortColumn.email:
          aValue = a.email.toLowerCase();
          bValue = b.email.toLowerCase();
          break;
        case SortColumn.role:
          aValue = a.role.toLowerCase();
          bValue = b.role.toLowerCase();
          break;
        case SortColumn.joinDate:
          aValue = a.joinDate;
          bValue = b.joinDate;
          break;
        case SortColumn.rewardPoint:
          aValue = a.rewardPoint;
          bValue = b.rewardPoint;
          break;
        case SortColumn.isActive:
          aValue = a.isActive ? 1 : 0;
          bValue = b.isActive ? 1 : 0;
          break;
        case SortColumn.isVerified:
          aValue = a.isVerified ? 1 : 0;
          bValue = b.isVerified ? 1 : 0;
          break;
      }

      int comparison = aValue.compareTo(bValue);
      return _sortDirection.value == SortDirection.ascending ? comparison : -comparison;
    });

    _filteredUsers.assignAll(filtered);

    // Reset to first page if current page exceeds total pages
    if (_currentPage.value > totalPages && totalPages > 0) {
      _currentPage.value = 1;
    }
  }

  void clearFilters() {
    _searchQuery.value = '';
    _selectedRole.value = 'All';
    _selectedStatus.value = 'All';
    _selectedVerificationStatus.value = 'All';
    _currentPage.value = 1;
    _applyFilters();
  }

  Future<void> toggleUserStatus(String userId) async {
    try {
      final userIndex = _users.indexWhere((user) => user.userId == userId);
      if (userIndex != -1) {
        final updatedUser = _users[userIndex].copyWith(
          isActive: !_users[userIndex].isActive,
        );
        _users[userIndex] = updatedUser;
        _applyFilters();

        // TODO: Update in Firestore
        Get.snackbar(
          'Success',
          'User status updated successfully',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user status: $e');
    }
  }

  Future<void> toggleUserVerification(String userId) async {
    try {
      final userIndex = _users.indexWhere((user) => user.userId == userId);
      if (userIndex != -1) {
        final updatedUser = _users[userIndex].copyWith(
          isVerified: !_users[userIndex].isVerified,
        );
        _users[userIndex] = updatedUser;
        _applyFilters();

        // TODO: Update in Firestore
        Get.snackbar(
          'Success',
          'User verification updated successfully',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user verification: $e');
    }
  }

  // Mock data generator
  List<UserModel> _generateMockUsers() {
    return List.generate(50, (index) {
      return UserModel(
        userId: 'user_$index',
        username: 'User${index + 1}',
        email: 'user${index + 1}@example.com',
        phoneNo: index % 3 == 0 ? '+60${1000000000 + index}' : null,
        profileImage: index % 4 == 0 ? 'https://via.placeholder.com/150' : null,
        loginAttemptCount: index % 5,
        role: ['User', 'Admin'][index % 2],
        isVerified: index % 3 == 0,
        isActive: index % 4 != 0,
        gender: ['Male', 'Female', null][(index) % 3],
        dob: index % 2 == 0 ? DateTime(1990 + (index % 30), 1 + (index % 12), 1 + (index % 28)) : null,
        joinDate: DateTime.now().subtract(Duration(days: index * 10)),
        rewardPoint: index * 10,
      );
    });
  }
}

// import 'package:flutter/material.dart';
// import 'package:fyp/common/models/role_model.dart';
// import 'package:fyp/features/authentication/models/user_model.dart';
//
// enum SortColumn {
//   userId,
//   username,
//   email,
//   phoneNo,
//   role,
//   joinDate,
//   rewardPoint,
//   isActive,
//   isVerified,
// }
//
// enum FilterStatus {
//   all,
//   active,
//   inactive,
//   verified,
//   unverified,
// }
//
// enum FilterRole {
//   all,
//   user,
//   admin,
//   moderator,
// }
//
// class UserManagementController extends ChangeNotifier {
//   // Data
//   List<UserModel> _allUsers = [];
//   List<UserModel> _filteredUsers = [];
//
//   // Pagination
//   int _currentPage = 1;
//   int _itemsPerPage = 10;
//   int _totalPages = 1;
//
//   // Search and Filter
//   String _searchQuery = '';
//   FilterStatus _statusFilter = FilterStatus.all;
//   FilterRole _roleFilter = FilterRole.all;
//
//   // Sorting
//   SortColumn _sortColumn = SortColumn.joinDate;
//   bool _sortAscending = false;
//
//   // Loading states
//   bool _isLoading = false;
//   String? _error;
//
//   // Selected items
//   Set<String> _selectedUserIds = {};
//   bool _isSelectAll = false;
//
//   // Getters
//   List<UserModel> get filteredUsers => _getPagedUsers();
//   List<UserModel> get allUsers => _allUsers;
//   int get currentPage => _currentPage;
//   int get itemsPerPage => _itemsPerPage;
//   int get totalPages => _totalPages;
//   int get totalItems => _filteredUsers.length;
//   String get searchQuery => _searchQuery;
//   FilterStatus get statusFilter => _statusFilter;
//   FilterRole get roleFilter => _roleFilter;
//   SortColumn get sortColumn => _sortColumn;
//   bool get sortAscending => _sortAscending;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   Set<String> get selectedUserIds => _selectedUserIds;
//   bool get isSelectAll => _isSelectAll;
//   bool get hasSelection => _selectedUserIds.isNotEmpty;
//
//   // Initialize with mock data
//   UserManagementController() {
//     _initializeMockData();
//   }
//
//   void _initializeMockData() {
//     _allUsers = [
//       UserModel(
//         userId: '00001',
//         username: 'Christine Brooks',
//         email: 'christine@example.com',
//         phoneNo: '+1234567890',
//         role: 'user',
//         isVerified: true,
//         isActive: true,
//         loginAttemptCount: 0,
//         gender: 'Female',
//         dob: DateTime(1990, 5, 15),
//         joinDate: DateTime(2023, 2, 14),
//         rewardPoint: 1250,
//         profileImage: null,
//       ),
//       UserModel(
//         userId: '00002',
//         username: 'Rosie Pearson',
//         email: 'rosie@example.com',
//         phoneNo: '+1234567891',
//         role: 'user',
//         isVerified: true,
//         isActive: true,
//         loginAttemptCount: 0,
//         gender: 'Female',
//         dob: DateTime(1985, 8, 22),
//         joinDate: DateTime(2023, 2, 14),
//         rewardPoint: 980,
//         profileImage: null,
//       ),
//       UserModel(
//         userId: '00003',
//         username: 'Darrell Caldwell',
//         email: 'darrell@example.com',
//         phoneNo: '+1234567892',
//         role: 'user',
//         isVerified: false,
//         isActive: false,
//         loginAttemptCount: 2,
//         gender: 'Male',
//         dob: DateTime(1992, 12, 3),
//         joinDate: DateTime(2023, 2, 14),
//         rewardPoint: 650,
//         profileImage: null,
//       ),
//       UserModel(
//         userId: '00004',
//         username: 'Gilbert Johnston',
//         email: 'gilbert@example.com',
//         phoneNo: '+1234567893',
//         role: 'user',
//         isVerified: true,
//         isActive: true,
//         loginAttemptCount: 0,
//         gender: 'Male',
//         dob: DateTime(1988, 3, 17),
//         joinDate: DateTime(2023, 2, 14),
//         rewardPoint: 2100,
//         profileImage: null,
//       ),
//       UserModel(
//         userId: '00005',
//         username: 'Alan Cain',
//         email: 'alan@example.com',
//         phoneNo: '+1234567894',
//         role: 'user',
//         isVerified: true,
//         isActive: true,
//         loginAttemptCount: 0,
//         gender: 'Male',
//         dob: DateTime(1995, 7, 9),
//         joinDate: DateTime(2023, 2, 14),
//         rewardPoint: 875,
//         profileImage: null,
//       ),
//     ];
//
//     _applyFiltersAndSort();
//   }
//
//   // Search
//   void updateSearch(String query) {
//     _searchQuery = query.toLowerCase();
//     _currentPage = 1;
//     _applyFiltersAndSort();
//     notifyListeners();
//   }
//
//   // Filters
//   void updateStatusFilter(FilterStatus status) {
//     _statusFilter = status;
//     _currentPage = 1;
//     _applyFiltersAndSort();
//     notifyListeners();
//   }
//
//   void updateRoleFilter(FilterRole role) {
//     _roleFilter = role;
//     _currentPage = 1;
//     _applyFiltersAndSort();
//     notifyListeners();
//   }
//
//   void resetFilters() {
//     _searchQuery = '';
//     _statusFilter = FilterStatus.all;
//     _roleFilter = FilterRole.all;
//     _currentPage = 1;
//     _applyFiltersAndSort();
//     notifyListeners();
//   }
//
//   // Sorting
//   void updateSort(SortColumn column) {
//     if (_sortColumn == column) {
//       _sortAscending = !_sortAscending;
//     } else {
//       _sortColumn = column;
//       _sortAscending = true;
//     }
//     _applyFiltersAndSort();
//     notifyListeners();
//   }
//
//   // Pagination
//   void updateItemsPerPage(int itemsPerPage) {
//     _itemsPerPage = itemsPerPage;
//     _currentPage = 1;
//     _calculateTotalPages();
//     notifyListeners();
//   }
//
//   void goToPage(int page) {
//     if (page >= 1 && page <= _totalPages) {
//       _currentPage = page;
//       notifyListeners();
//     }
//   }
//
//   void goToNextPage() {
//     if (_currentPage < _totalPages) {
//       _currentPage++;
//       notifyListeners();
//     }
//   }
//
//   void goToPreviousPage() {
//     if (_currentPage > 1) {
//       _currentPage--;
//       notifyListeners();
//     }
//   }
//
//   // Selection
//   void toggleUserSelection(String userId) {
//     if (_selectedUserIds.contains(userId)) {
//       _selectedUserIds.remove(userId);
//     } else {
//       _selectedUserIds.add(userId);
//     }
//     _updateSelectAllState();
//     notifyListeners();
//   }
//
//   void toggleSelectAll() {
//     if (_isSelectAll) {
//       _selectedUserIds.clear();
//     } else {
//       _selectedUserIds = _getPagedUsers().map((user) => user.userId).toSet();
//     }
//     _updateSelectAllState();
//     notifyListeners();
//   }
//
//   void clearSelection() {
//     _selectedUserIds.clear();
//     _isSelectAll = false;
//     notifyListeners();
//   }
//
//   // User Actions
//   Future<void> toggleUserStatus(String userId) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final userIndex = _allUsers.indexWhere((user) => user.userId == userId);
//       if (userIndex != -1) {
//         _allUsers[userIndex] = _allUsers[userIndex].copyWith(
//           isActive: !_allUsers[userIndex].isActive,
//         );
//         _applyFiltersAndSort();
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> deleteUser(String userId) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _allUsers.removeWhere((user) => user.userId == userId);
//       _selectedUserIds.remove(userId);
//       _applyFiltersAndSort();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> deleteSelectedUsers() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _allUsers.removeWhere((user) => _selectedUserIds.contains(user.userId));
//       _selectedUserIds.clear();
//       _applyFiltersAndSort();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Private methods
//   void _applyFiltersAndSort() {
//     _filteredUsers = _allUsers.where((user) {
//       // Search filter
//       if (_searchQuery.isNotEmpty) {
//         final searchLower = _searchQuery.toLowerCase();
//         if (!user.username.toLowerCase().contains(searchLower) &&
//             !user.email.toLowerCase().contains(searchLower) &&
//             !user.userId.toLowerCase().contains(searchLower) &&
//             !(user.phoneNo?.toLowerCase().contains(searchLower) ?? false)) {
//           return false;
//         }
//       }
//
//       // Status filter
//       switch (_statusFilter) {
//         case FilterStatus.active:
//           if (!user.isActive) return false;
//           break;
//         case FilterStatus.inactive:
//           if (user.isActive) return false;
//           break;
//         case FilterStatus.verified:
//           if (!user.isVerified) return false;
//           break;
//         case FilterStatus.unverified:
//           if (user.isVerified) return false;
//           break;
//         case FilterStatus.all:
//           break;
//       }
//
//       // Role filter
//       switch (_roleFilter) {
//         case FilterRole.user:
//           if (user.role != 'user') return false;
//           break;
//         case FilterRole.admin:
//           if (user.role != 'admin') return false;
//           break;
//         case FilterRole.moderator:
//           if (user.role != 'moderator') return false;
//           break;
//         case FilterRole.all:
//           break;
//       }
//
//       return true;
//     }).toList();
//
//     _sortUsers();
//     _calculateTotalPages();
//   }
//
//   void _sortUsers() {
//     _filteredUsers.sort((a, b) {
//       int comparison = 0;
//
//       switch (_sortColumn) {
//         case SortColumn.userId:
//           comparison = a.userId.compareTo(b.userId);
//           break;
//         case SortColumn.username:
//           comparison = a.username.compareTo(b.username);
//           break;
//         case SortColumn.email:
//           comparison = a.email.compareTo(b.email);
//           break;
//         case SortColumn.phoneNo:
//           comparison = (a.phoneNo ?? '').compareTo(b.phoneNo ?? '');
//           break;
//         case SortColumn.role:
//           comparison = a.role.compareTo(b.role);
//           break;
//         case SortColumn.joinDate:
//           comparison = a.joinDate.compareTo(b.joinDate);
//           break;
//         case SortColumn.rewardPoint:
//           comparison = a.rewardPoint.compareTo(b.rewardPoint);
//           break;
//         case SortColumn.isActive:
//           comparison = a.isActive.toString().compareTo(b.isActive.toString());
//           break;
//         case SortColumn.isVerified:
//           comparison = a.isVerified.toString().compareTo(b.isVerified.toString());
//           break;
//       }
//
//       return _sortAscending ? comparison : -comparison;
//     });
//   }
//
//   void _calculateTotalPages() {
//     _totalPages = (_filteredUsers.length / _itemsPerPage).ceil();
//     if (_totalPages == 0) _totalPages = 1;
//
//     // Adjust current page if necessary
//     if (_currentPage > _totalPages) {
//       _currentPage = _totalPages;
//     }
//   }
//
//   List<UserModel> _getPagedUsers() {
//     final startIndex = (_currentPage - 1) * _itemsPerPage;
//     final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredUsers.length);
//
//     if (startIndex >= _filteredUsers.length) {
//       return [];
//     }
//
//     return _filteredUsers.sublist(startIndex, endIndex);
//   }
//
//   void _updateSelectAllState() {
//     final pagedUsers = _getPagedUsers();
//     _isSelectAll = pagedUsers.isNotEmpty &&
//         pagedUsers.every((user) => _selectedUserIds.contains(user.userId));
//   }
// }

// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fyp/features/admin/controllers/user_management_controller.dart';
// import 'package:fyp/features/authentication/models/user_model.dart';
// import 'package:get/get.dart';
//
//
// class UserManagementController extends GetxController {
//   // Firebase Functions instance
//   late final FirebaseFunctions _functions;
//
//   // Observable variables
//   final RxList<UserModel> allUsers = <UserModel>[].obs;
//   final RxList<UserModel> filteredUsers = <UserModel>[].obs;
//   final RxString searchQuery = ''.obs;
//   final Rx<SortBy> currentSort = SortBy.username.obs;
//   final RxBool sortAscending = true.obs;
//   final Rx<FilterBy> currentFilter = FilterBy.all.obs;
//   final RxBool isLoading = false.obs;
//   final RxInt currentPage = 1.obs;
//   final RxInt itemsPerPage = 10.obs;
//   final RxInt totalItems = 0.obs;
//
//   // Controllers
//   final TextEditingController searchController = TextEditingController();
//   final ScrollController tableScrollController = ScrollController();
//
//   // Current user info
//   final RxString currentUserRole = ''.obs;
//   final RxList<String> currentUserPages = <String>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _functions = FirebaseFunctions.instance;
//
//     // Get current user access info
//     _getCurrentUserAccess();
//
//     // Load initial data
//     loadUsers();
//
//     // Listen to search changes
//     searchQuery.listen((query) {
//       filterAndSortUsers();
//     });
//
//     // Listen to filter changes
//     currentFilter.listen((filter) {
//       filterAndSortUsers();
//     });
//   }
//
//   @override
//   void onClose() {
//     searchController.dispose();
//     tableScrollController.dispose();
//     super.onClose();
//   }
//
//   Future<void> _getCurrentUserAccess() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final result = await _functions
//             .httpsCallable('getUserAccessiblePages')
//             .call({'uid': user.uid});
//
//         currentUserRole.value = result.data['role'] ?? '';
//         currentUserPages.value = List<String>.from(result.data['accessiblePages'] ?? []);
//       }
//     } catch (e) {
//       print('Error getting current user access: $e');
//     }
//   }
//
//   // Check if current user can access a specific page
//   bool canAccessPage(String page) {
//     return currentUserPages.contains(page);
//   }
//
//   // Load users from cloud functions
//   Future<void> loadUsers() async {
//     isLoading.value = true;
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception('User not authenticated');
//       }
//
//       // Check if user has permission to view users
//       if (!canAccessPage('user_management') && !canAccessPage('manager_management')) {
//         throw Exception('No permission to view users');
//       }
//
//       final result = await _functions
//           .httpsCallable('getUsersByRole')
//           .call({'uid': user.uid});
//
//       final users = (result.data['users'] as List)
//           .map((userData) => UserModel.fromJson(userData))
//           .toList();
//
//       allUsers.value = users;
//       filterAndSortUsers();
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load users: ${e.toString()}',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Load users by specific role
//   Future<void> loadUsersByRole(String role) async {
//     isLoading.value = true;
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;
//
//       final result = await _functions
//           .httpsCallable('getUsersByRole')
//           .call({'uid': user.uid, 'targetRole': role});
//
//       final users = (result.data['users'] as List)
//           .map((userData) => UserModel.fromJson(userData))
//           .toList();
//
//       allUsers.value = users;
//       filterAndSortUsers();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to load users: ${e.toString()}');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Assign role to user
//   Future<void> assignRole(String targetUserId, String newRole, {String? recyclingCenterId}) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;
//
//       await _functions.httpsCallable('assignRole').call({
//         'uid': user.uid,
//         'targetUserId': targetUserId,
//         'newRole': newRole,
//         if (recyclingCenterId != null) 'recyclingCenterId': recyclingCenterId,
//       });
//
//       Get.snackbar(
//         'Success',
//         'Role assigned successfully',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//
//       // Reload users
//       loadUsers();
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to assign role: ${e.toString()}');
//     }
//   }
//
//   // Toggle user status (active/inactive)
//   Future<void> toggleUserStatus(UserModel userModel) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;
//
//       await _functions.httpsCallable('toggleUserStatus').call({
//         'uid': user.uid,
//         'targetUserId': userModel.userId,
//         'isActive': !userModel.isActive,
//       });
//
//       Get.snackbar(
//         'Success',
//         userModel.isActive ? 'User deactivated' : 'User activated',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//
//       // Update local data
//       final index = allUsers.indexWhere((u) => u.userId == userModel.userId);
//       if (index != -1) {
//         allUsers[index] = UserModel.fromUserModel(
//           allUsers[index],
//           accessiblePages: allUsers[index].accessiblePages,
//           recyclingCenterId: allUsers[index].recyclingCenterId,
//           createdAt: allUsers[index].createdAt,
//           updatedAt: DateTime.now(),
//         );
//         allUsers[index] = UserModel(
//           userId: allUsers[index].userId,
//           username: allUsers[index].username,
//           email: allUsers[index].email,
//           phoneNo: allUsers[index].phoneNo,
//           profileImage: allUsers[index].profileImage,
//           password: allUsers[index].password,
//           loginAttemptCount: allUsers[index].loginAttemptCount,
//           lastFailedLogin: allUsers[index].lastFailedLogin,
//           role: allUsers[index].role,
//           isVerified: allUsers[index].isVerified,
//           isActive: !userModel.isActive,
//           accessiblePages: allUsers[index].accessiblePages,
//           recyclingCenterId: allUsers[index].recyclingCenterId,
//           createdAt: allUsers[index].createdAt,
//           updatedAt: DateTime.now(),
//         );
//         filterAndSortUsers();
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to update user status: ${e.toString()}');
//     }
//   }
//
//   // Search functionality
//   void onSearchChanged(String value) {
//     searchQuery.value = value;
//   }
//
//   void clearSearch() {
//     searchController.clear();
//     searchQuery.value = '';
//   }
//
//   // Filter functionality
//   void setFilter(FilterBy filter) {
//     currentFilter.value = filter;
//     currentPage.value = 1; // Reset to first page
//   }
//
//   // Sort functionality
//   void sortBy(SortBy sortBy) {
//     if (currentSort.value == sortBy) {
//       sortAscending.value = !sortAscending.value;
//     } else {
//       currentSort.value = sortBy;
//       sortAscending.value = true;
//     }
//     filterAndSortUsers();
//   }
//
//   // Filter and sort users
//   void filterAndSortUsers() {
//     List<UserModel> filtered = allUsers.where((user) {
//       // Search filter
//       bool matchesSearch = searchQuery.value.isEmpty ||
//           user.username.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
//           user.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
//           user.role.toLowerCase().contains(searchQuery.value.toLowerCase());
//
//       if (!matchesSearch) return false;
//
//       // Status filter
//       switch (currentFilter.value) {
//         case FilterBy.active:
//           return user.isActive;
//         case FilterBy.inactive:
//           return !user.isActive;
//         case FilterBy.verified:
//           return user.isVerified;
//         case FilterBy.unverified:
//           return !user.isVerified;
//         case FilterBy.user:
//           return user.role == 'user';
//         case FilterBy.communityManager:
//           return user.role == 'community_manager';
//         case FilterBy.eventManager:
//           return user.role == 'event_manager';
//         case FilterBy.rewardManager:
//           return user.role == 'reward_manager';
//         case FilterBy.admin:
//           return user.role == 'admin';
//         case FilterBy.recyclingCenterStaff:
//           return user.role == 'recycling_center_staff';
//         case FilterBy.all:
//         default:
//           return true;
//       }
//     }).toList();
//
//     // Sort
//     filtered.sort((a, b) {
//       int comparison = 0;
//       switch (currentSort.value) {
//         case SortBy.username:
//           comparison = a.username.compareTo(b.username);
//           break;
//         case SortBy.email:
//           comparison = a.email.compareTo(b.email);
//           break;
//         case SortBy.role:
//           comparison = a.role.compareTo(b.role);
//           break;
//         case SortBy.isActive:
//           comparison = a.isActive.toString().compareTo(b.isActive.toString());
//           break;
//         case SortBy.isVerified:
//           comparison = a.isVerified.toString().compareTo(b.isVerified.toString());
//           break;
//       }
//       return sortAscending.value ? comparison : -comparison;
//     });
//
//     totalItems.value = filtered.length;
//     filteredUsers.value = filtered;
//   }
//
//   // Pagination
//   List<UserModel> get paginatedUsers {
//     final startIndex = (currentPage.value - 1) * itemsPerPage.value;
//     final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredUsers.length);
//
//     if (startIndex >= filteredUsers.length) return [];
//
//     return filteredUsers.sublist(startIndex, endIndex);
//   }
//
//   int get totalPages => (totalItems.value / itemsPerPage.value).ceil();
//
//   void nextPage() {
//     if (currentPage.value < totalPages) {
//       currentPage.value++;
//     }
//   }
//
//   void previousPage() {
//     if (currentPage.value > 1) {
//       currentPage.value--;
//     }
//   }
//
//   void goToPage(int page) {
//     if (page >= 1 && page <= totalPages) {
//       currentPage.value = page;
//     }
//   }
//
//   // User actions
//   void viewUser(UserModel user) {
//     Get.toNamed('/admin/user-detail', arguments: user);
//   }
//
//   void editUser(UserModel user) {
//     // Show role assignment dialog
//     _showRoleAssignmentDialog(user);
//   }
//
//   void _showRoleAssignmentDialog(UserModel user) {
//     final roles = [
//       'user',
//       'community_manager',
//       'event_manager',
//       'reward_manager',
//       'admin',
//       'recycling_center_staff'
//     ];
//
//     String selectedRole = user.role;
//     final recyclingCenterController = TextEditingController(
//         text: user.recyclingCenterId ?? ''
//     );
//
//     Get.dialog(
//       AlertDialog(
//         title: Text('Assign Role to ${user.username}'),
//         content: StatefulBuilder(
//           builder: (context, setState) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 DropdownButtonFormField<String>(
//                   value: selectedRole,
//                   decoration: const InputDecoration(
//                     labelText: 'Role',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: roles.map((role) {
//                     return DropdownMenuItem<String>(
//                       value: role,
//                       child: Text(_getRoleDisplayName(role)),
//                     );
//                   }).toList(),
//                   onChanged: (String? value) {
//                     if (value != null) {
//                       setState(() {
//                         selectedRole = value;
//                       });
//                     }
//                   },
//                 ),
//                 if (selectedRole == 'recycling_center_staff') ...[
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: recyclingCenterController,
//                     decoration: const InputDecoration(
//                       labelText: 'Recycling Center ID',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//               ],
//             );
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               assignRole(
//                 user.userId,
//                 selectedRole,
//                 recyclingCenterId: selectedRole == 'recycling_center_staff'
//                     ? recyclingCenterController.text.trim()
//                     : null,
//               );
//               Get.back();
//             },
//             child: const Text('Assign'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getRoleDisplayName(String role) {
//     switch (role) {
//       case 'user': return 'User';
//       case 'community_manager': return 'Community Manager';
//       case 'event_manager': return 'Event Manager';
//       case 'reward_manager': return 'Reward Manager';
//       case 'admin': return '';
//       case 'recycling_center_staff': return 'Recycling Center Staff';
//       default: return role;
//     }
//   }
//
//   // Refresh data
//   void refreshUsers() {
//     loadUsers();
//   }
// }