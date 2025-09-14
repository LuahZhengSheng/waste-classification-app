import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../community/models/comment_model.dart';
import '../../../../community/models/post_model.dart';
import '../../../../community/models/reply_model.dart';
import '../../../controllers/community_management/post_detail_controller.dart';
import '../community_management.dart';

class AdminPostDetailsScreen extends StatelessWidget {
  final PostModel post;

  const AdminPostDetailsScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailsController(post));
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Post Details',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          // Toggle Status Button
          Obx(() => Container(
            margin: const EdgeInsets.only(right: FSizes.md),
            child: ElevatedButton.icon(
              onPressed: controller.togglePostStatus,
              icon: Icon(
                controller.currentPost.value.isDisabled ? Iconsax.play : Iconsax.pause,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                controller.currentPost.value.isDisabled ? 'Enable' : 'Disable',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.currentPost.value.isDisabled
                    ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                    : (dark ? FColors.adminDarkError : FColors.adminLightError),
                padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                ),
              ),
            ),
          )),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Details Card
            _buildPostCard(controller.currentPost.value, dark),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Comments Section
            _buildCommentsSection(controller, dark),
          ],
        ),
      )),
    );
  }

  Widget _buildPostCard(PostModel post, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with post metadata
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(FSizes.cardRadiusLg),
                topRight: Radius.circular(FSizes.cardRadiusLg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Post Type Badge
                    _buildPostTypeBadge(post.postType, dark),
                    const Spacer(),
                    // Status Badge
                    _buildStatusBadge(post.isDisabled, dark),
                  ],
                ),
                const SizedBox(height: FSizes.md),

                // Post ID and User ID
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Post ID',
                        post.postId,
                        Iconsax.document_text,
                        dark,
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    Expanded(
                      child: _buildInfoItem(
                        'User ID',
                        post.userId,
                        Iconsax.user,
                        dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.md),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Created',
                        _formatDateTime(post.createdAt),
                        Iconsax.calendar_add,
                        dark,
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    Expanded(
                      child: _buildInfoItem(
                        'Updated',
                        _formatDateTime(post.updatedAt),
                        Iconsax.calendar_edit,
                        dark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Post Content
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkBackground.withOpacity(0.5) : FColors.adminLightBackground,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  ),
                  child: Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ),

                // Media Section
                if (post.media.isNotEmpty) ...[
                  const SizedBox(height: FSizes.spaceBtwItems),
                  Text(
                    'Media (${post.media.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  _buildMediaGrid(post.media, dark),
                ],

                const SizedBox(height: FSizes.spaceBtwItems),

                // Statistics Row
                Row(
                  children: [
                    _buildStatItem(
                      'Likes',
                      post.likes.length.toString(),
                      Iconsax.heart,
                      dark,
                    ),
                    const SizedBox(width: FSizes.xl),
                    _buildStatItem(
                      'Comments',
                      post.commentCount.toString(),
                      Iconsax.message,
                      dark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeBadge(String postType, bool dark) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (postType.toLowerCase()) {
      case 'tip':
        backgroundColor = dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        break;
      case 'discussion':
        backgroundColor = dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        break;
      case 'question':
        backgroundColor = dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        break;
      case 'achievement':
        backgroundColor = const Color(0xFF8B5CF6);
        break;
      default:
        backgroundColor = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        postType.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDisabled, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: isDisabled
            ? (dark ? FColors.adminDarkError : FColors.adminLightError)
            : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDisabled ? Iconsax.pause : Iconsax.play,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: FSizes.xs),
          Text(
            isDisabled ? 'DISABLED' : 'ACTIVE',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(List<String> media, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkBackground.withOpacity(0.5) : FColors.adminLightBackground,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      padding: const EdgeInsets.all(FSizes.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: FSizes.sm,
          mainAxisSpacing: FSizes.sm,
          childAspectRatio: 1,
        ),
        itemCount: media.length,
        itemBuilder: (context, index) {
          final mediaUrl = media[index];
          return GestureDetector(
            onTap: () => _showMediaDialog(media, index, dark),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                border: Border.all(
                  color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusSm - 0.5),
                child: _isImageUrl(mediaUrl)
                    ? Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Iconsax.image,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                )
                    : Icon(
                  Iconsax.video_play,
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool dark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(FSizes.sm),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkPrimary.withOpacity(0.1)
                : FColors.adminLightPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
        ),
        const SizedBox(width: FSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsSection(PostDetailsController controller, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments Header
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(FSizes.cardRadiusLg),
                topRight: Radius.circular(FSizes.cardRadiusLg),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.message,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Comments (${controller.comments.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const Spacer(),
                if (controller.comments.isNotEmpty)
                  Obx(() => IconButton(
                    onPressed: controller.toggleCommentsExpanded,
                    icon: Icon(
                      controller.isCommentsExpanded.value
                          ? Iconsax.arrow_up_2
                          : Iconsax.arrow_down_1,
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                    tooltip: controller.isCommentsExpanded.value ? 'Collapse' : 'Expand',
                  )),
              ],
            ),
          ),

          // Comments List
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: controller.isCommentsExpanded.value
                ? null
                : (controller.comments.isEmpty ? 100 : 200),
            child: controller.comments.isEmpty
                ? _buildEmptyCommentsState(dark)
                : ListView.separated(
              shrinkWrap: true,
              physics: controller.isCommentsExpanded.value
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: controller.comments.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
              ),
              itemBuilder: (context, index) {
                final comment = controller.comments[index];
                return _buildCommentItem(comment, controller, dark);
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyCommentsState(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.message_question,
              size: 48,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 16,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, PostDetailsController controller, bool dark) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.all(FSizes.lg),
      childrenPadding: const EdgeInsets.only(
        left: FSizes.xl,
        right: FSizes.lg,
        bottom: FSizes.lg,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
        ),
        child: const Icon(
          Iconsax.user,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              comment.userId,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
          ),
          Text(
            _formatDateTime(comment.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: FSizes.sm),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Row(
            children: [
              Icon(
                Iconsax.heart,
                size: 16,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                '${comment.likes.length} likes',
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Icon(
                Iconsax.message_2,
                size: 16,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                '${comment.replyCount} replies',
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      children: comment.replies.map((reply) => _buildReplyItem(reply, dark)).toList(),
    );
  }

  Widget _buildReplyItem(Reply reply, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkBackground.withOpacity(0.5) : FColors.adminLightBackground,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
            ),
            child: const Icon(
              Iconsax.user,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.userId,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(reply.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  reply.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Row(
                  children: [
                    Icon(
                      Iconsax.heart,
                      size: 14,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      '${reply.likes.length} likes',
                      style: TextStyle(
                        fontSize: 11,
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _showMediaDialog(List<String> media, int initialIndex, bool dark) {
    // Reuse the MediaPreviewDialog from the management screen
    showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => MediaPreviewDialog(
        media: media,
        initialIndex: initialIndex,
        dark: dark,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)}, ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}