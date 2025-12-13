import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/recycling_center_management/edit_center_controller.dart';

import '../../../../../utils/popups/admin_loaders.dart';
import '../widgets/center_form.dart';

class EditPartnerCenterScreen extends StatelessWidget {
  final String centerId;

  const EditPartnerCenterScreen({
    super.key,
    required this.centerId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditCenterController());
    final dark = FHelperFunctions.isDarkMode(context);

    // Load center data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (centerId.isNotEmpty) {
        controller.loadCenterData(centerId);
      }
    });

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Edit Partner Recycling Center',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => ElevatedButton(
            onPressed: (controller.isLoading.value || !controller.hasChanges.value)
                ? null
                : () => _showUpdateConfirmationDialog(controller, dark),
            style: ElevatedButton.styleFrom(
              backgroundColor: dark
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
              disabledBackgroundColor: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
              padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.lg, vertical: FSizes.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Update Center',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),
          const SizedBox(width: FSizes.md),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.originalCenter.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  'Loading center data...',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
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
                      color: (dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                      border: Border.all(
                        color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                        ),
                        const SizedBox(width: FSizes.md),
                        Expanded(
                          child: Text(
                            'You have unsaved changes',
                            style: TextStyle(
                              color: dark ? FColors.adminDarkText : FColors.adminLightText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Basic Information Section
                CenterFormSection(
                  dark: dark,
                  title: 'Basic Information',
                  children: [
                    CenterTextField(
                      controller: controller.nameController,
                      label: 'Center Name *',
                      hint: 'e.g., Green Recycling Center KL',
                      icon: Iconsax.building_4,
                      dark: dark,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),
                    Row(
                      children: [
                        Expanded(
                          child: CenterTextField(
                            controller: controller.emailController,
                            label: 'Email Address *',
                            hint: 'center@example.com',
                            icon: Iconsax.sms,
                            dark: dark,
                            keyboardType: TextInputType.emailAddress,
                            validator: controller.validateEmail,
                          ),
                        ),
                        const SizedBox(width: FSizes.md),
                        Expanded(
                          child: CenterTextField(
                            controller: controller.phoneController,
                            label: 'Phone Number *',
                            hint: '0123456789',
                            icon: Iconsax.call,
                            dark: dark,
                            keyboardType: TextInputType.phone,
                            validator: controller.validatePhone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),
                    CenterTextField(
                      controller: controller.websiteController,
                      label: 'Website *',
                      hint: 'https://www.example.com',
                      icon: Iconsax.global,
                      dark: dark,
                      keyboardType: TextInputType.url,
                      validator: controller.validateWebsite,
                    ),
                  ],
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Location Section
                CenterFormSection(
                  dark: dark,
                  title: 'Location',
                  children: [
                    Obx(() {
                      final location = controller.selectedLocation.value;
                      return CenterLocationSelector(
                        selectedLocation: location,
                        onLocationSelected: controller.setLocation,
                        onClear: controller.clearLocation,
                        dark: dark,
                      );
                    }),
                  ],
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Opening Hours Section
                CenterFormSection(
                  dark: dark,
                  title: 'Opening Hours',
                  children: [
                    Obx(() {
                      final hours = controller.openingHours.value;

                      return OpeningHoursSelector(
                        openingHours: hours,
                        onTimeUpdated: controller.updateOpeningHours,
                        onDayToggle: controller.toggleDayStatus,
                        onBatchUpdate: controller.batchUpdateOpeningHours,
                        dark: dark,
                      );
                    }),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Select operating days and set business hours for each day',
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

                // Center Image Section
                CenterFormSection(
                  dark: dark,
                  title: 'Center Image',
                  children: [
                    Obx(() {
                      final imageBytes = controller.selectedImageBytes.value;
                      final isCompressing = controller.isCompressing.value;
                      return CenterImageUploader(
                        imageBytes: imageBytes,
                        existingImageName: controller.existingImageName.value,
                        getImageUrl: controller.getImageUrl,
                        onSelectImage: controller.selectImage,
                        onRemoveImage: controller.removeImage,
                        isCompressing: isCompressing,
                        dark: dark,
                      );
                    }),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Upload a clear image of the recycling center (optional)',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Accepted Materials Section
                CenterFormSection(
                  dark: dark,
                  title: 'Accepted Materials',
                  children: [
                    Obx(() {
                      final materials = controller.selectedMaterials.toList();
                      final categories = controller.availableCategories.toList();
                      return MaterialsSelector(
                        selectedMaterials: materials,
                        availableCategories: categories,
                        onToggleMaterial: controller.toggleMaterial,
                        dark: dark,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showUpdateConfirmationDialog(EditCenterController controller, bool dark) {
    FAdminLoaders.showRecyclingCenterUpdateDialog(
      changedFields: controller.getChangedFields(),
      onConfirm: controller.updateCenter,
    );
  }
}