import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class RecyclingTrendChart extends StatelessWidget {
  final Map<String, double> trendData;

  const RecyclingTrendChart({
    super.key,
    required this.trendData,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    // 🆕 合并同一天的数据
    final Map<String, double> aggregatedData = {};

    for (var entry in trendData.entries) {
      try {
        // 解析日期，只保留日期部分（忽略时间）
        final date = DateTime.parse(entry.key);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        // 累加同一天的数据
        aggregatedData[dateKey] = (aggregatedData[dateKey] ?? 0.0) + entry.value;
      } catch (e) {
        print('Error parsing date: ${entry.key}');
      }
    }

    // Sort data by date
    final sortedEntries = aggregatedData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Take last 7 days
    final last7Days = sortedEntries.length > 7
        ? sortedEntries.sublist(sortedEntries.length - 7)
        : sortedEntries;

    if (last7Days.isEmpty) {
      return _buildEmptyState(dark);
    }

    // Create chart data
    final spots = last7Days.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final maxY = (last7Days.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2);

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
                'Recycling Trend (Last 7 Days)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
              // Total weight indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: (dark
                      ? FColors.adminDarkPrimary
                      : FColors.adminLightPrimary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Text(
                  'Total: ${last7Days.map((e) => e.value).reduce((a, b) => a + b).toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: dark
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
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
                  horizontalInterval: maxY > 0 ? maxY / 5 : 1,
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
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}kg',
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
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= last7Days.length) {
                          return const SizedBox.shrink();
                        }

                        final date = DateTime.parse(last7Days[index].key);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
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
                maxX: (last7Days.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: dark
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
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
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (dark
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary)
                              .withOpacity(0.3),
                          (dark
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary)
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
                    // 🆕 移除 tooltipRoundedRadius，使用 tooltipBorder 替代
                    getTooltipColor: (touchedSpot) => dark
                        ? FColors.adminDarkSurface
                        : FColors.adminLightSurface,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= last7Days.length) {
                          return null;
                        }

                        final date = DateTime.parse(last7Days[index].key);
                        return LineTooltipItem(
                          '${date.day}/${date.month}\n${spot.y.toStringAsFixed(1)} kg',
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
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary)
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
                                  ? FColors.adminDarkPrimary
                                  : FColors.adminLightPrimary,
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
              'No recycling data available',
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
