import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/scan_sort_camera_controller.dart';

class ScanSortCameraScreen extends StatelessWidget {
  const ScanSortCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScanSortCameraController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      body: Obx(() => Stack(
        fit: StackFit.expand,
        children: [
          // Error State
          if (controller.hasError)
            _buildErrorState(controller, context, dark),

          // Loading State
          if (controller.isLoading)
            _buildLoadingState(dark),

          // Camera Preview with Gesture Detector for Zoom
          if (controller.isInitialized && controller.controller != null)
            GestureDetector(
              onScaleStart: controller.onScaleStart,
              onScaleUpdate: controller.onScaleUpdate,
              child: _buildCameraPreview(controller),
            ),

          // Top Buttons (Drop Off, Categories & History)
          if (!controller.isLoading && !controller.hasError)
            _buildTopButtons(context, dark),

          // Camera Frame Overlay with Text
          if (controller.isInitialized && !controller.isLoading)
            _buildCameraFrameOverlay(context, dark),

          // Bottom Controls
          if (!controller.isLoading && !controller.hasError)
            _buildBottomControls(controller, context, dark),

          // Zoom Controls
          if (controller.isInitialized && !controller.isLoading)
            _buildZoomControls(controller, context, dark),

          // Zoom Indicator
          if (controller.isInitialized && controller.currentZoom > 1.0)
            _buildZoomIndicator(controller, context, dark),
        ],
      )),
    );
  }

  Widget _buildCameraPreview(ScanSortCameraController controller) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.controller!.value.previewSize?.height ?? 100,
          height: controller.controller!.value.previewSize?.width ?? 100,
          child: CameraPreview(controller.controller!),
        ),
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context, bool dark) {
    final controller = Get.find<ScanSortCameraController>();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drop Off Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => controller.navigateToDropOff(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: FColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 20,
                      color: FColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Drop Off',
                      style: TextStyle(
                        color: FColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right side buttons
          Row(
            children: [
              // Categories Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => controller.navigateToCategories(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md,
                      vertical: FSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: FColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.category,
                          size: 20,
                          color: FColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Categories',
                          style: TextStyle(
                            color: FColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // History Button (NEW)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => controller.navigateToHistory(),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: FColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Iconsax.document,
                      size: 20,
                      color: FColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls(ScanSortCameraController controller, BuildContext context, bool dark) {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.4,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: dark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FColors.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zoom In Button
            _buildZoomButton(
              icon: Iconsax.add,
              onTap: controller.zoomIn,
              dark: dark,
              isEnabled: controller.currentZoom < controller.maxZoom,
            ),
            const SizedBox(height: 12),
            // Zoom Level Display
            Container(
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                controller.zoomText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark ? FColors.white : FColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Zoom Out Button
            _buildZoomButton(
              icon: Iconsax.minus,
              onTap: controller.zoomOut,
              dark: dark,
              isEnabled: controller.currentZoom > 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool dark,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled
              ? FColors.primary
              : (dark ? FColors.darkGrey : FColors.grey),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (dark ? Colors.black : Colors.grey).withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isEnabled ? FColors.white : FColors.lightGrey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCameraFrameOverlay(BuildContext context, bool dark) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.width * 0.75,
        child: Stack(
          children: [
            // Corner frames
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: FColors.white, width: 3),
                    left: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: FColors.white, width: 3),
                    right: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: FColors.white, width: 3),
                    left: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: FColors.white, width: 3),
                    right: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            // Text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Point your camera at',
                    style: TextStyle(
                      color: FColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'recycling objects and',
                    style: TextStyle(
                      color: FColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'take a photo',
                    style: TextStyle(
                      color: FColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
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

  Widget _buildBottomControls(
      ScanSortCameraController controller,
      BuildContext context,
      bool dark,
      ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 32,
          top: 32,
          left: 32,
          right: 32,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gallery Button
            _buildControlButton(
              icon: Iconsax.gallery,
              onTap: controller.canTakePhoto ? () async {
                print('🖼️ Gallery button pressed');
                try {
                  final file = await controller.pickFromGallery();
                  if (file != null) {
                    print('📸 Gallery image obtained: ${file.path}');
                    await controller.processCapturedImage(file);
                  } else {
                    print('❌ Gallery picker returned null');
                  }
                } catch (e) {
                  print('❌ Gallery picker error: $e');
                  Get.snackbar(
                    'Error',
                    'Failed to pick image: $e',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              } : null, // 🎯 上传时禁用相册按钮
              dark: dark,
              isEnabled: controller.canTakePhoto, // 🎯 根据状态设置启用状态
            ),

            // Capture Button
            GestureDetector(
              onTap: controller.canTakePhoto ? () async {
                print('🎯 Capture button pressed');
                try {
                  final file = await controller.capturePhoto();
                  if (file != null) {
                    print('📸 Photo file obtained: ${file.path}');
                    await controller.processCapturedImage(file);
                  } else {
                    print('❌ Photo capture returned null');
                    Get.snackbar(
                      'Error',
                      'Failed to capture photo',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                } catch (e) {
                  print('❌ Capture button error: $e');
                  Get.snackbar(
                    'Error',
                    'Failed to capture photo: $e',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              } : null, // 🎯 上传时禁用拍照按钮
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: controller.canTakePhoto
                        ? (dark ? FColors.white : FColors.primary)
                        : (dark ? FColors.darkGrey : FColors.grey), // 🎯 根据状态改变颜色
                    width: 5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: controller.canTakePhoto
                          ? (dark ? FColors.white : FColors.primary)
                          : (dark ? FColors.darkGrey : FColors.grey), // 🎯 根据状态改变颜色
                      shape: BoxShape.circle,
                    ),
                    child: controller.isCapturing || controller.isUploading
                        ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: dark ? FColors.primary : FColors.white,
                      ),
                    )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),

            // Flash Toggle Button
            _buildControlButton(
              icon: controller.isFlashOn ? Iconsax.flash_15 : Iconsax.flash_slash,
              onTap: controller.canTakePhoto ? controller.toggleFlash : null, // 🎯 上传时禁用闪光灯
              dark: dark,
              isActive: controller.isFlashOn,
              isEnabled: controller.canTakePhoto, // 🎯 根据状态设置启用状态
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool dark,
    bool isActive = false,
    bool isEnabled = true, // 🎯 新增启用状态参数
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isEnabled
              ? (isActive ? FColors.primary : (dark ? FColors.darkContainer : FColors.white))
              : (dark ? FColors.darkGrey : FColors.grey), // 🎯 根据启用状态改变颜色
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled
                ? (isActive ? FColors.primary : (dark ? FColors.borderPrimary.withOpacity(0.3) : FColors.borderPrimary))
                : (dark ? FColors.darkGrey : FColors.grey), // 🎯 根据启用状态改变边框颜色
            width: 2,
          ),
          boxShadow: isEnabled ? [ // 🎯 禁用时不显示阴影
            BoxShadow(
              color: (dark ? Colors.black : Colors.grey).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? (isActive ? FColors.white : (dark ? FColors.white : FColors.textPrimary))
              : (dark ? FColors.lightGrey : FColors.textSecondary), // 🎯 根据启用状态改变图标颜色
          size: 28,
        ),
      ),
    );
  }

  Widget _buildZoomIndicator(
      ScanSortCameraController controller,
      BuildContext context,
      bool dark,
      ) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm,
          vertical: FSizes.xs,
        ),
        decoration: BoxDecoration(
          color: dark
              ? Colors.black.withOpacity(0.6)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FColors.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.search_zoom_in,
              size: 16,
              color: FColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              controller.zoomText,
              style: TextStyle(
                color: dark ? FColors.white : FColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: FColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Initializing Camera...',
            style: TextStyle(
              color: dark ? FColors.white : FColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      ScanSortCameraController controller,
      BuildContext context,
      bool dark,
      ) {
    final errorMessageLower = controller.errorMessage.toLowerCase();
    final isPermissionError = errorMessageLower.contains('permission') ||
        errorMessageLower.contains('denied');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: FColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.camera_slash,
                color: FColors.error,
                size: 50,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            Text(
              isPermissionError ? 'Camera Permission Required' : 'Camera Error',
              style: TextStyle(
                color: dark ? FColors.white : FColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              controller.errorMessage,
              style: TextStyle(
                color: dark ? FColors.lightGrey : FColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ? FColors.darkGrey : FColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        color: dark ? FColors.white : FColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isPermissionError
                        ? controller.openSettings
                        : controller.retryInitialize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: Text(
                      isPermissionError ? 'Settings' : 'Retry',
                      style: const TextStyle(
                        color: FColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}