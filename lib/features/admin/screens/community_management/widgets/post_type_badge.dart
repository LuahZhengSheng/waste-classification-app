import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

/// Reusable post type badge widget for admin side
class PostTypeBadge extends StatelessWidget {
  final String postType;
  final bool dark;
  final bool showIcon;
  final double fontSize;

  const PostTypeBadge({
    super.key,
    required this.postType,
    required this.dark,
    this.showIcon = true,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getPostTypeConfig(postType);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor(dark),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
        border: Border.all(
          color: config.borderColor(dark),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: fontSize + 2,
              color: config.textColor(dark),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            postType.toUpperCase(),
            style: TextStyle(
              color: config.textColor(dark),
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  PostTypeConfig _getPostTypeConfig(String type) {
    switch (type.toLowerCase()) {
      case 'tip':
        return PostTypeConfig(
          icon: Iconsax.lamp_charge,
          backgroundColor: (dark) => dark
              ? FColors.adminDarkSuccess.withOpacity(0.15)
              : FColors.adminLightSuccess.withOpacity(0.15),
          borderColor: (dark) => dark
              ? FColors.adminDarkSuccess
              : FColors.adminLightSuccess,
          textColor: (dark) => dark
              ? FColors.adminDarkSuccess
              : FColors.adminLightSuccess,
        );
      case 'discussion':
        return PostTypeConfig(
          icon: Iconsax.message_2,
          backgroundColor: (dark) => dark
              ? FColors.adminDarkInfo.withOpacity(0.15)
              : FColors.adminLightInfo.withOpacity(0.15),
          borderColor: (dark) => dark
              ? FColors.adminDarkInfo
              : FColors.adminLightInfo,
          textColor: (dark) => dark
              ? FColors.adminDarkInfo
              : FColors.adminLightInfo,
        );
      case 'question':
        return PostTypeConfig(
          icon: Iconsax.message_question,
          backgroundColor: (dark) => dark
              ? FColors.adminDarkWarning.withOpacity(0.15)
              : FColors.adminLightWarning.withOpacity(0.15),
          borderColor: (dark) => dark
              ? FColors.adminDarkWarning
              : FColors.adminLightWarning,
          textColor: (dark) => dark
              ? FColors.adminDarkWarning
              : FColors.adminLightWarning,
        );
      case 'achievement':
        return PostTypeConfig(
          icon: Iconsax.crown,
          backgroundColor: (dark) => dark
              ? const Color(0xFF8B5CF6).withOpacity(0.15)
              : const Color(0xFF8B5CF6).withOpacity(0.15),
          borderColor: (dark) => const Color(0xFF8B5CF6),
          textColor: (dark) => const Color(0xFF8B5CF6),
        );
      default:
        return PostTypeConfig(
          icon: Iconsax.document_text,
          backgroundColor: (dark) => dark
              ? FColors.adminDarkTextMuted.withOpacity(0.15)
              : FColors.adminLightTextMuted.withOpacity(0.15),
          borderColor: (dark) => dark
              ? FColors.adminDarkTextMuted
              : FColors.adminLightTextMuted,
          textColor: (dark) => dark
              ? FColors.adminDarkTextMuted
              : FColors.adminLightTextMuted,
        );
    }
  }
}

class PostTypeConfig {
  final IconData icon;
  final Color Function(bool dark) backgroundColor;
  final Color Function(bool dark) borderColor;
  final Color Function(bool dark) textColor;

  PostTypeConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}