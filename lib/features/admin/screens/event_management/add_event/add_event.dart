import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../controllers/event_management/add_event_controller.dart';

class AddEventScreen extends StatelessWidget {
  const AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEventController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Add New Event',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Save as Draft Button
          TextButton(
            onPressed: controller.saveAsDraft,
            child: Text(
              'Save as Draft',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: FSizes.sm),
          // Create Event Button
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.createEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Create Event',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
              _buildSectionTitle('Basic Information', dark),
              const SizedBox(height: FSizes.spaceBtwItems),
              _buildBasicInfoSection(controller, dark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Date & Time Section
              _buildSectionTitle('Date & Time', dark),
              const SizedBox(height: FSizes.spaceBtwItems),
              _buildDateTimeSection(controller, dark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Location Section
              _buildSectionTitle('Location', dark),
              const SizedBox(height: FSizes.spaceBtwItems),
              _buildLocationSection(controller, dark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Registration Section
              _buildSectionTitle('Registration Settings', dark),
              const SizedBox(height: FSizes.spaceBtwItems),
              _buildRegistrationSection(controller, dark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Contact Information Section
              _buildSectionTitle('Contact Information', dark),
              const SizedBox(height: FSizes.spaceBtwItems),
              _buildContactSection(controller, dark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Event Poster Section
              _buildSectionTitle('Event Poster', dark),
              const SizedBox(height: FSizes.spaceBtwItems),
              _buildPosterSection(controller, dark),

              const SizedBox(height: FSizes.spaceBtwSections * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool dark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: dark ? FColors.adminDarkText : FColors.adminLightText,
      ),
    );
  }

  Widget _buildBasicInfoSection(AddEventController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Event Title
          TextFormField(
            controller: controller.titleController,
            decoration: _inputDecoration('Event Title *', Iconsax.text, dark),
            style: _inputTextStyle(dark),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Event title is required';
              }
              if (value.length < 3) {
                return 'Event title must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // Event Description
          TextFormField(
            controller: controller.descriptionController,
            decoration: _inputDecoration('Event Description *', Iconsax.document_text, dark),
            style: _inputTextStyle(dark),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Event description is required';
              }
              if (value.length < 10) {
                return 'Event description must be at least 10 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(AddEventController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start Date & Time
          Row(
            children: [
              Expanded(
                child: Obx(() => InkWell(
                  onTap: () => controller.selectStartDate(),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.calendar,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                              ),
                              Text(
                                controller.selectedStartDate.value != null
                                    ? controller.formatDate(controller.selectedStartDate.value!)
                                    : 'Select start date',
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Obx(() => InkWell(
                  onTap: () => controller.selectStartTime(),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                              ),
                              Text(
                                controller.selectedStartTime.value != null
                                    ? controller.formatTime(controller.selectedStartTime.value!)
                                    : 'Select start time',
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // End Date & Time
          Row(
            children: [
              Expanded(
                child: Obx(() => InkWell(
                  onTap: () => controller.selectEndDate(),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.calendar,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                              ),
                              Text(
                                controller.selectedEndDate.value != null
                                    ? controller.formatDate(controller.selectedEndDate.value!)
                                    : 'Select end date',
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Obx(() => InkWell(
                  onTap: () => controller.selectEndTime(),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                              ),
                              Text(
                                controller.selectedEndTime.value != null
                                    ? controller.formatTime(controller.selectedEndTime.value!)
                                    : 'Select end time',
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(AddEventController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => InkWell(
            onTap: controller.showLocationDialog,
            child: Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                border: Border.all(
                  color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                ),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.location,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Location *',
                          style: TextStyle(
                            fontSize: 12,
                            color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                          ),
                        ),
                        Text(
                          controller.selectedLocation.value != null
                              ? controller.selectedLocation.value!.shortAddress
                              : 'Add event location',
                          style: TextStyle(
                            color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRegistrationSection(AddEventController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Max Participants
          TextFormField(
            controller: controller.maxParticipantsController,
            decoration: _inputDecoration('Maximum Participants *', Iconsax.people, dark),
            style: _inputTextStyle(dark),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Maximum participants is required';
              }
              final number = int.tryParse(value);
              if (number == null || number <= 0) {
                return 'Please enter a valid number greater than 0';
              }
              return null;
            },
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // Registration Deadline
          Row(
            children: [
              Expanded(
                child: Obx(() => InkWell(
                  onTap: () => controller.selectRegistrationDeadlineDate(),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.calendar,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registration Deadline Date *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                              ),
                              Text(
                                controller.selectedRegistrationDeadlineDate.value != null
                                    ? controller.formatDate(controller.selectedRegistrationDeadlineDate.value!)
                                    : 'Select deadline date',
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Obx(() => InkWell(
                  onTap: () => controller.selectRegistrationDeadlineTime(),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deadline Time *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                                ),
                              ),
                              Text(
                                controller.selectedRegistrationDeadlineTime.value != null
                                    ? controller.formatTime(controller.selectedRegistrationDeadlineTime.value!)
                                    : 'Select deadline time',
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(AddEventController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contact Email
          TextFormField(
            controller: controller.contactEmailController,
            decoration: _inputDecoration('Contact Email *', Iconsax.sms, dark),
            style: _inputTextStyle(dark),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Contact email is required';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // Contact Phone Number
          TextFormField(
            controller: controller.contactPhoneController,
            decoration: _inputDecoration('Contact Phone Number *', Iconsax.call, dark),
            style: _inputTextStyle(dark),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Contact phone number is required';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPosterSection(AddEventController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Event Poster (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Add an eye-catching poster to promote your event',
            style: TextStyle(
              fontSize: 12,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          Obx(() => controller.selectedPosterPath.value != null
              ? Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  child: Image.network(
                    controller.selectedPosterPath.value!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                      ),
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
                            'Image Preview',
                            style: TextStyle(
                              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: FSizes.sm,
                  right: FSizes.sm,
                  child: GestureDetector(
                    onTap: controller.removePoster,
                    child: Container(
                      padding: const EdgeInsets.all(FSizes.xs),
                      decoration: BoxDecoration(
                        color: Colors.red,
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
          )
              : InkWell(
            onTap: controller.selectPoster,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(
                  color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.gallery_add,
                    size: 48,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'Click to upload poster',
                    style: TextStyle(
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'PNG, JPG up to 5MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool dark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
      ),
      prefixIcon: Icon(
        icon,
        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkError : FColors.adminLightError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkError : FColors.adminLightError,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
    );
  }

  TextStyle _inputTextStyle(bool dark) {
    return TextStyle(
      color: dark ? FColors.adminDarkText : FColors.adminLightText,
    );
  }
}