import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/admin/badge.dart';
import '../../../../../data/repositories/user/user_repository.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatter.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/helpers/media_helpers.dart';
import '../../../../../utils/popups/admin_loaders.dart';
import '../../../../community/models/post_model.dart';
import '../../../controllers/community_management/community_management_controller.dart';
import '../../../controllers/community_management/community_management_detail_controller.dart';
import '../community_management/widgets/post_report_dialog.dart';
import '../widgets/admin_media_preview.dart';
import '../widgets/post_type_badge.dart';

class CommunityManagementDetailScreen extends StatelessWidget {
  final PostModel post;

  const CommunityManagementDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityManagementDetailController(post));
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor:
      dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor:
        dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
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
          // 🆕 清空 reports 按钮（只在有 reports 时显示）
          Obx(() {
            final hasReports = controller.currentPost.value.reportCount > 0;
            if (hasReports) {
              return IconButton(
                onPressed: () => _showClearReportsDialog(controller.currentPost.value),
                icon: Icon(
                  Iconsax.shield_tick,
                  color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                ),
                tooltip: 'Clear All Reports',
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(
                () => IconButton(
              onPressed: () =>
                  showActionDialog(controller.currentPost.value),
              icon: Icon(
                controller.currentPost.value.isDisabled
                    ? Iconsax.refresh
                    : Iconsax.close_circle,
                color: controller.currentPost.value.isDisabled
                    ? (dark
                    ? FColors.adminDarkSuccess
                    : FColors.adminLightSuccess)
                    : (dark ? FColors.adminDarkError : FColors.adminLightError),
              ),
              tooltip: controller.currentPost.value.isDisabled
                  ? 'Recover'
                  : 'Disable',
            ),
          ),
          const SizedBox(width: FSizes.sm),
        ],
      ),
      body: Obx(
            () => Column(
          children: [
            // 固定顶部的 comments 变化提示
            if (controller.hasCommentsChanged.value)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.lg,
                ),
                child: buildCommentsChangedNotification(controller, dark),
              ),

            // 下面是可滚动区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(FSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPostCard(controller, dark, context), // 🔧 传入 context
                    const SizedBox(height: FSizes.spaceBtwSections),
                    buildCommentsSection(controller, dark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 通知区组件 ====================

Widget buildCommentsChangedNotification(
    CommunityManagementDetailController controller, bool dark) {
  return Container(
    margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
    padding: const EdgeInsets.all(FSizes.md),
    decoration: BoxDecoration(
      color: dark
          ? FColors.adminDarkInfo.withOpacity(0.1)
          : FColors.adminLightInfo.withOpacity(0.1),
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
    ),
    child: Row(
      children: [
        Icon(
          Iconsax.message_notif,
          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
          size: 20,
        ),
        const SizedBox(width: FSizes.sm),
        const Expanded(
          child: Text(
            'Comments have changed',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: () => controller.hasCommentsChanged.value = false,
          icon: Icon(
            Iconsax.close_circle,
            color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            size: 20,
          ),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: FSizes.sm),
        ElevatedButton.icon(
          onPressed: controller.refreshComments,
          icon: const Icon(Iconsax.refresh, size: 16),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
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

// ==================== Post Card ====================

Widget buildPostCard(CommunityManagementDetailController controller, bool dark, BuildContext context) { // 🔧 添加 context 参数
  final post = controller.currentPost.value;
  final poster = controller.usersCache[post.userId];

  // 🔧 修正：移除多余的参数
  void showReportDetailsDialog(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => PostReportDialog(
        post: post,
        dark: dark,
      ),
    );
  }

  return Container(
    decoration: BoxDecoration(
      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
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
            color: dark
                ? FColors.adminDarkPrimary.withOpacity(0.1)
                : FColors.adminLightPrimary.withOpacity(0.1),
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
                  _buildPostTypeBadge(post.postType, dark),
                  const Spacer(),
                  _buildStatusBadge(post.isDisabled, dark),
                ],
              ),
              const SizedBox(height: FSizes.md),
              buildInfoRow('Post ID', post.postId, Iconsax.document_text, dark),
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
                    color: dark
                        ? FColors.adminDarkTextMuted
                        : FColors.adminLightTextMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                FutureBuilder<String?>(
                  future: poster.profileImg != null &&
                      poster.profileImg!.isNotEmpty
                      ? UserRepository.instance
                      .getProfileImageUrl(poster.profileImg!)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    final imageUrl = snapshot.data;
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              Get.dialog(
                                AdminMediaLightbox(
                                  mediaUrls: [imageUrl],
                                  initialIndex: 0,
                                  dark: dark,
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: dark
                                ? FColors.adminDarkPrimary
                                : FColors.adminLightPrimary,
                            backgroundImage: imageUrl != null &&
                                imageUrl.isNotEmpty
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

        // Reports Section
        if (post.reportCount > 0)
          Container(
            margin: const EdgeInsets.all(FSizes.lg),
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  dark
                      ? FColors.adminDarkError.withOpacity(0.08)
                      : FColors.adminLightError.withOpacity(0.08),
                  dark
                      ? FColors.adminDarkError.withOpacity(0.03)
                      : FColors.adminLightError.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              border: Border.all(
                color: dark
                    ? FColors.adminDarkError.withOpacity(0.2)
                    : FColors.adminLightError.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: dark
                            ? FColors.adminDarkError.withOpacity(0.15)
                            : FColors.adminLightError.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: (dark
                                ? FColors.adminDarkError
                                : FColors.adminLightError)
                                .withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.warning_2,
                        color: dark
                            ? FColors.adminDarkError
                            : FColors.adminLightError,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content Reports',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: dark
                                  ? FColors.adminDarkText
                                  : FColors.adminLightText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: FSizes.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: dark
                                      ? FColors.adminDarkError
                                      : FColors.adminLightError,
                                  borderRadius:
                                  BorderRadius.circular(FSizes.cardRadiusXs),
                                ),
                                child: Text(
                                  '${post.reportCount}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                post.reportCount > 1
                                    ? 'unique reporters'
                                    : 'unique reporter',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // View Details Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => showReportDetailsDialog(post),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.md,
                            vertical: FSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: dark
                                  ? FColors.adminDarkError.withOpacity(0.4)
                                  : FColors.adminLightError.withOpacity(0.4),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.eye,
                                size: 16,
                                color: dark
                                    ? FColors.adminDarkError
                                    : FColors.adminLightError,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: dark
                                      ? FColors.adminDarkError
                                      : FColors.adminLightError,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: FSizes.md),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (dark ? FColors.adminDarkError : FColors.adminLightError)
                            .withOpacity(0.1),
                        (dark ? FColors.adminDarkError : FColors.adminLightError)
                            .withOpacity(0.3),
                        (dark ? FColors.adminDarkError : FColors.adminLightError)
                            .withOpacity(0.1),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: FSizes.md),

                // Reports Summary
                _buildReportsSummary(post, dark),
              ],
            ),
          ),

        if (post.reportCount > 0) const Divider(height: 1),

        // Dates
        Container(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Row(
            children: [
              Expanded(
                child: buildDateCard(
                  'Created',
                  post.createdAt,
                  Iconsax.calendar_add,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: buildDateCard(
                  'Updated',
                  post.updatedAt,
                  Iconsax.calendar_edit,
                  dark,
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
                ),
                child: SelectableText(
                  post.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
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
                    color:
                    dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                buildMediaGrid(post.media, dark),
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
                child: buildStatCard(
                  'Likes',
                  post.likes.length.toString(),
                  Iconsax.heart,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: buildStatCard(
                  'Comments',
                  controller.displayCommentCount.value.toString(),
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

Widget _buildReportsSummary(PostModel post, bool dark) {
  final reportTypeCount = <String, int>{};
  post.reports.forEach((reportType, userIds) {
    reportTypeCount[reportType] = userIds.length;
  });

  if (reportTypeCount.isEmpty) {
    return Center(
      child: Text(
        'No reports',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: dark
              ? FColors.adminDarkTextMuted
              : FColors.adminLightTextMuted,
        ),
      ),
    );
  }

  // Sort by count descending
  final sortedEntries = reportTypeCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Report Breakdown',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: dark
              ? FColors.adminDarkTextSecondary
              : FColors.adminLightTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: FSizes.sm),
      Wrap(
        spacing: FSizes.sm,
        runSpacing: FSizes.sm,
        children: sortedEntries.map((entry) {
          // Color intensity based on count
          final intensity = (entry.value / post.reportCount).clamp(0.3, 1.0);
          final bgColor = (dark
              ? FColors.adminDarkError
              : FColors.adminLightError)
              .withOpacity(0.1 * intensity);
          final borderColor = (dark
              ? FColors.adminDarkError
              : FColors.adminLightError)
              .withOpacity(0.4 * intensity);
          final textColor = dark
              ? FColors.adminDarkError
              : FColors.adminLightError;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getReportIcon(entry.key),
                  size: 14,
                  color: textColor,
                ),
                const SizedBox(width: FSizes.xs),
                Text(
                  _formatReportType(entry.key),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: FSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                  ),
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

// Helper function to get icon for report type
IconData _getReportIcon(String type) {
  switch (type.toLowerCase()) {
    case 'spam':
      return Iconsax.message_minus;
    case 'hatespeech':
      return Iconsax.danger;
    case 'inappropriate':
      return Iconsax.warning_2;
    case 'harassment':
      return Iconsax.user_remove;
    case 'violence':
      return Iconsax.shield_cross;
    case 'falseinformation':
      return Iconsax.info_circle;
    default:
      return Iconsax.flag;
  }
}

String _formatReportType(String type) {
  switch (type.toLowerCase()) {
    case 'spam':
      return 'Spam';
    case 'hatespeech':
      return 'Hate Speech';
    case 'inappropriate':
      return 'Inappropriate';
    case 'harassment':
      return 'Harassment';
    case 'violence':
      return 'Violence';
    case 'falseinformation':
      return 'False Info';
    default:
      return type.replaceAll('_', ' ').toUpperCase();
  }
}

Widget _buildPostTypeBadge(String postType, bool dark) {
  Color color;
  IconData icon;
  String label;

  switch (postType) {
    case 'question':
      color = dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
      icon = Iconsax.message_question;
      label = 'Question';
      break;
    case 'discussion':
      color = dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
      icon = Iconsax.messages_3;
      label = 'Discussion';
      break;
    case 'tip':
      color = dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
      icon = Iconsax.microphone;
      label = 'Tip';
      break;
    case 'event':
      color = dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
      icon = Iconsax.calendar;
      label = 'Event';
      break;
    default:
      color = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
      icon = Iconsax.document;
      label = postType;
  }

  return CommonBadge(
    icon: icon,
    color: color,
    text: label,
    iconSize: 14,
    textStyle: TextStyle(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    borderRadius: FSizes.cardRadiusMd,
    padding: const EdgeInsets.symmetric(
      horizontal: FSizes.sm,
      vertical: FSizes.xs,
    ),
    borderColor: color.withOpacity(0.3),
  );
}

Widget _buildStatusBadge(bool isDisabled, bool dark) {
  final color = isDisabled
      ? (dark ? FColors.adminDarkError : FColors.adminLightError)
      : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess);

  final icon = isDisabled ? Iconsax.pause : Iconsax.tick_circle;
  final label = isDisabled ? 'DISABLED' : 'ACTIVE';

  return CommonBadge(
    icon: icon,
    color: color,
    text: label,
    iconSize: 14,
    textStyle: TextStyle(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      letterSpacing: 0.5,
    ),
    borderRadius: FSizes.cardRadiusSm,
    padding: const EdgeInsets.symmetric(
      horizontal: FSizes.md,
      vertical: FSizes.xs,
    ),
    borderColor: color,
  );
}

// ==================== Comments Section ====================

Widget buildCommentsSection(CommunityManagementDetailController controller, bool dark) {
  return Container(
    decoration: BoxDecoration(
      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
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
        Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkPrimary.withOpacity(0.1)
                : FColors.adminLightPrimary.withOpacity(0.1),
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
                'Comments (${controller.displayCommentCount.value})',
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
        Obx(() {
          if (controller.isInitialLoading.value) {
            return buildLoadingState(dark);
          }
          if (controller.isLoadingComments.value &&
              controller.comments.isEmpty) {
            return buildLoadingState(dark);
          }
          if (controller.comments.isEmpty) {
            return buildEmptyCommentsState(dark);
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
                  color: dark
                      ? FColors.adminDarkDivider
                      : FColors.adminLightDivider,
                ),
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  return buildCommentItem(comment, controller, dark);
                },
              ),
              if (controller.hasMoreComments.value)
                Container(
                  padding: const EdgeInsets.all(FSizes.lg),
                  child: Center(
                    child: controller.isLoadingComments.value
                        ? CircularProgressIndicator(
                      color: dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                    )
                        : OutlinedButton.icon(
                      onPressed: controller.loadMoreComments,
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Load More Comments'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark
                              ? FColors.adminDarkBorder
                              : FColors.adminLightBorder,
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
                        color: dark
                            ? FColors.adminDarkTextMuted
                            : FColors.adminLightTextMuted,
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

// ==================== Helper Widgets ====================

Widget buildInfoRow(String label, String value, IconData icon, bool dark) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
          const SizedBox(width: FSizes.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
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

Widget buildDateCard(String label, DateTime? date, IconData icon, bool dark) {
  if (date == null) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant.withOpacity(0.3)
            : FColors.adminLightSurfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Center(
            child: Text(
              'N/A',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
            ),
          ),
        ],
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
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: dark
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          formatDateTime(date),
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
            color: dark
                ? FColors.adminDarkTextMuted
                : FColors.adminLightTextMuted,
          ),
        ),
      ],
    ),
  );
}

Widget buildStatCard(String label, String value, IconData icon, bool dark) {
  return Container(
    padding: const EdgeInsets.all(FSizes.md),
    decoration: BoxDecoration(
      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
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
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildMediaGrid(List<String> media, bool dark) {
  if (media.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      child: Center(
        child: Text(
          'No media',
          style: TextStyle(
            color: dark
                ? FColors.adminDarkTextMuted
                : FColors.adminLightTextMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  return Container(
    decoration: BoxDecoration(
      color: dark
          ? FColors.adminDarkBackground.withOpacity(0.5)
          : FColors.adminLightBackground,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
    ),
    padding: const EdgeInsets.all(FSizes.md),
    child: Wrap(
      spacing: FSizes.sm,
      runSpacing: FSizes.sm,
      children: List.generate(
        media.length,
            (index) {
          return buildMediaThumbnail(media[index], index, media, dark);
        },
      ),
    ),
  );
}

Widget buildMediaThumbnail(
    String mediaUrl, int index, List<String> allMedia, bool dark) {
  final bool isImage = MediaHelpers.isImageUrl(mediaUrl);

  return GestureDetector(
    onTap: () {
      showMediaDialog(allMedia, index, dark);
    },
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm - 1),
        child: isImage
            ? Image.network(
          mediaUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            final progress = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null;
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: dark
                      ? FColors.adminDarkPrimary
                      : FColors.adminLightPrimary,
                  value: progress,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Iconsax.image,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
              size: 24,
            );
          },
        )
            : Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary)
                    .withOpacity(0.2),
                (dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary)
                    .withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              Iconsax.video_play,
              color: dark
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget buildLoadingState(bool dark) {
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
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildEmptyCommentsState(bool dark) {
  return Container(
    padding: const EdgeInsets.all(FSizes.xl * 2),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.message_question,
            size: 64,
            color:
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
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
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildCommentItem(
    dynamic comment, CommunityManagementDetailController controller, bool dark) {
  final commenter = controller.usersCache[comment.userId];

  return Obx(() {
    final isExpanded = controller.expandedComments[comment.commentId] ?? false;

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (commenter != null)
            FutureBuilder<String?>(
            future: commenter.profileImg != null &&
                commenter.profileImg!.isNotEmpty
                ? UserRepository.instance
                .getProfileImageUrl(commenter.profileImg!)
                : Future.value(null),
            builder: (context, snapshot) {
              final imageUrl = snapshot.data;
              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        Get.dialog(
                          AdminMediaLightbox(
                            mediaUrls: [imageUrl],
                            initialIndex: 0,
                            dark: dark,
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                      backgroundImage:
                      imageUrl != null && imageUrl.isNotEmpty
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
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Row(
            children: [
              Icon(
                Iconsax.heart,
                size: 14,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${comment.likes.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Icon(
                Iconsax.message_2,
                size: 14,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${comment.replyCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
              ),
              const Spacer(),
              Text(
                FFormatter.formatTimeAgo(comment.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
              ),
              if (comment.replyCount > 0) ...[
                const SizedBox(width: FSizes.sm),
                TextButton.icon(
                  onPressed: () =>
                      controller.toggleCommentExpansion(comment.commentId),
                  icon: Icon(
                    isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: 16,
                  ),
                  label: Text(isExpanded ? 'Hide Replies' : 'View Replies'),
                  style: TextButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: FSizes.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: FSizes.md),
            Obx(() {
              final replies =
                  controller.commentReplies[comment.commentId] ?? [];
              final isLoadingReplies =
                  controller.loadingReplies[comment.commentId] ?? false;
              final hasMoreReplies =
                  controller.hasMoreRepliesMap[comment.commentId] ?? false;

              if (isLoadingReplies && replies.isEmpty) {
                return buildRepliesLoadingState(dark);
              }

              if (replies.isEmpty) {
                return buildNoRepliesState(dark);
              }

              return Column(
                children: [
                  ...replies.map((reply) =>
                      buildReplyItem(reply, controller, dark)),
                  if (hasMoreReplies)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: FSizes.xl,
                        top: FSizes.sm,
                      ),
                      child: isLoadingReplies
                          ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: dark
                                ? FColors.adminDarkPrimary
                                : FColors.adminLightPrimary,
                          ),
                        ),
                      )
                          : TextButton.icon(
                        onPressed: () =>
                            controller.loadMoreReplies(comment.commentId),
                        icon: const Icon(Iconsax.refresh, size: 14),
                        label: const Text('Load More Replies'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.sm),
                          minimumSize: Size.zero,
                        ),
                      ),
                    )
                  else if (replies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: FSizes.xl,
                        top: FSizes.sm,
                      ),
                      child: Center(
                        child: Text(
                          'No more replies',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: dark
                                ? FColors.adminDarkTextMuted
                                : FColors.adminLightTextMuted,
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

Widget buildRepliesLoadingState(bool dark) {
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

Widget buildNoRepliesState(bool dark) {
  return Container(
    margin: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
    padding: const EdgeInsets.all(FSizes.md),
    child: Center(
      child: Text(
        'No replies yet',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: dark
              ? FColors.adminDarkTextMuted
              : FColors.adminLightTextMuted,
        ),
      ),
    ),
  );
}

Widget buildReplyItem(
    dynamic reply, CommunityManagementDetailController controller, bool dark) {
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replier != null)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        Get.dialog(
                          AdminMediaLightbox(
                            mediaUrls: [imageUrl],
                            initialIndex: 0,
                            dark: dark,
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                      backgroundImage:
                      imageUrl != null && imageUrl.isNotEmpty
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
                            color: dark
                                ? FColors.adminDarkText
                                : FColors.adminLightText,
                          ),
                        ),
                        Text(
                          FFormatter.formatTimeAgo(reply.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: dark
                                ? FColors.adminDarkTextMuted
                                : FColors.adminLightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: FSizes.sm),
            Text(
              reply.content,
              style: TextStyle(
                fontSize: 12,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Row(
              children: [
                Icon(
                  Iconsax.heart,
                  size: 12,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${reply.likes.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: dark
                        ? FColors.adminDarkTextMuted
                        : FColors.adminLightTextMuted,
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

// ==================== Utility Functions ====================

void showMediaDialog(List<String> media, int initialIndex, bool dark) {
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

void showActionDialog(PostModel post) {
  final controller = CommunityManagementController.instance;

  FAdminLoaders.showPostDisableRecoverDialog(
    postContent: post.content.length > 50
        ? '${post.content.substring(0, 50)}...'
        : post.content,
    isDisabled: post.isDisabled,
    onConfirm: () => controller.togglePostStatus(post),
  );
}

void _showClearReportsDialog(PostModel post) {
  final controller = CommunityManagementController.instance;

  FAdminLoaders.showClearReportsConfirmationDialog(
    postContent: post.content.length > 50
        ? '${post.content.substring(0, 50)}...'
        : post.content,
    reportCount: post.reportCount,
    onConfirm: () async {
      await controller.clearPostReports(post);
      // 刷新 detail controller 的数据
      final detailController = Get.find<CommunityManagementDetailController>();
      await detailController.loadInitialData();
    },
  );
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
