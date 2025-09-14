// statistics_card.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.color,
    required this.icon,
    required this.dark,
  });

  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final Color color;
  final IconData icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: FSizes.iconMd,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                      size: 12,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            title,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// chart_card.dart
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.dark,
    required this.child,
  });

  final String title;
  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontSize: FSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Add functionality to view detailed chart
                },
                icon: Icon(
                  Iconsax.more,
                  color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon,
                  size: FSizes.iconSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          child,
        ],
      ),
    );
  }
}

// recent_activity_card.dart
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.title,
    required this.dark,
    required this.items,
    required this.itemBuilder,
  });

  final String title;
  final bool dark;
  final List<Map<String, dynamic>> items;
  final Widget Function(Map<String, dynamic> item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontSize: FSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to view all
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          SizedBox(
            height: 300,
            child: ListView.separated(
              itemCount: items.length > 5 ? 5 : items.length,
              separatorBuilder: (context, index) => Divider(
                color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                height: 1,
              ),
              itemBuilder: (context, index) => itemBuilder(items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

// dashboard_metric_card.dart
class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.dark,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: Border.all(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkPrimary.withOpacity(0.1)
                        : FColors.adminLightPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    size: FSizes.iconMd,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Iconsax.arrow_right_3,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    size: FSizes.iconSm,
                  ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              value,
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              title,
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontSize: FSizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              subtitle,
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// engagement_overview_card.dart
class EngagementOverviewCard extends StatelessWidget {
  const EngagementOverviewCard({
    super.key,
    required this.dark,
    required this.engagementRate,
    required this.totalInteractions,
    required this.growthRate,
  });

  final bool dark;
  final double engagementRate;
  final int totalInteractions;
  final double growthRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
            FColors.adminDarkPrimary.withOpacity(0.1),
            FColors.adminDarkSecondary.withOpacity(0.1),
          ]
              : [
            FColors.adminLightPrimary.withOpacity(0.1),
            FColors.adminLightSecondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.adminDarkPrimary.withOpacity(0.3)
              : FColors.adminLightPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: const Icon(
                  Iconsax.activity,
                  color: Colors.white,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Engagement',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        fontSize: FSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Overall platform activity',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwSections),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Engagement Rate',
                  '${engagementRate.toStringAsFixed(1)}%',
                  dark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
              ),
              Expanded(
                child: _buildMetric(
                  'Total Interactions',
                  totalInteractions.toString(),
                  dark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
              ),
              Expanded(
                child: _buildMetric(
                  'Growth Rate',
                  '+${growthRate.toStringAsFixed(1)}%',
                  dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value, bool dark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}