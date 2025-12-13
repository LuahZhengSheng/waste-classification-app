import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class WasteCategoryChart extends StatelessWidget {
  final Map<String, double> distribution;

  const WasteCategoryChart({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    if (distribution.isEmpty) {
      return _buildEmptyState(dark);
    }

    // Calculate total and percentages
    final total = distribution.values.reduce((a, b) => a + b);
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Color palette
    final colors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFFC107), // Amber
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF5722), // Deep Orange
    ];

    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkCard : FColors.adminLightCard,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.adminDarkBorder.withOpacity(0.3)
              : FColors.adminLightBorder.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Waste Distribution by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Chart Content
          SizedBox(
            height: 280,
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 60,
                      sections: sortedEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final percentage = (category.value / total * 100);
                        final color = colors[index % colors.length];

                        // 🆕 只在占比大于5%时显示百分比
                        final showTitle = percentage >= 5.0;

                        return PieChartSectionData(
                          color: color,
                          value: category.value,
                          title: showTitle ? '${percentage.toStringAsFixed(1)}%' : '',
                          radius: 65,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 2),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(width: FSizes.defaultSpace),

                // Legend - 直接使用分类名称（无需 FutureBuilder）
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sortedEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final color = colors[index % colors.length];
                        final percentage = (category.value / total * 100);

                        // 🎯 直接使用 category.key，因为它已经是名称了
                        final categoryName = category.key;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              // Color Box
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Label
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      categoryName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: dark
                                            ? FColors.adminDarkText
                                            : FColors.adminLightText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${category.value.toStringAsFixed(1)} kg',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: dark
                                            ? FColors.adminDarkTextSecondary
                                            : FColors.adminLightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Percentage
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkCard : FColors.adminLightCard,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.adminDarkBorder.withOpacity(0.3)
              : FColors.adminLightBorder.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.chart_21,
              size: 48,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No waste category data available',
              style: TextStyle(
                fontSize: 14,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
