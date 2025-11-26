import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/reward_management/edit_reward_controller.dart';
import '../widgets/reward_form.dart';

class EditRewardScreen extends StatelessWidget {
  final String rewardId;

  const EditRewardScreen({
    super.key,
    required this.rewardId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditRewardController());
    final dark = FHelperFunctions.isDarkMode(context);

    // Load reward data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rewardId.isNotEmpty) {
        controller.loadRewardData(rewardId);
      }
    });

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
          'Edit Reward',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: FSizes.md),
            child: Obx(() => ElevatedButton.icon(
              onPressed: (controller.isLoading.value || !controller.hasChanges.value)
                  ? null
                  : controller.updateReward,
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
                  : const Icon(Iconsax.edit, size: 18, color: Colors.white),
              label: Text(
                controller.isLoading.value ? 'Updating...' : 'Update Reward',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.originalReward.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  'Loading reward data...',
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Changes indicator
                Obx(() {
                  if (!controller.hasChanges.value) return const SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(bottom: FSizes.spaceBtwSections),
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: (dark
                          ? FColors.adminDarkWarning
                          : FColors.adminLightWarning)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                      border: Border.all(
                        color: dark
                            ? FColors.adminDarkWarning
                            : FColors.adminLightWarning,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: dark
                              ? FColors.adminDarkWarning
                              : FColors.adminLightWarning,
                        ),
                        const SizedBox(width: FSizes.md),
                        Expanded(
                          child: Text(
                            'You have unsaved changes',
                            style: TextStyle(
                              color: dark
                                  ? FColors.adminDarkText
                                  : FColors.adminLightText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

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
                      existingImageName: controller.existingImageName.value,
                      getImageUrl: controller.getImageUrl,
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
              ],
            ),
          ),
        );
      }),
    );
  }
}