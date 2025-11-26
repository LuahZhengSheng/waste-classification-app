import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/recycling_center_management/recycling_center_management_controller.dart';

import 'widgets/center_data_table.dart';

class PartnerCenterManagementScreen extends StatelessWidget {
  const PartnerCenterManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PartnerCenterManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Tabs and Add Button
            Row(
              children: [
                // Status Filter Tabs
                Obx(() => Row(
                  children: [
                    _buildFilterTab(
                      'Active Centers',
                      isActive: controller.selectedStatusFilter.value == 'active',
                      onTap: () => controller.changeStatusFilter('active'),
                      dark: dark,
                    ),
                    const SizedBox(width: FSizes.sm),
                    _buildFilterTab(
                      'Disabled Centers',
                      isActive: controller.selectedStatusFilter.value == 'disabled',
                      onTap: () => controller.changeStatusFilter('disabled'),
                      dark: dark,
                    ),
                  ],
                )),
                const Spacer(),
                // Add Center Button
                ElevatedButton.icon(
                  onPressed: controller.addCenter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                  ),
                  icon: const Icon(Iconsax.add, color: Colors.white),
                  label: const Text(
                    'Add Center',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, phone, city, or state...',
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Obx(() => IconButton(
                    onPressed: controller.showFilters,
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

            // Show entries and results
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DropdownButton<int>(
                        value: controller.itemsPerPage.value,
                        onChanged: controller.changeItemsPerPage,
                        items: [10, 25, 50, 100]
                            .map((int value) => DropdownMenuItem<int>(
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
                Obx(() => Text(
                  'Total: ${controller.totalCenters} centers',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                )),
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
                      Expanded(
                        child: CenterDataTable(
                          centers: controller.paginatedCenters,
                          onSort: controller.sortCenters,
                          sortColumnIndex: controller.sortColumnIndex.value,
                          sortAscending: controller.sortAscending.value,
                          dark: dark,
                          controller: controller,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(FSizes.md),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: _buildPagination(controller, dark),
                      ),
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

  Widget _buildPagination(PartnerCenterManagementController controller, bool dark) {
    int totalPages = (controller.totalCenters / controller.itemsPerPage.value).ceil();
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalCenters} entries',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        Row(
          children: [
            _buildPaginationButton(
              icon: Iconsax.previous,
              onTap: controller.currentPage.value > 1 ? () => controller.goToPage(1) : null,
              tooltip: 'First page',
              dark: dark,
            ),
            _buildPaginationButton(
              icon: Iconsax.arrow_left_2,
              onTap: controller.canGoPreviousPage ? controller.previousPage : null,
              tooltip: 'Previous page',
              dark: dark,
            ),
            const SizedBox(width: FSizes.sm),
            ...pageNumbers.map((pageNum) => GestureDetector(
              onTap: () => controller.goToPage(pageNum),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                decoration: BoxDecoration(
                  color: pageNum == currentPage
                      ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
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
            const SizedBox(width: FSizes.sm),
            _buildPaginationButton(
              icon: Iconsax.arrow_right_3,
              onTap: controller.canGoNextPage ? controller.nextPage : null,
              tooltip: 'Next page',
              dark: dark,
            ),
            _buildPaginationButton(
              icon: Iconsax.next,
              onTap: controller.currentPage.value < totalPages ? () => controller.goToPage(totalPages) : null,
              tooltip: 'Last page',
              dark: dark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    required bool dark,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: onTap != null
            ? (dark ? FColors.adminDarkText : FColors.adminLightText)
            : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
        size: 18,
      ),
      tooltip: tooltip,
    );
  }
}
