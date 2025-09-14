import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../reward_redemption/models/reward_model.dart';
import '../../screens/reward_management/reward_management.dart';

class RewardManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<RewardModel> allRewards = <RewardModel>[].obs;
  final RxList<RewardModel> filteredRewards = <RewardModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'status': null,
    'availabilityStatus': null,
    'pointsRange': null,
    'quantityRange': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadRewards();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(), time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
  }

  void loadRewards() {
    // Mock data - replace with actual API call
    allRewards.value = _generateMockRewards();
    filteredRewards.value = List.from(allRewards);
  }

  List<RewardModel> _generateMockRewards() {
    final now = DateTime.now();
    return [
      RewardModel(
        rewardId: '1',
        title: 'Eco-Friendly Water Bottle',
        description: 'Reusable stainless steel water bottle with eco-friendly design.',
        termsConditions: 'Valid for 30 days after redemption. Cannot be exchanged for cash.',
        rewardImage: 'https://example.com/water-bottle.jpg',
        pointsNeeded: 500,
        quantity: 100,
        validUntil: now.add(const Duration(days: 90)),
        redemptionCount: 25,
        createdAt: now.subtract(const Duration(days: 30)),
        status: 'active',
      ),
      RewardModel(
        rewardId: '2',
        title: 'Organic Cotton Tote Bag',
        description: 'Stylish tote bag made from 100% organic cotton.',
        termsConditions: 'Available in multiple colors. Subject to availability.',
        rewardImage: 'https://example.com/tote-bag.jpg',
        pointsNeeded: 300,
        quantity: 50,
        validUntil: now.add(const Duration(days: 60)),
        redemptionCount: 45,
        createdAt: now.subtract(const Duration(days: 45)),
        status: 'active',
      ),
      RewardModel(
        rewardId: '3',
        title: 'Solar Power Bank',
        description: 'Portable solar-powered charging device for mobile devices.',
        termsConditions: 'One year warranty included. Replacement parts not covered.',
        rewardImage: 'https://example.com/solar-powerbank.jpg',
        pointsNeeded: 1200,
        quantity: 25,
        validUntil: now.add(const Duration(days: 120)),
        redemptionCount: 8,
        createdAt: now.subtract(const Duration(days: 15)),
        status: 'active',
      ),
      RewardModel(
        rewardId: '4',
        title: 'Bamboo Kitchen Set',
        description: 'Complete kitchen utensil set made from sustainable bamboo.',
        termsConditions: 'Hand wash only. Not suitable for dishwasher.',
        rewardImage: 'https://example.com/bamboo-kitchen.jpg',
        pointsNeeded: 800,
        quantity: 0,
        validUntil: now.add(const Duration(days: 45)),
        redemptionCount: 30,
        createdAt: now.subtract(const Duration(days: 60)),
        status: 'active',
      ),
      RewardModel(
        rewardId: '5',
        title: 'Expired Gift Card',
        description: 'Digital gift card for eco-friendly products.',
        termsConditions: 'Valid for online purchases only. Cannot be combined with other offers.',
        rewardImage: 'https://example.com/gift-card.jpg',
        pointsNeeded: 1000,
        quantity: 200,
        validUntil: now.subtract(const Duration(days: 10)),
        redemptionCount: 5,
        createdAt: now.subtract(const Duration(days: 120)),
        status: 'active',
      ),
      RewardModel(
        rewardId: '6',
        title: 'Inactive Recycling Kit',
        description: 'Complete home recycling starter kit with bins and guides.',
        termsConditions: 'Assembly required. Instructions included.',
        rewardImage: 'https://example.com/recycling-kit.jpg',
        pointsNeeded: 1500,
        quantity: 15,
        validUntil: now.add(const Duration(days: 180)),
        redemptionCount: 2,
        createdAt: now.subtract(const Duration(days: 90)),
        status: 'inactive',
      ),
    ];
  }

  // Get computed reward status based on conditions
  String getRewardComputedStatus(RewardModel reward) {
    if (reward.status == 'inactive') {
      return 'inactive';
    }

    if (reward.isExpired) {
      return 'expired';
    }

    if (reward.remainingQuantity <= 0) {
      return 'out_of_stock';
    }

    return 'active';
  }

  // Get availability status for filtering
  String getAvailabilityStatus(RewardModel reward) {
    if (!reward.isAvailable) {
      if (reward.isExpired) return 'expired';
      if (reward.remainingQuantity <= 0) return 'out_of_stock';
      if (reward.status == 'inactive') return 'inactive';
    }
    return 'available';
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<RewardModel> result = List.from(allRewards);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((reward) {
        return reward.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            reward.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            reward.pointsNeeded.toString().contains(searchQuery.value);
      }).toList();
    }

    // Apply filters
    if (activeFilters['status'] != null) {
      result = result.where((reward) => reward.status == activeFilters['status']).toList();
    }

    if (activeFilters['availabilityStatus'] != null) {
      result = result.where((reward) => getAvailabilityStatus(reward) == activeFilters['availabilityStatus']).toList();
    }

    if (activeFilters['pointsRange'] != null) {
      result = result.where((reward) {
        switch (activeFilters['pointsRange']) {
          case 'low':
            return reward.pointsNeeded <= 500;
          case 'medium':
            return reward.pointsNeeded > 500 && reward.pointsNeeded <= 1000;
          case 'high':
            return reward.pointsNeeded > 1000;
          default:
            return true;
        }
      }).toList();
    }

    if (activeFilters['quantityRange'] != null) {
      result = result.where((reward) {
        switch (activeFilters['quantityRange']) {
          case 'low':
            return reward.remainingQuantity <= 10 && reward.remainingQuantity > 0;
          case 'medium':
            return reward.remainingQuantity > 10 && reward.remainingQuantity <= 50;
          case 'high':
            return reward.remainingQuantity > 50;
          case 'out_of_stock':
            return reward.remainingQuantity == 0;
          default:
            return true;
        }
      }).toList();
    }

    filteredRewards.value = result;
    currentPage.value = 1; // Reset to first page after filtering
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['status'] != null ||
        activeFilters['availabilityStatus'] != null ||
        activeFilters['pointsRange'] != null ||
        activeFilters['quantityRange'] != null;
  }

  // Sorting functionality
  void sortRewards(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredRewards.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Title
          aValue = a.title;
          bValue = b.title;
          break;
        case 1: // Points Needed
          aValue = a.pointsNeeded;
          bValue = b.pointsNeeded;
          break;
        case 2: // Total Quantity
          aValue = a.quantity;
          bValue = b.quantity;
          break;
        case 3: // Remaining Quantity
          aValue = a.remainingQuantity;
          bValue = b.remainingQuantity;
          break;
        case 4: // Redemption Count
          aValue = a.redemptionCount;
          bValue = b.redemptionCount;
          break;
        case 5: // Valid Until
          aValue = a.validUntil;
          bValue = b.validUntil;
          break;
        case 6: // Created At
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 7: // Status
          aValue = getRewardComputedStatus(a);
          bValue = getRewardComputedStatus(b);
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

  // Reward actions
  void toggleRewardStatus(RewardModel reward) {
    if (reward.status == 'active') {
      _deactivateReward(reward);
    } else {
      _activateReward(reward);
    }
  }

  void _activateReward(RewardModel reward) {
    // Check if reward can be activated
    final now = DateTime.now();

    if (reward.quantity <= 0) {
      FHelperFunctions.showAlert('Cannot Activate Reward',
          'Reward cannot be activated because quantity is 0. Please update the quantity first.');
      return;
    }

    if (reward.validUntil.isBefore(now)) {
      FHelperFunctions.showAlert('Cannot Activate Reward',
          'Reward cannot be activated because the valid until date has passed. Please update the expiry date first.');
      return;
    }

    final rewardIndex = allRewards.indexWhere((r) => r.rewardId == reward.rewardId);
    if (rewardIndex != -1) {
      allRewards[rewardIndex] = reward.copyWith(status: 'active');
      applyFiltersAndSearch();
      FHelperFunctions.showSnackBar('Reward activated successfully');
    }
  }

  void _deactivateReward(RewardModel reward) {
    final rewardIndex = allRewards.indexWhere((r) => r.rewardId == reward.rewardId);
    if (rewardIndex != -1) {
      allRewards[rewardIndex] = reward.copyWith(status: 'inactive');
      applyFiltersAndSearch();
      FHelperFunctions.showSnackBar('Reward deactivated successfully');
    }
  }

  void deleteReward(RewardModel reward) {
    allRewards.removeWhere((r) => r.rewardId == reward.rewardId);
    applyFiltersAndSearch();
    FHelperFunctions.showSnackBar('Reward deleted successfully');
  }

  void addReward() {
    // Navigate to add reward screen
    print('Navigate to add reward screen');
  }

  void viewReward(RewardModel reward) {
    // Navigate to view reward screen
    print('View reward: ${reward.title}');
  }

  void editReward(RewardModel reward) {
    // Navigate to edit reward screen
    print('Edit reward: ${reward.title}');
  }

  // Pagination functionality
  List<RewardModel> get paginatedRewards {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredRewards.length);

    if (startIndex >= filteredRewards.length) {
      return [];
    }

    return filteredRewards.sublist(startIndex, endIndex);
  }

  int get totalRewards => filteredRewards.length;
  int get totalPages => (totalRewards / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalRewards);

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
      RewardFilterDialog(
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