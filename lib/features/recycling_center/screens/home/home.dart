import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../controllers/center_staff_home_controller.dart';
import '../add_recyling_activity/add_recycling_activity.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StaffHomeController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: SafeArea(
        child: Obx(() => controller.isValidUser.value
            ? _buildActivitiesView(context, controller, dark)
            : _buildUserSearchView(context, controller, dark)
        ),
      ),
    );
  }

  Widget _buildUserSearchView(BuildContext context, StaffHomeController controller, bool dark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(dark),
          const SizedBox(height: FSizes.spaceBtwSections),

          // Search Card
          _buildSearchCard(context, controller, dark),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Instructions
          _buildInstructions(dark),
        ],
      ),
    );
  }

  Widget _buildActivitiesView(BuildContext context, StaffHomeController controller, bool dark) {
    return Column(
      children: [
        // User Info Header
        _buildUserInfoHeader(controller, dark),

        // Activities List
        Expanded(
          child: _buildActivitiesList(context, controller, dark),
        ),

        // Submit Button
        _buildSubmitButton(controller, dark),
      ],
    );
  }

  Widget _buildHeader(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff Dashboard',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          'Enter user details to start recycling session',
          style: TextStyle(
            fontSize: 16,
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(BuildContext context, StaffHomeController controller, bool dark) {
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
      child: Form(
        key: controller.userIdFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkPrimary.withOpacity(0.2) : FColors.adminLightPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    Iconsax.user_search,
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    size: FSizes.iconMd,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Text(
                  'User Identification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // User ID Input
            TextFormField(
              controller: controller.userIdController,
              validator: controller.validateUserId,
              decoration: InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter user ID or scan QR code',
                prefixIcon: const Icon(Iconsax.user),
                suffixIcon: IconButton(
                  onPressed: controller.scanQRCode,
                  icon: const Icon(Iconsax.scan_barcode),
                  tooltip: 'Scan QR Code',
                ),
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
            const SizedBox(height: FSizes.spaceBtwItems),

            // Search Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.searchUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.search_normal_1),
                    SizedBox(width: FSizes.xs),
                    Text('Search User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )),

            // QR Code Button
            const SizedBox(height: FSizes.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.scanQRCode,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.scan_barcode,
                      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkInfo.withOpacity(0.1)
            : FColors.adminLightInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          _buildInstructionItem(
            '1. Enter the user ID manually or scan their QR code',
            dark,
          ),
          _buildInstructionItem(
            '2. Once user is found, you can add recycling activities',
            dark,
          ),
          _buildInstructionItem(
            '3. Add all waste items they want to recycle',
            dark,
          ),
          _buildInstructionItem(
            '4. Submit all activities to award points to the user',
            dark,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: FSizes.sm),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoHeader(StaffHomeController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      margin: const EdgeInsets.all(FSizes.md),
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
      child: Obx(() => Row(
        children: [
          // User Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: const Icon(
              Iconsax.user,
              color: Colors.white,
              size: FSizes.iconLg,
            ),
          ),
          const SizedBox(width: FSizes.md),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName.value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Text(
                  'ID: ${controller.userId.value}',
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Iconsax.crown1,
                      size: 16,
                      color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      '${controller.userRewardPoints.value} points',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Reset Button
          IconButton(
            onPressed: controller.resetForm,
            icon: Icon(
              Iconsax.refresh,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildActivitiesList(BuildContext context, StaffHomeController controller, bool dark) {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      itemCount: controller.currentActivities.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.currentActivities.length) {
          // Add new activity card
          return _buildAddActivityCard(context, controller, dark);
        } else {
          // Existing activity card
          return _buildActivityCard(context, controller, index, dark);
        }
      },
    ));
  }

  Widget _buildAddActivityCard(BuildContext context, StaffHomeController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddActivityForm(context, controller),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              border: Border.all(
                color: dark
                    ? FColors.adminDarkPrimary.withOpacity(0.3)
                    : FColors.adminLightPrimary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.adminDarkPrimary.withOpacity(0.2)
                        : FColors.adminLightPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                  child: Icon(
                    Iconsax.add_circle,
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    size: FSizes.iconLg,
                  ),
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  'Add Recycling Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Tap to add a new waste item',
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, StaffHomeController controller, int index, bool dark) {
    final activity = controller.currentActivities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
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
          // Header with actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.adminDarkSecondary.withOpacity(0.2)
                      : FColors.adminLightSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.trash,
                  color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.wasteObject,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                    Text(
                      '${activity.formattedWeight} • ${activity.pointsEarned} points',
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _navigateToEditActivityForm(context, controller, index),
                    icon: Icon(
                      Iconsax.edit,
                      color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.deleteRecyclingActivity(index),
                    icon: Icon(
                      Iconsax.trash,
                      color: dark ? FColors.adminDarkError : FColors.adminLightError,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Image preview if available
          if (activity.supportImage.isNotEmpty) ...[
            const SizedBox(height: FSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              child: Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Image Preview'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(StaffHomeController controller, bool dark) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Column(
        children: [
          // Summary
          if (controller.currentActivities.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              margin: const EdgeInsets.only(bottom: FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkSecondary.withOpacity(0.1)
                    : FColors.adminLightSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                border: Border.all(
                  color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${controller.currentActivities.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        ),
                      ),
                      Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${controller.totalSessionWeight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        ),
                      ),
                      Text(
                        'Total Weight',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${controller.totalSessionPoints}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                        ),
                      ),
                      Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.currentActivities.isEmpty
                  ? null
                  : (controller.isLoading.value ? null : controller.submitAllActivities),
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                ),
                elevation: controller.currentActivities.isEmpty ? 0 : 4,
              ),
              child: controller.isLoading.value
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
                  const Icon(Iconsax.send_1),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    controller.currentActivities.isEmpty
                        ? 'Add Activities First'
                        : 'Submit All Activities',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // Navigation methods
  void _navigateToAddActivityForm(BuildContext context, StaffHomeController controller) {
    Get.to(() => AddRecyclingActivityScreen(
      controller: controller,
      isEditing: false,
    ));
  }

  void _navigateToEditActivityForm(BuildContext context, StaffHomeController controller, int index) {
    Get.to(() => AddRecyclingActivityScreen(
      controller: controller,
      isEditing: true,
      editIndex: index,
      existingActivity: controller.currentActivities[index],
    ));
  }
}