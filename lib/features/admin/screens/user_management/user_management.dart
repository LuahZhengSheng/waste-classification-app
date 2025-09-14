import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/user_management_controller.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation Tabs
            Row(
              children: [
                _buildNavButton(
                  'Active Users',
                  isActive: true,
                  onTap: () {},
                  dark: dark,
                ),
                const SizedBox(width: FSizes.sm),
                _buildNavButton(
                  'Banned Users',
                  isActive: false,
                  onTap: () {},
                  dark: dark,
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
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
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
                    border: Border.all(
                      color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    ),
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
                const SizedBox(width: FSizes.md),
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
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
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
                  border: Border.all(
                    color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    // Table
                    Expanded(
                      child: Obx(() => AdminUserDataTable(
                        users: controller.paginatedUsers,
                        onSort: controller.sortUsers,
                        sortColumnIndex: controller.sortColumnIndex.value,
                        sortAscending: controller.sortAscending.value,
                        dark: dark,
                      )),
                    ),

                    // Pagination
                    Container(
                      padding: const EdgeInsets.all(FSizes.md),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
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

  Widget _buildNavButton(String title, {required bool isActive, required VoidCallback onTap, required bool dark}) {
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

  Widget _buildPagination(UserManagementController controller, bool dark) {
    // Calculate page numbers to show (up to 5 pages)
    int totalPages = (controller.totalUsers / controller.itemsPerPage.value).ceil();
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
          'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalUsers} entries',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        Row(
          children: [
            // First page button
            IconButton(
              onPressed: controller.currentPage.value > 1
                  ? () => controller.goToPage(1)
                  : null,
              icon: Icon(
                Iconsax.previous,
                color: controller.currentPage.value > 1
                    ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                    : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
              ),
              tooltip: 'First page',
            ),

            // Previous page button
            IconButton(
              onPressed: controller.canGoPreviousPage ? controller.previousPage : null,
              icon: Icon(
                Iconsax.arrow_left_2,
                color: controller.canGoPreviousPage
                    ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                    : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
              ),
              tooltip: 'Previous page',
            ),

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

            // Next page button
            IconButton(
              onPressed: controller.canGoNextPage ? controller.nextPage : null,
              icon: Icon(
                Iconsax.arrow_right_3,
                color: controller.canGoNextPage
                    ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                    : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
              ),
              tooltip: 'Next page',
            ),

            // Last page button
            IconButton(
              onPressed: controller.currentPage.value < totalPages
                  ? () => controller.goToPage(totalPages)
                  : null,
              icon: Icon(
                Iconsax.next,
                color: controller.currentPage.value < totalPages
                    ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                    : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
              ),
              tooltip: 'Last page',
            ),
          ],
        ),
      ],
    );
  }
}

class AdminUserDataTable extends StatefulWidget {
  final List<UserModel> users;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;

  const AdminUserDataTable({
    super.key,
    required this.users,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
  });

  @override
  State<AdminUserDataTable> createState() => _AdminUserDataTableState();
}

class _AdminUserDataTableState extends State<AdminUserDataTable> {
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
    // Approximate column widths
    const double usernameWidth = 150;
    const double emailWidth = 200;
    const double phoneWidth = 150;
    const double genderWidth = 100;
    const double joinDateWidth = 150;
    const double pointsWidth = 100;
    const double verifiedWidth = 120;
    const double loginAttemptsWidth = 140;
    const double actionsWidth = 120;

    return usernameWidth + emailWidth + phoneWidth + genderWidth +
        joinDateWidth + pointsWidth + verifiedWidth + loginAttemptsWidth + actionsWidth;
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
        // Main scrollable table with scrollbars
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
              width: 120, // Fixed width for action column
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
                rows: widget.users
                    .map((user) => DataRow(cells: [_buildActionCell(user)]))
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
        label: Row(
          children: [
            Text('Username', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(0),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(0, ascending),
      ),
      DataColumn(
        label: Row(
          children: [
            Text('Email', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(1),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(1, ascending),
      ),
      DataColumn(
        label: Row(
          children: [
            Text('Phone', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(2),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(2, ascending),
      ),
      DataColumn(
        label: Row(
          children: [
            Text('Gender', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(3),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(3, ascending),
      ),
      DataColumn(
        label: Row(
          children: [
            Text('Join Date', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(4),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(4, ascending),
      ),
      DataColumn(
        label: Row(
          children: [
            Text('Points', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(5),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(5, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Row(
          children: [
            Text('Verified', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(6),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(6, ascending),
      ),
      DataColumn(
        label: Row(
          children: [
            Text('Login Attempts', style: _headerStyle()),
            const SizedBox(width: 4),
            // _buildSortIcon(7),
          ],
        ),
        onSort: (columnIndex, ascending) => widget.onSort(7, ascending),
        numeric: true,
      ),
      if (!_showFixedActionColumn) _buildActionColumn(),
    ];
  }

  Widget _buildSortIcon(int columnIndex) {
    if (widget.sortColumnIndex == columnIndex) {
      return Icon(
        widget.sortAscending ? Iconsax.arrow_up_3 : Iconsax.arrow_down_1,
        size: 16,
        color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
      );
    } else {
      return Icon(
        Iconsax.airplane,
        size: 16,
        color: widget.dark
            ? FColors.adminDarkTextMuted
            : FColors.adminLightTextMuted,
      );
    }
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: Text('Actions', style: _headerStyle()),
    );
  }

  List<DataRow> _buildRows() {
    return widget.users.map((user) {
      return DataRow(
        cells: [
          DataCell(Text(user.username, style: _cellStyle())),
          DataCell(Text(user.email, style: _cellStyle())),
          DataCell(Text(user.phoneNo ?? 'N/A', style: _cellStyle())),
          DataCell(Text(user.gender ?? 'N/A', style: _cellStyle())),
          DataCell(Text(_formatDate(user.joinDate), style: _cellStyle())),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
              decoration: BoxDecoration(
                color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
              ),
              child: Text(
                user.rewardPoint.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
              decoration: BoxDecoration(
                color: user.isVerified
                    ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                    : (widget.dark ? FColors.adminDarkError : FColors.adminLightError),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
              ),
              child: Text(
                user.isVerified ? 'Verified' : 'Unverified',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(Text(user.loginAttemptCount.toString(), style: _cellStyle())),
          if (!_showFixedActionColumn) _buildActionCell(user),
        ],
      );
    }).toList();
  }

  DataCell _buildActionCell(UserModel user) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _viewUser(user),
            icon: Icon(
              Iconsax.eye,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'View User',
          ),
          IconButton(
            onPressed: () => _editUser(user),
            icon: Icon(
              Iconsax.edit,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'Edit User',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _viewUser(UserModel user) {
    // Implement view user functionality
    print('View user: ${user.username}');
  }

  void _editUser(UserModel user) {
    // Implement edit user functionality
    print('Edit user: ${user.username}');
  }
}

class FilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterDialog> createState() {
    return _FilterDialogState();
  }
}

class _FilterDialogState extends State<FilterDialog> {
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
                  'Filter Users',
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

            // Gender Filter
            _buildFilterSection(
              'Gender',
              DropdownButton<String?>(
                value: filters['gender'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['gender'] = value),
                items: [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // Join Date Filter
            _buildFilterSection(
              'Join Date Range',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String?>(
                          value: filters['joinDateRange'],
                          isExpanded: true,
                          onChanged: (value) => setState(() => filters['joinDateRange'] = value),
                          items: [
                            DropdownMenuItem(value: null, child: Text('All Time')),
                            DropdownMenuItem(value: 'last7days', child: Text('Last 7 Days')),
                            DropdownMenuItem(value: 'last30days', child: Text('Last 30 Days')),
                            DropdownMenuItem(value: 'last90days', child: Text('Last 90 Days')),
                            DropdownMenuItem(value: 'thisYear', child: Text('This Year')),
                          ],
                          underline: const SizedBox(),
                          dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                          style: TextStyle(
                            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Verification Status Filter
            _buildFilterSection(
              'Verification Status',
              DropdownButton<bool?>(
                value: filters['isVerified'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['isVerified'] = value),
                items: [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: true, child: Text('Verified')),
                  DropdownMenuItem(value: false, child: Text('Unverified')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // Active Status Filter
            _buildFilterSection(
              'Account Status',
              DropdownButton<bool?>(
                value: filters['isActive'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['isActive'] = value),
                items: [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: true, child: Text('Active')),
                  DropdownMenuItem(value: false, child: Text('Inactive')),
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
                          'gender': null,
                          'joinDateRange': null,
                          'isVerified': null,
                          'isActive': null,
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
            border: Border.all(
              color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: content,
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
      ],
    );
  }
}

