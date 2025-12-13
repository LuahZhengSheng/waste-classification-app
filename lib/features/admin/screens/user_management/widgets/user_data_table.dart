import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/features/authentication/models/user_model.dart';

import '../../../../../common/widgets/admin/badge.dart';
import '../../../../../common/widgets/admin/small_profile_image.dart';
import 'user_actions_dialog.dart';
import 'user_detail_dialog.dart';

class UserDataTable extends StatefulWidget {
  final List<UserModel> users;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final bool isBannedView;

  const UserDataTable({
    super.key,
    required this.users,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    this.isBannedView = false,
  });

  @override
  State<UserDataTable> createState() => _UserDataTableState();
}

class _UserDataTableState extends State<UserDataTable> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _fixedColumnVerticalController = ScrollController();
  bool _showFixedActionColumn = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_onScroll);
    _verticalScrollController.addListener(_syncFixedColumnScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkIfActionColumnShouldBeFixed());
  }

  void _syncFixedColumnScroll() {
    if (_fixedColumnVerticalController.hasClients &&
        _verticalScrollController.hasClients) {
      _fixedColumnVerticalController.jumpTo(_verticalScrollController.offset);
    }
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
    return 80 + 150 + 200 + 220 + 120 + 90 + 150 + 120 + 140 + 120 + 100 + 160;
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
    if (widget.users.isEmpty) {
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
                    minWidth:
                        MediaQuery.of(context).size.width - (FSizes.lg * 2),
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      widget.dark
                          ? FColors.adminDarkSurfaceVariant
                          : FColors.adminLightSurfaceVariant,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.hovered)
                          ? (widget.dark
                              ? FColors.adminDarkHover
                              : FColors.adminLightHover)
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
              width: 160,
              decoration: BoxDecoration(
                color: widget.dark
                    ? FColors.adminDarkSurface
                    : FColors.adminLightSurface,
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
                    widget.dark
                        ? FColors.adminDarkSurfaceVariant
                        : FColors.adminLightSurfaceVariant,
                  ),
                  dataRowMinHeight: 80,
                  dataRowMaxHeight: double.infinity,
                  headingRowHeight: 60,
                  columns: [_buildActionColumn()],
                  rows: widget.users
                      .map((user) => DataRow(cells: [_buildActionCell(user)]))
                      .toList(),
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
            Icon(Iconsax.personalcard,
                size: 80,
                color: widget.dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted),
            const SizedBox(height: FSizes.lg),
            Text(
              "No Users Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: widget.dark
                    ? FColors.adminDarkText
                    : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              "There are no users matching your filters.",
              style: TextStyle(
                fontSize: 14,
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final columns = [
      DataColumn(
          label: SizedBox(
              width: 80, child: Text('Profile', style: _headerStyle()))),
      DataColumn(
          label:
              SizedBox(width: 150, child: _buildColumnHeader('Username', 0))),
      DataColumn(
          label: SizedBox(width: 200, child: _buildColumnHeader('User ID', 1))),
      DataColumn(
          label: SizedBox(width: 220, child: _buildColumnHeader('Email', 2))),
      DataColumn(
          label: SizedBox(width: 120, child: _buildColumnHeader('Phone', 3))),
      DataColumn(
          label: SizedBox(width: 90, child: _buildColumnHeader('Gender', 4))),
      DataColumn(
          label: SizedBox(
              width: 150, child: _buildColumnHeader('Date of Birth', 5))),
      DataColumn(
        label: SizedBox(width: 120, child: _buildColumnHeader('Points', 6)),
        numeric: true,
      ),
      DataColumn(
          label:
              SizedBox(width: 140, child: _buildColumnHeader('Join Date', 7))),
      DataColumn(
          label:
              SizedBox(width: 120, child: _buildColumnHeader('Verified', 8))),
      _buildEmptySpacerColumn(),
    ];
    if (!_showFixedActionColumn) {
      columns.add(_buildActionColumn());
    }
    return columns;
  }

  Widget _buildColumnHeader(String title, int columnIndex,
      {bool numeric = false}) {
    final isCurrentSort = widget.sortColumnIndex == columnIndex;
    return InkWell(
      onTap: () => widget.onSort(columnIndex, !widget.sortAscending),
      child: Row(
        mainAxisAlignment:
            numeric ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
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
                ? (widget.sortAscending
                    ? Iconsax.arrow_up_3
                    : Iconsax.arrow_down)
                : Iconsax.arrow_3,
            size: 16,
            color: isCurrentSort
                ? (widget.dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary)
                : (widget.dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted),
          ),
        ],
      ),
    );
  }

  DataColumn _buildEmptySpacerColumn() {
    return DataColumn(
      label: SizedBox(
        width: 100,
        child: const Text(''),
      ),
    );
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: SizedBox(
        width: 160,
        child: Text('Actions', style: _headerStyle()),
      ),
    );
  }

  List<DataRow> _buildRows() {
    return widget.users.map((user) {
      final cells = <DataCell>[
        DataCell(_buildProfileImage(user)),
        _wrapCell(user.username, 150),
        _wrapSelectableCell(user.userId, 200),
        _wrapCell(user.email, 220),
        _wrapCell(user.displayGender, 120),
        _wrapCell(user.displayGender, 90),
        _wrapCell(user.displayDob, 150),
        DataCell(
          Container(
            alignment: Alignment.centerRight,
            child: _buildPointsBadge(user.rewardPoint, widget.dark),
          ),
        ),
        _wrapCell(FFormatter.formatDate(user.joinDate), 140),
        DataCell(
          Container(
            child: _buildVerifiedBadge(user.isVerified, widget.dark),
          ),
        ),
        _buildEmptySpacerCell(),
      ];

      if (!_showFixedActionColumn) {
        cells.add(_buildActionCell(user));
      }

      return DataRow(cells: cells);
    }).toList();
  }

  DataCell _buildEmptySpacerCell() {
    return DataCell(
      Container(
        width: 100,
        child: const Text(''),
      ),
    );
  }

  Widget _buildProfileImage(UserModel user) {
    return SmallProfileImage(
      profileImg: user.profileImg,
      username: user.username,
      dark: widget.dark,
    );
  }

  DataCell _wrapCell(String text, double width) {
    return DataCell(
      Container(
        width: width,
        child: Text(
          text,
          style: _cellStyle(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _wrapSelectableCell(String text, double width) {
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

  Widget _buildPointsBadge(int points, bool dark) {
    final color = dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
    return CommonBadge(
      icon: Iconsax.medal_star5,
      color: color,
      text: points.toString(),
      iconSize: 16,
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      borderRadius: FSizes.cardRadiusMd,
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    );
  }

  Widget _buildVerifiedBadge(bool isVerified, bool dark) {
    final color = isVerified
        ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
        : (dark ? FColors.adminDarkError : FColors.adminLightError);
    final icon = isVerified ? Iconsax.verify5 : Iconsax.close_circle;
    final label = isVerified ? 'Verified' : 'Unverified';

    return CommonBadge(
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
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    );
  }

  DataCell _buildActionCell(UserModel user) {
    return DataCell(
      Container(
        width: 160,
        child: Row(
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
            IconButton(
              onPressed: () =>
                  widget.isBannedView ? _recoverUser(user) : _banUser(user),
              icon: Icon(
                widget.isBannedView ? Iconsax.refresh : Iconsax.slash,
                color: widget.isBannedView
                    ? (widget.dark
                        ? FColors.adminDarkSuccess
                        : FColors.adminLightSuccess)
                    : (widget.dark
                        ? FColors.adminDarkError
                        : FColors.adminLightError),
                size: 18,
              ),
              tooltip: widget.isBannedView ? 'Recover User' : 'Ban User',
            ),
          ],
        ),
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
      color: widget.dark
          ? FColors.adminDarkTextSecondary
          : FColors.adminLightTextSecondary,
      fontSize: 14,
    );
  }

  void _viewUser(UserModel user) {
    Get.dialog(
      UserDetailDialog(user: user, isEditMode: false),
      barrierDismissible: false,
    );
  }

  void _editUser(UserModel user) {
    Get.dialog(
      UserDetailDialog(user: user, isEditMode: true),
      barrierDismissible: false,
    );
  }

  void _banUser(UserModel user) {
    Get.dialog(
      BanUserDialog(user: user),
      barrierDismissible: false,
    );
  }

  void _recoverUser(UserModel user) {
    Get.dialog(
      RecoverUserDialog(user: user),
      barrierDismissible: false,
    );
  }
}
