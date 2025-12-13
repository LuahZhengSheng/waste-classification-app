import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:fyp/features/waste_classification/models/waste_category_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../community/screens/create_post/widgets/media_lightbox.dart';
import '../../controllers/staff_activity_detail_controller.dart';

class StaffActivityDetailScreen extends StatelessWidget {
  const StaffActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StaffActivityDetailController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Activity Details'),
        centerTitle: true,
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: FColors.staffLightPrimary),
          );
        }

        if (controller.activity.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: FColors.staffLightPrimary),
          );
        }

        final activity = controller.activity.value!;
        final category = controller.getWasteCategory();

        if (category == null) {
          return _buildErrorState(context);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Image Section
              _buildHeroImageSection(activity, category, dark, context),

              // Content
              Padding(
                padding: const EdgeInsets.all(FSizes.defaultSpace),
                child: Column(
                  children: [
                    // Basic Info Card
                    _buildBasicInfoCard(activity, category, dark, controller),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Metrics Cards
                    _buildMetricsSection(activity, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Category Info Card
                    _buildCategoryInfoCard(category, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // User Info Card
                    _buildUserInfoCard(controller, dark, context),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: FColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.warning_2,
              size: 48,
              color: FColors.warning,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Category Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'The waste category for this activity\ncould not be loaded.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FSizes.lg),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Iconsax.arrow_left_2),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.staffLightPrimary,
              foregroundColor: FColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImageSection(
      RecyclingActivity activity,
      WasteCategory category,
      bool dark,
      BuildContext context,
      ) {
    return GestureDetector(
      onTap: () {
        _showImageLightbox(activity, context);
      },
      child: Hero(
        tag: 'activity_${activity.activityId}',
        child: Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
          ),
          child: FutureBuilder<String>(
            future: activity.getSupportImageUrl(activity.userId),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final hasError = snapshot.hasError;
              final imageUrl = snapshot.data;
              final hasValidImage = imageUrl != null && imageUrl.isNotEmpty;

              return Stack(
                children: [
                  // Background Image
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: category.color,
                      ),
                    )
                  else if (hasValidImage)
                    Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackIcon(category);
                      },
                    )
                  else
                    _buildFallbackIcon(category),

                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(FSizes.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: category.color,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      category.icon,
                                      size: 16,
                                      color: FColors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category.name,
                                      style: Theme.of(Get.context!)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        color: FColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: FSizes.sm),
                          Text(
                            activity.wasteObject,
                            style: Theme.of(Get.context!)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              color: FColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Iconsax.calendar,
                                size: 14,
                                color: FColors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                activity.formattedCreatedAt,
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: FColors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tap to enlarge hint
                  if (hasValidImage && !isLoading)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.maximize_4,
                              size: 14,
                              color: FColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to enlarge',
                              style: Theme.of(Get.context!)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: FColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(WasteCategory category) {
    return Center(
      child: Icon(
        category.icon,
        size: 80,
        color: category.color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBasicInfoCard(
      RecyclingActivity activity,
      WasteCategory category,
      bool dark,
      StaffActivityDetailController controller,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.info_circle,
                  color: FColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Activity Information',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          _buildInfoRow(
            'Activity ID',
            activity.activityId,
            Iconsax.code_circle,
            FColors.darkGrey,
          ),
          _buildInfoRow(
            'Processed Date',
            activity.formattedCreatedAt,
            Iconsax.calendar,
            dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
          ),
          _buildInfoRow(
            'Processing Time',
            controller.activityAgeText,
            Iconsax.clock,
            FColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: FColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(RecyclingActivity activity, bool dark) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Weight',
            activity.formattedWeight,
            Iconsax.weight,
            FColors.info,
            dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildMetricCard(
            'Points',
            '${activity.pointsEarned}',
            Iconsax.medal_star5,
            FColors.warning,
            dark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String label,
      String value,
      IconData icon,
      Color color,
      bool dark,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            value,
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkGrey : FColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfoCard(WasteCategory category, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            category.description,
            style: Theme.of(Get.context!).textTheme.bodyMedium,
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.basePoints != null)
                  Row(
                    children: [
                      Icon(
                        Iconsax.star1,
                        size: 16,
                        color: category.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Base Points: ${category.basePoints!.toStringAsFixed(1)} pts/kg',
                        style:
                        Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                if (category.basePoints != null && category.examples.isNotEmpty)
                  const SizedBox(height: FSizes.sm),
                if (category.examples.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.category,
                        size: 16,
                        color: category.color,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Examples: ${category.examples.take(3).join(', ')}${category.examples.length > 3 ? '...' : ''}',
                          style: Theme.of(Get.context!).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildUserInfoCard(
      StaffActivityDetailController controller,
      bool dark,
      BuildContext context,
      ) {
    return Obx(() {
      if (controller.processedUser.value == null) {
        return Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            boxShadow: [
              BoxShadow(
                color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: FColors.staffLightPrimary),
          ),
        );
      }

      final user = controller.processedUser.value!;

      return Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.user,
                    color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Processed User',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: user.profileImg != null && user.profileImg!.isNotEmpty
                          ? Image.network(
                        user.profileImg!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Iconsax.user,
                            size: 50,
                            color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                          );
                        },
                      )
                          : Icon(
                        Iconsax.user,
                        size: 50,
                        color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    user.username,
                    style: Theme.of(Get.context!)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            _buildUserInfoRow(
              'Email',
              user.email,
              Iconsax.sms,
              FColors.info,
            ),
            if (user.phoneNo != null && user.phoneNo!.isNotEmpty)
              _buildUserInfoRow(
                'Phone',
                user.phoneNo!,
                Iconsax.call,
                dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
              ),
            _buildUserInfoRow(
              'User ID',
              user.userId,
              Iconsax.code_circle,
              FColors.darkGrey,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildUserInfoRow(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: FColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageLightbox(RecyclingActivity activity, BuildContext context) {
    Future<String> imageUrlFuture =
    activity.getSupportImageUrl(activity.userId);

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<String>(
        future: imageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: FColors.staffLightPrimary),
            );
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            Navigator.pop(context);
            return const SizedBox();
          }

          final imageUrl = snapshot.data!;
          return UnifiedMediaLightbox(
            mediaItems: [
              UnifiedMediaItem.network(
                id: activity.activityId,
                networkUrl: imageUrl,
                isVideo: false,
              ),
            ],
            initialIndex: 0,
          );
        },
      ),
    );
  }
}