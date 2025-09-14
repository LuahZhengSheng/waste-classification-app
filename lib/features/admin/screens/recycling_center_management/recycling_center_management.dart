import 'package:flutter/material.dart';
import 'package:fyp/features/admin/screens/recycling_center_management/recycling_center_detail/recycling_center_detail.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../recycling_center/models/partner_recycling_center_model.dart';
import '../../controllers/recycling_center_management/recycling_center_management_controller.dart';

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
            // Header with Add Center and Batch Delete Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Batch Delete Button (only visible when items are selected)
                Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: controller.selectedCenterIds.isNotEmpty
                      ? ElevatedButton.icon(
                    key: const ValueKey('batchDelete'),
                    onPressed: () => _showBatchDeleteConfirmation(controller, dark),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
                      padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                      ),
                    ),
                    icon: const Icon(Iconsax.trash, color: Colors.white),
                    label: Text(
                      'Delete Selected (${controller.selectedCenterIds.length})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                )),

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
                    'Add Recycling Center',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

                // Filters Button
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

            // Show entries dropdown and results info
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
                    Obx(
                          () => Container(
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
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Text(
                      'entries',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ],
                ),

                // Results info
                Obx(() => Text(
                  'Total: ${controller.totalCenters} partner centers',
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
                    // Table
                    Expanded(
                      child: Obx(() => AdminPartnerCenterDataTable(
                        centers: controller.paginatedCenters,
                        onSort: controller.sortCenters,
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

  void _showBatchDeleteConfirmation(PartnerCenterManagementController controller, bool dark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Delete Partner Centers',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${controller.selectedCenterIds.length} partner centers? This action cannot be undone and all associated staff will be deactivated.',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.batchDeleteCenters();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
            ),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(PartnerCenterManagementController controller, bool dark) {
    // Calculate page numbers to show (up to 5 pages)
    int totalPages = (controller.totalCenters / controller.itemsPerPage.value).ceil();
    int currentPage = controller.currentPage.value;

    List<int> pageNumbers = [];

    if (totalPages <= 5) {
      // Show all pages if total pages <= 5
      pageNumbers = List.generate(totalPages, (index) => index + 1);
    } else {
      // Show 5 pages centered around current page
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
            // First page button
            _buildPaginationButton(
              icon: Iconsax.previous,
              onTap: controller.currentPage.value > 1 ? () => controller.goToPage(1) : null,
              tooltip: 'First page',
              dark: dark,
            ),

            // Previous page button
            _buildPaginationButton(
              icon: Iconsax.arrow_left_2,
              onTap: controller.canGoPreviousPage ? controller.previousPage : null,
              tooltip: 'Previous page',
              dark: dark,
            ),

            const SizedBox(width: FSizes.sm),

            // Page numbers
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

            // Next page button
            _buildPaginationButton(
              icon: Iconsax.arrow_right_3,
              onTap: controller.canGoNextPage ? controller.nextPage : null,
              tooltip: 'Next page',
              dark: dark,
            ),

            // Last page button
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

// Data Table Component
class AdminPartnerCenterDataTable extends StatefulWidget {
  final List<PartnerRecyclingCenter> centers;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final PartnerCenterManagementController controller;

  const AdminPartnerCenterDataTable({
    super.key,
    required this.centers,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<AdminPartnerCenterDataTable> createState() => _AdminPartnerCenterDataTableState();
}

class _AdminPartnerCenterDataTableState extends State<AdminPartnerCenterDataTable> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _showFixedActionColumn = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfActionColumnShouldBeFixed());
  }

  void _onScroll() {
    _checkIfActionColumnShouldBeFixed();
  }

  void _checkIfActionColumnShouldBeFixed() {
    if (!mounted) return;

    final screenWidth = MediaQuery.of(context).size.width - (FSizes.lg * 2);
    final tableWidth = _calculateTableWidth();
    final hasHorizontalScroll = tableWidth > screenWidth;
    final isScrolledRight = _horizontalScrollController.offset > 0;

    final shouldShowFixed = hasHorizontalScroll && isScrolledRight;

    if (shouldShowFixed != _showFixedActionColumn) {
      setState(() {
        _showFixedActionColumn = shouldShowFixed;
      });
    }
  }

  double _calculateTableWidth() {
    return 1600.0; // Approximate total width including all columns
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main scrollable table
        Scrollbar(
          controller: _verticalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - (FSizes.lg * 2),
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      widget.dark
                          ? FColors.adminDarkSurfaceVariant
                          : FColors.adminLightSurfaceVariant,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.hovered)
                          ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                          : null,
                    ),
                    sortColumnIndex: widget.sortColumnIndex,
                    sortAscending: widget.sortAscending,
                    columns: _buildColumns(),
                    rows: _buildRows(),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 80,
                    dividerThickness: 0.5,
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: (widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Fixed action column with shadow
        if (_showFixedActionColumn)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 200, // Fixed width for action column
              decoration: BoxDecoration(
                color: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(-5, 0),
                  ),
                ],
                border: Border(
                  left: BorderSide(
                    color: widget.dark
                        ? FColors.adminDarkBorder.withOpacity(0.5)
                        : FColors.adminLightBorder.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  widget.dark
                      ? FColors.adminDarkSurfaceVariant
                      : FColors.adminLightSurfaceVariant,
                ),
                dataRowColor: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.hovered)
                      ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                      : null,
                ),
                columns: [_buildActionColumn()],
                rows: widget.centers
                    .map((center) => DataRow(
                  cells: [_buildActionCell(center)],
                  color: MaterialStateProperty.resolveWith(
                        (states) => states.contains(MaterialState.hovered)
                        ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                        : null,
                  ),
                ))
                    .toList(),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 80,
                dividerThickness: 0.5,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: (widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider).withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      // Selection checkbox column
      DataColumn(
        label: Obx(() => Checkbox(
          value: widget.controller.isSelectAllChecked.value,
          onChanged: (_) => widget.controller.toggleSelectAll(),
          activeColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
        )),
      ),
      DataColumn(
        label: Text('Image', style: _headerStyle()),
      ),
      DataColumn(
        label: Text('Name', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(0, ascending),
      ),
      DataColumn(
        label: Text('Contact Info', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(1, ascending),
      ),
      DataColumn(
        label: Text('Location', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(3, ascending),
      ),
      DataColumn(
        label: Text('Staff Count', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(5, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Created Date', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(6, ascending),
      ),
      // DataColumn(
      //   label: Text('Status', style: _headerStyle()),
      //   onSort: (columnIndex, ascending) => widget.onSort(7, ascending),
      // ),
      if (!_showFixedActionColumn) _buildActionColumn(),
    ];
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: Text('Actions', style: _headerStyle()),
    );
  }

  List<DataRow> _buildRows() {
    return widget.centers.map((center) {
      final isSelected = widget.controller.selectedCenterIds.contains(center.centerId);

      return DataRow(
        selected: isSelected,
        color: MaterialStateProperty.resolveWith(
              (states) {
            if (states.contains(MaterialState.selected)) {
              return (widget.dark ? FColors.adminDarkSelected : FColors.adminLightSelected);
            }
            if (states.contains(MaterialState.hovered)) {
              return (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover);
            }
            return null;
          },
        ),
        cells: [
          // Selection checkbox
          DataCell(
            Checkbox(
              value: isSelected,
              onChanged: (_) => widget.controller.toggleCenterSelection(center.centerId),
              activeColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
          ),
          // Image
          DataCell(_buildImageCell(center)),
          // Name with website
          DataCell(_buildNameCell(center)),
          // Contact info (Email & Phone)
          DataCell(_buildContactCell(center)),
          // Location
          DataCell(_buildLocationCell(center)),
          // Staff count
          DataCell(_buildStaffCountCell(center)),
          // Created date
          DataCell(Text(_formatDateTime(center.createdAt), style: _cellStyle())),
          // Status
          // DataCell(_buildStatusChip(center.status)),
          // Actions
          if (!_showFixedActionColumn) _buildActionCell(center),
        ],
      );
    }).toList();
  }

  Widget _buildImageCell(PartnerRecyclingCenter center) {
    return GestureDetector(
      onTap: () => _showImageDialog(center.image, center.name),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
          border: Border.all(
            color: widget.dark
                ? FColors.adminDarkBorder.withOpacity(0.3)
                : FColors.adminLightBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
          child: Image.network(
            center.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: widget.dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              child: Icon(
                Iconsax.image,
                color: widget.dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
                size: 20,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: widget.dark
                    ? FColors.adminDarkSurfaceVariant
                    : FColors.adminLightSurfaceVariant,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl, String centerName) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(Get.context!).size.width * 0.8,
                    maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        width: 300,
                        color: widget.dark
                            ? FColors.adminDarkSurfaceVariant
                            : FColors.adminLightSurfaceVariant,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.image,
                                color: widget.dark
                                    ? FColors.adminDarkTextMuted
                                    : FColors.adminLightTextMuted,
                                size: 48,
                              ),
                              const SizedBox(height: FSizes.sm),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: widget.dark
                                      ? FColors.adminDarkTextMuted
                                      : FColors.adminLightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FSizes.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.lg,
                    vertical: FSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: widget.dark
                        ? FColors.adminDarkSurface
                        : FColors.adminLightSurface,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  ),
                  child: Text(
                    centerName,
                    style: TextStyle(
                      color: widget.dark
                          ? FColors.adminDarkText
                          : FColors.adminLightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameCell(PartnerRecyclingCenter center) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            center.name,
            style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () => _launchUrl(center.website),
            child: Text(
              center.website,
              style: _cellStyle().copyWith(
                fontSize: 12,
                color: widget.dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCell(PartnerRecyclingCenter center) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            center.email,
            style: _cellStyle().copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            center.formattedPhoneNo,
            style: _cellStyle().copyWith(
              fontSize: 12,
              color: widget.dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCell(PartnerRecyclingCenter center) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${center.centerLocation.address.city}, ${center.centerLocation.address.state}',
            style: _cellStyle().copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            center.centerLocation.address.area,
            style: _cellStyle().copyWith(
              fontSize: 12,
              color: widget.dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCountCell(PartnerRecyclingCenter center) {
    Color staffCountColor;
    if (center.numberOfStaff <= 5) {
      staffCountColor = widget.dark ? FColors.adminDarkError : FColors.adminLightError;
    } else if (center.numberOfStaff <= 15) {
      staffCountColor = widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
    } else {
      staffCountColor = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: staffCountColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        center.numberOfStaff.toString(),
        style: _cellStyle().copyWith(
          fontWeight: FontWeight.w600,
          color: staffCountColor,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;

    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Active';
        break;
      case 'inactive':
        backgroundColor = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = 'Inactive';
        break;
      default:
        backgroundColor = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
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
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  DataCell _buildActionCell(PartnerRecyclingCenter center) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View button
          IconButton(
            onPressed: () => widget.controller.viewCenter(center),
            icon: Icon(
              Iconsax.eye,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'View Center Details',
          ),

          // Edit button
          IconButton(
            onPressed: () => widget.controller.editCenter(center),
            icon: Icon(
              Iconsax.edit,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'Edit Center',
          ),

          // Activate/Deactivate toggle
          // IconButton(
          //   onPressed: () => _showStatusToggleConfirmation(center),
          //   icon: Icon(
          //     center.status == 'active' ? Iconsax.pause_circle : Iconsax.play_circle,
          //     color: center.status == 'active'
          //         ? (widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
          //         : (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
          //     size: 18,
          //   ),
          //   tooltip: center.status == 'active' ? 'Deactivate Center' : 'Activate Center',
          // ),

          // Delete button
          IconButton(
            onPressed: () => _showDeleteConfirmation(center),
            icon: Icon(
              Iconsax.trash,
              color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
              size: 18,
            ),
            tooltip: 'Delete Center',
          ),
        ],
      ),
    );
  }

  void _showStatusToggleConfirmation(PartnerRecyclingCenter center) {
    final isActivating = center.status != 'active';

    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          isActivating ? 'Activate Partner Center' : 'Deactivate Partner Center',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          isActivating
              ? 'Are you sure you want to activate "${center.name}"? It will be available for operations.'
              : 'Are you sure you want to deactivate "${center.name}"? This will also deactivate all associated staff.',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.toggleCenterStatus(center);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActivating
                  ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                  : (widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning),
            ),
            child: Text(
              isActivating ? 'Activate' : 'Deactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(PartnerRecyclingCenter center) {
    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Delete Partner Center',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${center.name}"? This action cannot be undone and all associated staff will be deactivated.',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.deleteCenter(center);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) {
    // Implementation for launching URL - you can use url_launcher package
    print('Launch URL: $url');
  }

  TextStyle _headerStyle() {
    return TextStyle(
      color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
  }

  TextStyle _cellStyle() {
    return TextStyle(
      color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
      fontSize: 14,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)}, ${dateTime.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// Filter Dialog Component
class PartnerCenterFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final List<String> availableCities;
  final List<String> availableStates;
  final Function(Map<String, dynamic>) onApplyFilters;

  const PartnerCenterFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.availableCities,
    required this.availableStates,
    required this.onApplyFilters,
  });

  @override
  State<PartnerCenterFilterDialog> createState() => _PartnerCenterFilterDialogState();
}

class _PartnerCenterFilterDialogState extends State<PartnerCenterFilterDialog> {
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Partner Centers',
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
                    color: widget.dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Status Filter
            _buildFilterSection(
              'Status',
              DropdownButton<String?>(
                value: filters['status'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['status'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Status')),
                  const DropdownMenuItem(value: 'active', child: Text('Active')),
                  const DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // Staff Range Filter
            _buildFilterSection(
              'Staff Size',
              DropdownButton<String?>(
                value: filters['staffRange'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['staffRange'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Sizes')),
                  const DropdownMenuItem(value: 'small', child: Text('Small (≤ 10 staff)')),
                  const DropdownMenuItem(value: 'medium', child: Text('Medium (11-30 staff)')),
                  const DropdownMenuItem(value: 'large', child: Text('Large (> 30 staff)')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // City Filter
            _buildFilterSection(
              'City',
              DropdownButton<String?>(
                value: filters['city'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['city'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Cities')),
                  ...widget.availableCities.map(
                        (city) => DropdownMenuItem(value: city, child: Text(city)),
                  ),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // State Filter
            _buildFilterSection(
              'State',
              DropdownButton<String?>(
                value: filters['state'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['state'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All States')),
                  ...widget.availableStates.map(
                        (state) => DropdownMenuItem(value: state, child: Text(state)),
                  ),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
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
                          'status': null,
                          'staffRange': null,
                          'city': null,
                          'state': null,
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
          padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
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