import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_action.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

import '../../../../../utils/formatters/formatter.dart';
import '../../common_post_widgets/common_post_widgets.dart';
import '../../create_post/widgets/media_lightbox.dart';

class FPostCard extends StatelessWidget {
  final PostModel post;
  final bool isInDetailScreen;
  final VoidCallback? onMediaTap;

  const FPostCard({
    super.key,
    required this.post,
    this.isInDetailScreen = false,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostsController>();
    final dark = FHelperFunctions.isDarkMode(context);
    final postType = PostType.fromString(post.postType);
    final isDisabled = post.isDisabled;

    return GestureDetector(
      onTap: isInDetailScreen
          ? null
          : () => controller.navigateToPostDetails(post.postId),
      child: Stack(
        children: [
          Opacity(
            opacity: isDisabled ? 0.6 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(FSizes.md),
              margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
              decoration: BoxDecoration(
                color: isInDetailScreen
                    ? dark
                    ? FColors.dark
                    : FColors.white
                    : dark
                    ? FColors.communityDarkSurface
                    : FColors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: isDisabled
                    ? Border.all(color: FColors.error.withOpacity(0.3), width: 1.5)
                    : null,
                boxShadow: dark
                    ? null
                    : [
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
                  // User Info & Post Options
                  _buildUserInfoSection(context, dark, postType),
                  const SizedBox(height: FSizes.spaceBtwItems * 2),

                  // Post Content
                  Text(
                    post.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: dark ? FColors.darkText : FColors.black,
                    ),
                  ),

                  // Post Media (if any)
                  if (post.media.isNotEmpty) ...[
                    const SizedBox(height: FSizes.spaceBtwItems * 2),
                    _PostMediaPreview(
                      mediaUrls: post.media,
                      onTap: (index) => _openMediaLightbox(context, index),
                    ),
                  ],

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Action Buttons - Disabled if post is disabled
                  if (isDisabled)
                    Opacity(
                      opacity: 0.5,
                      child: IgnorePointer(
                        child: _buildPostActions(),  // ✅ 直接调用，不包裹在 Row 中
                      ),
                    )
                  else
                    _buildPostActions(),  // ✅ 直接调用
                ],
              ),
            ),
          ),
          // Violated badge for disabled posts
          if (isDisabled)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: FColors.error.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: FColors.error.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.warning_2,
                      color: FColors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'VIOLATED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: FColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openMediaLightbox(BuildContext context, int initialIndex) {
    final mediaItems = post.media.map((url) {
      return UnifiedMediaItem.network(
        id: url,
        networkUrl: url,
        isVideo: _isVideo(url),
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedMediaLightbox(
          mediaItems: mediaItems,
          initialIndex: initialIndex,
          showDeleteButton: false,
        ),
      ),
    );
  }

  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi');
  }

  Widget _buildUserInfoSection(
      BuildContext context,
      bool dark,
      PostType postType,
      ) {
    final displayDate = post.updatedAt ?? post.createdAt;
    final wasEdited = post.updatedAt != null;

    if (isInDetailScreen) {
      final controller = Get.find<PostDetailsController>();
      final currentUserId = controller.getCurrentUserId();
      final isUserPost = post.userId == currentUserId;

      return Row(
        children: [
          Expanded(
            child: FUserInfo(
              userId: post.userId,
              timeAgo: FFormatter.formatTimeAgo(displayDate),
              postType: postType,
              showMenuButton: false,
              wasEdited: wasEdited,
            ),
          ),
          // Menu button for both own posts and other users' posts
          _buildMenuButton(context, dark, isUserPost),
        ],
      );
    } else {
      final controller = Get.find<PostsController>();
      final currentUserId = controller.getCurrentUserId();
      final isUserPost = post.userId == currentUserId;

      return Row(
        children: [
          Expanded(
            child: FUserInfo(
              userId: post.userId,
              timeAgo: FFormatter.formatTimeAgo(displayDate),
              postType: postType,
              showMenuButton: false,
              wasEdited: wasEdited,
            ),
          ),
          // Menu button for both own posts and other users' posts
          _buildMenuButton(context, dark, isUserPost),
        ],
      );
    }
  }

  // Unified menu button
  Widget _buildMenuButton(BuildContext context, bool dark, bool isUserPost) {
    return IconButton(
      onPressed: () => _showPostOptionsMenu(context, isUserPost),
      icon: Icon(
        Icons.more_vert,
        color: dark ? FColors.darkGrey : FColors.grey,
        size: 20,
      ),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildPostActions() {
    if (isInDetailScreen) {
      return GetBuilder<PostDetailsController>(
        builder: (controller) {
          final currentUserId = controller.getCurrentUserId();
          final isLiked = post.likes.contains(currentUserId);

          return FPostActions(
            post: post,
            isLiked: isLiked,
            onLikePressed: () => controller.togglePostLike(),
            onCommentPressed: () {},
          );
        },
      );
    } else {
      return GetBuilder<PostsController>(
        builder: (controller) {
          final isLiked = post.likes.contains(controller.getCurrentUserId());

          return FPostActions(
            post: post,
            isLiked: isLiked,
            onLikePressed: () => controller.toggleLike(post.postId),
            onCommentPressed: () =>
                controller.navigateToPostDetails(post.postId),
          );
        },
      );
    }
  }

  // Show bottom sheet menu with appropriate options
  void _showPostOptionsMenu(BuildContext context, bool isUserPost) {
    final dark = FHelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show Edit & Delete for user's own posts
            if (isUserPost) ...[
              ListTile(
                leading: Icon(
                  Iconsax.edit,
                  color: FColors.primary,
                ),
                title: Text(
                  'Edit Post',
                  style: TextStyle(
                    color: dark ? FColors.white : FColors.black,
                  ),
                ),
                onTap: () {
                  Get.back();
                  final controller = Get.find<PostsController>();
                  controller.navigateToEditPost(post);
                },
              ),
              ListTile(
                leading: const Icon(
                  Iconsax.trash,
                  color: FColors.error,
                ),
                title: Text(
                  'Delete Post',
                  style: TextStyle(
                    color: FColors.error,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation(context, post);
                },
              ),
            ]
            // Show Report for other users' posts
            else ...[
              ListTile(
                leading: Icon(
                  Iconsax.warning_2,
                  color: FColors.error,
                ),
                title: Text(
                  'Report Post',
                  style: TextStyle(
                    color: dark ? FColors.white : FColors.black,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _showReportDialog(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    final dark = FHelperFunctions.isDarkMode(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          'Delete Post',
          style: TextStyle(
            color: dark ? FColors.white : FColors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: dark ? FColors.darkTextSecondary : FColors.darkGrey,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: FSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: dark ? FColors.lightGrey : FColors.darkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _confirmDelete(post),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: FColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _confirmDelete(PostModel post) async {
    Get.back();

    if (isInDetailScreen) {
      Get.back();
      final controller = Get.find<PostsController>();
      await controller.deletePost(post.postId);
    } else {
      final controller = Get.find<PostsController>();
      await controller.deletePost(post.postId);
    }
  }

  // Show report dialog
  void _showReportDialog(BuildContext context) async {
    final currentUserId = isInDetailScreen
        ? Get.find<PostDetailsController>().getCurrentUserId()
        : Get.find<PostsController>().getCurrentUserId();

    // Get already reported options by this user
    final alreadyReported = post.getUserReportedOptions(currentUserId);

    // Show report dialog
    final selectedOptions = await FLoaders.showReportDialog(
      alreadyReportedOptions: alreadyReported,
    );

    // If user selected options, submit report
    if (selectedOptions != null && selectedOptions.isNotEmpty) {
      await _submitReport(selectedOptions, currentUserId);
    }
  }

  // Submit report
  Future<void> _submitReport(List<String> selectedOptions, String userId) async {
    try {
      FLoaders.showLoading('Submitting report...');

      // Create updated reports map
      final updatedReports = Map<String, List<String>>.from(post.reports);

      // Process each selected option
      for (final option in selectedOptions) {
        if (updatedReports.containsKey(option)) {
          // Add user to existing list (using Set to avoid duplicates)
          final userSet = Set<String>.from(updatedReports[option]!);
          userSet.add(userId);
          updatedReports[option] = userSet.toList();
        } else {
          // Create new list with this user
          updatedReports[option] = [userId];
        }
      }

      // Remove options that user deselected
      final allOptions = ReportOption.allOptionNames;
      for (final option in allOptions) {
        if (!selectedOptions.contains(option) && updatedReports.containsKey(option)) {
          final userList = List<String>.from(updatedReports[option]!);
          userList.remove(userId);

          if (userList.isEmpty) {
            updatedReports.remove(option);
          } else {
            updatedReports[option] = userList;
          }
        }
      }

      // Update in repository
      if (isInDetailScreen) {
        final controller = Get.find<PostDetailsController>();
        await controller.updatePostReports(post.postId, updatedReports);
      } else {
        final controller = Get.find<PostsController>();
        await controller.updatePostReports(post.postId, updatedReports);
      }

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Report Submitted',
        message: 'Thank you for helping keep our community safe',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to submit report: $e',
      );
    }
  }
}

/// 优化的媒体预览组件 - 使用统一的布局计算
class _PostMediaPreview extends StatelessWidget {
  final List<String> mediaUrls;
  final Function(int) onTap;

  const _PostMediaPreview({
    required this.mediaUrls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) return const SizedBox();

    final count = mediaUrls.length;

    // 移除外层的 ClipRRect，让每个媒体项自己处理圆角
    return _buildMediaLayout(count);
  }

  Widget _buildMediaLayout(int count) {
    switch (count) {
      case 1:
        return _buildSingleMedia();
      case 2:
        return _buildTwoMedia();
      case 3:
        return _buildThreeMedia();
      case 4:
        return _buildFourMedia();
      default:
        return _buildFiveOrMoreMedia();
    }
  }

  /// 1张图片 - 全宽，保持比例
  Widget _buildSingleMedia() {
    return GestureDetector(
      onTap: () => onTap(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _MediaItem(
            mediaUrl: mediaUrls[0],
            showPlayIcon: _isVideo(mediaUrls[0]),
          ),
        ),
      ),
    );
  }

  /// 2张图片 - 左右各50%
  Widget _buildTwoMedia() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(0),
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(FSizes.borderRadiusLg),
                    bottomLeft: Radius.circular(FSizes.borderRadiusLg),
                  ),
                  child: _MediaItem(
                    mediaUrl: mediaUrls[0],
                    showPlayIcon: _isVideo(mediaUrls[0]),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(FSizes.borderRadiusLg),
                    bottomRight: Radius.circular(FSizes.borderRadiusLg),
                  ),
                  child: _MediaItem(
                    mediaUrl: mediaUrls[1],
                    showPlayIcon: _isVideo(mediaUrls[1]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3张图片 - 第1张全宽，第2、3张各50%（修复对齐）
  Widget _buildThreeMedia() {
    return Column(
      children: [
        // 第1张 - 全宽
        GestureDetector(
          onTap: () => onTap(0),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(FSizes.borderRadiusLg),
              topRight: Radius.circular(FSizes.borderRadiusLg),
            ),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: _MediaItem(
                mediaUrl: mediaUrls[0],
                showPlayIcon: _isVideo(mediaUrls[0]),
              ),
            ),
          ),
        ),

        // 固定间距
        const SizedBox(height: 4),

        // 第2、3张 - 各50%
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(FSizes.borderRadiusLg),
                    ),
                    child: _MediaItem(
                      mediaUrl: mediaUrls[1],
                      showPlayIcon: _isVideo(mediaUrls[1]),
                    ),
                  ),
                ),
              ),

              // 固定间距
              const SizedBox(width: 4),

              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(FSizes.borderRadiusLg),
                    ),
                    child: _MediaItem(
                      mediaUrl: mediaUrls[2],
                      showPlayIcon: _isVideo(mediaUrls[2]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 4张图片 - 2x2 网格
  Widget _buildFourMedia() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, bottom: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: _MediaItem(
                        mediaUrl: mediaUrls[0],
                        showPlayIcon: _isVideo(mediaUrls[0]),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(1),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: _MediaItem(
                        mediaUrl: mediaUrls[1],
                        showPlayIcon: _isVideo(mediaUrls[1]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, top: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: _MediaItem(
                        mediaUrl: mediaUrls[2],
                        showPlayIcon: _isVideo(mediaUrls[2]),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(3),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, top: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: _MediaItem(
                        mediaUrl: mediaUrls[3],
                        showPlayIcon: _isVideo(mediaUrls[3]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 5张或更多图片 - 2x2 网格 + 最后一张显示 overlay
  Widget _buildFiveOrMoreMedia() {
    final remaining = mediaUrls.length - 4;

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, bottom: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: _MediaItem(
                        mediaUrl: mediaUrls[0],
                        showPlayIcon: _isVideo(mediaUrls[0]),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(1),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: _MediaItem(
                        mediaUrl: mediaUrls[1],
                        showPlayIcon: _isVideo(mediaUrls[1]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, top: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: _MediaItem(
                        mediaUrl: mediaUrls[2],
                        showPlayIcon: _isVideo(mediaUrls[2]),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(3),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, top: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(FSizes.borderRadiusLg),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _MediaItem(
                            mediaUrl: mediaUrls[3],
                            showPlayIcon: _isVideo(mediaUrls[3]),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: Center(
                              child: Text(
                                '+$remaining',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi');
  }
}

/// 媒体布局数据模型
class _MediaLayout {
  final List<_MediaRow> rows;
  final double? itemHeight;

  _MediaLayout({
    required this.rows,
    this.itemHeight,
  });
}

class _MediaRow {
  final List<_MediaLayoutItem> items;

  _MediaRow({required this.items});
}

class _MediaLayoutItem {
  final int index;
  final int span;
  final int? overlayCount;

  _MediaLayoutItem({
    required this.index,
    required this.span,
    this.overlayCount,
  });
}

/// 媒体项组件 - 支持视频缩略图
class _MediaItem extends StatelessWidget {
  final String mediaUrl;
  final bool showPlayIcon;

  const _MediaItem({
    required this.mediaUrl,
    this.showPlayIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showPlayIcon) {
      return _VideoThumbnail(
        videoUrl: mediaUrl,
      );
    } else {
      return Image.network(
        mediaUrl,
        fit: BoxFit.cover, // ✅ 保持 cover 但确保容器有正确的约束
        width: double.infinity, // ✅ 强制宽度填满
        height: double.infinity, // ✅ 强制高度填满
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: FColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
  }
}

/// 视频缩略图组件
class _VideoThumbnail extends StatefulWidget {
  final String videoUrl;

  const _VideoThumbnail({
    required this.videoUrl,
  });

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Failed to initialize video thumbnail: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Iconsax.video_slash,
            color: Colors.white54,
            size: 32,
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: FColors.primary,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayer(_controller),
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        const Center(
          child: Icon(
            Iconsax.play_circle,
            color: Colors.white,
            size: 48,
          ),
        ),
      ],
    );
  }
}
