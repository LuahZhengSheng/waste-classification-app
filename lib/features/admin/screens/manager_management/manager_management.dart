import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../controllers/manager_management/manager_management_controller.dart';
import 'widgets/create_manager_dialog.dart';
import 'widgets/manager_actions_dialog.dart';
import 'widgets/manager_data_table.dart';

class ManagerManagementScreen extends StatelessWidget {
  const ManagerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagerManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Create Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter Tabs
                Obx(() => Row(
                  children: [
                    _buildFilterTab(
                      'Active Managers',
                      isActive: controller.currentFilter.value == ManagerFilter.active,
                      onTap: () => controller.changeFilter(ManagerFilter.active),
                      dark: dark,
                    ),
                    const SizedBox(width: FSizes.sm),
                    _buildFilterTab(
                      'Inactive Managers',
                      isActive: controller.currentFilter.value == ManagerFilter.inactive,
                      onTap: () => controller.changeFilter(ManagerFilter.inactive),
                      dark: dark,
                    ),
                    const SizedBox(width: FSizes.sm),
                    _buildFilterTab(
                      'Banned Managers',
                      isActive: controller.currentFilter.value == ManagerFilter.banned,
                      onTap: () => controller.changeFilter(ManagerFilter.banned),
                      dark: dark,
                    ),
                  ],
                )),

                // Create Manager Button
                ElevatedButton.icon(
                  onPressed: () => _showCreateManagerDialog(context, dark),
                  icon: const Icon(Iconsax.add_circle, size: 20),
                  label: const Text('Create Manager'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.lg,
                      vertical: FSizes.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search by username, email, or ID...',
                        hintStyle: TextStyle(
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal_1,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(FSizes.md),
                      ),
                      style: TextStyle(
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Container(
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    border: Border.all(
                      color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    ),
                  ),
                  child: Obx(() => IconButton(
                    onPressed: () => _showFilters(context, controller, dark),
                    icon: Stack(
                      children: [
                        Icon(
                          Iconsax.filter,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        if (controller.hasActiveFilters)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Items per page
            Row(
              children: [
                Text(
                  'Show',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    border: Border.all(
                      color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    ),
                  ),
                  child: DropdownButton<int>(
                    value: controller.itemsPerPage.value,
                    onChanged: controller.changeItemsPerPage,
                    items: [10, 25, 50, 100]
                        .map((value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        ),
                      ),
                    ))
                        .toList(),
                    underline: const SizedBox(),
                    dropdownColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                  ),
                )),
                const SizedBox(width: FSizes.sm),
                Text(
                  'entries',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Data Table
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                    border: Border.all(
                      color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ManagerDataTable(
                          managers: controller.paginatedManagers,
                          onSort: controller.sortManagers,
                          sortColumnIndex: controller.sortColumnIndex.value,
                          sortAscending: controller.sortAscending.value,
                          dark: dark,
                          isBannedView: controller.currentFilter.value == ManagerFilter.banned,
                        ),
                      ),
                      _buildPagination(controller, dark),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, {
    required bool isActive,
    required VoidCallback onTap,
    required bool dark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
        decoration: BoxDecoration(
          color: isActive
              ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: isActive
                ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                : (dark ? FColors.adminDarkBorder : FColors.adminLightBorder),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(ManagerManagementController controller, bool dark) {
    int totalPages = controller.totalPages;
    int currentPage = controller.currentPage.value;

    List<int> pageNumbers = [];
    if (totalPages <= 5) {
      pageNumbers = List.generate(totalPages, (index) => index + 1);
    } else {
      int start = (currentPage - 2).clamp(1, totalPages - 4);
      int end = (start + 4).clamp(5, totalPages);
      start = end - 4;
      pageNumbers = List.generate(5, (index) => start + index);
    }

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalManagers} entries',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 1 ? () => controller.goToPage(1) : null,
                icon: Icon(
                  Iconsax.arrow_left_3,
                  color: currentPage > 1
                      ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                      : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                ),
              ),
              IconButton(
                onPressed: controller.canGoPreviousPage ? controller.previousPage : null,
                icon: Icon(
                  Iconsax.arrow_left_2,
                  color: controller.canGoPreviousPage
                      ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                      : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                ),
              ),
              ...pageNumbers.map((pageNum) => GestureDetector(
                onTap: () => controller.goToPage(pageNum),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md, vertical: FSizes.sm),
                  decoration: BoxDecoration(
                    color: pageNum == currentPage
                        ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    border: Border.all(
                      color: pageNum == currentPage
                          ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                          : (dark ? FColors.adminDarkBorder : FColors.adminLightBorder),
                    ),
                  ),
                  child: Text(
                    pageNum.toString(),
                    style: TextStyle(
                      color: pageNum == currentPage
                          ? Colors.white
                          : (dark ? FColors.adminDarkText : FColors.adminLightText),
                      fontWeight: pageNum == currentPage ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              )),
              IconButton(
                onPressed: controller.canGoNextPage ? controller.nextPage : null,
                icon: Icon(
                  Iconsax.arrow_right_3,
                  color: controller.canGoNextPage
                      ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                      : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                ),
              ),
              IconButton(
                onPressed: currentPage < totalPages ? () => controller.goToPage(totalPages) : null,
                icon: Icon(
                  Iconsax.arrow_right_2,
                  color: currentPage < totalPages
                      ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                      : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context, ManagerManagementController controller, bool dark) {
    Get.dialog(
      ManagerFilterDialog(
        dark: dark,
        currentFilters: Map.from(controller.activeFilters),
        onApplyFilters: (filters) => controller.activeFilters.assignAll(filters),
      ),
      barrierDismissible: false,
    );
  }

  void _showCreateManagerDialog(BuildContext context, bool dark) {
    Get.dialog(
      CreateManagerDialog(dark: dark),
      barrierDismissible: false,
    );
  }
}