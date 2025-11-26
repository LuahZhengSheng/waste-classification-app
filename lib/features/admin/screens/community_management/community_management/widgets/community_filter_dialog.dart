import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

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
                  'Filter Posts',
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

            // Post Type Filter
            _buildFilterSection(
              'Post Type',
              DropdownButton<String?>(
                value: filters['postType'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['postType'] = value),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'All Types',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'tip',
                    child: Text(
                      'Tips',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'discussion',
                    child: Text(
                      'Discussions',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'question',
                    child: Text(
                      'Questions',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'achievement',
                    child: Text(
                      'Achievements',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              ),
            ),

            // Media Filter
            _buildFilterSection(
              'Media',
              DropdownButton<String?>(
                value: filters['mediaType'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['mediaType'] = value),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'All Posts',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'hasMedia',
                    child: Text(
                      'Posts with Media',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'noMedia',
                    child: Text(
                      'Posts without Media',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              ),
            ),

            // Date Range Filter
            _buildFilterSection(
              'Date Range',
              DropdownButton<String?>(
                value: filters['dateRange'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['dateRange'] = value),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'All Time',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'today',
                    child: Text(
                      'Today',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'last7days',
                    child: Text(
                      'Last 7 Days',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'last30days',
                    child: Text(
                      'Last 30 Days',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'thisMonth',
                    child: Text(
                      'This Month',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
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
                          'mediaType': null,
                          'dateRange': null,
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