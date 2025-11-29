import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/recycling_center_management/recycling_center_detail_controller.dart';
import 'package:fyp/features/recycling_center/models/recycling_center_staff_model.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';

class RecyclingCenterDetailsScreen extends StatelessWidget {
  final String centerId;

  const RecyclingCenterDetailsScreen({super.key, required this.centerId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecyclingCenterDetailsController(centerId: centerId));
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Iconsax.arrow_left_2, color: dark ? FColors.adminDarkText : FColors.adminLightText),
        ),
        title: Obx(() => Text(
          controller.center.value?.name ?? 'Center Details',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        )),
        actions: [
          IconButton(
            onPressed: controller.editCenter,
            icon: Icon(Iconsax.edit, color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
            tooltip: 'Edit Center',
          ),
          Obx(() {
            if (controller.center.value == null) return const SizedBox();
            final isDisabled = controller.center.value!.status == 'disabled';

            return IconButton(
              onPressed: () => _showDisableDialog(controller, dark),
              icon: Icon(
                isDisabled ? Iconsax.refresh : Iconsax.close_circle,
                color: isDisabled
                    ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                    : (dark ? FColors.adminDarkError : FColors.adminLightError),
              ),
              tooltip: isDisabled ? 'Recover Center' : 'Disable Center',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
          );
        }

        if (controller.center.value == null) {
          return const Center(child: Text('Center not found'));
        }

        return Column(
          children: [
            // New Activity Notification - Only show after initial load
            Obx(() {
              if (!controller.showNewActivityNotification.value) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(FSizes.md),
                margin: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.information, color: Colors.white),
                    const SizedBox(width: FSizes.md),
                    const Expanded(
                      child: Text(
                        'New recycling activities detected',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.refreshActivities,
                      child: const Text('Refresh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(FSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCenterOverviewCard(controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    _buildStatisticsGrid(controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    _buildCategoryStatistics(controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    _buildStaffSection(controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    _buildRecentActivitiesSection(controller, dark),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showDisableDialog(RecyclingCenterDetailsController controller, bool dark) {
    final isDisabled = controller.center.value!.status == 'disabled';

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          isDisabled ? 'Recover Center' : 'Disable Center',
          style: TextStyle(color: dark ? FColors.adminDarkText : FColors.adminLightText),
        ),
        content: Text(
          isDisabled
              ? 'Are you sure you want to recover this center? It will be reactivated but staff accounts will remain banned.'
              : 'Are you sure you want to disable this center? This will ban all associated staff members.',
          style: TextStyle(color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.disableCenter();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                  : (dark ? FColors.adminDarkError : FColors.adminLightError),
            ),
            child: Text(isDisabled ? 'Recover' : 'Disable', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterOverviewCard(RecyclingCenterDetailsController controller, bool dark) {
    final center = controller.center.value!;
    print('center image: ${controller.center.value?.image}');

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with clickable image
          GestureDetector(
            onTap: controller.showCenterImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FSizes.cardRadiusLg),
                  topRight: Radius.circular(FSizes.cardRadiusLg),
                ),
                image: DecorationImage(
                  image: NetworkImage(center.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(FSizes.cardRadiusLg),
                        topRight: Radius.circular(FSizes.cardRadiusLg),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: FSizes.md,
                    right: FSizes.md,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                      ),
                      child: IconButton(
                        onPressed: controller.showCenterImage,
                        icon: const Icon(Iconsax.maximize_4, color: Colors.white),
                        tooltip: 'View full image',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: FSizes.md,
                    left: FSizes.md,
                    right: FSizes.md,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                center.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: FSizes.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
                                decoration: BoxDecoration(
                                  color: controller.getCenterStatusColor(dark),
                                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                                ),
                                child: Text(
                                  controller.centerStatusText,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details content
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  'Center Information',
                  [
                    _buildInfoRow(Iconsax.card, 'Center ID', center.centerId, dark),
                    _buildInfoRow(Iconsax.sms, 'Email', center.email, dark),
                    _buildInfoRow(Iconsax.call, 'Phone', center.formattedPhoneNo, dark),
                    _buildInfoRow(Iconsax.global, 'Website', center.website, dark, isUrl: true),
                  ],
                  dark,
                ),
                const SizedBox(height: FSizes.spaceBtwSections),
                _buildInfoSection(
                  'Location',
                  [
                    _buildInfoRow(Iconsax.location, 'Address', center.centerLocation.fullAddress, dark),
                    _buildInfoRow(Iconsax.map_1, 'Coordinates', center.centerLocation.coordinates, dark),
                  ],
                  dark,
                ),
                const SizedBox(height: FSizes.spaceBtwSections),
                _buildAcceptedMaterialsSection(center, dark),
                const SizedBox(height: FSizes.spaceBtwSections),
                _buildOpeningHoursSection(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),
                _buildInfoSection(
                  'Additional Details',
                  [
                    _buildInfoRow(Iconsax.people, 'Total Staff', center.numberOfStaff.toString(), dark),
                    _buildInfoRow(Iconsax.calendar_1, 'Created Date', center.formattedCreatedAt, dark),
                  ],
                  dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedMaterialsSection(center, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accepted Materials',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Wrap(
          spacing: FSizes.sm,
          runSpacing: FSizes.sm,
          children: center.acceptedMaterials.map<Widget>((material) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
              decoration: BoxDecoration(
                color: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                border: Border.all(
                  color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                  width: 1,
                ),
              ),
              child: Text(
                material,
                style: TextStyle(
                  color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool dark, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            ),
            child: Icon(icon, size: 18, color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: isUrl ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHoursSection(RecyclingCenterDetailsController controller, bool dark) {
    if (controller.center.value?.openingHours != null) {
      print('🔍 Opening Hours Data: ${controller.center.value!.openingHours}');
      final periods = controller.center.value!.openingHours!['periods'] as List<dynamic>?;
      if (periods != null) {
        print('🔍 Number of periods: ${periods.length}');
        for (var i = 0; i < periods.length; i++) {
          print('🔍 Period $i: ${periods[i]}');
        }
      }
    }

    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    List<Map<String, dynamic>> groupedHours = _groupOpeningHours(controller, days, dayNames);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opening Hours',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Container(
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: Column(
            children: List.generate(groupedHours.length, (index) {
              final group = groupedHours[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index == groupedHours.length - 1 ? 0 : FSizes.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        group['displayDays'],
                        style: TextStyle(
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        group['hours'],
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _groupOpeningHours(
      RecyclingCenterDetailsController controller,
      List<String> days,
      List<String> dayNames) {
    List<Map<String, dynamic>> groups = [];
    int startIndex = 0;

    while (startIndex < days.length) {
      String currentHours = controller.formatOpeningHours(days[startIndex]);
      int endIndex = startIndex;

      // 找到连续相同营业时间的日期范围
      while (endIndex + 1 < days.length &&
          controller.formatOpeningHours(days[endIndex + 1]) == currentHours) {
        endIndex++;
      }

      String displayDays;
      if (startIndex == endIndex) {
        displayDays = dayNames[startIndex];
      } else if (endIndex - startIndex == 1) {
        displayDays = '${dayNames[startIndex]}, ${dayNames[endIndex]}';
      } else {
        displayDays = '${dayNames[startIndex]} - ${dayNames[endIndex]}';
      }

      groups.add({
        'displayDays': displayDays,
        'hours': currentHours,
      });

      startIndex = endIndex + 1;
    }

    return groups;
  }

  Widget _buildStatisticsGrid(RecyclingCenterDetailsController controller, bool dark) {
    return Obx(() => Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Today',
                controller.totalActivitiesToday,
                'Activities',
                Iconsax.calendar_tick,
                dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                dark,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: _buildStatCard(
                'This Week',
                controller.totalActivitiesThisWeek,
                'Activities',
                Iconsax.chart_1,
                dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                dark,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: _buildStatCard(
                'Total Weight',
                controller.totalWeightProcessed,
                'Processed',
                Iconsax.weight,
                dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                controller.totalActivitiesCount,
                'Activities',
                Iconsax.activity,
                dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                dark,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: _buildStatCard(
                'Total Points',
                controller.totalPointsAssigned,
                'Assigned',
                Iconsax.medal_star,
                dark ? FColors.adminDarkAccent : FColors.adminLightAccent,
                dark,
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                title,
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatistics(RecyclingCenterDetailsController controller, bool dark) {
    return Obx(() {
      if (controller.categoryStats.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(FSizes.lg),
              child: Text(
                'Waste Category Statistics',
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.categoryStats.length,
              separatorBuilder: (context, index) => Divider(
                color: (dark ? FColors.adminDarkDivider : FColors.adminLightDivider).withOpacity(0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final entry = controller.categoryStats.entries.elementAt(index);
                final categoryData = entry.value;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(FSizes.xs),
                            decoration: BoxDecoration(
                              color: (categoryData['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                            ),
                            child: Icon(
                              categoryData['icon'] as IconData,
                              color: categoryData['color'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text(
                              categoryData['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCategoryStatItem(
                              'Activities',
                              categoryData['count'].toString(),
                              Iconsax.activity,
                              dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                              dark,
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: _buildCategoryStatItem(
                              'Weight',
                              '${(categoryData['weight'] as double).toStringAsFixed(2)} kg',
                              Iconsax.weight,
                              dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                              dark,
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: _buildCategoryStatItem(
                              'Points',
                              categoryData['points'].toString(),
                              Iconsax.medal_star,
                              dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                              dark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryStatItem(String label, String value, IconData icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: FSizes.xs),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection(RecyclingCenterDetailsController controller, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Staff Members',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  final activeCount = controller.allStaff.where((s) => s.isActive && !s.isBanned).length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                    decoration: BoxDecoration(
                      color: (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    ),
                    child: Text(
                      '$activeCount Active / ${controller.allStaff.length} Total',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            if (controller.allStaff.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(FSizes.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.people,
                        size: 48,
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                      const SizedBox(height: FSizes.md),
                      Text(
                        'No staff members',
                        style: TextStyle(
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.allStaff.length,
              separatorBuilder: (context, index) => Divider(
                color: (dark ? FColors.adminDarkDivider : FColors.adminLightDivider).withOpacity(0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final staff = controller.allStaff[index];
                final activityCount = controller.staffActivityCounts[staff.userId] ?? 0;
                final isInactive = !staff.isActive || staff.isBanned;

                return Stack(
                  children: [
                    _buildStaffTile(staff, activityCount, controller, dark),
                    if (isInactive)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                              decoration: BoxDecoration(
                                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                                borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                              ),
                              child: Text(
                                staff.isBanned ? 'BANNED' : 'INACTIVE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStaffTile(RecyclingCenterStaff staff, int activityCount, RecyclingCenterDetailsController controller, bool dark) {
    final imageUrl = controller.getStaffImageUrl(staff.userId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
      child: Row(
        children: [
          // Profile Image - Clickable
          GestureDetector(
            onTap: () {
              if (imageUrl != null && imageUrl.isNotEmpty) {
                controller.showProfileImage(imageUrl, staff.username);
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (dark ? FColors.adminDarkBorder : FColors.adminLightBorder).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                    child: Icon(
                      Iconsax.user,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  ),
                )
                    : Container(
                  color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                  child: Icon(
                    Iconsax.user,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),

          // Staff Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.username,
                        style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildStatusBadge(staff, dark),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  staff.email,
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Iconsax.activity,
                      size: 14,
                      color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      '$activityCount activities handled',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RecyclingCenterStaff staff, bool dark) {
    if (staff.isBanned) {
      return _buildBadge('Banned', dark ? FColors.adminDarkError : FColors.adminLightError);
    }

    if (!staff.isActive) {
      return _buildBadge('Inactive', dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted);
    }

    if (!staff.isVerified) {
      return _buildBadge('Not Verified', dark ? FColors.adminDarkWarning : FColors.adminLightWarning);
    }

    return _buildBadge('Active', dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess);
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection(RecyclingCenterDetailsController controller, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                      decoration: BoxDecoration(
                        color: (dark ? FColors.adminDarkInfo : FColors.adminLightInfo).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                      ),
                      child: Text(
                        '${controller.filteredActivities.length} Activities',
                        style: TextStyle(
                          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: FSizes.md),

                // Filters
                Row(
                  children: [
                    Expanded(child: _buildStaffFilterDropdown(controller, dark)),
                    const SizedBox(width: FSizes.md),
                    _buildSortDropdown(controller, dark),
                  ],
                ),
              ],
            ),
          ),

          // Activities List
          Obx(() {
            if (controller.filteredActivities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(FSizes.xl),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.activity,
                      size: 48,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                    const SizedBox(height: FSizes.md),
                    Text(
                      'No activities found',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredActivities.length,
              separatorBuilder: (context, index) => Divider(
                color: (dark ? FColors.adminDarkDivider : FColors.adminLightDivider).withOpacity(0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final activity = controller.filteredActivities[index];
                final staff = controller.getStaffById(activity.centerStaffId);
                final user = controller.getUserById(activity.userId);

                return _buildActivityTile(activity, staff, user, controller, dark);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStaffFilterDropdown(RecyclingCenterDetailsController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Obx(() => DropdownButton<String>(
        value: controller.selectedStaffFilter.value,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (value) => controller.changeStaffFilter(value!),
        dropdownColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        style: TextStyle(color: dark ? FColors.adminDarkText : FColors.adminLightText),
        items: [
          DropdownMenuItem(
            value: 'all',
            child: Row(
              children: [
                Icon(Iconsax.people, size: 16, color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                const SizedBox(width: FSizes.sm),
                const Text('All Staff'),
              ],
            ),
          ),
          ...controller.allStaff.map((staff) {
            final imageUrl = controller.getStaffImageUrl(staff.userId);
            return DropdownMenuItem(
              value: staff.userId,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Iconsax.user,
                          size: 14,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                      )
                          : Icon(
                        Iconsax.user,
                        size: 14,
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(child: Text(staff.username)),
                ],
              ),
            );
          }),
        ],
      )),
    );
  }

  Widget _buildSortDropdown(RecyclingCenterDetailsController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Obx(() => DropdownButton<String>(
        value: controller.sortBy.value,
        underline: const SizedBox(),
        onChanged: (value) => controller.changeSorting(value!),
        dropdownColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        style: TextStyle(color: dark ? FColors.adminDarkText : FColors.adminLightText),
        items: [
          DropdownMenuItem(
            value: 'newest',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.arrow_down_1, size: 16, color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                const SizedBox(width: FSizes.sm),
                const Text('Newest'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'oldest',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.arrow_up_1, size: 16, color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                const SizedBox(width: FSizes.sm),
                const Text('Oldest'),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildActivityTile(RecyclingActivity activity, RecyclingCenterStaff? staff, UserModel? user, RecyclingCenterDetailsController controller, bool dark) {
    final activityImageUrl = controller.getActivityImageUrl(activity.activityId);
    final userImageUrl = controller.getUserImageUrl(activity.userId);
    final staffImageUrl = controller.getStaffImageUrl(activity.centerStaffId);
    final categoryName = controller.getCategoryName(activity.wasteCategoryId);

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Image - Clickable
          GestureDetector(
            onTap: () {
              if (activityImageUrl != null && activityImageUrl.isNotEmpty) {
                controller.showActivityImage(activity.activityId, activity.wasteObject);
              }
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(
                  color: (dark ? FColors.adminDarkBorder : FColors.adminLightBorder).withOpacity(0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                child: activityImageUrl != null && activityImageUrl.isNotEmpty
                    ? Image.network(
                  activityImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                    child: Icon(Iconsax.image, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                  ),
                )
                    : Container(
                  color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                  child: Icon(Iconsax.image, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),

          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Waste object and DateTime + Status
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.wasteObject,
                            style: TextStyle(
                              color: dark ? FColors.adminDarkText : FColors.adminLightText,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          Text(
                            categoryName,
                            style: TextStyle(
                              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Row(
                      children: [
                        Icon(Iconsax.clock, size: 14, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                        const SizedBox(width: FSizes.xs),
                        Text(
                          _formatDateTime(activity.createdAt),
                          style: TextStyle(
                            color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: FSizes.sm),
                        _buildActivityStatusChip(activity.status, dark),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: FSizes.sm),

                // Third row: Weight and Points
                Row(
                  children: [
                    Icon(Iconsax.weight, size: 14, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      activity.formattedWeight,
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Icon(Iconsax.medal_star, size: 14, color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      '${activity.pointsEarned} points',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.md),

                // Fourth row: User and Staff info
                Row(
                  children: [
                    Expanded(
                      child: _buildPersonInfo(
                        'User',
                        user?.username ?? 'Unknown',
                        userImageUrl,
                        user?.rewardPoint.toString(),
                        Iconsax.medal_star,
                        controller,
                        dark,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: _buildPersonInfo(
                        'Staff',
                        staff?.username ?? 'Unknown',
                        staffImageUrl,
                        null,
                        Iconsax.user_tag,
                        controller,
                        dark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInfo(String label, String name, String? imageUrl, String? extraInfo, IconData extraIcon, RecyclingCenterDetailsController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  controller.showProfileImage(imageUrl, name);
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (dark ? FColors.adminDarkBorder : FColors.adminLightBorder).withOpacity(0.3),
                  ),
                ),
                child: ClipOval(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Iconsax.user,
                      size: 14,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  )
                      : Icon(Iconsax.user, size: 14, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                ),
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityStatusChip(String status, bool dark) {
    Color backgroundColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Completed';
        break;
      case 'approved':
        backgroundColor = dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        displayText = 'Approved';
        break;
      case 'pending':
        backgroundColor = dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        displayText = 'Pending';
        break;
      case 'rejected':
        backgroundColor = dark ? FColors.adminDarkError : FColors.adminLightError;
        displayText = 'Rejected';
        break;
      default:
        backgroundColor = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        displayText,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Format: "DD MMM YYYY, HH:MM AM/PM"
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return dateFormat.format(dateTime);
    }
  }
}