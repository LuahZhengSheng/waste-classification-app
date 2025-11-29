import 'package:flutter/material.dart';

/// Reward Transaction Type Enum
enum TransactionType {
  earning,
  spending;

  String get displayName {
    switch (this) {
      case TransactionType.earning:
        return 'Earning';
      case TransactionType.spending:
        return 'Spending';
    }
  }
}

/// Date Filter Type Enum
enum DateFilterType {
  today,
  yesterday,
  last7Days,
  last30Days,
  custom;

  String get displayName {
    switch (this) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.yesterday:
        return 'Yesterday';
      case DateFilterType.last7Days:
        return 'Last 7 Days';
      case DateFilterType.last30Days:
        return 'Last 30 Days';
      case DateFilterType.custom:
        return 'Custom Range';
    }
  }

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateFilterType.today:
        return DateTimeRange(
          start: today,
          end: now,
        );
      case DateFilterType.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: yesterday,
          end: today,
        );
      case DateFilterType.last7Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: now,
        );
      case DateFilterType.last30Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        );
      case DateFilterType.custom:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        );
    }
  }
}

/// Reward sorting options
enum RewardSortOption {
  highestToLowest,
  lowestToHighest;

  String get displayName {
    switch (this) {
      case RewardSortOption.highestToLowest:
        return 'Highest Points to Lowest';
      case RewardSortOption.lowestToHighest:
        return 'Lowest Points to Highest';
    }
  }

  String get shortName {
    switch (this) {
      case RewardSortOption.highestToLowest:
        return 'Highest First';
      case RewardSortOption.lowestToHighest:
        return 'Lowest First';
    }
  }
}

/// Reward status enum
enum RewardStatus {
  active,
  inactive,
  expired,
  outOfStock;

  String get displayName {
    switch (this) {
      case RewardStatus.active:
        return 'Active';
      case RewardStatus.inactive:
        return 'Inactive';
      case RewardStatus.expired:
        return 'Expired';
      case RewardStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  static RewardStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return RewardStatus.active;
      case 'inactive':
        return RewardStatus.inactive;
      case 'expired':
        return RewardStatus.expired;
      case 'out_of_stock':
      case 'outofstock':
        return RewardStatus.outOfStock;
      default:
        return RewardStatus.inactive;
    }
  }
}

/// Redemption status enum
enum RedemptionStatus {
  active,
  expired;

  String get displayName {
    switch (this) {
      case RedemptionStatus.active:
        return 'Active';
      case RedemptionStatus.expired:
        return 'Expired';
    }
  }

  static RedemptionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return RedemptionStatus.active;
      case 'expired':
        return RedemptionStatus.expired;
      default:
        return RedemptionStatus.expired;
    }
  }
}