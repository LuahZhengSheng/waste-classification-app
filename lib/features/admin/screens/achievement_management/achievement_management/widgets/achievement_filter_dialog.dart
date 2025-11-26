import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

class AchievementFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const AchievementFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<AchievementFilterDialog> createState() => _AchievementFilterDialogState();
}

class _AchievementFilterDialogState extends State<AchievementFilterDialog> {
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
                  'Filter Achievements',
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
                    color: widget.dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Category Filter
            _buildFilterSection(
              'Category',
              DropdownButton<String?>(
                value: filters['category'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['category'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  const DropdownMenuItem(value: 'Recycling', child: Text('Recycling')),
                  const DropdownMenuItem(value: 'Scanning', child: Text('Scanning')),
                  const DropdownMenuItem(value: 'Community', child: Text('Community')),
                  const DropdownMenuItem(value: 'Streak', child: Text('Streak')),
                  const DropdownMenuItem(value: 'Environmental', child: Text('Environmental')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // Max Level Range Filter
            _buildFilterSection(
              'Max Level Range',
              DropdownButton<String?>(
                value: filters['maxLevelRange'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['maxLevelRange'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Levels')),
                  const DropdownMenuItem(value: 'low', child: Text('Low (1-3 levels)')),
                  const DropdownMenuItem(value: 'medium', child: Text('Medium (4-6 levels)')),
                  const DropdownMenuItem(value: 'high', child: Text('High (7+ levels)')),
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
                          'category': null,
                          'maxLevelRange': null,
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
          padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
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