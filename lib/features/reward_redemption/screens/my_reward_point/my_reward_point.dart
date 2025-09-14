import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/reward_point_controller.dart';
import '../transaction_detail/transaction_detail.dart';

class MyRewardPointsScreen extends StatelessWidget {
  const MyRewardPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardPointsController());
    final isDark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Reward Points'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1A1F36), const Color(0xFF0A0E21)]
                  : [FColors.primary.withOpacity(0.1), Colors.white.withOpacity(0.8)],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: FSizes.md),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: FColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => controller.showCustomDateRangePicker(context),
              icon: Icon(
                Iconsax.calendar,
                color: FColors.primary,
                size: FSizes.iconMd,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: FColors.primary,
        backgroundColor: isDark ? const Color(0xFF1A1F36) : Colors.white,
        child: Column(
          children: [
            // Points Summary Card with Glass Effect
            _buildPointsSummaryCard(controller, isDark),

            // Date Filter Info with Modern Design
            _buildDateFilterInfo(controller, isDark),

            // Modern Tab Bar
            _buildModernTabBar(controller, isDark),

            // Tab Bar View
            Expanded(
              child: _buildTabBarView(controller, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsSummaryCard(RewardPointsController controller, bool isDark) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(FSizes.defaultSpace),
      padding: const EdgeInsets.all(FSizes.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
            const Color(0xFF667EEA).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.award5,
                      color: FColors.white,
                      size: FSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      color: FColors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.lg),
              // Points with animated counter effect
              Text(
                '${controller.currentPoints.value}',
                style: const TextStyle(
                  color: FColors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                'Points',
                style: TextStyle(
                  color: FColors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildDateFilterInfo(RewardPointsController controller, bool isDark) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F36).withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FColors.primary.withOpacity(0.2),
                  FColors.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.calendar_1,
              size: FSizes.iconSm,
              color: FColors.primary,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Text(
              '${FFormatter.formatDate(controller.selectedDateRange.value.start)} - ${FFormatter.formatDate(controller.selectedDateRange.value.end)}',
              style: TextStyle(
                color: isDark ? FColors.white : const Color(0xFF2D3748),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildStatChip(
            '+${controller.totalEarningPoints}',
            'Earned',
            FColors.success,
            isDark,
          ),
          const SizedBox(width: FSizes.sm),
          _buildStatChip(
            '-${controller.totalSpendingPoints}',
            'Spent',
            FColors.error,
            isDark,
          ),
        ],
      ),
    ));
  }

  Widget _buildStatChip(String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDark ? FColors.white.withOpacity(0.7) : const Color(0xFF718096),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar(RewardPointsController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(FSizes.defaultSpace),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F36).withOpacity(0.6)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller.tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [FColors.primary, FColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: FColors.white,
        unselectedLabelColor: isDark
            ? FColors.white.withOpacity(0.6)
            : const Color(0xFF718096),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Earning'),
          Tab(text: 'Spending'),
        ],
      ),
    );
  }

  Widget _buildTabBarView(RewardPointsController controller, bool isDark) {
    return TabBarView(
      controller: controller.tabController,
      children: [
        _buildTransactionsList(controller.filteredAllTransactions, controller, isDark),
        _buildTransactionsList(controller.filteredEarningTransactions, controller, isDark),
        _buildTransactionsList(controller.filteredSpendingTransactions, controller, isDark),
      ],
    );
  }

  Widget _buildTransactionsList(
      RxList<RewardTransaction> transactions,
      RewardPointsController controller,
      bool isDark,
      ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingSkeleton(isDark);
      }

      if (transactions.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildModernTransactionCard(transaction, controller, isDark, index);
        },
      );
    });
  }

  Widget _buildModernTransactionCard(
      RewardTransaction transaction,
      RewardPointsController controller,
      bool isDark,
      int index,
      ) {
    final isEarning = transaction.isEarning;
    final pointsColor = isEarning ? FColors.success : FColors.error;
    final pointsPrefix = isEarning ? '+' : '';

    return Container(
      margin: EdgeInsets.only(
        bottom: FSizes.md,
        top: index == 0 ? FSizes.sm : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => TransactionDetailsScreen(transaction: transaction)),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1F36).withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Modern Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        pointsColor.withOpacity(0.2),
                        pointsColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: pointsColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isEarning ? Iconsax.arrow_up_3 : Iconsax.arrow_down_1,
                    color: pointsColor,
                    size: FSizes.iconMd,
                  ),
                ),

                const SizedBox(width: FSizes.lg),

                // Transaction Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? FColors.white : const Color(0xFF2D3748),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              FFormatter.formatDate(transaction.date),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? FColors.white.withOpacity(0.7)
                                    : const Color(0xFF718096),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (transaction.wasteType != null) ...[
                        const SizedBox(height: FSizes.xs),
                        Row(
                          children: [
                            Icon(
                              Iconsax.weight,
                              size: 12,
                              color: isDark
                                  ? FColors.white.withOpacity(0.5)
                                  : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: FSizes.xs),
                            Text(
                              '${transaction.weight?.toStringAsFixed(1)} kg • ${transaction.wasteType}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? FColors.white.withOpacity(0.6)
                                    : const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Points Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        pointsColor.withOpacity(0.1),
                        pointsColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$pointsPrefix${transaction.points}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: pointsColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? FColors.white.withOpacity(0.6)
                              : const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: FSizes.md),
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                const Color(0xFF1A1F36).withOpacity(0.3),
                const Color(0xFF1A1F36).withOpacity(0.1),
              ]
                  : [
                Colors.grey.withOpacity(0.1),
                Colors.grey.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  isDark
                      ? Colors.white.withOpacity(0.02)
                      : Colors.white.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FColors.primary.withOpacity(0.1),
                  FColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Iconsax.empty_wallet,
              size: 48,
              color: FColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: FSizes.xl),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? FColors.white : const Color(0xFF2D3748),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? FColors.white.withOpacity(0.6)
                  : const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}