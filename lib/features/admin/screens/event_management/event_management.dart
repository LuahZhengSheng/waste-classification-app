import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../event/models/event_model.dart';
import '../../controllers/event_management/event_management_controller.dart';
import 'add_event/add_event.dart';

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
            // Header with Add Event Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                        hintText: 'Search events by title, description, or contact email...',
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
                      child: Obx(() => AdminEventDataTable(
                        events: controller.paginatedEvents,
                        onSort: controller.sortEvents,
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

  Widget _buildPagination(EventManagementController controller, bool dark) {
    // Calculate page numbers to show (up to 5 pages)
    int totalPages = (controller.totalEvents / controller.itemsPerPage.value).ceil();
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
          'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalEvents} entries',
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

class AdminEventDataTable extends StatefulWidget {
  final List<Event> events;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final EventManagementController controller;

  const AdminEventDataTable({
    super.key,
    required this.events,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<AdminEventDataTable> createState() => _AdminEventDataTableState();
}

class _AdminEventDataTableState extends State<AdminEventDataTable> {
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
    return 1200.0; // Approximate total width including all columns
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
              width: 160, // Fixed width for action column
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
                rows: widget.events
                    .map((event) => DataRow(cells: [_buildActionCell(event)]))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Text('Title', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(0, ascending),
      ),
      DataColumn(
        label: Text('Start Date', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(2, ascending),
      ),
      DataColumn(
        label: Text('End Date', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(3, ascending),
      ),
      DataColumn(
        label: Text('Registration Deadline', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(4, ascending),
      ),
      DataColumn(
        label: Text('Max Participants', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(5, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Registered', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(6, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Published', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(7, ascending),
      ),
      DataColumn(
        label: Text('Status', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(1, ascending),
      ),
      if (!_showFixedActionColumn) _buildActionColumn(),
    ];
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: Text('Actions', style: _headerStyle()),
    );
  }

  List<DataRow> _buildRows() {
    return widget.events.map((event) {
      final computedStatus = widget.controller.getEventComputedStatus(event);
      return DataRow(
        cells: [
          DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                event.title,
                style: _cellStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          DataCell(Text(_formatDateTime(event.startDateTime), style: _cellStyle())),
          DataCell(Text(_formatDateTime(event.endDateTime), style: _cellStyle())),
          DataCell(Text(_formatDateTime(event.registrationDeadline), style: _cellStyle())),
          DataCell(Text(event.maxParticipants.toString(), style: _cellStyle())),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${event.registeredCount}', style: _cellStyle()),
                const SizedBox(width: 4),
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.dark
                        ? FColors.adminDarkBorder
                        : FColors.adminLightBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: event.registrationProgress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          DataCell(_buildPublishedChip(event.isPublish)),
          DataCell(_buildStatusChip(computedStatus)),
          if (!_showFixedActionColumn) _buildActionCell(event),
        ],
      );
    }).toList();
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;

    switch (status) {
      case 'upcoming':
        backgroundColor = widget.dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        displayText = 'Upcoming';
        break;
      case 'ongoing':
        backgroundColor = widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        displayText = 'Ongoing';
        break;
      case 'completed':
        backgroundColor = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = widget.dark ? FColors.adminDarkError : FColors.adminLightError;
        displayText = 'Cancelled';
        break;
      case 'deleted':
        backgroundColor = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = 'Deleted';
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

  Widget _buildPublishedChip(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: isPublished
            ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
            : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        isPublished ? 'Published' : 'Draft',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  DataCell _buildActionCell(Event event) {
    final computedStatus = widget.controller.getEventComputedStatus(event);

    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View button - always available
          IconButton(
            onPressed: () => widget.controller.viewEvent(event.eventId),
            icon: Icon(
              Iconsax.eye,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'View Event',
          ),

          // Edit button - disabled for ongoing events
          IconButton(
            onPressed: computedStatus != 'ongoing'
                ? () => widget.controller.editEvent(event)
                : null,
            icon: Icon(
              Iconsax.edit,
              color: computedStatus != 'ongoing'
                  ? (widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary)
                  : (widget.dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted),
              size: 18,
            ),
            tooltip: computedStatus == 'ongoing' ? 'Cannot edit ongoing event' : 'Edit Event',
          ),

          // Publish/Unpublish toggle - only for upcoming events
          if (computedStatus == 'upcoming')
            IconButton(
              onPressed: () => widget.controller.togglePublishStatus(event),
              icon: Icon(
                event.isPublish ? Iconsax.eye_slash : Iconsax.eye,
                color: event.isPublish
                    ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                    : (widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                size: 18,
              ),
              tooltip: event.isPublish ? 'Unpublish Event' : 'Publish Event',
            ),

          // Cancel button - only for upcoming events
          if (computedStatus == 'upcoming' && event.status != 'cancelled')
            IconButton(
              onPressed: () => _showCancelConfirmation(event),
              icon: Icon(
                Iconsax.close_circle,
                color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
                size: 18,
              ),
              tooltip: 'Cancel Event',
            ),

          // Delete button - only for completed and cancelled events
          if ((computedStatus == 'completed' || event.status == 'cancelled') && event.status != 'deleted')
            IconButton(
              onPressed: () => _showDeleteConfirmation(event),
              icon: Icon(
                Iconsax.trash,
                color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
                size: 18,
              ),
              tooltip: 'Delete Event',
            ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(Event event) {
    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Cancel Event',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel "${event.title}"? This action cannot be undone.',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'No, Keep Event',
              style: TextStyle(
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.cancelEvent(event);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
            ),
            child: const Text(
              'Yes, Cancel Event',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Event event) {
    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Delete Event',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
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
              widget.controller.deleteEvent(event);
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
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)}, ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
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
      backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors
          .adminLightSurface,
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
                  'Filter Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.dark ? FColors.adminDarkText : FColors
                        .adminLightText,
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

            // Event Status Filter
            _buildFilterSection(
              'Event Status',
              DropdownButton<String?>(
                value: filters['status'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['status'] = value),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Status')),
                  const DropdownMenuItem(
                      value: 'upcoming', child: Text('Upcoming')),
                  const DropdownMenuItem(
                      value: 'ongoing', child: Text('Ongoing')),
                  const DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                  const DropdownMenuItem(
                      value: 'cancelled', child: Text('Cancelled')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors
                    .adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors
                      .adminLightText,
                ),
              ),
            ),

            // Published Status Filter
            _buildFilterSection(
              'Published Status',
              DropdownButton<bool?>(
                value: filters['isPublished'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['isPublished'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  const DropdownMenuItem(value: true, child: Text('Published')),
                  const DropdownMenuItem(value: false, child: Text('Draft')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors
                    .adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors
                      .adminLightText,
                ),
              ),
            ),

            // Registration Status Filter
            _buildFilterSection(
              'Registration Status',
              DropdownButton<String?>(
                value: filters['registrationStatus'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['registrationStatus'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  const DropdownMenuItem(
                      value: 'open', child: Text('Registration Open')),
                  const DropdownMenuItem(
                      value: 'closed', child: Text('Registration Closed')),
                  const DropdownMenuItem(
                      value: 'full', child: Text('Fully Booked')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors
                    .adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors
                      .adminLightText,
                ),
              ),
            ),

            // Date Range Filter
            _buildFilterSection(
              'Date Range',
              DropdownButton<String?>(
                value: filters['dateRange'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['dateRange'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Time')),
                  const DropdownMenuItem(
                      value: 'next7days', child: Text('Next 7 Days')),
                  const DropdownMenuItem(
                      value: 'next30days', child: Text('Next 30 Days')),
                  const DropdownMenuItem(
                      value: 'thisMonth', child: Text('This Month')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors
                    .adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors
                      .adminLightText,
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
                          'isPublished': null,
                          'registrationStatus': null,
                          'dateRange': null,
                        };
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.dark ? FColors.adminDarkBorder : FColors
                            .adminLightBorder,
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