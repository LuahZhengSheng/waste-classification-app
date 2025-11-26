import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/admin/controllers/community_management/post_detail_controller.dart';
import 'package:fyp/features/admin/screens/community_management/widgets/post_type_badge.dart';
import 'package:fyp/features/admin/screens/community_management/widgets/admin_media_preview.dart';
import 'package:fyp/features/admin/screens/community_management/community_management/widgets/post_actions_dialog.dart';

import '../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../data/repositories/user/user_repository.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailController(post));
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
          Obx(() => IconButton(
            onPressed: () => _showActionDialog(controller.currentPost.value, context),
            icon: Icon(
              controller.currentPost.value.isDisabled ? Iconsax.refresh : Iconsax.close_circle,
              color: controller.currentPost.value.isDisabled
                  ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                  : (dark ? FColors.adminDarkError : FColors.adminLightError),
            ),
            tooltip: controller.currentPost.value.isDisabled ? 'Recover' : 'Disable',
          )),
          const SizedBox(width: FSizes.sm),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content changed notification
            if (controller.hasContentChanged.value)
              _buildContentChangedNotification(controller, dark),

            // Comment/Reply count change notification
            if (controller.hasCommentsChanged.value)
              _buildCommentsChangedNotification(controller, dark),

            // Post Card
            _buildPostCard(controller, dark),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Comments Section
            _buildCommentsSection(controller, dark),
          ],
        ),
      )),
    );
  }

  Widget _buildContentChangedNotification(PostDetailController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkWarning.withOpacity(0.1)
            : FColors.adminLightWarning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
            size: 20,
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              'Post content has been updated',
              style: TextStyle(
                color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.dismissContentChangedNotification,
            icon: Icon(
              Iconsax.close_circle,
              color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
              size: 20,
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsChangedNotification(PostDetailController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkInfo.withOpacity(0.1)
            : FColors.adminLightInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.message_notif,
            color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            size: 20,
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              controller.commentsChangeMessage.value,
              style: TextStyle(
                color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: controller.refreshComments,
            icon: const Icon(Iconsax.refresh, size: 16),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostDetailController controller, bool dark) {
    final post = controller.currentPost.value;
    final poster = controller.usersCache[post.userId];

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status badge
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dark ? FColors.adminDarkPrimary.withOpacity(0.1) : FColors.adminLightPrimary.withOpacity(0.1),
                  dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                    PostTypeBadge(
                      postType: post.postType,
                      dark: dark,
                      showIcon: true,
                      fontSize: 13,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.md,
                        vertical: FSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: post.isDisabled
                            ? (dark ? FColors.adminDarkError : FColors.adminLightError)
                            : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            post.isDisabled ? Iconsax.pause : Iconsax.tick_circle,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: FSizes.xs),
                          Text(
                            post.isDisabled ? 'DISABLED' : 'ACTIVE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.md),

                // Post ID
                _buildInfoRow(
                  'Post ID',
                  post.postId,
                  Iconsax.document_text,
                  dark,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Poster Info
          if (poster != null)
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posted by',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      letterSpacing: 0.5,
                      // textTransform: TextTransform.uppercase,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  FutureBuilder<String?>(
                    future: poster.profileImg != null && poster.profileImg!.isNotEmpty
                        ? UserRepository.instance.getProfileImageUrl(poster.profileImg!)
                        : Future.value(null),
                    builder: (context, snapshot) {
                      final imageUrl = snapshot.data;

                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                Get.dialog(
                                  ImageLightbox(
                                    imageUrl: imageUrl,
                                    title: poster.username,
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: dark
                                  ? FColors.adminDarkPrimary
                                  : FColors.adminLightPrimary,
                              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl == null || imageUrl.isEmpty
                                  ? const Icon(
                                Iconsax.user,
                                color: Colors.white,
                                size: 28,
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  poster.username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: dark
                                        ? FColors.adminDarkText
                                        : FColors.adminLightText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  poster.email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: dark
                                        ? FColors.adminDarkTextSecondary
                                        : FColors.adminLightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // Dates
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateCard(
                    'Created',
                    post.createdAt,
                    Iconsax.calendar_add,
                    dark,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: _buildDateCard(
                    'Updated',
                    post.updatedAt,
                    Iconsax.calendar_edit,
                    dark,
                    isEdited: post.updatedAt.difference(post.createdAt).inSeconds > 60,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkBackground.withOpacity(0.5)
                        : FColors.adminLightBackground,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    border: Border.all(
                      color: dark
                          ? FColors.adminDarkBorder
                          : FColors.adminLightBorder,
                    ),
                  ),
                  child: SelectableText(
                    post.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ),

                // Media
                if (post.media.isNotEmpty) ...[
                  const SizedBox(height: FSizes.spaceBtwItems),
                  Text(
                    'Media (${post.media.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  _buildMediaGrid(post.media, dark),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Statistics
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.adminDarkSurfaceVariant.withOpacity(0.5)
                  : FColors.adminLightSurfaceVariant,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(FSizes.cardRadiusLg),
                bottomRight: Radius.circular(FSizes.cardRadiusLg),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Likes',
                    post.likes.length.toString(),
                    Iconsax.heart,
                    dark,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: _buildStatCard(
                    'Comments',
                    controller.currentCommentCount.value.toString(),
                    Iconsax.message,
                    dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool dark) {
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
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.xs),
        SelectableText(
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

  Widget _buildDateCard(String label, DateTime date, IconData icon, bool dark, {bool isEdited = true}) {
    if (!isEdited && label == 'Updated') {
      return Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark
              ? FColors.adminDarkSurfaceVariant.withOpacity(0.3)
              : FColors.adminLightSurfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
          ),
        ),
        child: Center(
          child: Text(
            'Not Edited',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            _formatDateTime(date),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          Text(
            FFormatter.formatTimeAgo(date),
            style: TextStyle(
              fontSize: 11,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Row(
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
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _buildMediaGrid(List<String> media, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkBackground.withOpacity(0.5)
            : FColors.adminLightBackground,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
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
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusSm - 1),
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

  Widget _buildCommentsSection(PostDetailController controller, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dark ? FColors.adminDarkPrimary.withOpacity(0.1) : FColors.adminLightPrimary.withOpacity(0.1),
                  dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                  size: 22,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Comments (${controller.currentCommentCount.value})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Comments List
          Obx(() {
            if (controller.isLoadingComments.value && controller.comments.isEmpty) {
              return _buildLoadingState(dark);
            }

            if (controller.comments.isEmpty) {
              return _buildEmptyCommentsState(dark);
            }

            return Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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

                // Load More Button
                if (controller.hasMoreComments.value)
                  Container(
                    padding: const EdgeInsets.all(FSizes.lg),
                    child: Center(
                      child: controller.isLoadingComments.value
                          ? CircularProgressIndicator(
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      )
                          : OutlinedButton.icon(
                        onPressed: controller.loadMoreComments,
                        icon: const Icon(Iconsax.refresh),
                        label: const Text('Load More Comments'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.lg,
                            vertical: FSizes.md,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (controller.comments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(FSizes.lg),
                    child: Center(
                      child: Text(
                        'No more comments',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl * 2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Loading comments...',
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCommentsState(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl * 2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.message_question,
              size: 64,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Be the first to comment on this post',
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

  Widget _buildCommentItem(dynamic comment, PostDetailController controller, bool dark) {
    final commenter = controller.usersCache[comment.userId];

    return Obx(() {
      final isExpanded = controller.expandedComments[comment.commentId] ?? false;

      return Container(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commenter Info
            if (commenter != null)
              FutureBuilder<String?>(
                future: commenter.profileImg != null && commenter.profileImg!.isNotEmpty
                    ? UserRepository.instance.getProfileImageUrl(commenter.profileImg!)
                    : Future.value(null),
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data;

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            Get.dialog(
                              ImageLightbox(
                                imageUrl: imageUrl,
                                title: commenter.username,
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: dark
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary,
                          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl == null || imageUrl.isEmpty
                              ? const Icon(
                            Iconsax.user,
                            color: Colors.white,
                            size: 20,
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commenter.username,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: dark
                                    ? FColors.adminDarkText
                                    : FColors.adminLightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: FSizes.sm),

            // Comment Content
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkBackground.withOpacity(0.5)
                    : FColors.adminLightBackground,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: Text(
                comment.content,
                style: TextStyle(
                  fontSize: 13,
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: FSizes.sm),

            // Comment Stats & Actions
            Row(
              children: [
                Icon(
                  Iconsax.heart,
                  size: 14,
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${comment.likes.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Icon(
                  Iconsax.message_2,
                  size: 14,
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${comment.replyCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  FFormatter.formatTimeAgo(comment.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
                if (comment.replyCount > 0) ...[
                  const SizedBox(width: FSizes.sm),
                  TextButton.icon(
                    onPressed: () => controller.toggleCommentExpansion(comment.commentId),
                    icon: Icon(
                      isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                      size: 16,
                    ),
                    label: Text(isExpanded ? 'Hide Replies' : 'View Replies'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),

            // Replies Section
            if (isExpanded) ...[
              const SizedBox(height: FSizes.md),
              Obx(() {
                final replies = controller.commentReplies[comment.commentId] ?? [];
                final isLoadingReplies = controller.loadingReplies[comment.commentId] ?? false;
                final hasMoreReplies = controller.hasMoreRepliesMap[comment.commentId] ?? false;

                if (isLoadingReplies && replies.isEmpty) {
                  return _buildRepliesLoadingState(dark);
                }

                if (replies.isEmpty) {
                  return _buildNoRepliesState(dark);
                }

                return Column(
                  children: [
                    ...replies.map((reply) => _buildReplyItem(reply, controller, dark)),

                    // Load More Replies Button
                    if (hasMoreReplies)
                      Padding(
                        padding: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
                        child: isLoadingReplies
                            ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                            ),
                          ),
                        )
                            : TextButton.icon(
                          onPressed: () => controller.loadMoreReplies(comment.commentId),
                          icon: const Icon(Iconsax.refresh, size: 14),
                          label: const Text('Load More Replies'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                            minimumSize: Size.zero,
                          ),
                        ),
                      )
                    else if (replies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
                        child: Center(
                          child: Text(
                            'No more replies',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildRepliesLoadingState(bool dark) {
    return Container(
      margin: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
      padding: const EdgeInsets.all(FSizes.md),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoRepliesState(bool dark) {
    return Container(
      margin: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
      padding: const EdgeInsets.all(FSizes.md),
      child: Center(
        child: Text(
          'No replies yet',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildReplyItem(dynamic reply, PostDetailController controller, bool dark) {
    final replier = controller.usersCache[reply.userId];

    return FutureBuilder<String?>(
      future: replier?.profileImg != null && replier!.profileImg!.isNotEmpty
          ? UserRepository.instance.getProfileImageUrl(replier.profileImg!)
          : Future.value(null),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;

        return Container(
          margin: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkSurfaceVariant.withOpacity(0.5)
                : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            border: Border.all(
              color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Replier Info
              if (replier != null)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          Get.dialog(
                            ImageLightbox(
                              imageUrl: imageUrl,
                              title: replier.username,
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null || imageUrl.isEmpty
                            ? const Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 16,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replier.username,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: dark ? FColors.adminDarkText : FColors.adminLightText,
                            ),
                          ),
                          Text(
                            FFormatter.formatTimeAgo(reply.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: FSizes.xs),

              // Reply Content
              Text(
                reply.content,
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
              const SizedBox(height: FSizes.xs),

              // Reply Stats
              Row(
                children: [
                  Icon(
                    Iconsax.heart,
                    size: 12,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reply.likes.length}',
                    style: TextStyle(
                      fontSize: 11,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _showMediaDialog(List<String> media, int initialIndex, bool dark) {
    showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => AdminMediaLightbox(
        mediaUrls: media,
        initialIndex: initialIndex,
        dark: dark,
      ),
    );
  }

  void _showActionDialog(PostModel post, BuildContext context) {
    if (post.isDisabled) {
      Get.dialog(
        RecoverPostDialog(post: post),
        barrierDismissible: false,
      );
    } else {
      Get.dialog(
        DisablePostDialog(post: post),
        barrierDismissible: false,
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}