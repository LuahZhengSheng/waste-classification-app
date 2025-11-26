import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../controllers/detection_controller.dart';
import '../../models/detection_result_model.dart';
import '../waste_category_guideline/waste_category_guide_detail.dart';
import 'widgets/bounding_box_painter.dart';

class DetectionResultScreen extends StatelessWidget {
  final ImageDetectionResult result;

  const DetectionResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetectionController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('Detection Results'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => Get.back(),
            tooltip: 'Scan Again',
          ),
        ],
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
                            '${result.detectionCount} Objects Detected',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dark ? FColors.white : FColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: FSizes.xs),
                          Text(
                            'Tap on labels to view details',
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

            // Image with Bounding Boxes
            _buildImageWithDetections(context, dark),

            // Detection List
            if (result.hasDetections)
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
                    ...result.detections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final detection = entry.value;
                      return _buildDetectionCard(
                        context,
                        detection,
                        index,
                        dark,
                      );
                    }).toList(),
                  ],
                ),
              ),

            // No Detections Message
            if (!result.hasDetections)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(FSizes.spaceBtwSections),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.search_normal,
                        size: 64,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      Text(
                        'No objects detected',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FSizes.sm),
                      Text(
                        'Try taking another photo with better lighting',
                        style: TextStyle(
                          fontSize: 14,
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: FSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithDetections(BuildContext context, bool dark) {
    return Container(
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
        child: AspectRatio(
          aspectRatio: result.imageSize.width / result.imageSize.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Original Image
              Image.file(
                File(result.imagePath),
                fit: BoxFit.contain,
              ),

              // Bounding Boxes and Labels
              CustomPaint(
                painter: BoundingBoxPainter(
                  detections: result.detections,
                  imageSize: result.imageSize,
                  displaySize: Size(
                      MediaQuery.of(context).size.width - (FSizes.defaultSpace * 2),
                      (MediaQuery.of(context).size.width - (FSizes.defaultSpace * 2)) *
                          (result.imageSize.height / result.imageSize.width)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableLabel(
      BuildContext context,
      DetectionResult detection,
      int index,
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

    return Positioned(
      left: detection.boundingBox.left,
      top: detection.boundingBox.top - 30,
      child: GestureDetector(
        onTap: () {
          if (detection.category != null) {
            Get.to(() => WasteCategoryDetailScreen(
              category: detection.category!,
            ));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                detection.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (detection.category != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Iconsax.arrow_right_3,
                  color: Colors.white,
                  size: 12,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionCard(
      BuildContext context,
      DetectionResult detection,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          onTap: detection.category != null
              ? () => Get.to(() => WasteCategoryDetailScreen(
            category: detection.category!,
          ))
              : null,
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Row(
              children: [
                // Color Indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: FSizes.md),

                // Detection Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detection.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        'Confidence: ${detection.confidencePercent}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                      ),
                      if (detection.category != null) ...[
                        const SizedBox(height: FSizes.xs),
                        Row(
                          children: [
                            Icon(
                              detection.category!.isRecyclable
                                  ? Iconsax.tick_circle
                                  : Iconsax.close_circle,
                              size: 16,
                              color: detection.category!.isRecyclable
                                  ? FColors.success
                                  : FColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              detection.category!.isRecyclable
                                  ? 'Recyclable'
                                  : 'Not Recyclable',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: detection.category!.isRecyclable
                                    ? FColors.success
                                    : FColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon
                if (detection.category != null)
                  Icon(
                    Iconsax.arrow_right_3,
                    color: dark ? FColors.white : FColors.textPrimary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}