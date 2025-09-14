import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../personalization/models/recycle_activity_model.dart';
import '../../controllers/add_activity_controller.dart';
import '../../controllers/center_staff_home_controller.dart';

class AddRecyclingActivityScreen extends StatelessWidget {
  final StaffHomeController controller;
  final bool isEditing;
  final int? editIndex;
  final RecyclingActivity? existingActivity;

  const AddRecyclingActivityScreen({
    super.key,
    required this.controller,
    required this.isEditing,
    this.editIndex,
    this.existingActivity,
  });

  @override
  Widget build(BuildContext context) {
    final formController = Get.put(AddActivityFormController(
      isEditing: isEditing,
      existingActivity: existingActivity,
      wasteCategories: controller.wasteCategories,
    ));

    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Activity' : 'Add Recycling Activity',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
        ),
      ),
      body: Form(
        key: formController.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Waste Category Selection
              _buildWasteCategorySection(formController, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Waste Object Input
              _buildWasteObjectSection(formController, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Weight Input
              _buildWeightSection(formController, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Image Upload Section
              _buildImageUploadSection(formController, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Points Preview
              _buildPointsPreview(formController, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Submit Button
              _buildSubmitButton(formController, dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWasteCategorySection(AddActivityFormController formController, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.category,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Waste Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          Obx(() => Wrap(
            spacing: FSizes.sm,
            runSpacing: FSizes.sm,
            children: formController.wasteCategories.map((category) {
              final isSelected = formController.selectedCategory.value?.categoryId == category.categoryId;

              return GestureDetector(
                onTap: () => formController.selectCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                        : (dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    border: Border.all(
                      color: isSelected
                          ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                          : (dark ? FColors.adminDarkBorder : FColors.adminLightBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected
                            ? Colors.white
                            : (dark ? FColors.adminDarkText : FColors.adminLightText),
                        size: 16,
                      ),
                      const SizedBox(width: FSizes.xs),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (dark ? FColors.adminDarkText : FColors.adminLightText),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildWasteObjectSection(AddActivityFormController formController, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.edit,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Waste Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          TextFormField(
            controller: formController.wasteObjectController,
            validator: formController.validateWasteObject,
            decoration: InputDecoration(
              labelText: 'Waste Item Description',
              hintText: 'e.g., Plastic bottles, Newspaper, Old laptop',
              prefixIcon: const Icon(Iconsax.document_text),
              filled: true,
              fillColor: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide(
                  color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide(
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  width: 2,
                ),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSection(AddActivityFormController formController, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.weight_1,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Weight (kg)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: formController.weightController,
                  validator: formController.validateWeight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => formController.calculatePoints(),
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    hintText: '0.00',
                    prefixIcon: const Icon(Iconsax.weight_1),
                    suffixText: 'kg',
                    filled: true,
                    fillColor: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                      borderSide: BorderSide(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                      borderSide: BorderSide(
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        width: 2,
                      ),
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

  Widget _buildImageUploadSection(AddActivityFormController formController, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.camera,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Support Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                '*',
                style: TextStyle(
                  color: dark ? FColors.adminDarkError : FColors.adminLightError,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          Obx(() => formController.selectedImage.value == null
              ? _buildImageUploadButton(formController, dark)
              : _buildImagePreview(formController, dark)
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton(AddActivityFormController formController, bool dark) {
    return GestureDetector(
      onTap: formController.pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: Border.all(
            color: dark
                ? FColors.adminDarkPrimary.withOpacity(0.3)
                : FColors.adminLightPrimary.withOpacity(0.3),
            width: 2,
            style: BorderStyle.values[1], // dashed style equivalent
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkPrimary.withOpacity(0.2)
                    : FColors.adminLightPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Icon(
                Iconsax.camera,
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                size: FSizes.iconLg,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Tap to upload image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Take a photo of the waste items',
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(AddActivityFormController formController, bool dark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Text('Image Preview\n(Mock)'),
            ),
          ),
        ),
        Positioned(
          top: FSizes.sm,
          right: FSizes.sm,
          child: GestureDetector(
            onTap: formController.removeImage,
            child: Container(
              padding: const EdgeInsets.all(FSizes.xs),
              decoration: BoxDecoration(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: const Icon(
                Iconsax.close_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: FSizes.sm,
          left: FSizes.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: const Text(
              'Image uploaded',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsPreview(AddActivityFormController formController, bool dark) {
    return Obx(() => formController.calculatedPoints.value > 0
        ? Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSecondary.withOpacity(0.1)
            : FColors.adminLightSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: const Icon(
              Iconsax.crown1,
              color: Colors.white,
              size: FSizes.iconLg,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Points Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Text(
                  'User will earn ${formController.calculatedPoints.value} points',
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${formController.calculatedPoints.value}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
            ),
          ),
        ],
      ),
    )
        : const SizedBox()
    );
  }

  Widget _buildSubmitButton(AddActivityFormController formController, bool dark) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: formController.isLoading.value
            ? null
            : () => _submitForm(formController),
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.buttonRadius),
          ),
        ),
        child: formController.isLoading.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isEditing ? Iconsax.edit : Iconsax.add),
            const SizedBox(width: FSizes.sm),
            Text(
              isEditing ? 'Update Activity' : 'Add Activity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _submitForm(AddActivityFormController formController) {
    if (formController.validateForm()) {
      final activity = formController.createActivity(controller.userId.value, 'center123');

      if (isEditing && editIndex != null) {
        controller.editRecyclingActivity(editIndex!, activity);
      } else {
        controller.addRecyclingActivity(activity);
      }
    }
  }
}