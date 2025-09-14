import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../controllers/reward_management/add_reward_controller.dart';

class AddRewardScreen extends StatelessWidget {
  const AddRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddRewardController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Add New Reward',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: FSizes.md),
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.saveReward,
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
              ),
              icon: controller.isLoading.value
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Iconsax.tick_circle, size: 18, color: Colors.white),
              label: Text(
                controller.isLoading.value ? 'Saving...' : 'Save Reward',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              _buildSectionCard(
                dark: dark,
                title: 'Basic Information',
                icon: Iconsax.info_circle,
                children: [
                  // Title Field
                  _buildInputField(
                    label: 'Reward Title',
                    controller: controller.titleController,
                    validator: controller.validateTitle,
                    hint: 'Enter reward title',
                    dark: dark,
                    required: true,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Description Field
                  _buildInputField(
                    label: 'Description',
                    controller: controller.descriptionController,
                    validator: controller.validateDescription,
                    hint: 'Describe the reward in detail',
                    dark: dark,
                    maxLines: 3,
                    required: true,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Terms & Conditions Field
                  _buildInputField(
                    label: 'Terms & Conditions',
                    controller: controller.termsController,
                    validator: controller.validateTerms,
                    hint: 'Enter terms and conditions for this reward',
                    dark: dark,
                    maxLines: 3,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Reward Details Card
              _buildSectionCard(
                dark: dark,
                title: 'Reward Details',
                icon: Iconsax.gift,
                children: [
                  Row(
                    children: [
                      // Points Needed
                      Expanded(
                        child: _buildInputField(
                          label: 'Points Required',
                          controller: controller.pointsController,
                          validator: controller.validatePoints,
                          hint: '0',
                          dark: dark,
                          keyboardType: TextInputType.number,
                          prefixIcon: Iconsax.coin,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: FSizes.md),

                      // Quantity
                      Expanded(
                        child: _buildInputField(
                          label: 'Total Quantity',
                          controller: controller.quantityController,
                          validator: controller.validateQuantity,
                          hint: '0',
                          dark: dark,
                          keyboardType: TextInputType.number,
                          prefixIcon: Iconsax.box,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Valid Until Date
                  _buildDateField(
                    label: 'Valid Until',
                    controller: controller.validUntilController,
                    dark: dark,
                    onTap: controller.selectValidUntilDate,
                    validator: controller.validateValidUntil,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Image Upload Card
              _buildSectionCard(
                dark: dark,
                title: 'Reward Image',
                icon: Iconsax.image,
                children: [
                  Obx(() => _buildImageUpload(controller, dark)),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Status Card
              _buildSectionCard(
                dark: dark,
                title: 'Reward Status',
                icon: Iconsax.status,
                children: [
                  Container(
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
                                'Set whether this reward should be active immediately after creation',
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
                        Obx(() => _buildStatusToggle(controller, dark)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.isLoading.value ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        side: BorderSide(
                          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: dark
                              ? FColors.adminDarkTextSecondary
                              : FColors.adminLightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.saveReward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Create Reward',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool dark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required String hint,
    required bool dark,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    bool required = false,
  }) {
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
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            )
                : null,
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
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
              ),
            ),
            contentPadding: const EdgeInsets.all(FSizes.md),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required bool dark,
    required VoidCallback onTap,
    required String? Function(String?)? validator,
    bool required = false,
  }) {
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
          readOnly: true,
          onTap: onTap,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
          decoration: InputDecoration(
            hintText: 'Select expiry date',
            hintStyle: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            prefixIcon: Icon(
              Iconsax.calendar_1,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            suffixIcon: Icon(
              Iconsax.arrow_down_2,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
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
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
              ),
            ),
            contentPadding: const EdgeInsets.all(FSizes.md),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload(AddRewardController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reward Image',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),

        if (controller.selectedImagePath.value.isEmpty)
        // Upload placeholder
          GestureDetector(
            onTap: controller.pickImage,
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
          )
        else
        // Image preview
          Container(
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
                    child: Icon(
                      Iconsax.image,
                      size: 48,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  ),
                ),
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
                          onPressed: controller.pickImage,
                          icon: const Icon(
                            Iconsax.edit,
                            color: Colors.white,
                            size: 18,
                          ),
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
                          onPressed: controller.removeImage,
                          icon: const Icon(
                            Iconsax.trash,
                            color: Colors.white,
                            size: 18,
                          ),
                          tooltip: 'Remove Image',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusToggle(AddRewardController controller, bool dark) {
    return GestureDetector(
      onTap: controller.toggleStatus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: controller.isActive.value
              ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
              : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: controller.isActive.value ? 30 : 2,
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
                  controller.isActive.value ? Iconsax.tick_circle : Iconsax.close_circle,
                  size: 16,
                  color: controller.isActive.value
                      ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                      : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}