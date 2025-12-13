import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/models/post_enums.dart';

class PostReportDialog extends StatelessWidget {
  final PostModel post;
  final bool dark;

  const PostReportDialog({
    super.key,
    required this.post,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total report instances
    int totalInstances = 0;
    post.reports.forEach((key, value) {
      totalInstances += value.length;
    });

    // Sort reports by count
    final sortedReports = post.reports.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Dialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkError.withOpacity(0.1)
                    : FColors.adminLightError.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FSizes.cardRadiusLg),
                  topRight: Radius.circular(FSizes.cardRadiusLg),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: dark
                          ? FColors.adminDarkError.withOpacity(0.2)
                          : FColors.adminLightError.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.warning_2,
                      color: dark ? FColors.adminDarkError : FColors.adminLightError,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post Reports',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${post.reportCount} unique reporter${post.reportCount > 1 ? 's' : ''} • $totalInstances total report${totalInstances > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Post Info
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkBackground.withOpacity(0.5)
                    : FColors.adminLightBackground,
                border: Border(
                  bottom: BorderSide(
                    color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.document_text,
                        size: 16,
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                      const SizedBox(width: FSizes.xs),
                      Text(
                        'Post Content',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                    child: Text(
                      post.content.length > 150
                          ? '${post.content.substring(0, 150)}...'
                          : post.content,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Report Statistics
            Flexible(
              child: sortedReports.isEmpty
                  ? _buildNoReportsState()
                  : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: sortedReports.length,
                itemBuilder: (context, index) {
                  final entry = sortedReports[index];
                  final reportOption = ReportOption.fromString(entry.key);
                  final reportCount = entry.value.length;

                  return _buildReportItem(
                    reportOption: reportOption,
                    reportCount: reportCount,
                    totalReports: totalInstances,
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkBackground.withOpacity(0.5)
                    : FColors.adminLightBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(FSizes.cardRadiusLg),
                  bottomRight: Radius.circular(FSizes.cardRadiusLg),
                ),
                border: Border(
                  top: BorderSide(
                    color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 16,
                    color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Text(
                      'Review reports carefully before taking action',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.lg,
                        vertical: FSizes.md,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoReportsState() {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl * 2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.shield_tick,
              size: 64,
              color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'This post has no reports',
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem({
    required ReportOption? reportOption,
    required int reportCount,
    required int totalReports,
  }) {
    final percentage = (reportCount / totalReports * 100).toStringAsFixed(1);

    // Get color based on report type severity
    Color getReportColor() {
      if (reportOption == null) return dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;

      switch (reportOption) {
        case ReportOption.hateSpeech:
        case ReportOption.violence:
        case ReportOption.harassment:
          return dark ? FColors.adminDarkError : FColors.adminLightError;
        case ReportOption.spam:
        case ReportOption.falseInformation:
          return dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        case ReportOption.inappropriateContent:
          return dark ? FColors.adminDarkError.withOpacity(0.8) : FColors.adminLightError.withOpacity(0.8);
        default:
          return dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
      }
    }

    final color = getReportColor();
    final displayName = reportOption?.displayName ?? 'Unknown';
    final description = reportOption?.description ?? 'No description available';

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Report type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForReportType(reportOption),
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reportCount.toString(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'report${reportCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkSurfaceVariant
                        : FColors.adminLightSurfaceVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: reportCount / totalReports,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForReportType(ReportOption? option) {
    if (option == null) return Iconsax.info_circle;

    switch (option) {
      case ReportOption.spam:
        return Iconsax.message_remove;
      case ReportOption.harassment:
        return Iconsax.warning_2;
      case ReportOption.hateSpeech:
        return Iconsax.danger;
      case ReportOption.falseInformation:
        return Iconsax.document_text;
      case ReportOption.inappropriateContent:
        return Iconsax.eye_slash;
      case ReportOption.violence:
        return Iconsax.shield_cross;
      case ReportOption.other:
        return Iconsax.more_circle;
    }
  }
}