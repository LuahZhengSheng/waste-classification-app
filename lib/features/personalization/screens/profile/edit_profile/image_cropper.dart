// image_cropper.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/popups/loaders.dart';

class ImageCropperScreen extends StatelessWidget {
  final File imageFile;

  const ImageCropperScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageCropperController(imageFile: imageFile));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image with interactive transformation
          Center(
            child: Obx(() {
              if (!controller.isImageLoaded.value) {
                return const CircularProgressIndicator(color: FColors.primary);
              }

              return GestureDetector(
                onScaleStart: controller.onScaleStart,
                onScaleUpdate: controller.onScaleUpdate,
                onScaleEnd: controller.onScaleEnd,
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  color: Colors.black,
                  child: Transform(
                    transform: controller.imageMatrix.value,
                    alignment: Alignment.center,
                    child: Image.file(
                      controller.imageFile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            }),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),

                  // Done button
                  Obx(() => ElevatedButton.icon(
                    onPressed: controller.isProcessing.value
                        ? null
                        : controller.saveImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: controller.isProcessing.value
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Iconsax.tick_circle, color: Colors.white),
                    label: Text(
                      controller.isProcessing.value ? 'Processing...' : 'Done',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rotate left
                  _buildControlButton(
                    icon: Iconsax.rotate_left,
                    label: 'Rotate',
                    onTap: controller.rotateLeft,
                  ),
                  // Flip horizontal
                  _buildControlButton(
                    icon: Iconsax.arrange_square_2,
                    label: 'Flip',
                    onTap: controller.flipHorizontal,
                  ),
                  // Reset
                  _buildControlButton(
                    icon: Iconsax.refresh,
                    label: 'Reset',
                    onTap: controller.reset,
                  ),
                ],
              ),
            ),
          ),

          // Zoom indicator
          Obx(() {
            if (controller.currentScale.value > 1.0) {
              return Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.currentScale.value.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageCropperController extends GetxController {
  final File imageFile;

  ImageCropperController({required this.imageFile});

  // Observable variables
  final isImageLoaded = false.obs;
  final isProcessing = false.obs;
  final imageMatrix = Matrix4.identity().obs;
  final currentScale = 1.0.obs;

  // Image transformation variables
  double scale = 1.0;
  double previousScale = 1.0;
  Offset offset = Offset.zero;
  Offset previousOffset = Offset.zero;
  double rotation = 0.0;
  bool isFlippedHorizontal = false;

  img.Image? originalImage;
  Size imageSize = Size.zero;

  @override
  void onInit() {
    super.onInit();
    loadImage();
  }

  @override
  void onClose() {
    originalImage = null;
    super.onClose();
  }

  Future<void> loadImage() async {
    try {
      final bytes = await imageFile.readAsBytes();
      originalImage = img.decodeImage(bytes);

      if (originalImage != null) {
        imageSize = Size(
          originalImage!.width.toDouble(),
          originalImage!.height.toDouble(),
        );
        isImageLoaded.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load image: $e');
      Get.back();
    }
  }

  void onScaleStart(ScaleStartDetails details) {
    previousScale = scale;
    previousOffset = offset;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    // Update scale (pinch zoom)
    scale = (previousScale * details.scale).clamp(0.5, 4.0);
    currentScale.value = scale;

    // Update offset (pan)
    offset = previousOffset + details.focalPointDelta;

    // Update transformation matrix
    updateMatrix();
  }

  void onScaleEnd(ScaleEndDetails details) {
    // Finalize the transformation
  }

  void updateMatrix() {
    final matrix = Matrix4.identity();

    // Apply translation (pan)
    matrix.translate(offset.dx, offset.dy);

    // Apply scale (zoom)
    matrix.scale(scale, scale);

    // Apply rotation
    if (rotation != 0) {
      matrix.rotateZ(rotation * 3.14159 / 180);
    }

    // Apply flip
    if (isFlippedHorizontal) {
      matrix.scale(-1.0, 1.0);
    }

    imageMatrix.value = matrix;
  }

  void rotateLeft() {
    rotation = (rotation - 90) % 360;
    updateMatrix();
  }

  void flipHorizontal() {
    isFlippedHorizontal = !isFlippedHorizontal;
    updateMatrix();
  }

  void reset() {
    scale = 1.0;
    previousScale = 1.0;
    offset = Offset.zero;
    previousOffset = Offset.zero;
    rotation = 0.0;
    isFlippedHorizontal = false;
    currentScale.value = 1.0;
    updateMatrix();
  }

  Future<void> saveImage() async {
    if (originalImage == null) return;

    try {
      isProcessing.value = true;

      img.Image processedImage = img.copyResize(
        originalImage!,
        width: originalImage!.width,
        height: originalImage!.height,
      );

      // Apply rotation if needed
      if (rotation == 90 || rotation == -270) {
        processedImage = img.copyRotate(processedImage, angle: 90);
      } else if (rotation == 180 || rotation == -180) {
        processedImage = img.copyRotate(processedImage, angle: 180);
      } else if (rotation == 270 || rotation == -90) {
        processedImage = img.copyRotate(processedImage, angle: 270);
      }

      // Apply flip if needed
      if (isFlippedHorizontal) {
        processedImage = img.flipHorizontal(processedImage);
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // Encode and save
      final pngBytes = img.encodePng(processedImage);
      await tempFile.writeAsBytes(pngBytes);

      // Return processed image
      Get.back(result: tempFile);
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to process image: $e');
    } finally {
      isProcessing.value = false;
    }
  }
}
