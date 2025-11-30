import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:get/get.dart';

import '../../common_post_widgets/common_post_widgets.dart';

class FWriteCommentInput extends StatelessWidget {
  final String postId;

  const FWriteCommentInput({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommentController>();

    // 【修改】使用 Obx 包裹，监听 isSubmitting 和 isEditMode 变化
    return Obx(() {
      print('🔄 FWriteCommentInput rebuilding');
      print('   isSubmitting: ${controller.isSubmitting.value}');
      print('   isEditMode: ${controller.isEditMode.value}');

      return FInputField(
        controller: controller.commentController,
        focusNode: controller.commentFocusNode,
        isEnabled: !controller.isSubmitting.value,
        isSubmitting: controller.isSubmitting.value,
        hintText: 'Write a comment...',
        isEditMode: controller.isEditMode.value,
        onSubmit: () {
          print('📤 Submit button pressed');
          if (controller.isEditMode.value) {
            controller.saveEdit();
          } else {
            controller.addComment(postId);
          }
        },
        onCancel: () => controller.cancelEdit(),
        isComment: true,
      );
    });
  }
}
