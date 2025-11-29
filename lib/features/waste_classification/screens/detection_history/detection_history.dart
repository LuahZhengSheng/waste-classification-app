import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../controllers/detection_history_controller.dart';
import '../../models/detection_history_model.dart';

class DetectionHistoryScreen extends StatelessWidget {
  const DetectionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetectionHistoryController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('Detection History'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () => controller.clearAllHistory(),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: FColors.primary,
            ),
          );
        }

        if (controller.historyList.isEmpty) {
          return _buildEmptyState(context, dark);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDetectionHistory(),
          color: FColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            itemCount: controller.historyList.length,
            itemBuilder: (context, index) {
              final history = controller.historyList[index];
              return _buildHistoryCard(context, history, dark, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.spaceBtwSections),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document,
              size: 80,
              color: dark ? FColors.darkGrey : FColors.grey,
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              'No Detection History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.textPrimary,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Start scanning objects to build your history',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
      BuildContext context,
      DetectionHistoryModel history,
      bool dark,
      DetectionHistoryController controller,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          onTap: () {
            // Navigate to detail view with this history
            Get.to(() => DetectionHistoryDetailScreen(history: history));
          },
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  child: CachedNetworkImage(
                    imageUrl: history.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: dark ? FColors.dark : FColors.lightGrey,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: FColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: dark ? FColors.dark : FColors.lightGrey,
                      child: Icon(
                        Iconsax.gallery_slash,
                        color: dark ? FColors.darkGrey : FColors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        '${history.detectionCount} Object${history.detectionCount > 1 ? 's' : ''} Detected',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),

                      // Detected items
                      Text(
                        history.detectedItems.take(3).join(', ') +
                            (history.detectedItems.length > 3 ? '...' : ''),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: FSizes.xs),

                      // Time
                      Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 14,
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            FFormatter.formatTimeAgo(history.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: dark ? FColors.darkGrey : FColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  icon: Icon(
                    Iconsax.trash,
                    color: FColors.error,
                    size: 20,
                  ),
                  onPressed: () => controller.deleteHistory(history),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetectionHistoryDetailScreen extends StatelessWidget {
  final DetectionHistoryModel history;

  const DetectionHistoryDetailScreen({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('Detection Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detection Summary Card
            Padding(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              child: Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: dark ? FColors.darkContainer : FColors.white,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.black26 : Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: FColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.scan_barcode,
                        color: FColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${history.detectionCount} Objects Detected',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dark ? FColors.white : FColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: FSizes.xs),
                          Text(
                            FFormatter.formatTimeAgo(history.createdAt),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dark ? FColors.darkGrey : FColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Image with detections
            Container(
              margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                child: CachedNetworkImage(
                  imageUrl: history.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: dark ? FColors.dark : FColors.lightGrey,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: FColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: dark ? FColors.dark : FColors.lightGrey,
                    child: Center(
                      child: Icon(
                        Iconsax.gallery_slash,
                        size: 64,
                        color: dark ? FColors.darkGrey : FColors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Detected Items List
            Padding(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? FColors.white : FColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),
                  ...history.detectedItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildDetectedItemCard(context, item, index, dark);
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedItemCard(
      BuildContext context,
      String item,
      int index,
      bool dark,
      ) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(FSizes.md),
        child: Row(
          children: [
            // Color Indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: FSizes.md),

            // Item Info
            Expanded(
              child: Text(
                item,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}