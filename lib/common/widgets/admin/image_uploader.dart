import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

import 'admin_lightbox.dart';

class ImageUploader extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingImageName;
  final Future<String?> Function(String) getImageUrl;
  final VoidCallback onSelectImage;
  final VoidCallback onRemoveImage;
  final bool isCompressing;
  final bool dark;
  final bool required;
  final String label;
  final String? description;

  const ImageUploader({
    super.key,
    this.imageBytes,
    this.existingImageName,
    required this.getImageUrl,
    required this.onSelectImage,
    required this.onRemoveImage,
    required this.isCompressing,
    required this.dark,
    this.required = false,
    this.label = 'Image',
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null ||
        (existingImageName != null && existingImageName!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color:
                  dark ? FColors.adminDarkError : FColors.adminLightError,
                ),
              ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: FSizes.sm),
          Text(
            description!,
            style: TextStyle(
              fontSize: 12,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          ),
        ],
        const SizedBox(height: FSizes.spaceBtwItems),

        Builder(
          builder: (context) {
            if (isCompressing) {
              return _buildCompressingState();
            }

            if (imageBytes != null) {
              return _buildImagePreview(
                imageBytes: imageBytes!,
                onRemove: onRemoveImage,
                onTap: () => _showImageLightbox(imageBytes!, dark),
                dark: dark,
              );
            }

            if (existingImageName != null && existingImageName!.isNotEmpty) {
              return _buildExistingImagePreview(
                imageFileName: existingImageName!,
                onRemove: onRemoveImage,
                onSelect: onSelectImage,
                onTap: () =>
                    _showExistingImageLightbox(existingImageName!, dark),
                dark: dark,
              );
            }

            // 没有图片时，才根据 required 用红色
            return _buildUploadPrompt(
              onTap: onSelectImage,
              dark: dark,
              required: required,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompressingState() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Compressing image...',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview({
    required Uint8List imageBytes,
    required VoidCallback onRemove,
    required VoidCallback onTap,
    required bool dark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
          ),
        ),
        child: Stack(
          children: [
            // Image container - use contain to maintain aspect ratio
            Container(
              margin: const EdgeInsets.all(FSizes.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd - 2),
                child: Image.memory(
                  imageBytes,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Delete button
            Positioned(
              top: FSizes.sm,
              right: FSizes.sm,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(FSizes.xs),
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkError : FColors.adminLightError,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                  ),
                  child: const Icon(
                    Iconsax.trash,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingImagePreview({
    required String imageFileName,
    required VoidCallback onRemove,
    required VoidCallback onSelect,
    required VoidCallback onTap,
    required bool dark,
  }) {
    return FutureBuilder<String?>(
      future: getImageUrl(imageFileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250,
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildUploadPrompt(
            onTap: onSelect,
            dark: dark,
            required: true,
          );
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
            ),
            child: Stack(
              children: [
                // Image container - use contain to maintain aspect ratio
                Container(
                  margin: const EdgeInsets.all(FSizes.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd - 2),
                    child: Image.network(
                      snapshot.data!,
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.image,
                              size: 48,
                              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                            ),
                            const SizedBox(height: FSizes.sm),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: FSizes.sm,
                  right: FSizes.sm,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onSelect,
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.xs),
                          decoration: BoxDecoration(
                            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                            borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                          ),
                          child: const Icon(
                            Iconsax.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: FSizes.xs),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.xs),
                          decoration: BoxDecoration(
                            color: dark ? FColors.adminDarkError : FColors.adminLightError,
                            borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                          ),
                          child: const Icon(
                            Iconsax.trash,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadPrompt({
    required VoidCallback onTap,
    required bool dark,
    required bool required,
  }) {
    // 不再根据 required/hasImage 切颜色，保持统一样式
    final borderColor =
    dark ? FColors.adminDarkBorder : FColors.adminLightBorder;
    final iconColor =
    dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary;
    final textColor =
    dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark
              ? FColors.adminDarkSurfaceVariant
              : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gallery_add,
              size: 48,
              color: iconColor,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              required
                  ? 'Click to upload image (Required)'
                  : 'Click to upload image',
              style: TextStyle(
                color: textColor,
                fontWeight: required ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'JPG, PNG, WebP up to 5MB',
              style: TextStyle(
                fontSize: 12,
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

  void _showImageLightbox(Uint8List imageBytes, bool dark, {String title = 'Image Preview'}) {
    Get.dialog(
      ImageLightbox(
        imageBytes: imageBytes,
        title: title,
      ),
    );
  }

  void _showExistingImageLightbox(String imageFileName, bool dark) {
    getImageUrl(imageFileName).then((imageUrl) {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        Get.dialog(
          ImageLightbox(
            imageUrl: imageUrl,
            title: label,
          ),
        );
      }
    });
  }
}