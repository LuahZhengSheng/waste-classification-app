import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/air_travel/air_travel_input.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/energy/energy_input.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/food/food.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/land_travel/land_travel_input.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/stuff/stuff_input.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class EmissionsProfileScreen extends StatelessWidget {
  const EmissionsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmissionsProfileController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(
          'Emissions Profile',
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
            // Header Section
            Text(
              'Refine my emissions profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Select a category to improve your estimate',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Categories List
            Container(
              decoration: BoxDecoration(
                color: FColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Obx(() => Column(
                children: controller.categories.map((category) {
                  return _buildCategoryItem(context, controller, category, dark);
                }).toList(),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, EmissionsProfileController controller, EmissionCategory category, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: FSizes.xs),
      child: ListTile(
        onTap: () => controller.navigateToCategory(category),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(FSizes.sm),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
          ),
          child: Icon(
            category.icon,
            color: category.color,
            size: FSizes.iconLg,
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${category.emission.toStringAsFixed(2)} kg',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: FColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'CO2e',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmissionCategory {
  final String name;
  final String id;
  final IconData icon;
  final Color color;
  final double emission;

  EmissionCategory({
    required this.name,
    required this.id,
    required this.icon,
    required this.color,
    required this.emission,
  });
}

class EmissionsProfileController extends GetxController {
  final categories = <EmissionCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeCategories();
  }

  void initializeCategories() {
    categories.value = [
      EmissionCategory(
        name: 'Land Travel',
        id: 'land_travel',
        icon: Iconsax.car,
        color: const Color(0x00755cf1),
        emission: 3.12,
      ),
      EmissionCategory(
        name: 'Air Travel',
        id: 'air_travel',
        icon: Iconsax.airplane,
        color: const Color(0x00E972F9),
        emission: 5.15,
      ),
      EmissionCategory(
        name: 'Energy',
        id: 'energy',
        icon: Iconsax.flash_1,
        color: const Color(0x00EAE60C),
        emission: 2.50,
      ),
      EmissionCategory(
        name: 'Food',
        id: 'food',
        icon: Iconsax.shop,
        color: const Color(0x00FF9191),
        emission: 3.52,
      ),
      EmissionCategory(
        name: 'Stuff',
        id: 'stuff',
        icon: Iconsax.box,
        color: const Color(0x00F72222),
        emission: 7.15,
      ),
    ];
  }

  void navigateToCategory(EmissionCategory category) {
    switch (category.id) {
      case 'land_travel':
        Get.to(() => const LandTravelInputScreen());
        break;
      case 'air_travel':
        Get.to(() => const AirTravelInputScreen());
        break;
      case 'energy':
        Get.to(() => const EnergyInputScreen());
        break;
      case 'food':
        Get.to(() => const FoodInputScreen());
        break;
      case 'stuff':
        Get.to(() => const StuffInputScreen());
        break;
    }
  }

  void updateCategoryEmission(String categoryId, double newEmission) {
    final index = categories.indexWhere((cat) => cat.id == categoryId);
    if (index != -1) {
      categories[index] = EmissionCategory(
        name: categories[index].name,
        id: categories[index].id,
        icon: categories[index].icon,
        color: categories[index].color,
        emission: newEmission,
      );
    }
  }
}