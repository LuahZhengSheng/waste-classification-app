import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/features/waste_classification/models/waste_category_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

import '../../../../common/widgets/time_filter/time_filter.dart';
import '../../../community/screens/create_post/widgets/media_lightbox.dart';
import '../../controllers/staff_recycle_activity_controller.dart';
import 'staff_activity_detail.dart';

class StaffRecycleHistoryScreen extends StatelessWidget {
  const StaffRecycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StaffRecycleActivityController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('My Processing History'),
        centerTitle: true,
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.activities.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: FColors.staffLightPrimary),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshActivities,
          color: FColors.staffLightPrimary,
          child: CustomScrollView(
            slivers: [
              // Interactive Donut Chart Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(FSizes.defaultSpace),
                  child: _buildInteractiveChart(controller, dark),
                ),
              ),

              // Statistics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.defaultSpace),
                  child: _buildStatisticsSection(controller, dark),
                ),
              ),

              // Filter Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(FSizes.defaultSpace),
                  child: _buildFilterSection(controller, dark, context),
                ),
              ),

              // Activities List - Grouped by Date OR Empty State
              controller.filteredActivities.isEmpty
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: _buildEmptyState(dark),
                      ),
                    )
                  : _buildGroupedActivitiesList(controller, dark, context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInteractiveChart(
      StaffRecycleActivityController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FColors.staffLightPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.chart_21,
                  color: dark
                      ? FColors.staffDarkPrimary
                      : FColors.staffLightPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Category Distribution',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          SizedBox(
            height: 220,
            child: Obx(() {
              final categories = controller.getCategoryDistribution();
              if (categories.isEmpty) {
                return Center(
                  child: Text(
                    'No data available',
                    style:
                        Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                              color: dark ? FColors.darkGrey : FColors.grey,
                            ),
                  ),
                );
              }

              return GestureDetector(
                onTapDown: (details) {
                  _handleChartTap(details, controller, categories);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: DonutChartPainter(
                        categories: categories,
                        selectedCategory:
                            controller.selectedCategoryForChart.value,
                        controller: controller,
                        dark: dark,
                      ),
                    ),
                    Obx(() => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.selectedCategoryForChart.value != null
                                  ? '${controller.getCategoryPercentage(controller.selectedCategoryForChart.value!).toStringAsFixed(1)}%'
                                  : 'Tap\nCategory',
                              style: Theme.of(Get.context!)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: controller.selectedCategoryForChart
                                            .value?.color ??
                                        (dark
                                            ? FColors.staffDarkPrimary
                                            : FColors.staffLightPrimary),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            if (controller.selectedCategoryForChart.value !=
                                null)
                              Text(
                                controller.selectedCategoryForChart.value!.name,
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: dark
                                          ? FColors.darkGrey
                                          : FColors.grey,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        )),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Obx(() {
            final categories = controller.getCategoryDistribution();
            if (categories.isEmpty) return const SizedBox.shrink();

            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected =
                    controller.selectedCategoryForChart.value == category;
                return GestureDetector(
                  onTap: () => controller.selectCategoryForChart(category),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withOpacity(0.15)
                          : (dark
                              ? FColors.darkContainer
                              : FColors.lightContainer),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? category.color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.name,
                          style: Theme.of(Get.context!)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected ? category.color : null,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  void _handleChartTap(
      TapDownDetails details,
      StaffRecycleActivityController controller,
      List<WasteCategory> categories,
      ) {
    final center = const Offset(100, 100);
    final tapPosition = details.localPosition - const Offset(10, 30);
    final distance = (tapPosition - center).distance;

    if (distance >= 60 && distance <= 100) {
      final angle = math.atan2(tapPosition.dy - center.dy, tapPosition.dx - center.dx);
      final normalizedAngle = (angle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);

      final totalWeight = controller.activities
          .fold<double>(0, (sum, activity) => sum + activity.weight);

      if (totalWeight == 0) return;

      // ✅ 计算最小角度阈值（例如 5 度）
      const minClickableAngle = 5 * math.pi / 180; // 5度的弧度

      double currentAngle = 0;
      WasteCategory? bestMatch;
      double closestDistance = double.infinity;

      for (final category in categories) {
        final categoryWeight = controller.getCategoryWeight(category);
        final sweepAngle = (categoryWeight / totalWeight) * 2 * math.pi;

        // ✅ 扩展小 segment 的点击范围
        final expandedSweepAngle = sweepAngle < minClickableAngle
            ? minClickableAngle
            : sweepAngle;

        final midAngle = currentAngle + sweepAngle / 2;
        final angleDiff = (normalizedAngle - midAngle).abs();

        // ✅ 检查是否在扩展后的范围内
        if (normalizedAngle >= currentAngle &&
            normalizedAngle < currentAngle + expandedSweepAngle) {
          // ✅ 优先选择角度差最小的
          if (angleDiff < closestDistance) {
            closestDistance = angleDiff;
            bestMatch = category;
          }
        }

        currentAngle += sweepAngle;
      }

      if (bestMatch != null) {
        controller.selectCategoryForChart(bestMatch);
      }
    }
  }

  Widget _buildStatisticsSection(
      StaffRecycleActivityController controller, bool dark) {
    return Obx(() {
      final isFiltered = controller.selectedCategoryForChart.value != null;
      return Container(
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Iconsax.chart_success,
                          color: FColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isFiltered
                              ? '${controller.selectedCategoryForChart.value!.name} Stats'
                              : 'Total Statistics',
                          style: Theme.of(Get.context!)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFiltered)
                  IconButton(
                    onPressed: () => controller.clearCategoryFilter(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: FColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Iconsax.close_circle,
                        size: 16,
                        color: FColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Points',
                    isFiltered
                        ? controller
                            .getCategoryPoints(
                                controller.selectedCategoryForChart.value!)
                            .toString()
                        : controller.totalPointsProcessed.toString(),
                    Iconsax.medal_star5,
                    FColors.warning,
                    dark,
                  ),
                ),
                const SizedBox(width: FSizes.spaceBtwItems),
                Expanded(
                  child: _buildStatCard(
                    'Weight',
                    isFiltered
                        ? '${controller.getCategoryWeight(controller.selectedCategoryForChart.value!).toStringAsFixed(1)} kg'
                        : '${controller.totalWeightProcessed.toStringAsFixed(1)} kg',
                    Iconsax.weight,
                    FColors.info,
                    dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            _buildStatCard(
              'Activities Processed',
              isFiltered
                  ? controller
                      .getCategoryActivityCount(
                          controller.selectedCategoryForChart.value!)
                      .toString()
                  : controller.activities.length.toString(),
              Iconsax.activity,
              dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
              dark,
              isFullWidth: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool dark,
      {bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: isFullWidth
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(Get.context!)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: dark ? FColors.darkGrey : FColors.grey,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: Theme.of(Get.context!)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  title,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildFilterSection(StaffRecycleActivityController controller,
      bool dark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: FColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.filter,
                    color: FColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filters',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            Obx(() => controller.hasActiveFilters
                ? TextButton.icon(
                    onPressed: controller.clearAllFilters,
                    // icon:
                    //     Icon(Iconsax.refresh_2, size: 16, color: FColors.error),
                    label: Text('Clear All',
                        style: TextStyle(color: FColors.error)),
                    style: TextButton.styleFrom(
                      backgroundColor: FColors.error.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: FSizes.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Universal Time Filter with Staff Blue Theme
              Obx(() => UniversalTimeFilter(
                    selectedFilter: controller.selectedTimeFilter.value,
                    onFilterChanged: (filter) {
                      controller.setTimeFilter(filter);
                    },
                    darkMode: dark,
                    showCloseButton: true,
                    primaryColor: dark
                        ? FColors.staffDarkPrimary
                        : FColors.staffLightPrimary,
                  )),

              const SizedBox(width: FSizes.sm),

              // Category Filter
              Obx(() => _buildCategoryFilterChip(controller, dark, context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterChip(StaffRecycleActivityController controller,
      bool dark, BuildContext context) {
    final hasFilter = controller.selectedCategoryForChart.value != null;
    final category = controller.selectedCategoryForChart.value;

    return Material(
      color: FColors.transparent,
      child: InkWell(
        onTap: () => _showCategoryFilterBottomSheet(controller, dark, context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: hasFilter
                ? category!.color.withOpacity(0.1)
                : (dark
                    ? FColors.communityDarkSurface
                    : FColors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFilter
                  ? category!.color
                  : (dark
                      ? FColors.communityDarkBorder
                      : FColors.grey.withOpacity(0.2)),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.category,
                color: hasFilter
                    ? category!.color
                    : (dark
                        ? FColors.darkTextSecondary
                        : FColors.textSecondary),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hasFilter ? category!.name : 'Category',
                style: TextStyle(
                  color: hasFilter
                      ? category!.color
                      : (dark ? FColors.white : FColors.black),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Iconsax.arrow_down_1,
                color: hasFilter
                    ? category!.color
                    : (dark
                        ? FColors.darkTextSecondary
                        : FColors.textSecondary),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryFilterBottomSheet(StaffRecycleActivityController controller,
      bool dark, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: dark ? FColors.communityDarkSurface : FColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? FColors.darkGrey : FColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.category,
                      color: dark
                          ? FColors.staffDarkPrimary
                          : FColors.staffLightPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filter by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.white : FColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // All Categories Option
              Obx(() => _buildCategoryOption(
                    null,
                    'All Categories',
                    controller.selectedCategoryForChart.value == null,
                    controller,
                    context,
                    dark,
                  )),

              // Category Options
              Obx(() {
                final categories = controller.getCategoryDistribution();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: categories.map((category) {
                    return _buildCategoryOption(
                      category,
                      category.name,
                      controller.selectedCategoryForChart.value == category,
                      controller,
                      context,
                      dark,
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 12),
              // Close Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark
                          ? FColors.staffDarkPrimary
                          : FColors.staffLightPrimary,
                      foregroundColor: FColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption(
    WasteCategory? category,
    String label,
    bool isSelected,
    StaffRecycleActivityController controller,
    BuildContext context,
    bool dark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (category == null) {
            controller.clearCategoryFilter();
          } else {
            controller.selectCategoryForChart(category);
          }
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.defaultSpace,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)
                    .withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (category?.color ??
                              (dark
                                  ? FColors.staffDarkPrimary
                                  : FColors.staffLightPrimary))
                          .withOpacity(0.2)
                      : (dark
                          ? FColors.communityDarkBorder
                          : FColors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category?.icon ?? Iconsax.category,
                  color: isSelected
                      ? (category?.color ??
                          (dark
                              ? FColors.staffDarkPrimary
                              : FColors.staffLightPrimary))
                      : (dark
                          ? FColors.darkTextSecondary
                          : FColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? (category?.color ??
                            (dark
                                ? FColors.staffDarkPrimary
                                : FColors.staffLightPrimary))
                        : (dark ? FColors.white : FColors.black),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Iconsax.tick_circle5,
                  color: category?.color ??
                      (dark
                          ? FColors.staffDarkPrimary
                          : FColors.staffLightPrimary),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedActivitiesList(
    StaffRecycleActivityController controller,
    bool dark,
    BuildContext context,
  ) {
    final groupedActivities = controller.getActivitiesGroupedByDate();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dateKey = groupedActivities.keys.elementAt(index);
          final activities = groupedActivities[dateKey]!;
          final dateHeader = controller.getFormattedDateHeader(dateKey);
          final summary = controller.getDateSummary(activities);

          return Padding(
            padding: const EdgeInsets.only(
              left: FSizes.defaultSpace,
              right: FSizes.defaultSpace,
              bottom: FSizes.spaceBtwSections,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header with Summary
                _buildDateHeader(dateHeader, summary, dark),
                const SizedBox(height: FSizes.spaceBtwItems),

                // Activities for this date
                ...activities.map((activity) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
                      child: _buildActivityCard(
                          activity, dark, controller, context),
                    )),
              ],
            ),
          );
        },
        childCount: groupedActivities.length,
      ),
    );
  }

  Widget _buildDateHeader(
      String dateHeader, Map<String, dynamic> summary, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)
              .withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.calendar_1,
              color:
                  dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateHeader,
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary['count']} activities • ${summary['weight'].toStringAsFixed(1)} kg',
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.grey,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Iconsax.medal_star5, size: 14, color: FColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    '${summary['points']}',
                    style:
                        Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                              color: FColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    RecyclingActivity activity,
    bool dark,
    StaffRecycleActivityController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final category =
          controller.getWasteCategoryById(activity.wasteCategoryId);

      return Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                      color: FColors.staffLightPrimary),
                ),
              );

              await Future.delayed(const Duration(milliseconds: 300));
              Navigator.pop(context);

              final result = await Get.to(
                () => const StaffActivityDetailScreen(),
                arguments: activity,
              );

              if (result == true) {
                controller.refreshActivities();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(FSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Support Image
                      GestureDetector(
                        onTap: () {
                          _showImageLightbox(activity, context);
                        },
                        child: Hero(
                          tag: 'activity_${activity.activityId}',
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: category.color.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: FutureBuilder<String>(
                              future:
                                  activity.getSupportImageUrl(activity.userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: category.color,
                                    ),
                                  );
                                }

                                if (snapshot.hasError ||
                                    snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 28,
                                  );
                                }

                                final imageUrl = snapshot.data!;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        category.icon,
                                        color: category.color,
                                        size: 28,
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          color: category.color,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: FSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: category.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: category.color,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.wasteObject,
                              style: Theme.of(Get.context!)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.md),
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: (dark
                              ? FColors.darkContainer
                              : FColors.lightContainer)
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricItem(
                          icon: Iconsax.weight,
                          value: activity.formattedWeight,
                          color: FColors.info,
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: dark ? FColors.darkGrey : FColors.grey,
                        ),
                        _buildMetricItem(
                          icon: Iconsax.medal_star5,
                          value: '${activity.pointsEarned} pts',
                          color: FColors.warning,
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
    });
  }

  void _showImageLightbox(RecyclingActivity activity, BuildContext context) {
    Future<String> imageUrlFuture =
        activity.getSupportImageUrl(activity.userId);

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<String>(
        future: imageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: FColors.staffLightPrimary),
            );
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            Navigator.pop(context);
            return const SizedBox();
          }

          final imageUrl = snapshot.data!;
          return UnifiedMediaLightbox(
            mediaItems: [
              UnifiedMediaItem.network(
                id: activity.activityId,
                networkUrl: imageUrl,
                isVideo: false,
              ),
            ],
            initialIndex: 0,
          );
        },
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color:
                  (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)
                      .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.box_remove,
              size: 64,
              color:
                  dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            'No Activities Found',
            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: FSizes.sm),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace * 2),
            child: Text(
              'Try adjusting your filters or process more recycling activities.',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  final List<WasteCategory> categories;
  final WasteCategory? selectedCategory;
  final StaffRecycleActivityController controller;
  final bool dark;

  DonutChartPainter({
    required this.categories,
    required this.selectedCategory,
    required this.controller,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final strokeWidth = 25.0;
    double startAngle = -math.pi / 2;

    final totalWeight = categories.fold<double>(
      0,
          (sum, category) => sum + controller.getCategoryWeight(category),
    );

    if (totalWeight == 0) return;

    // Draw background ring
    final backgroundPaint = Paint()
      ..color = (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // ✅ 按权重从大到小排序，这样小的会最后绘制（显示在上层）
    final sortedCategories = List<WasteCategory>.from(categories)
      ..sort((a, b) {
        final weightA = controller.getCategoryWeight(a);
        final weightB = controller.getCategoryWeight(b);
        return weightB.compareTo(weightA); // 降序排列
      });

    // ✅ 重新计算起始角度（保持绘制顺序）
    startAngle = -math.pi / 2;

    // Draw category segments - 使用排序后的列表
    for (var category in sortedCategories) {
      final weight = controller.getCategoryWeight(category);
      final sweepAngle = (weight / totalWeight) * 2 * math.pi;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Highlight selected category
      if (selectedCategory == category) {
        // Draw shadow
        final shadowPaint = Paint()
          ..color = category.color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        final shadowRect = Rect.fromCircle(
          center: center,
          radius: radius - strokeWidth / 2,
        );

        canvas.drawArc(shadowRect, startAngle, sweepAngle, false, shadowPaint);

        paint.strokeWidth = strokeWidth + 2;
      }

      final rect = Rect.fromCircle(
        center: center,
        radius: radius - strokeWidth / 2,
      );

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => true;
}
