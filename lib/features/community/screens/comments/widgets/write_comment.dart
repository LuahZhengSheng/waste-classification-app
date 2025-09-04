import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/screens/view_post/post_detail.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class FWriteCommentInput extends StatelessWidget {
  const FWriteCommentInput({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailsController>();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: FSizes.md,
        right: FSizes.md,
        top: FSizes.sm,
        bottom: MediaQuery.of(context).padding.bottom + FSizes.sm,
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              controller.getUserAvatar(controller.getCurrentUserId()),
            ),
          ),

          const SizedBox(width: FSizes.sm),

          // Input field
          Expanded(
            child: TextField(
              controller: controller.commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
              ),
              maxLines: null,
            ),
          ),

          const SizedBox(width: FSizes.sm),

          // Send button
          GestureDetector(
            onTap: () => controller.addComment(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}