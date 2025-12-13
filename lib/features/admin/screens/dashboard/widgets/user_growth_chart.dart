import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class UserGrowthChart extends StatelessWidget {
  final Map<String, int> growthData;

  const UserGrowthChart({
    super.key,
    required this.growthData,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    // Sort data by month
    final sortedEntries = growthData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Take last 6 months
    final last6Months = sortedEntries.length > 6
        ? sortedEntries.sublist(sortedEntries.length - 6)
        : sortedEntries;

    if (last6Months.isEmpty) {
      return _buildEmptyState(dark);
    }

    // Create chart data
    final spots = last6Months.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    final maxValue = last6Months.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue * 1.2).toDouble();

    // 🆕 计算合适的 Y 轴间隔
    final yInterval = _calculateYInterval(maxValue);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Growth (Last 6 Months)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
              // 🆕 Total users indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: (dark
                      ? FColors.adminDarkSuccess
                      : FColors.adminLightSuccess)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Text(
                  'Total: ${last6Months.map((e) => e.value).reduce((a, b) => a + b)} users',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: dark
                        ? FColors.adminDarkSuccess
                        : FColors.adminLightSuccess,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Chart
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval, // 🆕 使用计算的间隔
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: dark
                          ? FColors.adminDarkBorder
                          : FColors.adminLightBorder,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: yInterval, // 🆕 使用相同间隔
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
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1, // 🆕 确保每个月都显示
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= last6Months.length) {
                          return const SizedBox.shrink();
                        }

                        final monthKey = last6Months[index].key.split('-');
                        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        final monthIndex = int.parse(monthKey[1]) - 1;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            monthNames[monthIndex],
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
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (last6Months.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: dark
                        ? FColors.adminDarkSuccess
                        : FColors.adminLightSuccess,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: dark
                              ? FColors.adminDarkSuccess
                              : FColors.adminLightSuccess,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (dark
                              ? FColors.adminDarkSuccess
                              : FColors.adminLightSuccess)
                              .withOpacity(0.3),
                          (dark
                              ? FColors.adminDarkSuccess
                              : FColors.adminLightSuccess)
                              .withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => dark
                        ? FColors.adminDarkSurface
                        : FColors.adminLightSurface,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= last6Months.length) {
                          return null;
                        }

                        final monthKey = last6Months[index].key.split('-');
                        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        final monthIndex = int.parse(monthKey[1]) - 1;
                        final monthName = monthNames[monthIndex];

                        return LineTooltipItem(
                          '$monthName ${monthKey[0]}\n${spot.y.toInt()} users',
                          TextStyle(
                            color: dark
                                ? FColors.adminDarkText
                                : FColors.adminLightText,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: (dark
                              ? FColors.adminDarkSuccess
                              : FColors.adminLightSuccess)
                              .withOpacity(0.5),
                          strokeWidth: 2,
                          dashArray: [5, 5],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: dark
                                  ? FColors.adminDarkSuccess
                                  : FColors.adminLightSuccess,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🆕 计算合适的 Y 轴间隔
  double _calculateYInterval(int maxValue) {
    if (maxValue <= 5) return 1.0;
    if (maxValue <= 10) return 2.0;
    if (maxValue <= 20) return 5.0;
    if (maxValue <= 50) return 10.0;
    if (maxValue <= 100) return 20.0;
    if (maxValue <= 200) return 50.0;
    return 100.0;
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
              Iconsax.chart,
              size: 48,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No user growth data available',
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
