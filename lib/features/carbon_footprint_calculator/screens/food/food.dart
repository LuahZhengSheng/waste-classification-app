// import 'package:flutter/material.dart';
// import 'package:fyp/common/widgets/appbar/appbar.dart';
// import 'package:fyp/common/widgets/options/options_selector.dart';
// import 'package:fyp/common/widgets/options/options_slider.dart';
// import 'package:fyp/features/carbon_footprint_calculator/screens/food/widgets/food_detail_inputs.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:get/get.dart';
//
// class FoodScreen extends StatelessWidget {
//   FoodScreen({super.key});
//
//   final RxInt isVegetarian = 0.obs;
//   final RxInt isVegan = 0.obs;
//   final RxInt isMinimize = 0.obs;
//   final RxInt cowOpt = 0.obs;
//   final RxInt pigOpt = 0.obs;
//   final RxInt chickenOpt = 0.obs;
//   final RxInt fishOpt = 0.obs;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: FAppBar(title: Text('Food', style: Theme.of(context).textTheme.headlineMedium!.apply(color: FColors.primary)), showBackArrow: true),
//       body: Container(
//         padding: const EdgeInsets.all(FSizes.defaultSpace),
//         decoration: const BoxDecoration(
//           color: Color(0xFF0D1B46),
//           borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: FSizes.defaultSpace),
//               const Text('How many days per week do you eat meat or seafood?', style: TextStyle(color: Colors.white, fontSize: 18)),
//               const FOptionsSlider(min: 0, max: 7, activeColor: FColors.white, thumbColor: FColors.primary, sliderWidthFactor: 0.85),
//               const SizedBox(height: FSizes.spaceBtwSections),
//
//               const Text('Are you a vegetarian?', style: TextStyle(color: Colors.white, fontSize: 18)),
//               FOptionsSelector(options: const ["Yes", "No"], selectedIndex: isVegetarian, onSelect: (index) {isVegetarian.value = index;}),
//               const SizedBox(height: FSizes.spaceBtwItems),
//
//               const Text('Are you a vegan?', style: TextStyle(color: Colors.white, fontSize: 18)),
//               FOptionsSelector(options: const ["Yes", "No"], selectedIndex: isVegan, onSelect: (index) {isVegan.value = index;}),
//               const SizedBox(height: FSizes.spaceBtwItems),
//
//               const Text('Do you minimize food waste?', style: TextStyle(color: Colors.white, fontSize: 18)),
//               FOptionsSelector(options: const ["Yes", "No"], selectedIndex: isMinimize, onSelect: (index) {isMinimize.value = index;}),
//               const SizedBox(height: FSizes.spaceBtwItems),
//
//               FFoodDetailInputs(cowOpt: cowOpt, pigOpt: pigOpt, chickenOpt: chickenOpt, fishOpt: fishOpt)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class FoodInputScreen extends StatelessWidget {
  const FoodInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FoodController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(
          'Food',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
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
                color: const Color(0xFFFF5722).withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: const Icon(
                      Iconsax.shop,
                      color: Color(0xFFFF5722),
                      size: FSizes.iconLg,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Food Emissions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Calculate emissions from your diet',
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

            // Diet Type
            Text(
              'Diet Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),

            Obx(() => Wrap(
              spacing: FSizes.sm,
              children: controller.dietTypes.map((type) {
                final isSelected = controller.selectedDietType.value == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedDietType.value = type;
                      controller.calculateEmissions();
                    }
                  },
                  selectedColor: const Color(0xFFFF5722).withOpacity(0.2),
                  backgroundColor: dark ? FColors.darkContainer : FColors.lightContainer,
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Meat Consumption
            Text(
              'Meat Consumption per Week',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),

            Obx(() => Column(
              children: controller.meatTypes.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: FSizes.md),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Slider(
                          value: controller.meatConsumption[entry.key]?.value ?? 0.0,
                          min: 0,
                          max: 7,
                          divisions: 14,
                          activeColor: const Color(0xFFFF5722),
                          label: '${controller.meatConsumption[entry.key]?.value.toStringAsFixed(1)} servings',
                          onChanged: (value) {
                            controller.meatConsumption[entry.key]?.value = value;
                            controller.calculateEmissions();
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${controller.meatConsumption[entry.key]?.value.toStringAsFixed(1)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Dairy & Eggs
            Text(
              'Dairy & Eggs per Week',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),

            Obx(() => Column(
              children: controller.dairyTypes.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: FSizes.md),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Slider(
                          value: controller.dairyConsumption[entry.key]?.value ?? 0.0,
                          min: 0,
                          max: 14,
                          divisions: 14,
                          activeColor: const Color(0xFFFF5722),
                          label: '${controller.dairyConsumption[entry.key]?.value.toStringAsFixed(1)} servings',
                          onChanged: (value) {
                            controller.dairyConsumption[entry.key]?.value = value;
                            controller.calculateEmissions();
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${controller.dairyConsumption[entry.key]?.value.toStringAsFixed(1)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Local Food Preference
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark ? FColors.darkContainer : FColors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prefer Local/Seasonal Food',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '10% reduction in emissions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FColors.success,
                        ),
                      ),
                    ],
                  ),
                  Obx(() => Switch(
                    value: controller.preferLocalFood.value,
                    activeColor: const Color(0xFFFF5722),
                    onChanged: (value) {
                      controller.preferLocalFood.value = value;
                      controller.calculateEmissions();
                    },
                  )),
                ],
              ),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Results Card
            Obx(() => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF5722).withOpacity(0.1),
                    const Color(0xFFFF5722).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: const Color(0xFFFF5722).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Iconsax.calculator,
                        color: Color(0xFFFF5722),
                        size: FSizes.iconMd,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Text(
                        'Estimated Annual Emissions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${controller.calculatedEmissions.value.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFFFF5722),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'CO2e per year',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dark ? FColors.darkGrey : FColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(FSizes.sm),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5722).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                        ),
                        child: const Icon(
                          Iconsax.shop,
                          color: Color(0xFFFF5722),
                          size: FSizes.iconLg,
                        ),
                      ),
                    ],
                  ),
                  if (controller.calculatedEmissions.value > 0) ...[
                    const SizedBox(height: FSizes.md),
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: dark ? FColors.darkContainer : FColors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diet type: ${controller.selectedDietType.value}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (controller.preferLocalFood.value)
                            Text(
                              '✓ Local food preference applied',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: FColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
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
                  backgroundColor: const Color(0xFFFF5722),
                  disabledBackgroundColor: FColors.buttonDisabled,
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                  elevation: FSizes.buttonElevation,
                ),
                child: Text(
                  'Save Food Emissions',
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

class FoodController extends GetxController {
  final dietTypes = ['Omnivore', 'Vegetarian', 'Vegan', 'Pescatarian'].obs;
  final selectedDietType = 'Omnivore'.obs;
  final preferLocalFood = false.obs;
  final calculatedEmissions = 0.0.obs;

  // Meat types and their emission factors (kg CO2e per serving)
  final meatTypes = {
    'Beef': 6.61,
    'Pork': 2.45,
    'Chicken': 1.57,
    'Fish': 1.70,
  };

  final meatConsumption = <String, RxDouble>{}.obs;

  // Dairy types and their emission factors (kg CO2e per serving)
  final dairyTypes = {
    'Milk': 0.63,
    'Cheese': 2.78,
    'Eggs': 0.51,
  };

  final dairyConsumption = <String, RxDouble>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initializeConsumption();
    calculateEmissions();
  }

  void initializeConsumption() {
    // Initialize meat consumption with default values based on diet type
    for (String meatType in meatTypes.keys) {
      meatConsumption[meatType] = 2.0.obs;
    }

    // Initialize dairy consumption
    for (String dairyType in dairyTypes.keys) {
      dairyConsumption[dairyType] = 3.0.obs;
    }
  }

  void calculateEmissions() {
    double totalEmissions = 0.0;

    // Calculate meat emissions based on diet type
    if (selectedDietType.value != 'Vegan') {
      meatConsumption.forEach((type, consumption) {
        if (selectedDietType.value == 'Vegetarian' && type != 'Fish') {
          return; // Skip non-fish meat for vegetarians
        }
        if (selectedDietType.value == 'Pescatarian' && type != 'Fish') {
          return; // Only fish for pescatarians
        }

        final emissionFactor = meatTypes[type] ?? 0.0;
        totalEmissions += consumption.value * emissionFactor * 52; // Weekly to annual
      });
    }

    // Calculate dairy emissions (vegans don't consume dairy)
    if (selectedDietType.value != 'Vegan') {
      dairyConsumption.forEach((type, consumption) {
        final emissionFactor = dairyTypes[type] ?? 0.0;
        totalEmissions += consumption.value * emissionFactor * 52; // Weekly to annual
      });
    }

    // Apply diet type base emissions (including plant-based foods)
    final Map<String, double> baseDietEmissions = {
      'Omnivore': 500.0, // Base plant + processed food emissions
      'Vegetarian': 400.0,
      'Vegan': 300.0,
      'Pescatarian': 450.0,
    };

    totalEmissions += baseDietEmissions[selectedDietType.value] ?? 500.0;

    // Apply local food preference discount
    if (preferLocalFood.value) {
      totalEmissions *= 0.9; // 10% reduction for local/seasonal preference
    }

    calculatedEmissions.value = totalEmissions;
  }

  void saveEmissions() {
    try {
      final emissionData = {
        'category': 'food',
        'dietType': selectedDietType.value,
        'preferLocalFood': preferLocalFood.value,
        'meatConsumption': meatConsumption.map((key, value) => MapEntry(key, value.value)),
        'dairyConsumption': dairyConsumption.map((key, value) => MapEntry(key, value.value)),
        'annualEmissions': calculatedEmissions.value,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Here you would typically save to your backend or local storage
      // For now, we'll just show a success message

      FHelperFunctions.showSnackBar('Food emissions saved successfully! ${calculatedEmissions.value.toStringAsFixed(1)} kg CO2e/year');
      Get.back(result: {
        'category': 'food',
        'emissions': calculatedEmissions.value,
        'data': emissionData,
      });
    } catch (e) {
      FHelperFunctions.showAlert('Error', 'Failed to save emissions: $e');
    }
  }

  void resetToDefaults() {
    selectedDietType.value = 'Omnivore';
    preferLocalFood.value = false;
    initializeConsumption();
    calculateEmissions();
  }
}