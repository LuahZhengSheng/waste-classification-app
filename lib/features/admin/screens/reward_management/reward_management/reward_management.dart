import 'package:flutter/material.dart';
import 'package:fyp/features/admin/screens/reward_management/add_reward/add_reward.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../controllers/reward_management/reward_management_controller.dart';
import 'widgets/reward_data_table.dart';

class RewardManagementScreen extends StatelessWidget {
  const RewardManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor:
          dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Tabs and Add Button Row
            Row(
              children: [
                // Status Filter Tabs
                Obx(() => Row(
                      children: [
                        _buildFilterTab(
                          'Active Rewards',
                          isActive:
                              controller.selectedStatusFilter.value == 'active',
                          onTap: () => controller.changeStatusFilter('active'),
                          dark: dark,
                        ),
                        const SizedBox(width: FSizes.sm),
                        _buildFilterTab(
                          'Inactive Rewards',
                          isActive: controller.selectedStatusFilter.value ==
                              'inactive',
                          onTap: () =>
                              controller.changeStatusFilter('inactive'),
                          dark: dark,
                        ),
                      ],
                    )),
                const Spacer(),
                // Add Reward Button
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => AddRewardScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.lg, vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                  ),
                  icon: const Icon(Iconsax.add, color: Colors.white),
                  label: const Text(
                    'Add Reward',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Search and Filter Row
            Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark
                          ? FColors.adminDarkSurface
                          : FColors.adminLightSurface,
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
                        hintText:
                            'Search rewards by title, description, or points...',
                        hintStyle: TextStyle(
                          color: dark
                              ? FColors.adminDarkTextMuted
                              : FColors.adminLightTextMuted,
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal_1,
                          color: dark
                              ? FColors.adminDarkTextMuted
                              : FColors.adminLightTextMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(FSizes.md),
                      ),
                      style: TextStyle(
                        color: dark
                            ? FColors.adminDarkText
                            : FColors.adminLightText,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: FSizes.md),

                // Filters Button
                Container(
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkSurface
                        : FColors.adminLightSurface,
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
                              color: dark
                                  ? FColors.adminDarkTextSecondary
                                  : FColors.adminLightTextSecondary,
                            ),
                            if (controller.hasActiveFilters)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? FColors.adminDarkPrimary
                                        : FColors.adminLightPrimary,
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

            // Show entries dropdown
            Row(
              children: [
                Text(
                  'Show',
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                    decoration: BoxDecoration(
                      color: dark
                          ? FColors.adminDarkSurface
                          : FColors.adminLightSurface,
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
                                    color: dark
                                        ? FColors.adminDarkText
                                        : FColors.adminLightText,
                                  ),
                                ),
                              ))
                          .toList(),
                      underline: const SizedBox(),
                      dropdownColor: dark
                          ? FColors.adminDarkSurface
                          : FColors.adminLightSurface,
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'entries',
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: FSizes.spaceBtwItems),

            // Data Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.adminDarkSurface
                      : FColors.adminLightSurface,
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
                    // Table
                    Expanded(
                      child: Obx(() => RewardDataTable(
                            rewards: controller.paginatedRewards,
                            onSort: controller.sortRewards,
                            sortColumnIndex: controller.sortColumnIndex.value,
                            sortAscending: controller.sortAscending.value,
                            dark: dark,
                            controller: controller,
                          )),
                    ),

                    // Pagination
                    Container(
                      padding: const EdgeInsets.all(FSizes.md),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: dark
                                ? FColors.adminDarkDivider
                                : FColors.adminLightDivider,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Obx(() => _buildPagination(controller, dark)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title,
      {required bool isActive,
      required VoidCallback onTap,
      required bool dark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: FSizes.lg, vertical: FSizes.md),
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
                : (dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Continuation of RewardManagementScreen class

Widget _buildPagination(RewardManagementController controller, bool dark) {
  int totalPages =
      (controller.totalRewards / controller.itemsPerPage.value).ceil();
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
        'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalRewards} entries',
        style: TextStyle(
          color: dark
              ? FColors.adminDarkTextSecondary
              : FColors.adminLightTextSecondary,
        ),
      ),
      Row(
        children: [
          _buildPaginationButton(
            icon: Iconsax.previous,
            onTap: controller.currentPage.value > 1
                ? () => controller.goToPage(1)
                : null,
            tooltip: 'First page',
            dark: dark,
          ),
          _buildPaginationButton(
            icon: Iconsax.arrow_left_2,
            onTap:
                controller.canGoPreviousPage ? controller.previousPage : null,
            tooltip: 'Previous page',
            dark: dark,
          ),
          const SizedBox(width: FSizes.sm),
          ...pageNumbers.map((pageNum) => GestureDetector(
                onTap: () => controller.goToPage(pageNum),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md, vertical: FSizes.sm),
                  decoration: BoxDecoration(
                    color: pageNum == currentPage
                        ? (dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                  ),
                  child: Text(
                    pageNum.toString(),
                    style: TextStyle(
                      color: pageNum == currentPage
                          ? Colors.white
                          : (dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText),
                      fontWeight: pageNum == currentPage
                          ? FontWeight.w600
                          : FontWeight.normal,
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
            onTap: controller.currentPage.value < totalPages
                ? () => controller.goToPage(totalPages)
                : null,
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

// Reward Filter Dialog
class RewardFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const RewardFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<RewardFilterDialog> createState() => _RewardFilterDialogState();
}

class _RewardFilterDialogState extends State<RewardFilterDialog> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Rewards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.dark
                        ? FColors.adminDarkText
                        : FColors.adminLightText,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: widget.dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Availability Filter
            _buildFilterSection(
              'Availability',
              DropdownButton<String?>(
                value: filters['availabilityStatus'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['availabilityStatus'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  const DropdownMenuItem(
                      value: 'available', child: Text('Available')),
                  const DropdownMenuItem(
                      value: 'out_of_stock', child: Text('Out of Stock')),
                  const DropdownMenuItem(
                      value: 'expired', child: Text('Expired')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark
                    ? FColors.adminDarkSurface
                    : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark
                      ? FColors.adminDarkText
                      : FColors.adminLightText,
                ),
              ),
            ),

            // Points Range Filter
            _buildFilterSection(
              'Points Range',
              DropdownButton<String?>(
                value: filters['pointsRange'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['pointsRange'] = value),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Points')),
                  const DropdownMenuItem(
                      value: 'low', child: Text('Low (≤ 500)')),
                  const DropdownMenuItem(
                      value: 'medium', child: Text('Medium (501-1000)')),
                  const DropdownMenuItem(
                      value: 'high', child: Text('High (> 1000)')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark
                    ? FColors.adminDarkSurface
                    : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark
                      ? FColors.adminDarkText
                      : FColors.adminLightText,
                ),
              ),
            ),

            // Quantity Range Filter
            _buildFilterSection(
              'Stock Level',
              DropdownButton<String?>(
                value: filters['quantityRange'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['quantityRange'] = value),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Levels')),
                  const DropdownMenuItem(
                      value: 'out_of_stock', child: Text('Out of Stock')),
                  const DropdownMenuItem(
                      value: 'low', child: Text('Low Stock (1-10)')),
                  const DropdownMenuItem(
                      value: 'medium', child: Text('Medium Stock (11-50)')),
                  const DropdownMenuItem(
                      value: 'high', child: Text('High Stock (> 50)')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark
                    ? FColors.adminDarkSurface
                    : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark
                      ? FColors.adminDarkText
                      : FColors.adminLightText,
                ),
              ),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        filters = {
                          'availabilityStatus': null,
                          'pointsRange': null,
                          'quantityRange': null,
                        };
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.dark
                            ? FColors.adminDarkBorder
                            : FColors.adminLightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: widget.dark
                            ? FColors.adminDarkTextSecondary
                            : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(filters);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md, vertical: FSizes.sm),
          decoration: BoxDecoration(
            color: widget.dark
                ? FColors.adminDarkSurfaceVariant
                : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: content,
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
      ],
    );
  }
}
