import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/reward_management/add_reward_controller.dart';

import '../widgets/reward_form.dart';

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
              onPressed: controller.isLoading.value ? null : controller.createReward,
              style: ElevatedButton.styleFrom(
                backgroundColor: dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary,
                padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
                disabledBackgroundColor: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
              icon: controller.isLoading.value
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Iconsax.add_circle, size: 18, color: Colors.white),
              label: Text(
                controller.isLoading.value ? 'Creating...' : 'Create Reward',
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
              // Basic Information Section
              RewardFormSection(
                dark: dark,
                title: 'Basic Information',
                icon: Iconsax.info_circle,
                children: [
                  RewardTextField(
                    label: 'Reward Title',
                    controller: controller.titleController,
                    validator: controller.validateTitle,
                    hint: 'Enter reward title',
                    dark: dark,
                    required: true,
                  ),
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  RewardTextField(
                    label: 'Description',
                    controller: controller.descriptionController,
                    validator: controller.validateDescription,
                    hint: 'Describe the reward in detail',
                    dark: dark,
                    maxLines: 3,
                    required: true,
                  ),
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  RewardTextField(
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

              // Reward Details Section
              RewardFormSection(
                dark: dark,
                title: 'Reward Details',
                icon: Iconsax.gift,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RewardTextField(
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
                      Expanded(
                        child: RewardTextField(
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
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  RewardDateTimeField(
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

              // Image Upload Section
              RewardFormSection(
                dark: dark,
                title: 'Reward Image',
                icon: Iconsax.image,
                children: [
                  Obx(() => RewardImageUploader(
                    imageBytes: controller.selectedImageBytes.value,
                    onSelectImage: controller.pickImage,
                    onRemoveImage: controller.removeImage,
                    isCompressing: controller.isCompressing.value,
                    dark: dark,
                  )),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'Upload a clear image of the reward (optional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark
                          ? FColors.adminDarkTextMuted
                          : FColors.adminLightTextMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Status Section
              RewardFormSection(
                dark: dark,
                title: 'Reward Status',
                icon: Iconsax.status,
                children: [
                  Obx(() => RewardStatusToggle(
                    isActive: controller.isActive.value,
                    onToggle: controller.toggleStatus,
                    dark: dark,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}