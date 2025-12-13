import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class FPostActions extends StatelessWidget {
  final PostModel post;
  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;

  const FPostActions({
    super.key,
    required this.post,
    required this.isLiked,
    this.onLikePressed,
    this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        // ✅ 上半部分：统计数据（87 likes, 10 comments）
        _buildStatsSection(dark),

        const SizedBox(height: FSizes.xs),

        // ✅ 分隔线
        Divider(
          height: 1,
          thickness: 0.5,
          color: dark
              ? FColors.communityDarkBorder.withOpacity(0.3)
              : FColors.grey.withOpacity(0.2),
        ),

        // ✅ 下半部分：操作按钮（Like, Comment）
        _buildActionButtons(dark),
      ],
    );
  }

  /// ✅ 统计数据部分
  Widget _buildStatsSection(bool dark) {
    final hasLikes = post.likes.isNotEmpty;
    final hasComments = post.commentCount > 0;

    // 如果没有任何统计数据，不显示此部分
    if (!hasLikes && !hasComments) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Likes 统计
          if (hasLikes)
            Row(
              children: [
                // 点赞图标（使用表情符号模仿 Facebook）
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: FColors.primary,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.thumb_up,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatCount(post.likes.length),
                  style: TextStyle(
                    fontSize: 13,
                    color: dark ? FColors.grey : FColors.darkGrey,
                  ),
                ),
              ],
            )
          else
            const SizedBox.shrink(),

          // Comments 统计
          if (hasComments)
            Text(
              '${_formatCount(post.commentCount)} comment${post.commentCount > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: dark ? FColors.grey : FColors.darkGrey,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// ✅ 操作按钮部分
  Widget _buildActionButtons(bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Like Button
        Expanded(
          child: _FacebookActionButton(
            icon: isLiked ? Iconsax.like_15 : Iconsax.like_1,
            label: 'Like',
            isActive: isLiked,
            onPressed: onLikePressed,
            dark: dark,
          ),
        ),

        // Comment Button
        Expanded(
          child: _FacebookActionButton(
            icon: Iconsax.message,
            label: 'Comment',
            isActive: false,
            onPressed: onCommentPressed,
            dark: dark,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}

// ✅ Facebook-style Action Button
class _FacebookActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;
  final bool dark;

  const _FacebookActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onPressed,
    required this.dark,
  });

  @override
  State<_FacebookActionButton> createState() => _FacebookActionButtonState();
}

class _FacebookActionButtonState extends State<_FacebookActionButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          vertical: FSizes.sm,
          horizontal: FSizes.xs,
        ),
        decoration: BoxDecoration(
          color: isPressed
              ? (widget.dark
              ? FColors.grey.withOpacity(0.1)
              : FColors.grey.withOpacity(0.15))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: widget.isActive
                  ? FColors.primary
                  : (widget.dark ? FColors.grey : FColors.darkGrey),
              size: 20,
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.isActive
                    ? FColors.primary
                    : (widget.dark ? FColors.grey : FColors.darkGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
