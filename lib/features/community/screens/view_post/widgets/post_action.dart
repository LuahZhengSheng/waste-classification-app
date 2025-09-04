import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/view_post.dart';
import 'package:fyp/features/community/screens/view_post/widgets/action_button.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

// Post actions widgets (like, comment buttons)
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
    return Row(
      children: [
        FActionButton(
          icon: isLiked ? Iconsax.like_15 : Iconsax.like_1,
          text: _formatCount(post.likes.length),
          backgroundColor: isLiked ? const Color(0xFF4CAF50) : Colors.grey[200]!,
          iconColor: isLiked ? Colors.white : Colors.grey[600]!,
          textColor: isLiked ? Colors.white : Colors.grey[600]!,
          hasHoverEffect: true,
          onPressed: onLikePressed,
        ),
        const SizedBox(width: FSizes.spaceBtwItems),
        FActionButton(
          icon: Iconsax.message,
          text: _formatCount(post.commentCount),
          backgroundColor: Colors.grey[200]!,
          iconColor: Colors.grey[600]!,
          textColor: Colors.grey[600]!,
          hasHoverEffect: true,
          onPressed: onCommentPressed,
        ),
      ],
    );
  }

  // Format count display (1.2K, etc.)
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