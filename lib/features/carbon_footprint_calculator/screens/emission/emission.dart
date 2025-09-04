import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/controllers/emission_controller.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/emission/emission.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class EmissionsScreen extends StatelessWidget {
  const EmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmissionsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(
          'Emissions',
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
            // Title Section
            Text(
              'My Relative Emissions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Annual Kilograms Pollution (CO2e)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Chart Section
            Obx(() => _buildChartSection(context, controller, dark)),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Legend Section
            _buildLegendSection(context, dark),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Comparison Card
            Obx(() => _buildComparisonCard(context, controller, dark)),

            const SizedBox(height: FSizes.md),

            // Emissions Profile Card
            _buildEmissionsProfileCard(context, controller, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, EmissionsController controller, bool dark) {
    return Stack(
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.all(FSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBarChart(context, controller, 'You', controller.userEmissions, true),
              _buildBarChart(context, controller, 'All Users Avg', controller.avgEmissions, false),
            ],
          ),
        ),
        // Overlay when no emissions calculated
        if (!controller.hasCalculatedEmissions.value)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco,
                      size: 48,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: FSizes.md),
                    Text(
                      'Calculate your emissions first',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, EmissionsController controller, String label, Map<String, double> data, bool isUser) {
    final totalEmissions = data.values.fold(0.0, (sum, value) => sum + value);

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTapDown: (details) {
              if (controller.hasCalculatedEmissions.value && isUser) {
                controller.showTooltip(details.localPosition, data);
              }
            },
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildStackedBar(data, totalEmissions),
              ),
            ),
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          totalEmissions.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStackedBar(Map<String, double> data, double total) {
    if (total == 0) return [Container(height: 20, width: 80, color: Colors.grey[300])];

    final categories = ['Land Travel', 'Air Travel', 'Energy', 'Food', 'Stuff'];
    final colors = [
      FColors.primary,
      const Color(0xFFE91E63),
      const Color(0xFFFFEB3B),
      const Color(0xFFFF5722),
      const Color(0xFFF44336),
    ];

    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final value = data[category] ?? 0.0;
      final height = (value / total) * 200; // Max height 200

      return Container(
        height: height,
        width: 80,
        color: colors[index],
      );
    }).toList();
  }

  Widget _buildLegendSection(BuildContext context, bool dark) {
    final legendItems = [
      ('Land Travel', FColors.primary),
      ('Air Travel', const Color(0xFFE91E63)),
      ('Energy', const Color(0xFFFFEB3B)),
      ('Food', const Color(0xFFFF5722)),
      ('Stuff', const Color(0xFFF44336)),
    ];

    return Wrap(
      spacing: FSizes.md,
      runSpacing: FSizes.sm,
      children: legendItems.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: item.$2,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              item.$1,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildComparisonCard(BuildContext context, EmissionsController controller, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkGrey.withOpacity(0.1) : FColors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: Column(
        children: [
          Text(
            '${controller.comparisonPercentage.value.toStringAsFixed(0)}% more',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            'than All Users Average',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmissionsProfileCard(BuildContext context, EmissionsController controller, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: FColors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emissions Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            'Update Your Inputs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
            ),
          ),
          const SizedBox(height: FSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.navigateToEmissionsProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                ),
              ),
              child: Text(
                'Calculate Emission',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: FColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

