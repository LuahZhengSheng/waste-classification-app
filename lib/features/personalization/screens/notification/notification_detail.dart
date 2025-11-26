import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/notification_controller.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationModel notification = Get.arguments as NotificationModel;
    final controller = Get.find<NotificationController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('Notification Details'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.darkSurface
                  : FColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Iconsax.trash,
                color: dark
                    ? FColors.error
                    : FColors.error,
                size: 20,
              ),
              onPressed: () => _showDeleteConfirmation(
                context,
                notification,
                controller,
                dark,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Modern SliverAppBar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(notification, dark),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Message Card
                  _buildMessageCard(notification, dark),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Metadata Card
                  _buildMetadataCard(notification, controller, dark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(NotificationModel notification, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.darkSurface : FColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type, dark).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type, dark),
              size: 28,
            ),
          ),
          const SizedBox(width: FSizes.md),

          // Title and Type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: dark
                        ? FColors.darkText
                        : FColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.type, dark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getTypeLabel(notification.type),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(notification.type, dark),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Read status
          if (!notification.isRead)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.accent
                    : FColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(NotificationModel notification, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.darkSurface : FColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (dark
                      ? FColors.accent
                      : FColors.accent).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.message_text,
                  size: 18,
                  color: dark
                      ? FColors.accent
                      : FColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark
                      ? FColors.darkText
                      : FColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            notification.message,
            style: TextStyle(
              fontSize: 15,
              color: dark
                  ? FColors.darkTextSecondary
                  : FColors.textSecondary,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(
      NotificationModel notification,
      NotificationController controller,
      bool dark,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.darkSurface : FColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (dark
                      ? FColors.info
                      : FColors.info).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.info_circle,
                  size: 18,
                  color: dark
                      ? FColors.info
                      : FColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark
                      ? FColors.darkText
                      : FColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Received time
          _buildMetadataRow(
            'Received',
            _formatDateTime(notification.createdAt),
            Iconsax.clock,
            dark,
          ),
          const SizedBox(height: FSizes.sm),

          // Status
          _buildMetadataRow(
            'Status',
            notification.isRead ? 'Read' : 'Unread',
            notification.isRead ? Iconsax.tick_circle : Iconsax.record_circle,
            dark,
          ),
          const SizedBox(height: FSizes.sm),

          // Type
          _buildMetadataRow(
            'Type',
            _getTypeLabel(notification.type),
            _getTypeIcon(notification.type),
            dark,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, IconData icon, bool dark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: dark
              ? FColors.darkText
              : FColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: dark
                ? FColors.darkText
                : FColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dark
                ? FColors.darkText
                : FColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type, bool dark) {
    switch (type) {
      case 'system':
        return dark ? FColors.primary : FColors.primary;
      case 'achievement':
        return dark ? FColors.success : FColors.success;
      case 'reminder':
        return dark ? FColors.warning : FColors.warning;
      default:
        return dark ? FColors.info : FColors.info;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'system':
        return Iconsax.info_circle;
      case 'achievement':
        return Iconsax.medal_star;
      case 'reminder':
        return Iconsax.timer;
      default:
        return Iconsax.notification;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'system':
        return 'System Notification';
      case 'achievement':
        return 'Achievement';
      case 'reminder':
        return 'Reminder';
      default:
        return 'Notification';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 24) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final hourStr = hour == 0 ? '12' : hour.toString();
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');

      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return 'Today at $hourStr:$minuteStr $period';
    } else if (difference.inDays == 1) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final hourStr = hour == 0 ? '12' : hour.toString();
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');
      return 'Yesterday at $hourStr:$minuteStr $period';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showDeleteConfirmation(
      BuildContext context,
      NotificationModel notification,
      NotificationController controller,
      bool dark,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dark ? FColors.darkSurface : FColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.trash,
                  color: FColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Notification',
                style: TextStyle(
                  color: dark
                      ? FColors.darkText
                      : FColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this notification? This action cannot be undone.',
            style: TextStyle(
              color: dark
                  ? FColors.darkTextSecondary
                  : FColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dark
                      ? FColors.darkTextSecondary
                      : FColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.deleteNotification(notification.notificationId);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.error,
                foregroundColor: FColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}