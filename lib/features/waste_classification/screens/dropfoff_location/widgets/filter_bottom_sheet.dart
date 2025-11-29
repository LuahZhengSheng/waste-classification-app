import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../controllers/dropoff_location_controller.dart';
import '../../../../../utils/constants/google_maps_config.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DropoffLocationsController.instance;
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: dark ? FColors.dark : FColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(FSizes.borderRadiusLg * 2),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
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
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.md),

              // Partner Only Toggle
              Obx(() => Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: dark ? FColors.darkContainer : FColors.lightContainer,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partner Centers Only',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: FSizes.xs),
                        Text(
                          'Show only verified partner centers',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: FColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: controller.showPartnerOnly.value,
                      onChanged: (_) => controller.togglePartnerFilter(),
                      activeColor: FColors.primary,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: FSizes.md),

              // Search Radius
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Radius',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(controller.currentRadius.value / 1000).toStringAsFixed(1)} km',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: FColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: controller.currentRadius.value / 1000,
                    min: GoogleMapsConfig.minSearchRadiusKm,
                    max: GoogleMapsConfig.maxSearchRadiusKm,
                    divisions: 49,
                    activeColor: FColors.primary,
                    onChanged: (value) => controller.updateRadius(value),
                  ),
                ],
              )),
              const SizedBox(height: FSizes.md),

              // Minimum Rating
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Minimum Rating',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        controller.minRating.value > 0
                            ? '${controller.minRating.value.toStringAsFixed(1)} ⭐'
                            : 'Any',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: FColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: controller.minRating.value,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: FColors.primary,
                    onChanged: (value) => controller.updateMinRating(value),
                  ),
                ],
              )),
              const SizedBox(height: FSizes.md),

              // Opening Hours Filter
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opening Hours',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Wrap(
                    spacing: FSizes.sm,
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'Any Time',
                        isSelected: controller.openingHoursFilter.value == OpeningHoursFilter.anyTime,
                        onTap: () => controller.updateOpeningHoursFilter(OpeningHoursFilter.anyTime),
                      ),
                      _buildFilterChip(
                        context,
                        label: 'Open Now',
                        isSelected: controller.openingHoursFilter.value == OpeningHoursFilter.openNow,
                        onTap: () => controller.updateOpeningHoursFilter(OpeningHoursFilter.openNow),
                      ),
                      _buildFilterChip(
                        context,
                        label: '24 Hours',
                        isSelected: controller.openingHoursFilter.value == OpeningHoursFilter.open24Hours,
                        onTap: () => controller.updateOpeningHoursFilter(OpeningHoursFilter.open24Hours),
                      ),
                    ],
                  ),
                ],
              )),
              const SizedBox(height: FSizes.md),

              // Accepted Materials (Only for Partner Centers)
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Accepted Materials',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: controller.showPartnerOnly.value
                              ? (dark ? FColors.white : FColors.textPrimary)
                              : FColors.darkGrey,
                        ),
                      ),
                      if (!controller.showPartnerOnly.value)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.sm,
                            vertical: FSizes.xs / 2,
                          ),
                          decoration: BoxDecoration(
                            color: FColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                          child: Text(
                            'Partner Only',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: FColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: FSizes.sm),
                  Wrap(
                    spacing: FSizes.sm,
                    runSpacing: FSizes.sm,
                    children: controller.availableMaterials.map((material) {
                      final isSelected = controller.selectedMaterials.contains(material);
                      final isEnabled = controller.showPartnerOnly.value;

                      return _buildFilterChip(
                        context,
                        label: material,
                        isSelected: isSelected,
                        onTap: isEnabled
                            ? () => controller.toggleMaterialFilter(material)
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              )),
              const SizedBox(height: FSizes.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.clearFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        side: BorderSide(color: FColors.primary),
                      ),
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: FColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(color: FColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, {
        required String label,
        required bool isSelected,
        VoidCallback? onTap,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isDisabled
              ? (dark ? FColors.darkContainer.withOpacity(0.3) : FColors.lightContainer.withOpacity(0.3))
              : isSelected
              ? FColors.primary
              : (dark ? FColors.darkContainer : FColors.lightContainer),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: isDisabled
                ? FColors.darkGrey
                : isSelected
                ? FColors.primary
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDisabled
                ? FColors.darkGrey
                : isSelected
                ? FColors.white
                : (dark ? FColors.white : FColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}