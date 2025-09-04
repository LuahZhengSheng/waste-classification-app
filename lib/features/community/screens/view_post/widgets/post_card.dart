import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/post_detail.dart';
import 'package:fyp/features/community/screens/view_post/view_post.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_action.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_media.dart';
import 'package:fyp/features/community/screens/view_post/widgets/user_info.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Post card widgets
class FPostCard extends StatelessWidget {
  final PostModel post;

  const FPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostsController>();
    final currentUserId = controller.getCurrentUserId();
    final isUserPost = post.userId == currentUserId;

    return GestureDetector(
      onTap: () {
        // Navigate to post detail screen
        Get.to(() => PostDetailsScreen(postId: post.postId));
      },
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: FColors.white,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: FColors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Info & Post Options
            Row(
              children: [
                Expanded(
                  child: FUserInfo(
                    userId: post.userId,
                    timeAgo: _formatTimeAgo(post.createdAt),
                    postType: post.postType,
                  ),
                ),
                // Show more options if user owns the post
                if (isUserPost)
                  IconButton(
                    onPressed: () => _showPostOptions(context, post),
                    icon: const Icon(Iconsax.more),
                    iconSize: FSizes.iconMd,
                    color: Colors.grey[600],
                  ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            /// Post Content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),

            /// Post Media (if any)
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: FSizes.spaceBtwItems),
              FPostMedia(mediaUrls: post.media),
            ],

            const SizedBox(height: FSizes.spaceBtwItems),

            /// Action Buttons - 用 Obx 包装以监听 likes 变化
            Obx(() {
              final currentPost = controller.posts.firstWhere((p) => p.postId == post.postId, orElse: () => post);
              final isLiked = currentPost.likes.contains(currentUserId);

              return FPostActions(
                post: currentPost,
                isLiked: isLiked,
                onLikePressed: () => controller.toggleLike(post.postId),
                onCommentPressed: () => Get.to(() => ViewPostScreen(postId: post.postId)),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Format time ago display
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  // Show post options (edit/delete)
  void _showPostOptions(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.edit, color: Color(0xFF4CAF50)),
              title: const Text('Edit Post'),
              onTap: () {
                Get.back();
                // Navigate to edit post screen
                Get.to(() => EditPostScreen(post: post));
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context, post);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<PostsController>().deletePost(post.postId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}