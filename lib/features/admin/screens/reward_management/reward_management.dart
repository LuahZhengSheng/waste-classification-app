import 'package:flutter/material.dart';
import 'package:fyp/features/admin/screens/reward_management/add_reward/add_reward.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../reward_redemption/models/reward_model.dart';
import '../../controllers/reward_management/reward_management_controller.dart';
import 'reward_detail/reward_detail.dart';

class RewardManagementScreen extends StatelessWidget {
  const RewardManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Add Reward Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => AddRewardScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                  ),
                  icon: const Icon(Iconsax.add, color: Colors.white),
                  label: const Text(
                    'Add Reward',
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
                        hintText: 'Search rewards by title, description, or points...',
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
                      child: Obx(() => AdminRewardDataTable(
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

  Widget _buildPagination(RewardManagementController controller, bool dark) {
    // Calculate page numbers to show (up to 5 pages)
    int totalPages = (controller.totalRewards / controller.itemsPerPage.value).ceil();
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
          'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalRewards} entries',
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

class AdminRewardDataTable extends StatefulWidget {
  final List<RewardModel> rewards;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final RewardManagementController controller;

  const AdminRewardDataTable({
    super.key,
    required this.rewards,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<AdminRewardDataTable> createState() => _AdminRewardDataTableState();
}

class _AdminRewardDataTableState extends State<AdminRewardDataTable> {
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
    return 1400.0; // Approximate total width including all columns
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
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 72,
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
              width: 180, // Fixed width for action column
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
                rows: widget.rewards
                    .map((reward) => DataRow(
                  cells: [_buildActionCell(reward)],
                  color: MaterialStateProperty.resolveWith(
                        (states) => states.contains(MaterialState.hovered)
                        ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                        : null,
                  ),
                ))
                    .toList(),
                dataRowMinHeight: 56,
                dataRowMaxHeight: 72,
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
      DataColumn(
        label: Text('Title', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(0, ascending),
      ),
      DataColumn(
        label: Text('Points', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(1, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Total Qty', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(2, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Remaining', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(3, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Redeemed', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(4, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Valid Until', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(5, ascending),
      ),
      DataColumn(
        label: Text('Created', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(6, ascending),
      ),
      DataColumn(
        label: Text('Status', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(7, ascending),
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
    return widget.rewards.map((reward) {
      final computedStatus = widget.controller.getRewardComputedStatus(reward);
      return DataRow(
        color: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.hovered)
              ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
              : null,
        ),
        cells: [
          DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    reward.title,
                    style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (reward.description.isNotEmpty)
                    Text(
                      reward.description,
                      style: _cellStyle().copyWith(
                        fontSize: 12,
                        color: widget.dark
                            ? FColors.adminDarkTextMuted
                            : FColors.adminLightTextMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                ],
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
              decoration: BoxDecoration(
                color: widget.dark
                    ? FColors.adminDarkPrimary.withOpacity(0.1)
                    : FColors.adminLightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
              ),
              child: Text(
                '${reward.pointsNeeded}',
                style: _cellStyle().copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                ),
              ),
            ),
          ),
          DataCell(Text(reward.quantity.toString(), style: _cellStyle())),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${reward.remainingQuantity}',
                  style: _cellStyle().copyWith(
                    color: reward.remainingQuantity == 0
                        ? (widget.dark ? FColors.adminDarkError : FColors.adminLightError)
                        : reward.remainingQuantity <= 10
                        ? (widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                        : null,
                    fontWeight: reward.remainingQuantity <= 10 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.dark
                        ? FColors.adminDarkBorder
                        : FColors.adminLightBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: reward.quantity > 0
                        ? (reward.remainingQuantity / reward.quantity).clamp(0.0, 1.0)
                        : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: reward.remainingQuantity == 0
                            ? (widget.dark ? FColors.adminDarkError : FColors.adminLightError)
                            : reward.remainingQuantity <= 10
                            ? (widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                            : (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            Text(
              reward.redemptionCount.toString(),
              style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_formatDateTime(reward.validUntil), style: _cellStyle()),
                if (reward.isExpired)
                  Text(
                    'Expired',
                    style: _cellStyle().copyWith(
                      color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          DataCell(Text(_formatDateTime(reward.createdAt), style: _cellStyle())),
          DataCell(_buildStatusChip(computedStatus, reward)),
          if (!_showFixedActionColumn) _buildActionCell(reward),
        ],
      );
    }).toList();
  }

  Widget _buildStatusChip(String status, RewardModel reward) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;

    switch (status) {
      case 'active':
        backgroundColor = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Active';
        break;
      case 'inactive':
        backgroundColor = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = 'Inactive';
        break;
      case 'expired':
        backgroundColor = widget.dark ? FColors.adminDarkError : FColors.adminLightError;
        displayText = 'Expired';
        break;
      case 'out_of_stock':
        backgroundColor = widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        displayText = 'Out of Stock';
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

  DataCell _buildActionCell(RewardModel reward) {
    final computedStatus = widget.controller.getRewardComputedStatus(reward);

    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View button - always available
          IconButton(
            onPressed: () => Get.to(() => AdminRewardDetailScreen(reward: reward)),
            icon: Icon(
              Iconsax.eye,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'View Reward Details',
          ),

          // Edit button - always available except for deleted
          if (computedStatus != 'deleted')
            IconButton(
              onPressed: () => widget.controller.editReward(reward),
              icon: Icon(
                Iconsax.edit,
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'Edit Reward',
            ),

          // Activate/Deactivate toggle
          if (computedStatus != 'deleted')
            IconButton(
              onPressed: () => _showActivationConfirmation(reward),
              icon: Icon(
                reward.status == 'active' ? Iconsax.pause_circle : Iconsax.play_circle,
                color: reward.status == 'active'
                    ? (widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                    : (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                size: 18,
              ),
              tooltip: reward.status == 'active' ? 'Deactivate Reward' : 'Activate Reward',
            ),

          // Delete button - only for inactive or expired rewards
          if (reward.status == 'inactive' || computedStatus == 'expired')
            IconButton(
              onPressed: () => _showDeleteConfirmation(reward),
              icon: Icon(
                Iconsax.trash,
                color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
                size: 18,
              ),
              tooltip: 'Delete Reward',
            ),
        ],
      ),
    );
  }

  void _showActivationConfirmation(RewardModel reward) {
    final isActivating = reward.status != 'active';

    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          isActivating ? 'Activate Reward' : 'Deactivate Reward',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          isActivating
              ? 'Are you sure you want to activate "${reward.title}"? It will be available for users to redeem.'
              : 'Are you sure you want to deactivate "${reward.title}"? Users will no longer be able to redeem this reward.',
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
              widget.controller.toggleRewardStatus(reward);
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

  void _showDeleteConfirmation(RewardModel reward) {
    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Delete Reward',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${reward.title}"? This action cannot be undone and all associated redemption data will be lost.',
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
              widget.controller.deleteReward(reward);
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
                  'Filter Rewards',
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

            // Status Filter
            _buildFilterSection(
              'Status',
              DropdownButton<String?>(
                value: filters['status'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['status'] = value),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Status')),
                  const DropdownMenuItem(
                      value: 'active', child: Text('Active')),
                  const DropdownMenuItem(
                      value: 'inactive', child: Text('Inactive')),
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
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors
                    .adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors
                      .adminLightText,
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
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors
                    .adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors
                      .adminLightText,
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
                          'availabilityStatus': null,
                          'pointsRange': null,
                          'quantityRange': null,
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
          padding: const EdgeInsets.symmetric(horizontal: FSizes.md,
              vertical: FSizes.sm),
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