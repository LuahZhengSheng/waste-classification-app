import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/features/admin/controllers/recycling_center_management/recycling_center_management_controller.dart';

import '../../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../../common/widgets/admin/badge.dart';
import '../../../../../../utils/popups/admin_loaders.dart';
import '../../../../../recycling_center/models/partner_recycling_center_model.dart';

class CenterDataTable extends StatefulWidget {
  final List<PartnerRecyclingCenter> centers;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final PartnerCenterManagementController controller;

  const CenterDataTable({
    super.key,
    required this.centers,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<CenterDataTable> createState() => _AdminPartnerCenterDataTableState();
}

class _AdminPartnerCenterDataTableState extends State<CenterDataTable> {
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
    return 200 + 120 + 200 + 180 + 220 + 220 + 120 + 180 + 120 + 180;
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
    if (widget.centers.isEmpty) {
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
              width: 180,
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
                  rows: widget.centers
                      .map((center) =>
                          DataRow(cells: [_buildActionCell(center)]))
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
            Icon(Iconsax.building_4,
                size: 80,
                color: widget.dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted),
            const SizedBox(height: FSizes.lg),
            Text(
              "No Centers Found",
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
              "There are no centers matching your filters.",
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
          label:
              SizedBox(width: 200, child: _buildColumnHeader('Center ID', 0))),
      DataColumn(
          label: SizedBox(width: 120, child: _buildColumnHeader('Image', 1))),
      DataColumn(
          label: SizedBox(width: 200, child: _buildColumnHeader('Name', 2))),
      DataColumn(
          label: SizedBox(width: 180, child: _buildColumnHeader('Contact', 3))),
      DataColumn(
          label:
              SizedBox(width: 220, child: _buildColumnHeader('Location', 4))),
      DataColumn(
          label:
              SizedBox(width: 220, child: _buildColumnHeader('Materials', 5))),
      DataColumn(
          label: SizedBox(width: 120, child: _buildColumnHeader('Staff', 6)),
          numeric: true),
      DataColumn(
          label: SizedBox(width: 180, child: _buildColumnHeader('Created', 7))),
      DataColumn(
          label: SizedBox(width: 120, child: _buildColumnHeader('Status', 8))),
      _buildEmptySpacerColumn(),
    ];
    if (!_showFixedActionColumn) {
      columns.add(_buildActionColumn());
    }
    return columns;
  }

  DataColumn _buildEmptySpacerColumn() {
    return DataColumn(
      label: SizedBox(width: 120, child: const Text('')),
    );
  }

  Widget _buildColumnHeader(String title, int columnIndex,
      {bool numeric = false}) {
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

  DataColumn _buildActionColumn() {
    return DataColumn(
      label:
          SizedBox(width: 180, child: Text('Actions', style: _headerStyle())),
    );
  }

  List<DataRow> _buildRows() {
    return widget.centers.map((center) {
      return DataRow(cells: [
        _wrapSelectableText(center.centerId, 200),
        _buildImageCell(center),
        _buildNameCell(center),
        _buildContactCell(center),
        _buildLocationCell(center),
        _buildMaterialsCell(center),
        _buildStaffCountCell(center),
        DataCell(Text(_formatDateTime(center.createdAt), style: _cellStyle())),
        _buildStatusBadge(center.status, widget.dark),
        _buildEmptySpacerCell(),
        if (!_showFixedActionColumn) _buildActionCell(center),
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

  DataCell _buildImageCell(PartnerRecyclingCenter center) {
    return DataCell(
      GestureDetector(
        onTap: () {
          Get.dialog(
            ImageLightbox(
              imageUrl: center.image,
              title: center.name,
            ),
            barrierDismissible: true,
          );
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            border: Border.all(
              color: widget.dark
                  ? FColors.adminDarkBorder.withOpacity(0.3)
                  : FColors.adminLightBorder.withOpacity(0.3),
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
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildNameCell(PartnerRecyclingCenter center) {
    return DataCell(
      Container(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              center.name,
              style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            if (center.website.isNotEmpty)
              GestureDetector(
                onTap: () => _launchUrl(center.website),
                child: Text(
                  center.website,
                  style: _cellStyle().copyWith(
                    fontSize: 11,
                    color: widget.dark
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  DataCell _buildContactCell(PartnerRecyclingCenter center) {
    return DataCell(
      Container(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(center.email,
                style: _cellStyle(), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(
              center.phoneNo,
              style: _cellStyle().copyWith(
                fontSize: 11,
                color: widget.dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildLocationCell(PartnerRecyclingCenter center) {
    return DataCell(
      Container(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // '${center.centerLocation.address.city}, ${center.centerLocation.address.state}',
              center.centerLocation.fullAddress,
              style: _cellStyle(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            // const SizedBox(height: 2),
            // Text(
            //   center.centerLocation.address.area,
            //   style: _cellStyle().copyWith(
            //     fontSize: 11,
            //     color: widget.dark
            //         ? FColors.adminDarkTextMuted
            //         : FColors.adminLightTextMuted,
            //   ),
            //   overflow: TextOverflow.ellipsis,
            // ),
          ],
        ),
      ),
    );
  }

  DataCell _buildMaterialsCell(PartnerRecyclingCenter center) {
    return DataCell(
      Container(
        width: 220,
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...center.acceptedMaterials.take(3).map((material) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (widget.dark
                          ? FColors.adminDarkSuccess
                          : FColors.adminLightSuccess)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  material,
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.dark
                        ? FColors.adminDarkSuccess
                        : FColors.adminLightSuccess,
                  ),
                ),
              );
            }).toList(),
            if (center.acceptedMaterials.length > 3)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '+${center.acceptedMaterials.length - 3}',
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.dark
                        ? FColors.adminDarkTextMuted
                        : FColors.adminLightTextMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DataCell _buildStaffCountCell(PartnerRecyclingCenter center) {
    Color staffCountColor;
    if (center.numberOfStaff <= 5) {
      staffCountColor =
          widget.dark ? FColors.adminDarkError : FColors.adminLightError;
    } else if (center.numberOfStaff <= 15) {
      staffCountColor =
          widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
    } else {
      staffCountColor =
          widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
    }

    return DataCell(
      Container(
        width: 120,
        child: Text(
          center.numberOfStaff.toString(),
          style: _cellStyle().copyWith(
            fontWeight: FontWeight.w600,
            color: staffCountColor,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
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
      case 'disabled':
        color = dark ? FColors.adminDarkError : FColors.adminLightError;
        icon = Iconsax.close_circle;
        label = 'Disabled';
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
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    ));
  }

  DataCell _buildActionCell(PartnerRecyclingCenter center) {
    final isDisabled = center.status == 'disabled';

    return DataCell(
      Container(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => widget.controller.viewCenter(center),
              icon: Icon(
                Iconsax.eye,
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'View Details',
            ),
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
            IconButton(
              onPressed: () => _showDisableRecoverDialog(center, context),
              icon: Icon(
                isDisabled ? Iconsax.refresh : Iconsax.close_circle,
                size: 18,
                color: isDisabled
                    ? (widget.dark
                        ? FColors.adminDarkSuccess
                        : FColors.adminLightSuccess)
                    : (widget.dark
                        ? FColors.adminDarkError
                        : FColors.adminLightError),
              ),
              tooltip: isDisabled ? 'Recover Center' : 'Disable Center',
            ),
          ],
        ),
      ),
    );
  }

  void _showDisableRecoverDialog(PartnerRecyclingCenter center, BuildContext context) {
    FAdminLoaders.showRecyclingCenterDisableRecoverDialog(
      centerName: center.name,
      isDisabled: center.status == 'disabled',
      onConfirm: () {
        if (center.status == 'disabled') {
          widget.controller.recoverCenter(center);
        } else {
          widget.controller.disableCenter(center);
        }
      },
    );
  }

  void _launchUrl(String url) {
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
      color: widget.dark
          ? FColors.adminDarkTextSecondary
          : FColors.adminLightTextSecondary,
      fontSize: 13,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)}, ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
