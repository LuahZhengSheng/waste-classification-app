import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/device/device_utility.dart';
import '../../controllers/dashboard_controller.dart';
import 'widgets/statistic_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: RefreshIndicator(
        onRefresh: controller.refreshDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Statistics Cards
              _buildStatisticsSection(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Charts Section
              _buildChartsSection(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Recent Activity Section
              _buildRecentActivitySection(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Quick Actions
              _buildQuickActionsSection(controller, dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool dark) {
    final controller = Get.find<AdminDashboardController>();

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkPrimary.withOpacity(0.1) : FColors.adminLightPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              Iconsax.chart,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              size: FSizes.iconLg,
            ),
          ),
          const SizedBox(width: FSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Welcome back! Here\'s what\'s happening with your platform.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.refreshDashboard(),
            icon: Icon(
              Iconsax.refresh,
              color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(AdminDashboardController controller, bool dark) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final stats = controller.getStatisticsCards();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: FDeviceUtils.getScreenWidth() > 600 ? 4 : 2,
          crossAxisSpacing: FSizes.spaceBtwItems,
          mainAxisSpacing: FSizes.spaceBtwItems,
          childAspectRatio: 1.2,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return StatisticsCard(
            title: stats[index]['title'],
            value: stats[index]['value'],
            change: stats[index]['change'],
            isPositive: stats[index]['isPositive'],
            color: stats[index]['color'],
            icon: _getIconFromString(stats[index]['icon']),
            dark: dark,
          );
        },
      );
    });
  }

  Widget _buildChartsSection(AdminDashboardController controller, bool dark) {
    return Row(
      children: [
        // User Growth Chart
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'User Growth (Last 7 Days)',
            dark: dark,
            child: Obx(() {
              // Check if data is available and not empty
              if (controller.userGrowthData.isEmpty) {
                return const SizedBox(
                  height: 250,
                  child: Center(child: Text('No data available')),
                );
              }

              return SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 250,
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.userGrowthData.toList(),
                        isCurved: true,
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: FSizes.spaceBtwItems),
        // Event Participation Pie Chart
        Expanded(
          child: ChartCard(
            title: 'Event Participation',
            dark: dark,
            child: Obx(() {
              // Check if data is available and not empty
              if (controller.eventParticipationData.isEmpty) {
                return const SizedBox(
                  height: 250,
                  child: Center(child: Text('No data available')),
                );
              }

              return SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: controller.eventParticipationData.toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(AdminDashboardController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: FSizes.fontSizeLg,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
        Row(
          children: [
            // Recent Users
            Expanded(
              child: Obx(() => RecentActivityCard(
                title: 'New Users',
                dark: dark,
                items: controller.recentUsers,
                itemBuilder: (item) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    child: Text(
                      item['name'].toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: TextStyle(
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    item['email'],
                    style: TextStyle(
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item['status'] == 'Active'
                          ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1)
                          : (dark ? FColors.adminDarkError : FColors.adminLightError).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(
                        color: item['status'] == 'Active'
                            ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                            : (dark ? FColors.adminDarkError : FColors.adminLightError),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )),
            ),
            const SizedBox(width: FSizes.spaceBtwItems),
            // Recent Events
            // Expanded(
            //   child: Obx(() => RecentActivityCard(
            //     title: 'Recent Events',
            //     dark: dark,
            //     items: controller.recentEvents,
            //     itemBuilder: (item) => ListTile(
            //       leading: Container(
            //         padding: const EdgeInsets.all(FSizes.sm),
            //         decoration: BoxDecoration(
            //           color: dark ? FColors.adminDarkInfo.withOpacity(0.1) : FColors.adminLightInfo.withOpacity(0.1),
            //           borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            //         ),
            //         child: Icon(
            //           Iconsax.calendar,
            //           color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            //           size: FSizes.iconSm,
            //         ),
            //       ),
            //       title: Text(
            //         item['title'],
            //         style: TextStyle(
            //           color: dark ? FColors.adminDarkText : FColors.adminLightText,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //       subtitle: Text(
            //         '${item['participants']} participants • ${item['date']}',
            //         style: TextStyle(
            //           color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            //         ),
            //       ),
            //       trailing: Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //         decoration: BoxDecoration(
            //           color: item['status'] == 'Upcoming'
            //               ? (dark ? FColors.adminDarkWarning : FColors.adminLightWarning).withOpacity(0.1)
            //               : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
            //           borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            //         ),
            //         child: Text(
            //           item['status'],
            //           style: TextStyle(
            //             color: item['status'] == 'Upcoming'
            //                 ? (dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
            //                 : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
            //             fontSize: 12,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   )),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(AdminDashboardController controller, bool dark) {
    final actions = controller.getQuickActions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: FSizes.fontSizeLg,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: FDeviceUtils.getScreenWidth() > 600 ? 4 : 2,
            crossAxisSpacing: FSizes.spaceBtwItems,
            mainAxisSpacing: FSizes.spaceBtwItems,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                // Navigate to the respective screen
                // Get.toNamed(actions[index]['route']); // Commented out to prevent navigation errors
                print('Navigate to ${actions[index]['route']}');
              },
              child: Container(
                padding: const EdgeInsets.all(FSizes.lg),
                decoration: BoxDecoration(
                  color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                  border: Border.all(
                    color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconFromString(actions[index]['icon']),
                      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      size: FSizes.iconLg,
                    ),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      actions[index]['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'users':
        return Iconsax.people;
      case 'user_check':
        return Iconsax.user_tick;
      case 'calendar':
        return Iconsax.calendar;
      case 'message':
        return Iconsax.message;
      case 'calendar_plus':
        return Iconsax.calendar_add;
      case 'users_manage':
        return Iconsax.user_edit;
      case 'chart':
        return Iconsax.chart_21;
      case 'settings':
        return Iconsax.setting_2;
      default:
        return Iconsax.info_circle;
    }
  }
}