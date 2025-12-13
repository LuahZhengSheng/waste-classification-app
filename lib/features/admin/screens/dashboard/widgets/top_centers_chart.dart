import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class TopCentersChart extends StatelessWidget {
  final List<Map<String, dynamic>> topCenters;

  const TopCentersChart({
    super.key,
    required this.topCenters,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    if (topCenters.isEmpty) {
      return _buildEmptyState(dark);
    }

    // Take top 10
    final top10 = topCenters.take(10).toList();
    final maxCount = top10.isNotEmpty
        ? top10.map((e) => e['activityCount'] as int).reduce((a, b) => a > b ? a : b)
        : 100;

    // 🆕 计算合适的 Y 轴间隔
    final maxY = maxCount.toDouble() * 1.2;
    final yInterval = _calculateYInterval(maxCount);

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
            'Top Recycling Centers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Chart
          SizedBox(
            height: 350,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => dark
                        ? FColors.adminDarkSurface
                        : FColors.adminLightSurface,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (group.x.toInt() >= top10.length) {
                        return null;
                      }
                      final centerName = top10[group.x.toInt()]['centerName'] as String;
                      return BarTooltipItem(
                        '$centerName\n',
                        TextStyle(
                          color: dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} activities',
                            style: TextStyle(
                              color: dark
                                  ? FColors.adminDarkTextSecondary
                                  : FColors.adminLightTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      interval: 1, // 🆕 确保每个 bar 都显示标签
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= top10.length) {
                          return const SizedBox.shrink();
                        }
                        final centerName = top10[value.toInt()]['centerName'] as String;

                        // 智能截断名称
                        final displayName = centerName.length > 15
                            ? '${centerName.substring(0, 15)}...'
                            : centerName;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5, // 斜角显示（约 -30 度）
                            alignment: Alignment.topCenter, // 🆕 从上方中心旋转
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 11,
                                color: dark
                                    ? FColors.adminDarkTextSecondary
                                    : FColors.adminLightTextSecondary,
                              ),
                              textAlign: TextAlign.center, // 🆕 居中对齐
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: yInterval, // 🆕 使用计算的间隔
                      getTitlesWidget: (value, meta) {
                        // 🆕 只显示整数值
                        if (value % 1 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: dark
                                  ? FColors.adminDarkTextSecondary
                                  : FColors.adminLightTextSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval, // 🆕 使用相同的间隔
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: dark
                          ? FColors.adminDarkBorder
                          : FColors.adminLightBorder,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: top10.asMap().entries.map((entry) {
                  final index = entry.key;
                  final count = entry.value['activityCount'] as int;

                  // 金银铜牌颜色 + 渐变效果
                  Color barColor;
                  List<Color>? gradientColors;

                  if (index == 0) {
                    // Gold
                    barColor = const Color(0xFFFFD700);
                    gradientColors = [
                      const Color(0xFFFFD700),
                      const Color(0xFFFFE55C),
                    ];
                  } else if (index == 1) {
                    // Silver
                    barColor = const Color(0xFFC0C0C0);
                    gradientColors = [
                      const Color(0xFFC0C0C0),
                      const Color(0xFFE0E0E0),
                    ];
                  } else if (index == 2) {
                    // Bronze
                    barColor = const Color(0xFFCD7F32);
                    gradientColors = [
                      const Color(0xFFCD7F32),
                      const Color(0xFFE69A5A),
                    ];
                  } else {
                    barColor = dark
                        ? FColors.adminDarkInfo
                        : FColors.adminLightInfo;
                    gradientColors = null;
                  }

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: barColor,
                        width: 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        gradient: gradientColors != null
                            ? LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                            : null,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🆕 计算合适的 Y 轴间隔
  double _calculateYInterval(int maxCount) {
    if (maxCount <= 5) return 1.0;
    if (maxCount <= 10) return 2.0;
    if (maxCount <= 20) return 5.0;
    if (maxCount <= 50) return 10.0;
    if (maxCount <= 100) return 20.0;
    return 50.0;
  }

  Widget _buildEmptyState(bool dark) {
    return Container(
      height: 450,
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
              Iconsax.chart,
              size: 48,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No center data available',
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
