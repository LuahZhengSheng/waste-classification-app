import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

/// Reusable section card wrapper
class RewardFormSection extends StatelessWidget {
  final bool dark;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const RewardFormSection({
    super.key,
    required this.dark,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.adminDarkPrimary.withOpacity(0.1)
                      : FColors.adminLightPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                ),
                child: Icon(
                  icon,
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Text(
                title,
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          ...children,
        ],
      ),
    );
  }
}

/// Reusable text field
class RewardTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hint;
  final bool dark;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool required;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters; // 新增

  const RewardTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    required this.hint,
    required this.dark,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.required = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.inputFormatters, // 新增
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color: dark ? FColors.adminDarkError : FColors.adminLightError,
                ),
              ),
          ],
        ),
        const SizedBox(height: FSizes.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters, // 新增
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
              prefixIcon,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: dark
                ? FColors.adminDarkSurfaceVariant
                : FColors.adminLightSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark
                    ? FColors.adminDarkBorder.withOpacity(0.1)
                    : FColors.adminLightBorder.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color:
                dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark
                    ? FColors.adminDarkError
                    : FColors.adminLightError,
              ),
            ),
            contentPadding: const EdgeInsets.all(FSizes.md),
          ),
        ),
      ],
    );
  }
}

/// Reusable date time field
class RewardDateTimeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool dark;
  final VoidCallback onTap;
  final bool required;

  const RewardDateTimeField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    required this.dark,
    required this.onTap,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return RewardTextField(
      label: label,
      controller: controller,
      validator: validator,
      hint: 'Select date and time',
      dark: dark,
      readOnly: true,
      onTap: onTap,
      prefixIcon: Iconsax.calendar_1,
      suffixIcon: Icon(
        Iconsax.arrow_down_2,
        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
      ),
      required: required,
    );
  }
}

/// Reusable image uploader
class RewardImageUploader extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingImageName;
  final Future<String?> Function(String)? getImageUrl;
  final VoidCallback onSelectImage;
  final VoidCallback onRemoveImage;
  final bool isCompressing;
  final bool dark;

  const RewardImageUploader({
    super.key,
    required this.imageBytes,
    this.existingImageName,
    this.getImageUrl,
    required this.onSelectImage,
    required this.onRemoveImage,
    required this.isCompressing,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    // Show new image if selected
    if (imageBytes != null) {
      return _buildImagePreview(
        child: Image.memory(imageBytes!, fit: BoxFit.cover),
      );
    }

    // Show existing image if available
    if (existingImageName != null && existingImageName!.isNotEmpty && getImageUrl != null) {
      return FutureBuilder<String?>(
        future: getImageUrl!(existingImageName!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingPlaceholder();
          }

          if (snapshot.hasData && snapshot.data != null) {
            return _buildImagePreview(
              child: Image.network(
                snapshot.data!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
              ),
            );
          }

          return _buildUploadPlaceholder();
        },
      );
    }

    // Show upload placeholder
    return _buildUploadPlaceholder();
  }

  Widget _buildImagePreview({required Widget child}) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              color: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              child: child,
            ),
          ),
          if (isCompressing)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: FSizes.sm),
                    Text(
                      'Compressing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          if (!isCompressing)
            Positioned(
              top: FSizes.sm,
              right: FSizes.sm,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    ),
                    child: IconButton(
                      onPressed: onSelectImage,
                      icon: const Icon(Iconsax.edit, color: Colors.white, size: 18),
                      tooltip: 'Change Image',
                    ),
                  ),
                  const SizedBox(width: FSizes.xs),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    ),
                    child: IconButton(
                      onPressed: onRemoveImage,
                      icon: const Icon(Iconsax.trash, color: Colors.white, size: 18),
                      tooltip: 'Remove Image',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: onSelectImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark
              ? FColors.adminDarkSurfaceVariant
              : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark
                ? FColors.adminDarkBorder.withOpacity(0.3)
                : FColors.adminLightBorder.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkPrimary.withOpacity(0.1)
                    : FColors.adminLightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              ),
              child: Icon(
                Iconsax.gallery_add,
                size: 32,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Upload Reward Image',
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Click to browse and select an image file',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: dark
          ? FColors.adminDarkSurfaceVariant
          : FColors.adminLightSurfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.image,
            size: 48,
            color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable status toggle
class RewardStatusToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;
  final bool dark;

  const RewardStatusToggle({
    super.key,
    required this.isActive,
    required this.onToggle,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
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
              Iconsax.setting_3,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward Status',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Set whether this reward should be active',
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkTextMuted
                        : FColors.adminLightTextMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isActive
                    ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                    : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: isActive ? 30 : 2,
                    top: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isActive ? Iconsax.tick_circle : Iconsax.close_circle,
                        size: 16,
                        color: isActive
                            ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                            : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                      ),
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
}