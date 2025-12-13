import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/widgets/admin/badge.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/popups/admin_loaders.dart';
import '../../../../../leaderboard_achievement/models/achievement_model.dart';
import '../../../../controllers/achievement_management/achievement_management_controller.dart';
import '../../achievement_management_detail/achievement_management_detail.dart';

class AchievementDataTable extends StatefulWidget {
  final List<Achievement> achievements;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final AchievementManagementController controller;

  const AchievementDataTable({
    super.key,
    required this.achievements,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<AchievementDataTable> createState() => _AdminAchievementDataTableState();
}

class _AdminAchievementDataTableState extends State<AchievementDataTable> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _fixedColumnVerticalController = ScrollController();
  bool _showFixedActionColumn = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_onScroll);
    _verticalScrollController.addListener(_syncFixedColumnScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfActionColumnShouldBeFixed());
  }

  void _syncFixedColumnScroll() {
    if (_fixedColumnVerticalController.hasClients && _verticalScrollController.hasClients) {
      _fixedColumnVerticalController.jumpTo(_verticalScrollController.offset);
    }
  }

  void _onScroll() {
    _checkIfActionColumnShouldBeFixed();
  }

  void _checkIfActionColumnShouldBeFixed() {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width - (FSizes.lg * 18);
    final tableWidth = _calculateTableWidth();
    print('screenwidth: $screenWidth, tablewidth: $tableWidth');
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
    return 200 + 200 + 150 + 120 + 180 + 120 + 180;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _fixedColumnVerticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.achievements.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
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
                      widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.hovered)
                          ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                          : null,
                    ),
                    dataRowMinHeight: 80,
                    dataRowMaxHeight: double.infinity,
                    headingRowHeight: 60,
                    showCheckboxColumn: false,
                    columns: _buildColumns(),
                    rows: _buildRows(),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showFixedActionColumn)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 180,
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
              child: SingleChildScrollView(
                controller: _fixedColumnVerticalController,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                  ),
                  dataRowMinHeight: 80,
                  dataRowMaxHeight: double.infinity,
                  headingRowHeight: 60,
                  columns: [_buildActionColumn()],
                  rows: widget.achievements.map((achievement) => DataRow(cells: [_buildActionCell(achievement)])).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.award, size: 80, color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
            const SizedBox(height: FSizes.lg),
            Text(
              "No Achievements Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              "There are no achievements matching your filters.",
              style: TextStyle(
                fontSize: 14,
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final columns = [
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Achievement ID', 0))),
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Title', 1))),
      DataColumn(label: SizedBox(width: 150, child: _buildColumnHeader('Category', 2))),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Max Level', 3)), numeric: true),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Created', 4))),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Status', 5))),
      _buildEmptySpacerColumn(),
    ];
    if (!_showFixedActionColumn) {
      columns.add(_buildActionColumn());
    }
    return columns;
  }

  Widget _buildColumnHeader(String title, int columnIndex, {bool numeric = false}) {
    final isCurrentSort = widget.sortColumnIndex == columnIndex;
    return InkWell(
      onTap: () => widget.onSort(columnIndex, !widget.sortAscending),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Align(
              alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                title,
                style: _headerStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Icon(
            isCurrentSort
                ? (widget.sortAscending ? Iconsax.arrow_up_3 : Iconsax.arrow_down)
                : Iconsax.arrow_3,
            size: 16,
            color: isCurrentSort
                ? (widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
          ),
        ],
      ),
    );
  }

  DataColumn _buildEmptySpacerColumn() {
    return DataColumn(
      label: SizedBox(width: 120, child: const Text('')),
    );
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: SizedBox(width: 180, child: Text('Actions', style: _headerStyle())),
    );
  }

  List<DataRow> _buildRows() {
    return widget.achievements.map((achievement) {
      return DataRow(cells: [
        _wrapSelectableText(achievement.achievementId, 200),
        _wrapText(achievement.title, 200),
        _buildCategoryBadge(achievement.category),
        DataCell(Text(achievement.maxLevel.toString(), style: _cellStyle())),
        DataCell(Text(_formatDateTime(achievement.createdAt), style: _cellStyle())),
        _buildStatusBadge(achievement.status, widget.dark),
        _buildEmptySpacerCell(),
        if (!_showFixedActionColumn) _buildActionCell(achievement),
      ]);
    }).toList();
  }

  DataCell _buildEmptySpacerCell() {
    return DataCell(
      Container(width: 120, child: const Text('')),
    );
  }

  DataCell _wrapSelectableText(String text, double width) {
    return DataCell(
      Container(
        width: width,
        child: SelectableText(
          text,
          style: _cellStyle(),
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _wrapText(String text, double width) {
    return DataCell(
      Container(
        width: width,
        child: Text(
          text,
          style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _buildCategoryBadge(String category) {
    Color color;
    IconData icon;
    String label;

    switch (category.toLowerCase()) {
      case 'recycling':
        color = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        icon = Iconsax.trash;
        label = 'Recycling';
        break;
      case 'scanning':
        color = widget.dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        icon = Iconsax.scan_barcode;
        label = 'Scanning';
        break;
      case 'community':
        color = widget.dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary;
        icon = Iconsax.people;
        label = 'Community';
        break;
      case 'streak':
        color = widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        icon = Iconsax.calendar_tick;
        label = 'Streak';
        break;
      default:
        color = widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
        icon = Iconsax.award;
        label = category;
    }

    return DataCell(CommonBadge(
      icon: icon,
      color: color,
      text: label,
      iconSize: 14,
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      borderRadius: FSizes.cardRadiusMd,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    ));
  }

  DataCell _buildStatusBadge(String status, bool dark) {
    Color color;
    IconData icon;
    String label;
    switch (status) {
      case 'active':
        color = dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        icon = Iconsax.tick_circle;
        label = 'Active';
        break;
      case 'inactive':
        color = dark ? FColors.adminDarkError : FColors.adminLightError;
        icon = Iconsax.close_circle;
        label = 'Inactive';
        break;
      default:
        color = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        icon = Iconsax.slash;
        label = status;
    }
    return DataCell(CommonBadge(
      icon: icon,
      color: color,
      text: label,
      iconSize: 14,
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      borderRadius: FSizes.cardRadiusMd,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    ));
  }

  DataCell _buildActionCell(Achievement achievement) {
    return DataCell(
      Container(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => Get.to(
                    () => const AchievementDetailsScreen(),
                arguments: achievement,
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              ),
              icon: Icon(
                Iconsax.eye,
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'View Details',
            ),
            IconButton(
              onPressed: () => widget.controller.editAchievement(achievement),
              icon: Icon(
                Iconsax.edit,
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'Edit Achievement',
            ),
            IconButton(
              onPressed: () => _showStatusToggleConfirmation(achievement),
              icon: Icon(
                achievement.status == 'active' ? Iconsax.close_circle : Iconsax.tick_circle,
                color: achievement.status == 'active'
                    ? (widget.dark ? FColors.adminDarkError : FColors.adminLightError)
                    : (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                size: 18,
              ),
              tooltip: achievement.status == 'active' ? 'Deactivate' : 'Activate',
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusToggleConfirmation(Achievement achievement) {
    FAdminLoaders.showAchievementStatusToggleDialog(
      achievementTitle: achievement.title,
      isActivating: achievement.status != 'active',
      onConfirm: () => widget.controller.toggleAchievementStatus(achievement),
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
      fontSize: 13,
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