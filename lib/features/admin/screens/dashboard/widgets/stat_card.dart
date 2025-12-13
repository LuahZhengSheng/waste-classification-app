import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final String subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    final isPositiveTrend = trend.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkCard : FColors.adminLightCard,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.adminDarkBorder.withOpacity(0.3)
              : FColors.adminLightBorder.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              // Trend Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isPositiveTrend
                      ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1)
                      : (dark ? FColors.adminDarkError : FColors.adminLightError).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositiveTrend ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                      size: 14,
                      color: isPositiveTrend
                          ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                          : (dark ? FColors.adminDarkError : FColors.adminLightError),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPositiveTrend
                            ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                            : (dark ? FColors.adminDarkError : FColors.adminLightError),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: FSizes.md),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),

          const SizedBox(height: FSizes.xs),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),

          const SizedBox(height: FSizes.xs),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
