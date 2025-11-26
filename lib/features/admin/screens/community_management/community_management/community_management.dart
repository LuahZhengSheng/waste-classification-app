import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/community_management/community_management_controller.dart';
import 'package:fyp/features/admin/screens/community_management/community_management/widgets/community_filter_dialog.dart';

import 'widgets/community_data_table.dart';

class CommunityManagementScreen extends StatelessWidget {
  const CommunityManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Tabs
            Obx(() => Row(
              children: [
                _buildFilterTab(
                  'Active Posts',
                  isActive: controller.currentFilter.value == PostStatusFilter.active,
                  onTap: () => controller.changeFilter(PostStatusFilter.active),
                  dark: dark,
                ),
                const SizedBox(width: FSizes.sm),
                _buildFilterTab(
                  'Disabled Posts',
                  isActive: controller.currentFilter.value == PostStatusFilter.disabled,
                  onTap: () => controller.changeFilter(PostStatusFilter.disabled),
                  dark: dark,
                ),
              ],
            )),
            const SizedBox(height: FSizes.spaceBtwItems),

            // New posts notification
            Obx(() {
              if (controller.hasNewPosts.value) {
                return Container(
                  margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkInfo.withOpacity(0.1)
                        : FColors.adminLightInfo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    border: Border.all(
                      color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                        size: 20,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Text(
                          controller.newPostsMessage.value.isNotEmpty
                              ? controller.newPostsMessage.value
                              : 'Posts have been updated',
                          style: TextStyle(
                            color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: controller.refreshPosts,
                        icon: const Icon(Iconsax.refresh, size: 16),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.md,
                            vertical: FSizes.sm,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

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
                        hintText: 'Search by post ID, content, type, username, or email...',
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
                        child: CommunityDataTable(
                          posts: controller.paginatedPosts,
                          usersCache: controller.usersCache,
                          onSort: controller.sortPosts,
                          sortColumnIndex: controller.sortColumnIndex.value,
                          sortAscending: controller.sortAscending.value,
                          dark: dark,
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

  Widget _buildPagination(CommunityManagementController controller, bool dark) {
    // Calculate page numbers to show (up to 5 pages)
    int totalPages = controller.totalPages;
    int currentPage = controller.currentPage.value;

    if (totalPages == 0) totalPages = 1;

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
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalPosts} entries',
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
      ),
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

  void _showFilters(BuildContext context, CommunityManagementController controller, bool dark) {
    Get.dialog(
      CommunityFilterDialog(
        dark: dark,
        currentFilters: Map.from(controller.activeFilters),
        onApplyFilters: (filters) => controller.activeFilters.assignAll(filters),
      ),
      barrierDismissible: false,
    );
  }
}