import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../../event/models/event_enums.dart';
import '../../../../event/models/event_model.dart';
import '../../../controllers/event_management/event_management_controller.dart';
import '../add_event/add_event.dart';
import 'widgets/event_data_table.dart';

class EventManagementScreen extends StatelessWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Buttons Row
            Obx(() => Row(
              children: [
                _buildFilterTab(
                  'Published Events',
                  isActive: controller.publishFilter.value == EventPublishFilter.published,
                  onTap: () => controller.changeFilter(EventPublishFilter.published),
                  dark: dark,
                ),
                const SizedBox(width: FSizes.sm),
                _buildFilterTab(
                  'Unpublished Events',
                  isActive: controller.publishFilter.value == EventPublishFilter.unpublished,
                  onTap: () => controller.changeFilter(EventPublishFilter.unpublished),
                  dark: dark,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddEventScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                  ),
                  icon: const Icon(Iconsax.add, color: Colors.white),
                  label: const Text(
                    'Add Event',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )),
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
                      decoration: InputDecoration(
                        hintText: 'Search events by title, description, email, or ID...',
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

            // Show entries dropdown
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
            const SizedBox(height: FSizes.spaceBtwItems),

            // Data Table with Loading State
            Expanded(
              child: Container(
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
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                            ),
                          );
                        }

                        if (controller.paginatedEvents.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.calendar_remove,
                                  size: 64,
                                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                                const SizedBox(height: FSizes.md),
                                Text(
                                  'No events found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                  ),
                                ),
                                const SizedBox(height: FSizes.sm),
                                Text(
                                  controller.searchController.text.isNotEmpty || controller.hasActiveFilters
                                      ? 'Try adjusting your search or filters'
                                      : 'Start by adding your first event',
                                  style: TextStyle(
                                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return EventDataTable(
                          events: controller.paginatedEvents,
                          onSort: controller.sortEvents,
                          sortColumnIndex: controller.sortColumnIndex.value,
                          sortAscending: controller.sortAscending.value,
                          dark: dark,
                          controller: controller,
                        );
                      }),
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

  Widget _buildPagination(EventManagementController controller, bool dark) {
    int totalPages = (controller.totalEvents / controller.itemsPerPage.value).ceil();
    int currentPage = controller.currentPage.value;

    if (totalPages == 0) {
      return const SizedBox();
    }

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
          'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalEvents} entries',
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

class EventFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const EventFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<EventFilterDialog> createState() => _EventFilterDialogState();
}

class _EventFilterDialogState extends State<EventFilterDialog> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
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
                  'Filter Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            _buildFilterSection(
              'Event Status',
              DropdownButton<String?>(
                value: filters['status'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['status'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Status')),
                  const DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                  const DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                  const DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  const DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            _buildFilterSection(
              'Registration Status',
              DropdownButton<String?>(
                value: filters['registrationStatus'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['registrationStatus'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  const DropdownMenuItem(value: 'open', child: Text('Registration Open')),
                  const DropdownMenuItem(value: 'closed', child: Text('Registration Closed')),
                  const DropdownMenuItem(value: 'full', child: Text('Fully Booked')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            _buildFilterSection(
              'Date Range',
              DropdownButton<String?>(
                value: filters['dateRange'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['dateRange'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Time')),
                  const DropdownMenuItem(value: 'next7days', child: Text('Next 7 Days')),
                  const DropdownMenuItem(value: 'next30days', child: Text('Next 30 Days')),
                  const DropdownMenuItem(value: 'thisMonth', child: Text('This Month')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        filters = {
                          'status': null,
                          'registrationStatus': null,
                          'dateRange': null,
                        };
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
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
                      backgroundColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
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
          padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
          decoration: BoxDecoration(
            color: widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: content,
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
      ],
    );
  }
}