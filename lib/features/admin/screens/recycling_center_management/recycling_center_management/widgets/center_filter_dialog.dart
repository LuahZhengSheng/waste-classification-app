import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

class PartnerCenterFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final List<String> availableCities;
  final List<String> availableStates;
  final Function(Map<String, dynamic>) onApplyFilters;

  const PartnerCenterFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.availableCities,
    required this.availableStates,
    required this.onApplyFilters,
  });

  @override
  State<PartnerCenterFilterDialog> createState() => _PartnerCenterFilterDialogState();
}

class _PartnerCenterFilterDialogState extends State<PartnerCenterFilterDialog> {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FSizes.cardRadiusLg)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Centers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Iconsax.close_circle, color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Staff Size Filter
            _buildFilterSection(
              'Staff Size',
              DropdownButton<String?>(
                value: filters['staffRange'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['staffRange'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Sizes')),
                  const DropdownMenuItem(value: 'small', child: Text('Small (≤ 10)')),
                  const DropdownMenuItem(value: 'medium', child: Text('Medium (11-30)')),
                  const DropdownMenuItem(value: 'large', child: Text('Large (> 30)')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(color: widget.dark ? FColors.adminDarkText : FColors.adminLightText),
              ),
            ),

            // City Filter
            _buildFilterSection(
              'City',
              DropdownButton<String?>(
                value: filters['city'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['city'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Cities')),
                  ...widget.availableCities.map((city) => DropdownMenuItem(value: city, child: Text(city))),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(color: widget.dark ? FColors.adminDarkText : FColors.adminLightText),
              ),
            ),

            // State Filter
            _buildFilterSection(
              'State',
              DropdownButton<String?>(
                value: filters['state'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['state'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All States')),
                  ...widget.availableStates.map((state) => DropdownMenuItem(value: state, child: Text(state))),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(color: widget.dark ? FColors.adminDarkText : FColors.adminLightText),
              ),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        filters = {'staffRange': null, 'city': null, 'state': null};
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
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
                    child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
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
            color: widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: content,
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
      ],
    );
  }
}