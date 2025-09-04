import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/activity_detail_controller.dart';
import 'package:fyp/utils/loaders/circular_loader.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityDetailController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.shareActivity,
            icon: const Icon(Iconsax.share),
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(value, controller),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Iconsax.refresh),
                    SizedBox(width: FSizes.sm),
                    Text('Refresh'),
                  ],
                ),
              ),
              if (controller.activity.value.canEdit)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Iconsax.edit),
                      SizedBox(width: FSizes.sm),
                      Text('Edit'),
                    ],
                  ),
                ),
              if (controller.activity.value.canDelete)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, color: FColors.error),
                      SizedBox(width: FSizes.sm),
                      Text('Delete', style: TextStyle(color: FColors.error)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'copy_id',
                child: Row(
                  children: [
                    Icon(Iconsax.copy),
                    SizedBox(width: FSizes.sm),
                    Text('Copy ID'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: FCircularLoader());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Header Card
              _buildStatusCard(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Activity Overview Card
              _buildActivityOverviewCard(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Support Image Card
              if (controller.activity.value.supportImage.isNotEmpty) ...[
                _buildSupportImageCard(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),
              ],

              // Environmental Impact Card
              _buildEnvironmentalImpactCard(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Recycling Center Card
              _buildRecyclingCenterCard(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Activity Timeline Card
              _buildTimelineCard(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Action Buttons
              _buildActionButtons(controller, dark),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(ActivityDetailController controller, bool dark) {
    final activity = controller.activity.value;
    Color statusColor = _getStatusColor(activity.statusColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(activity.status),
            size: 48,
            color: statusColor,
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            activity.statusDisplayText,
            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            controller.activityAge,
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
              color: dark ? FColors.textSecondary : FColors.darkGrey,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: (dark ? FColors.darkContainer : FColors.lightContainer).withOpacity(0.5),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Text(
              controller.statusMessage,
              style: Theme.of(Get.context!).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOverviewCard(ActivityDetailController controller, bool dark) {
    final activity = controller.activity.value;

    return Card(
      elevation: FSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: _getWasteTypeColor(activity.wasteObject).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                  ),
                  child: Icon(
                    _getWasteTypeIcon(activity.wasteObject),
                    color: _getWasteTypeColor(activity.wasteObject),
                    size: FSizes.iconLg,
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.wasteObject,
                        style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Activity ID: ${activity.activityId.substring(0, 8)}...',
                        style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                          color: dark ? FColors.textSecondary : FColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            const Divider(),
            const SizedBox(height: FSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    'Weight',
                    activity.formattedWeight,
                    Iconsax.weight,
                    FColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    'Points',
                    '${activity.pointsEarned}',
                    Iconsax.star,
                    FColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    'Date',
                    activity.formattedCreatedAt,
                    Iconsax.calendar,
                    FColors.info,
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    'Status',
                    activity.statusDisplayText,
                    Iconsax.info_circle,
                    _getStatusColor(activity.statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(FSizes.sm),
      margin: const EdgeInsets.all(FSizes.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: FSizes.iconMd),
          const SizedBox(height: FSizes.xs),
          Text(
            value,
            style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(Get.context!).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportImageCard(ActivityDetailController controller, bool dark) {
    return Card(
      elevation: FSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.image,
                  color: FColors.primary,
                  size: FSizes.iconMd,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Support Image',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            GestureDetector(
              onTap: controller.openFullScreenImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  color: dark ? FColors.darkContainer : FColors.lightContainer,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  child: CachedNetworkImage(
                    imageUrl: controller.activity.value.supportImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.image, size: 48, color: FColors.darkGrey),
                          SizedBox(height: FSizes.sm),
                          Text('Failed to load image'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Tap to view full size',
              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                color: dark ? FColors.textSecondary : FColors.darkGrey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard(ActivityDetailController controller, bool dark) {
    return Card(
      elevation: FSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          gradient: LinearGradient(
            colors: [
              FColors.success.withOpacity(0.1),
              FColors.primary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.tree,
                  color: FColors.success,
                  size: FSizes.iconLg,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Environmental Impact',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: FColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(color: FColors.success.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.global,
                        color: FColors.success,
                        size: FSizes.iconMd,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Text(
                          controller.environmentImpact,
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.sm),
                  Row(
                    children: [
                      Icon(
                        Iconsax.cloud,
                        color: FColors.info,
                        size: FSizes.iconMd,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Text(
                          'CO₂ Saved: ~${controller.co2Saved.toStringAsFixed(1)} kg',
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: FColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecyclingCenterCard(ActivityDetailController controller, bool dark) {
    return Obx(() {
      if (controller.isCenterLoading.value) {
        return Card(
          child: Container(
            height: 100,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final center = controller.recyclingCenter.value;
      if (center.name.isEmpty) {
        return const SizedBox.shrink();
      }

      return Card(
        elevation: FSizes.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.building,
                    color: FColors.primary,
                    size: FSizes.iconLg,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Text(
                      'Recycling Center',
                      style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                center.name,
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              if (center.email.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Iconsax.sms,
                      size: FSizes.iconSm,
                      color: dark ? FColors.textSecondary : FColors.darkGrey,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Expanded(child: Text(center.email)),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
              ],
              if (center.phoneNo.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Iconsax.call,
                      size: FSizes.iconSm,
                      color: dark ? FColors.textSecondary : FColors.darkGrey,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Expanded(child: Text(center.formattedPhoneNo)),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
              ],
              if (center.website.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Iconsax.global,
                      size: FSizes.iconSm,
                      color: dark ? FColors.textSecondary : FColors.darkGrey,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Expanded(child: Text(center.website)),
                  ],
                ),
              ],
              const SizedBox(height: FSizes.spaceBtwItems),
              Row(
                children: [
                  if (center.phoneNo.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.contactCenter,
                        icon: const Icon(Iconsax.call, size: FSizes.iconSm),
                        label: const Text('Call'),
                      ),
                    ),
                  if (center.phoneNo.isNotEmpty && center.email.isNotEmpty)
                    const SizedBox(width: FSizes.sm),
                  if (center.email.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.emailCenter,
                        icon: const Icon(Iconsax.sms, size: FSizes.iconSm),
                        label: const Text('Email'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTimelineCard(ActivityDetailController controller, bool dark) {
    final activity = controller.activity.value;

    return Card(
      elevation: FSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.clock,
                  color: FColors.primary,
                  size: FSizes.iconLg,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Activity Timeline',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark ? FColors.darkContainer : FColors.lightContainer,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: FColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activity Submitted',
                              style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              activity.formattedCreatedAt,
                              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                color: dark ? FColors.textSecondary : FColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.sm),
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    height: 20,
                    width: 2,
                    color: activity.isPending ? FColors.darkGrey : FColors.primary,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: activity.isPending ? FColors.darkGrey : _getStatusColor(activity.statusColor),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: FSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.isPending ? 'Under Review' : activity.statusDisplayText,
                              style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: activity.isPending ? FColors.darkGrey : null,
                              ),
                            ),
                            Text(
                              activity.isPending ? 'Waiting for center approval' : 'Status updated',
                              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                color: dark ? FColors.textSecondary : FColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                border: Border.all(color: FColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: FColors.info,
                    size: FSizes.iconSm,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Text(
                      controller.nextStepsMessage,
                      style: Theme.of(Get.context!).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ActivityDetailController controller, bool dark) {
    final activity = controller.activity.value;

    return Column(
      children: [
        if (activity.canEdit) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.editActivity,
              icon: const Icon(Iconsax.edit),
              label: const Text('Edit Activity'),
            ),
          ),
          const SizedBox(height: FSizes.sm),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.shareActivity,
            icon: const Icon(Iconsax.share),
            label: const Text('Share Activity'),
          ),
        ),
        if (activity.canDelete) ...[
          const SizedBox(height: FSizes.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(controller),
              icon: const Icon(Iconsax.trash),
              label: const Text('Delete Activity'),
              style: OutlinedButton.styleFrom(
                foregroundColor: FColors.error,
                side: BorderSide(color: FColors.error.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _handleMenuSelection(String value, ActivityDetailController controller) {
    switch (value) {
      case 'refresh':
        controller.refreshActivity();
        break;
      case 'edit':
        controller.editActivity();
        break;
      case 'delete':
        _showDeleteConfirmation(controller);
        break;
      case 'copy_id':
        controller.copyActivityId();
        break;
    }
  }

  void _showDeleteConfirmation(ActivityDetailController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text(
          'Are you sure you want to delete this recycling activity? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteActivity();
            },
            style: TextButton.styleFrom(foregroundColor: FColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return FColors.success;
      case 'orange':
        return FColors.warning;
      case 'red':
        return FColors.error;
      case 'blue':
        return FColors.info;
      default:
        return FColors.darkGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Iconsax.clock;
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      case 'completed':
        return Iconsax.medal_star;
      default:
        return Iconsax.info_circle;
    }
  }

  Color _getWasteTypeColor(String wasteObject) {
    switch (wasteObject.toLowerCase()) {
      case 'plastic':
        return Colors.blue;
      case 'paper':
        return Colors.brown;
      case 'glass':
        return Colors.green;
      case 'metal':
        return Colors.grey;
      case 'electronics':
        return Colors.purple;
      default:
        return FColors.primary;
    }
  }

  IconData _getWasteTypeIcon(String wasteObject) {
    switch (wasteObject.toLowerCase()) {
      case 'plastic':
        return Iconsax.box;
      case 'paper':
        return Iconsax.document;
      case 'glass':
        return Iconsax.glass;
      case 'metal':
        return Iconsax.setting_2;
      case 'electronics':
        return Iconsax.mobile;
      default:
        return Iconsax.trash;
    }
  }
}