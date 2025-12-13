import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

class UniversalTimeFilter extends StatelessWidget {
  final TimeFilter selectedFilter;
  final Function(TimeFilter) onFilterChanged;
  final bool darkMode;
  final bool showCloseButton;
  final Color? primaryColor; // 新增：自定义主题色

  const UniversalTimeFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.darkMode,
    this.showCloseButton = true,
    this.primaryColor, // 可选参数，默认使用 FColors.primary
  });

  // 获取实际使用的主题色
  Color get _primaryColor => primaryColor ?? FColors.primary;

  IconData _getTimeFilterIcon(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today:
        return Iconsax.sun_1;
      case TimeFilter.thisWeek:
        return Iconsax.calendar_1;
      case TimeFilter.thisMonth:
        return Iconsax.calendar;
      case TimeFilter.thisYear:
        return Iconsax.calendar_2;
      default:
        return Iconsax.clock;
    }
  }

  void _showTimeFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(context),
    );
  }

  Widget _buildFilterBottomSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkMode ? FColors.communityDarkSurface : FColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: darkMode ? FColors.darkGrey : FColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
              child: Row(
                children: [
                  Icon(
                    Iconsax.filter,
                    color: _primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter by Time',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkMode ? FColors.white : FColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Options
            Column(
              mainAxisSize: MainAxisSize.min,
              children: TimeFilter.values
                  .map((filter) => _buildTimeFilterOption(filter, context))
                  .toList(),
            ),

            if (showCloseButton) ...[
              const SizedBox(height: 12),
              // Close Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: FColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterOption(TimeFilter filter, BuildContext context) {
    final isSelected = selectedFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onFilterChanged(filter);
          Navigator.pop(context); // 关闭底部弹窗
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.defaultSpace,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _primaryColor.withOpacity(0.2)
                      : (darkMode ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTimeFilterIcon(filter),
                  color: isSelected
                      ? _primaryColor
                      : (darkMode ? FColors.darkTextSecondary : FColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    color: isSelected ? _primaryColor : (darkMode ? FColors.white : FColors.black),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Iconsax.tick_circle5,
                  color: _primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFiltered = selectedFilter != TimeFilter.allTime;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTimeFilterBottomSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isFiltered
                ? _primaryColor.withOpacity(0.1)
                : (darkMode ? FColors.communityDarkSurface : FColors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFiltered
                  ? _primaryColor
                  : (darkMode ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2)),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTimeFilterIcon(selectedFilter),
                color: isFiltered
                    ? _primaryColor
                    : (darkMode ? FColors.darkTextSecondary : FColors.textSecondary),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                selectedFilter.displayName,
                style: TextStyle(
                  color: isFiltered
                      ? _primaryColor
                      : (darkMode ? FColors.white : FColors.black),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Iconsax.arrow_down_1,
                color: isFiltered
                    ? _primaryColor
                    : (darkMode ? FColors.darkTextSecondary : FColors.textSecondary),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}