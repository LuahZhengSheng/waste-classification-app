import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/reward_model.dart';

enum RewardCardMode {
  redemption, // 显示 pointsNeeded
  myReward,   // 显示时间
}

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final RewardCardMode mode;
  final String? subtitleText;
  final List<String>? tags;
  final VoidCallback? onTap;

  const RewardCard({
    super.key,
    required this.reward,
    required this.mode,
    this.subtitleText,
    this.tags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = FHelperFunctions.isDarkMode(context);

    final effectiveTags = <String>[
      if (tags != null && tags!.isNotEmpty) ...tags!
      else if (mode == RewardCardMode.redemption) 'Promo code',
    ];

    final titleColor = dark ? FColors.darkText : FColors.textPrimary;
    final tagBgColor = dark
        ? FColors.primary.withOpacity(0.25)
        : FColors.primary.withOpacity(0.08);
    final tagTextColor = FColors.primary;
    final subtitleColor = FColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 正方形 rounded image（不加白底）
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1,
              child: reward.rewardImage.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: reward.rewardImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: FColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(
                    Iconsax.gift,
                    size: 40,
                    color: FColors.primary.withOpacity(0.5),
                  ),
                ),
              )
                  : Center(
                child: Icon(
                  Iconsax.gift,
                  size: 40,
                  color: FColors.primary.withOpacity(0.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: FSizes.sm),

          // 标签行
          if (effectiveTags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: effectiveTags
                  .map((tag) => _buildTagChip(tag, tagBgColor, tagTextColor))
                  .toList(),
            ),

          if (effectiveTags.isNotEmpty)
            const SizedBox(height: FSizes.sm),

          // 标题
          Text(
            reward.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: titleColor,
              height: 1.3,
            ),
          ),

          const SizedBox(height: FSizes.sm),

          // 积分/时间
          Text(
            mode == RewardCardMode.redemption
                ? '${reward.pointsNeeded} points'
                : (subtitleText ?? ''),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtitleColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(
      String text,
      Color bgColor,
      Color textColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
