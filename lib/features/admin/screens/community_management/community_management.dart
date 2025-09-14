import 'package:flutter/material.dart';
import 'package:fyp/features/admin/screens/community_management/post_detail/post_detail.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../community/models/post_model.dart';
import '../../controllers/community_management/community_management_controller.dart';

class CommunityManagementScreen extends StatelessWidget {
  const CommunityManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        hintText: 'Search posts by content, type, or user ID...',
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
                      child: Obx(() => AdminCommunityDataTable(
                        posts: controller.paginatedPosts,
                        onSort: controller.sortPosts,
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

  Widget _buildPagination(CommunityManagementController controller, bool dark) {
    // Calculate page numbers to show (up to 5 pages)
    int totalPages = (controller.totalPosts / controller.itemsPerPage.value).ceil();
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
          'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalPosts} entries',
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

class AdminCommunityDataTable extends StatefulWidget {
  final List<PostModel> posts;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final CommunityManagementController controller;

  const AdminCommunityDataTable({
    super.key,
    required this.posts,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<AdminCommunityDataTable> createState() => _AdminCommunityDataTableState();
}

class _AdminCommunityDataTableState extends State<AdminCommunityDataTable> {
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
                rows: widget.posts
                    .map((post) => DataRow(cells: [_buildActionCell(post)]))
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
        label: Text('User ID', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(0, ascending),
      ),
      DataColumn(
        label: Text('Post Type', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(1, ascending),
      ),
      // DataColumn(
      //   label: Text('Content', style: _headerStyle()),
      // ),
      DataColumn(
        label: Text('Media', style: _headerStyle()),
      ),
      DataColumn(
        label: Text('Likes', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(2, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Comments', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(3, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Created At', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(4, ascending),
      ),
      DataColumn(
        label: Text('Updated At', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(5, ascending),
      ),
      DataColumn(
        label: Text('Status', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(6, ascending),
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
    return widget.posts.map((post) {
      return DataRow(
        cells: [
          DataCell(Text(post.userId, style: _cellStyle())),
          DataCell(_buildPostTypeChip(post.postType)),
          // DataCell(
          //   Container(
          //     constraints: const BoxConstraints(maxWidth: 250),
          //     child: Text(
          //       post.content,
          //       style: _cellStyle(),
          //       maxLines: 3,
          //       overflow: TextOverflow.ellipsis,
          //     ),
          //   ),
          // ),
          DataCell(_buildMediaPreview(post.media)),
          DataCell(Text(post.likes.length.toString(), style: _cellStyle())),
          DataCell(Text(post.commentCount.toString(), style: _cellStyle())),
          DataCell(Text(_formatDateTime(post.createdAt), style: _cellStyle())),
          DataCell(Text(_formatDateTime(post.updatedAt), style: _cellStyle())),
          DataCell(_buildStatusChip(post.isDisabled)),
          if (!_showFixedActionColumn) _buildActionCell(post),
        ],
      );
    }).toList();
  }

  Widget _buildPostTypeChip(String postType) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (postType.toLowerCase()) {
      case 'tip':
        backgroundColor = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        break;
      case 'discussion':
        backgroundColor = widget.dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        break;
      case 'question':
        backgroundColor = widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        break;
      case 'achievement':
        backgroundColor = widget.dark ? Color(0xFF8B5CF6) : Color(0xFF8B5CF6);
        break;
      default:
        backgroundColor = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        postType.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMediaPreview(List<String> media) {
    if (media.isEmpty) {
      return Text(
        'No media',
        style: TextStyle(
          color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return SizedBox(
      width: 120,
      height: 40,
      child: Stack(
        children: [
          // Show up to 3 media items
          ...media.take(3).toList().asMap().entries.map(
                (entry) {
              final index = entry.key;
              final mediaUrl = entry.value;
              return Positioned(
                left: index * 15.0,
                child: GestureDetector(
                  onTap: () => _showMediaDialog(media, index),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                      border: Border.all(
                        color: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusXs - 2),
                      child: _isImageUrl(mediaUrl)
                          ? Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Iconsax.image,
                          size: 16,
                          color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                      )
                          : Icon(
                        Iconsax.video_play,
                        size: 16,
                        color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Show count if more than 3 items
          if (media.length > 3)
            Positioned(
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.dark ? FColors.adminDarkPrimary.withOpacity(0.9) : FColors.adminLightPrimary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                  border: Border.all(
                    color: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+${media.length - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _showMediaDialog(List<String> media, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => MediaPreviewDialog(
        media: media,
        initialIndex: initialIndex,
        dark: widget.dark,
      ),
    );
  }

  Widget _buildStatusChip(bool isDisabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: isDisabled
            ? (widget.dark ? FColors.adminDarkError : FColors.adminLightError)
            : (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        isDisabled ? 'Disabled' : 'Active',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  DataCell _buildActionCell(PostModel post) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View button
          IconButton(
            onPressed: () => Get.to(() => AdminPostDetailsScreen(post: post)),
            icon: Icon(
              Iconsax.eye,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'View Post Details',
          ),

          // Enable/Disable toggle button
          IconButton(
            onPressed: () => widget.controller.togglePostStatus(post),
            icon: Icon(
              post.isDisabled ? Iconsax.play : Iconsax.pause,
              color: post.isDisabled
                  ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                  : (widget.dark ? FColors.adminDarkError : FColors.adminLightError),
              size: 18,
            ),
            tooltip: post.isDisabled ? 'Enable Post' : 'Disable Post',
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

class MediaPreviewDialog extends StatefulWidget {
  final List<String> media;
  final int initialIndex;
  final bool dark;

  const MediaPreviewDialog({
    super.key,
    required this.media,
    required this.initialIndex,
    required this.dark,
  });

  @override
  State<MediaPreviewDialog> createState() => _MediaPreviewDialogState();
}

class _MediaPreviewDialogState extends State<MediaPreviewDialog> {
  late int currentIndex;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Media Preview (${currentIndex + 1} of ${widget.media.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Media content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemCount: widget.media.length,
                itemBuilder: (context, index) {
                  final mediaUrl = widget.media[index];
                  return Container(
                    padding: const EdgeInsets.all(FSizes.lg),
                    child: Center(
                      child: _isImageUrl(mediaUrl)
                          ? Image.network(
                        mediaUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(FSizes.xl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.image,
                                size: 64,
                                color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                              ),
                              const SizedBox(height: FSizes.md),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          : Container(
                        padding: const EdgeInsets.all(FSizes.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.video_play,
                              size: 64,
                              color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                            ),
                            const SizedBox(height: FSizes.md),
                            Text(
                              'Video Preview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                              ),
                            ),
                            const SizedBox(height: FSizes.sm),
                            Text(
                              mediaUrl,
                              style: TextStyle(
                                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation controls
            if (widget.media.length > 1)
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: currentIndex > 0
                          ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                          : null,
                      icon: Icon(
                        Iconsax.arrow_left_2,
                        color: currentIndex > 0
                            ? (widget.dark ? FColors.adminDarkText : FColors.adminLightText)
                            : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    // Dots indicator
                    Row(
                      children: List.generate(
                        widget.media.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == currentIndex
                                ? (widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                                : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    IconButton(
                      onPressed: currentIndex < widget.media.length - 1
                          ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                          : null,
                      icon: Icon(
                        Iconsax.arrow_right_3,
                        color: currentIndex < widget.media.length - 1
                            ? (widget.dark ? FColors.adminDarkText : FColors.adminLightText)
                            : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class CommunityFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const CommunityFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<CommunityFilterDialog> createState() => _CommunityFilterDialogState();
}

class _CommunityFilterDialogState extends State<CommunityFilterDialog> {
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
                  'Filter Posts',
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

            // Post Type Filter
            _buildFilterSection(
              'Post Type',
              DropdownButton<String?>(
                value: filters['postType'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['postType'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Types')),
                  const DropdownMenuItem(value: 'tip', child: Text('Tips')),
                  const DropdownMenuItem(
                      value: 'discussion', child: Text('Discussions')),
                  const DropdownMenuItem(
                      value: 'question', child: Text('Questions')),
                  const DropdownMenuItem(
                      value: 'achievement', child: Text('Achievements')),
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

            // Status Filter
            _buildFilterSection(
              'Status',
              DropdownButton<bool?>(
                value: filters['isDisabled'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['isDisabled'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Posts')),
                  const DropdownMenuItem(
                      value: false, child: Text('Active Posts')),
                  const DropdownMenuItem(
                      value: true, child: Text('Disabled Posts')),
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

            // Media Filter
            _buildFilterSection(
              'Media',
              DropdownButton<String?>(
                value: filters['mediaType'],
                isExpanded: true,
                onChanged: (value) =>
                    setState(() => filters['mediaType'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Posts')),
                  const DropdownMenuItem(
                      value: 'hasMedia', child: Text('Posts with Media')),
                  const DropdownMenuItem(
                      value: 'noMedia', child: Text('Posts without Media')),
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
                  const DropdownMenuItem(value: 'today', child: Text('Today')),
                  const DropdownMenuItem(
                      value: 'last7days', child: Text('Last 7 Days')),
                  const DropdownMenuItem(
                      value: 'last30days', child: Text('Last 30 Days')),
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
                          'postType': null,
                          'isDisabled': null,
                          'mediaType': null,
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