import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/dashboard_controller.dart';
import 'widgets/stat_card.dart';
import 'widgets/recycling_trend_chart.dart';
import 'widgets/waste_category_chart.dart';
import 'widgets/user_growth_chart.dart';
import 'widgets/top_centers_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark
          ? FColors.adminDarkBackground
          : FColors.adminLightBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📊 Page Header
              _buildHeader(dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // 📈 Stats Cards (Always 4 columns on desktop, 2 on tablet, 1 on mobile)
              _buildStatsSection(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections * 1.5),

              // 📉 Main Charts Section (Recycling Trend - Full Width)
              _buildMainChartsSection(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections * 1.5),

              // 🏆 Secondary Charts Section (New Layout)
              _buildSecondaryChartsSection(controller, dark),

              const SizedBox(height: FSizes.spaceBtwSections),
            ],
          ),
        );
      }),
    );
  }

  /// 📊 Header Section
  Widget _buildHeader(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          'Real-time insights into your recycling system performance',
          style: TextStyle(
            fontSize: 15,
            color: dark
                ? FColors.adminDarkTextSecondary
                : FColors.adminLightTextSecondary,
          ),
        ),
      ],
    );
  }

  /// 📈 Stats Cards Section
  Widget _buildStatsSection(DashboardController controller, bool dark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive columns
        int crossAxisCount = 4;
        double childAspectRatio = 1.4;

        if (constraints.maxWidth < 600) {
          // Mobile: 1 column
          crossAxisCount = 1;
          childAspectRatio = 2.5;
        } else if (constraints.maxWidth < 900) {
          // Tablet: 2 columns
          crossAxisCount = 2;
          childAspectRatio = 1.8;
        } else if (constraints.maxWidth < 1200) {
          // Small Desktop: 2 columns
          crossAxisCount = 2;
          childAspectRatio = 1.6;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: FSizes.lg,
          mainAxisSpacing: FSizes.lg,
          childAspectRatio: childAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Obx(() => StatCard(
              title: 'Total Users',
              value: controller.formatNumber(controller.totalUsers.value),
              icon: Iconsax.people,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              trend: controller.userTrend.value,
              subtitle: 'vs last month',
            )),
            Obx(() => StatCard(
              title: 'Total Recycled',
              value: '${controller.totalWeightRecycled.value.toStringAsFixed(0)} kg',
              icon: Iconsax.box,
              color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
              trend: controller.weightTrend.value,
              subtitle: 'this month',
            )),
            Obx(() => StatCard(
              title: 'Active Centers',
              value: controller.activeCenters.value.toString(),
              icon: Iconsax.location,
              color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
              trend: controller.centerTrend.value,
              subtitle: 'recycling centers',
            )),
            Obx(() => StatCard(
              title: 'Points Issued',
              value: controller.formatNumber(controller.totalPointsIssued.value),
              icon: Iconsax.coin_1,
              color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
              trend: controller.pointsTrend.value,
              subtitle: 'reward points',
            )),
          ],
        );
      },
    );
  }

  /// 📉 Main Charts Section (Full Width Recycling Trend)
  Widget _buildMainChartsSection(DashboardController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Recycling Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.md),

        // Full Width Chart
        Obx(() => RecyclingTrendChart(
          trendData: controller.recyclingTrend.value,
        )),
      ],
    );
  }

  /// 🏆 Secondary Charts Section (NEW LAYOUT)
  /// Row 1: Waste Category + User Growth (Same Height)
  /// Row 2: Top Centers (Full Width)
  Widget _buildSecondaryChartsSection(DashboardController controller, bool dark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'Detailed Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.md),

            // 🆕 Row 1: Waste Category + User Growth (Side by Side with Same Height)
            if (isWideScreen)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Obx(() => WasteCategoryChart(
                        distribution: controller.wasteCategoryDistribution.value,
                      )),
                    ),
                    const SizedBox(width: FSizes.lg),
                    Expanded(
                      child: Obx(() => UserGrowthChart(
                        growthData: controller.userGrowth.value,
                      )),
                    ),
                  ],
                ),
              )
            else
            // Mobile: Stack them
              Column(
                children: [
                  Obx(() => WasteCategoryChart(
                    distribution: controller.wasteCategoryDistribution.value,
                  )),
                  const SizedBox(height: FSizes.lg),
                  Obx(() => UserGrowthChart(
                    growthData: controller.userGrowth.value,
                  )),
                ],
              ),

            const SizedBox(height: FSizes.lg),

            // 🆕 Row 2: Top Centers (Full Width)
            Obx(() => TopCentersChart(
              topCenters: controller.topCenters.value,
            )),
          ],
        );
      },
    );
  }
}
