import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/recycling_center_management/add_center_controller.dart';

import '../widgets/center_form.dart';

class AddPartnerCenterScreen extends StatelessWidget {
  const AddPartnerCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddCenterController());
    final dark = FHelperFunctions.isDarkMode(context);

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
          'Add Partner Recycling Center',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => ElevatedButton(
            onPressed:
            controller.isLoading.value ? null : controller.createCenter,
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
                : const Text(
              'Create Center',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          )),
          const SizedBox(width: FSizes.md),
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
                  // ✅ Fixed: Directly access the observable map value
                  Obx(() {
                    // Force rebuild by accessing the observable
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
                      existingImageName: null,
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
      ),
    );
  }
}