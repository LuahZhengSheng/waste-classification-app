import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/screens/view_post/view_post.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

// User info widgets
class FUserInfo extends StatelessWidget {
  final String userId;
  final String timeAgo;
  final String postType;

  const FUserInfo({
    super.key,
    required this.userId,
    required this.timeAgo,
    required this.postType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostsController>();

    return Row(
      children: [
        // User avatar - fetch from controller
        Obx(() => CircleAvatar(
          radius: FSizes.iconMd,
          backgroundImage: NetworkImage(controller.getUserAvatar(userId)),
        )),
        const SizedBox(width: FSizes.spaceBtwItems),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User name - fetch from controller
              Obx(() => Text(
                controller.getUserName(userId),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(height: FSizes.xs),
              Text(
                timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // Post type tag
        FCustomTag(
          text: postType,
          backgroundColor: _getTagBackgroundColor(postType),
          textColor: _getTagTextColor(postType),
        ),
      ],
    );
  }

  // Get tag background color based on post type
  Color _getTagBackgroundColor(String postType) {
    switch (postType.toLowerCase()) {
      case 'tips':
        return const Color(0xFFE8F5E8);
      case 'question':
        return const Color(0xFFF3E5F5);
      case 'discussion':
        return const Color(0xFFE3F2FD);
      default:
        return Colors.grey[200]!;
    }
  }

  // Get tag text color based on post type
  Color _getTagTextColor(String postType) {
    switch (postType.toLowerCase()) {
      case 'tips':
        return const Color(0xFF4CAF50);
      case 'question':
        return const Color(0xFF9C27B0);
      case 'discussion':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey[600]!;
    }
  }
}