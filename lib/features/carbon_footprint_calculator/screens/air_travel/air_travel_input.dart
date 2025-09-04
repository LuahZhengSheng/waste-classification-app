import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/emission_profile/emission_profile.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class AirTravelInputScreen extends StatelessWidget {
  const AirTravelInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AirTravelController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(
          'Air Travel',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: const Icon(
                      Iconsax.airplane,
                      color: Color(0xFFE91E63),
                      size: FSizes.iconLg,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Air Travel Emissions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Calculate emissions from flights',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Flight Type Selection
            Text(
              'Flight Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Obx(() => Wrap(
              spacing: FSizes.sm,
              children: controller.flightTypes.map((type) {
                final isSelected = controller.selectedFlightType.value == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.selectedFlightType.value = type;
                  },
                  selectedColor: const Color(0xFFE91E63).withOpacity(0.2),
                  backgroundColor: dark ? FColors.darkContainer : FColors.lightContainer,
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Number of Flights
            Text(
              'Number of Round Trips per Year',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            TextFormField(
              controller: controller.flightsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter number of round trips',
                prefixIcon: Icon(Iconsax.airplane),
                suffixText: 'trips',
              ),
              onChanged: (value) => controller.calculateEmissions(),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Average Flight Distance
            Text(
              'Average Flight Distance (km)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            TextFormField(
              controller: controller.distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter average flight distance',
                prefixIcon: Icon(Iconsax.global),
                suffixText: 'km',
              ),
              onChanged: (value) => controller.calculateEmissions(),
            ),

            const SizedBox(height: FSizes.md),

            // Distance helper buttons
            Wrap(
              spacing: FSizes.sm,
              children: controller.distancePresets.entries.map((entry) {
                return OutlinedButton(
                  onPressed: () => controller.setDistancePreset(entry.value),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: FColors.primary.withOpacity(0.5)),
                  ),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Results Card
            Obx(() => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: dark ? FColors.darkContainer : FColors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Annual Emissions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.calculatedEmissions.value.toStringAsFixed(2)} kg CO2e',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFFE91E63),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Iconsax.airplane,
                        color: Color(0xFFE91E63),
                        size: FSizes.iconLg,
                      ),
                    ],
                  ),
                  if (controller.calculatedEmissions.value > 0) ...[
                    const SizedBox(height: FSizes.sm),
                    Text(
                      '${controller.flightsController.text} ${controller.selectedFlightType.value.toLowerCase()} flights/year',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.calculatedEmissions.value > 0
                    ? () => controller.saveEmissions()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: Text(
                  'Save Air Travel Emissions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: FColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AirTravelController extends GetxController {
  final flightsController = TextEditingController();
  final distanceController = TextEditingController();

  final flightTypes = ['Domestic', 'Short-haul', 'Long-haul'].obs;
  final selectedFlightType = 'Domestic'.obs;
  final calculatedEmissions = 0.0.obs;

  // Distance presets for common routes
  final distancePresets = {
    'Domestic (500km)': 500.0,
    'Regional (1500km)': 1500.0,
    'International (5000km)': 5000.0,
    'Long-haul (10000km)': 10000.0,
  };

  // Emission factors (kg CO2e per passenger per km)
  final Map<String, double> emissionFactors = {
    'Domestic': 0.255,     // Short domestic flights
    'Short-haul': 0.156,   // Medium efficiency
    'Long-haul': 0.150,    // Better efficiency on long flights
  };

  void calculateEmissions() {
    final flights = double.tryParse(flightsController.text) ?? 0.0;
    final distance = double.tryParse(distanceController.text) ?? 0.0;

    if (flights > 0 && distance > 0) {
      final emissionFactor = emissionFactors[selectedFlightType.value] ?? 0.156;

      // Calculate total annual emissions
      // Round trips = 2 * one-way distance
      calculatedEmissions.value = flights * distance * 2 * emissionFactor;
    } else {
      calculatedEmissions.value = 0.0;
    }
  }

  void setDistancePreset(double distance) {
    distanceController.text = distance.toStringAsFixed(0);
    calculateEmissions();
  }

  void saveEmissions() {
    final emissionData = {
      'flightType': selectedFlightType.value,
      'numberOfFlights': double.tryParse(flightsController.text) ?? 0.0,
      'averageDistance': double.tryParse(distanceController.text) ?? 0.0,
      'annualEmissions': calculatedEmissions.value,
    };

    // Update emissions profile
    final profileController = Get.find<EmissionsProfileController>();
    profileController.updateCategoryEmission('air_travel', calculatedEmissions.value);

    FHelperFunctions.showSnackBar('Air travel emissions saved successfully!');
    Get.back();
  }

  @override
  void onClose() {
    flightsController.dispose();
    distanceController.dispose();
    super.onClose();
  }
}