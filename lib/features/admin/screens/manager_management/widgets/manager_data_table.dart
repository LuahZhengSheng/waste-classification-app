import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';

import '../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../common/widgets/admin/badge.dart';
import '../../../controllers/manager_management/manager_management_controller.dart';
import '../../../models/admin_model.dart';
import 'manager_actions_dialog.dart';
import 'manager_detail_dialog.dart';
import 'send_password_reset_dialog.dart';

class ManagerDataTable extends StatefulWidget {
  final List<AdminModel> managers;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final bool isBannedView;

  const ManagerDataTable({
    super.key,
    required this.managers,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    this.isBannedView = false,
  });

  @override
  State<ManagerDataTable> createState() => _ManagerDataTableState();
}

class _ManagerDataTableState extends State<ManagerDataTable> {
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
    final screenWidth = MediaQuery.of(context).size.width - (FSizes.lg * 9);
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
    return 80 + 150 + 200 + 200 + 150 + 180 + 120 + 100 + 200; // 增加Action Column宽度
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
    if (widget.managers.isEmpty) {
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
                        widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant),
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
              width: 200, // 增加固定列的宽度
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
                  rows: widget.managers
                      .map((manager) => DataRow(cells: [_buildActionCell(manager)]))
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
            Icon(Iconsax.user_tag, size: 80, color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
            const SizedBox(height: FSizes.lg),
            Text(
              "No Managers Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              "There are no managers matching your filters.",
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
      DataColumn(label: SizedBox(width: 80, child: Text('Profile', style: _headerStyle()))),
      DataColumn(label: SizedBox(width: 150, child: _buildColumnHeader('Username', 0))),
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Manager ID', 1))),
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Email', 2))),
      DataColumn(label: SizedBox(width: 150, child: _buildColumnHeader('Phone', 3))),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Role', 4))),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Verified', 5))),
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
      label: SizedBox(
        width: 150,
        child: const Text(''),
      ),
    );
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: SizedBox(
        width: 200, // 增加Action Column宽度
        child: Text('Actions', style: _headerStyle()),
      ),
    );
  }

  List<DataRow> _buildRows() {
    return widget.managers.map((manager) {
      final cells = <DataCell>[
        DataCell(_buildProfileImage(manager)),
        _wrapCell(manager.username, 150),
        _wrapSelectableCell(manager.userId, 200),
        _wrapCell(manager.email, 200),
        _wrapCell(manager.phoneNo ?? 'N/A', 150),
        DataCell(_buildRoleBadge(manager.role)),
        DataCell(_buildVerifiedBadge(manager.isVerified)),
        _buildEmptySpacerCell(),
      ];

      if (!_showFixedActionColumn) {
        cells.add(_buildActionCell(manager));
      }

      return DataRow(cells: cells);
    }).toList();
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

  DataCell _buildEmptySpacerCell() {
    return DataCell(
      Container(
        width: 150,
        child: const Text(''),
      ),
    );
  }

  Widget _buildProfileImage(AdminModel manager) {
    final userRepo = UserRepository.instance;
    final cachedUrl = userRepo.getCachedProfileImageUrl(manager.profileImg);

    return GestureDetector(
      onTap: () {
        if (cachedUrl != null && cachedUrl.isNotEmpty) {
          Get.to(() => ImageLightbox(
            imageUrl: cachedUrl,
            title: manager.username,
          ));
        }
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
        backgroundImage: cachedUrl != null && cachedUrl.isNotEmpty
            ? NetworkImage(cachedUrl)
            : null,
        child: cachedUrl == null || cachedUrl.isEmpty
            ? const Icon(Iconsax.user, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    IconData? icon;
    Color color;
    String displayText;

    switch (role) {
      case 'community_manager':
        icon = Iconsax.user_tag;
        color = widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
        displayText = 'Community Manager';
        break;
      case 'event_manager':
        icon = Iconsax.calendar_edit;
        color = widget.dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary;
        displayText = 'Event Manager';
        break;
      case 'reward_manager':
        icon = Iconsax.medal_star;
        color = widget.dark ? FColors.adminDarkAccent : FColors.adminLightAccent;
        displayText = 'Reward Manager';
        break;
      default:
        icon = Iconsax.slash;
        color = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = 'Unknown';
    }

    return CommonBadge(
      icon: icon,
      color: color,
      text: displayText,
      iconSize: 16,
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      borderRadius: FSizes.cardRadiusMd,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    );
  }

  Widget _buildVerifiedBadge(bool isVerified) {
    final color = isVerified
        ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
        : (widget.dark ? FColors.adminDarkError : FColors.adminLightError);
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
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    );
  }

  DataCell _buildActionCell(AdminModel manager) {
    final controller = ManagerManagementController.instance;

    return DataCell(
      Container(
        width: 200, // 增加Action Cell宽度
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 查看按钮
            IconButton(
              onPressed: () => _viewManager(manager),
              icon: Icon(
                Iconsax.eye,
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'View Manager',
            ),

            // 编辑按钮
            IconButton(
              onPressed: () => _editManager(manager),
              icon: Icon(
                Iconsax.edit,
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'Edit Manager',
            ),

            // 封禁/恢复按钮
            if (!manager.isBanned)
              IconButton(
                onPressed: () => _banManager(manager),
                icon: Icon(
                  Iconsax.slash,
                  size: 18,
                  color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
                ),
                tooltip: 'Ban Manager',
              )
            else
              IconButton(
                onPressed: () => _recoverManager(manager),
                icon: Icon(
                  Iconsax.refresh,
                  size: 18,
                  color: widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                ),
                tooltip: 'Recover Manager',
              ),

            // 发送密码重置链接按钮 - 现在是第四个按钮
            // 移除条件限制，始终显示但根据条件启用/禁用
            IconButton(
              onPressed: manager.canSendPasswordResetLink() && !manager.isVerified && manager.isActive && !manager.isBanned
                  ? () => _showSendResetLinkDialog(manager)
                  : null,
              icon: Icon(
                Iconsax.send_2,
                size: 18,
                color: manager.canSendPasswordResetLink() && !manager.isVerified && manager.isActive && !manager.isBanned
                    ? widget.dark ? FColors.adminDarkInfo : FColors.adminLightInfo
                    : widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
              tooltip: manager.canSendPasswordResetLink() && !manager.isVerified && manager.isActive && !manager.isBanned
                  ? 'Send Password Reset Link'
                  : manager.canSendPasswordResetLink()
                  ? 'Only available for unverified, active, and unbanned managers'
                  : 'Wait ${manager.getFormattedRemainingResetTime()} before sending again',
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
      color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
      fontSize: 14,
    );
  }

  void _viewManager(AdminModel manager) {
    Get.dialog(
      ManagerDetailDialog(manager: manager, isEditMode: false),
      barrierDismissible: false,
    );
  }

  void _editManager(AdminModel manager) {
    Get.dialog(
      ManagerDetailDialog(manager: manager, isEditMode: true),
      barrierDismissible: false,
    );
  }

  void _banManager(AdminModel manager) {
    Get.dialog(
      BanManagerDialog(manager: manager),
      barrierDismissible: false,
    );
  }

  void _recoverManager(AdminModel manager) {
    Get.dialog(
      RecoverManagerDialog(manager: manager),
      barrierDismissible: false,
    );
  }

  void _showSendResetLinkDialog(AdminModel manager) {
    // 检查是否可以发送
    if (!manager.canSendPasswordResetLink()) {
      final remainingTime = manager.getFormattedRemainingResetTime();
      Get.snackbar(
        'Wait Required',
        'Please wait $remainingTime before sending another reset link.',
        backgroundColor: widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
        colorText: Colors.white,
      );
      return;
    }

    // 使用 SendPasswordResetDialog 替代原来的自定义对话框
    Get.dialog(
      SendPasswordResetDialog(manager: manager),
      barrierDismissible: false,
    );
  }

  // 辅助方法：构建信息行
  Widget _buildInfoRow(String label, String value, bool dark) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: FSizes.xs),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}