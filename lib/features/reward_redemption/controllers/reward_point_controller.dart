import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RewardPointsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab Controller
  late TabController tabController;

  // Observable variables
  final currentPoints = 0.obs;
  final isLoading = false.obs;
  final selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  ).obs;

  // Transaction lists
  final allTransactions = <RewardTransaction>[].obs;
  final earningTransactions = <RewardTransaction>[].obs;
  final spendingTransactions = <RewardTransaction>[].obs;

  // Filtered transactions
  final filteredAllTransactions = <RewardTransaction>[].obs;
  final filteredEarningTransactions = <RewardTransaction>[].obs;
  final filteredSpendingTransactions = <RewardTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    loadRewardPointsData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Load all reward points data
  Future<void> loadRewardPointsData() async {
    try {
      isLoading(true);

      // Load current points
      await loadCurrentPoints();

      // Load transactions
      await loadTransactions();

      // Apply initial filter
      applyDateFilter();

    } catch (e) {
      Get.snackbar('Error', 'Failed to load reward points data: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Load current user's points
  Future<void> loadCurrentPoints() async {
    // TODO: Implement actual API call to get current user's points
    // For now, using mock data
    await Future.delayed(const Duration(milliseconds: 500));
    currentPoints.value = 1250; // Mock current points
  }

  /// Load all transactions
  Future<void> loadTransactions() async {
    // TODO: Implement actual API calls to load transactions
    // For now, using mock data
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock earning transactions from recycling activities
    final mockEarnings = [
      RewardTransaction(
        id: '1',
        type: TransactionType.earning,
        points: 50,
        description: 'Plastic Bottles Recycling',
        date: DateTime.now().subtract(const Duration(days: 1)),
        relatedActivityId: 'activity_1',
        weight: 2.5,
        wasteType: 'Plastic',
      ),
      RewardTransaction(
        id: '2',
        type: TransactionType.earning,
        points: 75,
        description: 'Electronics Recycling',
        date: DateTime.now().subtract(const Duration(days: 3)),
        relatedActivityId: 'activity_2',
        weight: 1.2,
        wasteType: 'Electronics',
      ),
      RewardTransaction(
        id: '3',
        type: TransactionType.earning,
        points: 30,
        description: 'Paper Recycling',
        date: DateTime.now().subtract(const Duration(days: 5)),
        relatedActivityId: 'activity_3',
        weight: 3.0,
        wasteType: 'Paper',
      ),
    ];

    // Mock spending transactions from redemptions
    final mockSpendings = [
      RewardTransaction(
        id: '4',
        type: TransactionType.spending,
        points: -100,
        description: 'Starbucks Voucher',
        date: DateTime.now().subtract(const Duration(days: 2)),
        relatedRedemptionId: 'redemption_1',
        pinCode: '123456',
      ),
      RewardTransaction(
        id: '5',
        type: TransactionType.spending,
        points: -200,
        description: 'Eco-Friendly Tote Bag',
        date: DateTime.now().subtract(const Duration(days: 7)),
        relatedRedemptionId: 'redemption_2',
        pinCode: '789012',
      ),
    ];

    // Combine all transactions
    allTransactions.assignAll([...mockEarnings, ...mockSpendings]);
    earningTransactions.assignAll(mockEarnings);
    spendingTransactions.assignAll(mockSpendings);

    // Sort by date (newest first)
    allTransactions.sort((a, b) => b.date.compareTo(a.date));
    earningTransactions.sort((a, b) => b.date.compareTo(a.date));
    spendingTransactions.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Apply date filter to transactions
  void applyDateFilter() {
    final startDate = selectedDateRange.value.start;
    final endDate = selectedDateRange.value.end.add(const Duration(days: 1)); // Include end date

    filteredAllTransactions.assignAll(
      allTransactions.where((transaction) =>
      transaction.date.isAfter(startDate) && transaction.date.isBefore(endDate)
      ).toList(),
    );

    filteredEarningTransactions.assignAll(
      earningTransactions.where((transaction) =>
      transaction.date.isAfter(startDate) && transaction.date.isBefore(endDate)
      ).toList(),
    );

    filteredSpendingTransactions.assignAll(
      spendingTransactions.where((transaction) =>
      transaction.date.isAfter(startDate) && transaction.date.isBefore(endDate)
      ).toList(),
    );
  }

  /// Show date range picker
  Future<void> showCustomDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange.value,
    );

    if (picked != null && picked != selectedDateRange.value) {
      selectedDateRange.value = picked;
      applyDateFilter();
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadRewardPointsData();
  }

  /// Get total earning points in selected date range
  int get totalEarningPoints {
    return filteredEarningTransactions.fold(0, (sum, transaction) => sum + transaction.points);
  }

  /// Get total spending points in selected date range
  int get totalSpendingPoints {
    return filteredSpendingTransactions.fold(0, (sum, transaction) => sum + transaction.points.abs());
  }

  /// Get transactions for current tab
  List<RewardTransaction> get currentTabTransactions {
    switch (tabController.index) {
      case 0:
        return filteredAllTransactions;
      case 1:
        return filteredEarningTransactions;
      case 2:
        return filteredSpendingTransactions;
      default:
        return filteredAllTransactions;
    }
  }
}

/// Reward Transaction Model
class RewardTransaction {
  final String id;
  final TransactionType type;
  final int points;
  final String description;
  final DateTime date;
  final String? relatedActivityId;
  final String? relatedRedemptionId;
  final double? weight;
  final String? wasteType;
  final String? pinCode;

  RewardTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.date,
    this.relatedActivityId,
    this.relatedRedemptionId,
    this.weight,
    this.wasteType,
    this.pinCode,
  });

  bool get isEarning => type == TransactionType.earning;
  bool get isSpending => type == TransactionType.spending;
}

enum TransactionType { earning, spending }