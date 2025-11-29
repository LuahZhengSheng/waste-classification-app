import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/admin/image_uploader.dart';
import '../../../../../common/widgets/inputs/location_input_dialog.dart';
import '../../../../../data/repositories/event/event_repository.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../../event/models/event_model.dart';
import '../../../controllers/event_management/edit_event_controller.dart';


class EditEventScreen extends StatelessWidget {
  final Event event;

  const EditEventScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditEventController());
    controller.initializeWithEvent(event);
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Edit Event',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value || !controller.hasChanges
                ? null
                : controller.updateEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.hasChanges
                  ? (dark ? FColors.adminDarkAccent : FColors.adminLightAccent)
                  : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
              disabledBackgroundColor: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
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
                : Text(
              controller.hasChanges ? 'Update Event' : 'No Changes',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600
              ),
            ),
          )),
          const SizedBox(width: FSizes.md),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventFormSection(
                title: 'Basic Information',
                dark: dark,
                children: [
                  _buildTextField(
                    controller: controller.titleController,
                    label: 'Event Title *',
                    icon: Iconsax.text,
                    dark: dark,
                    validator: (value) => FValidator.validateEmptyText('Event title', value),
                  ),
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  _buildTextField(
                    controller: controller.descriptionController,
                    label: 'Event Description *',
                    icon: Iconsax.document_text,
                    dark: dark,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Event description is required';
                      }
                      if (value.length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              _EventFormSection(
                title: 'Date & Time',
                dark: dark,
                children: [
                  _buildDateTimeRow(
                    context: context,
                    controller: controller,
                    dark: dark,
                    isStart: true,
                  ),
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  _buildDateTimeRow(
                    context: context,
                    controller: controller,
                    dark: dark,
                    isStart: false,
                  ),
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  _buildDeadlineRow(
                    context: context,
                    controller: controller,
                    dark: dark,
                  ),
                ],
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              _EventFormSection(
                title: 'Location',
                dark: dark,
                children: [
                  _buildLocationSelector(controller, dark),
                ],
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              _EventFormSection(
                title: 'Registration Settings',
                dark: dark,
                children: [
                  _buildTextField(
                    controller: controller.maxParticipantsController,
                    label: 'Maximum Participants * (Min: ${event.registeredCount}, Max: 1000)',
                    icon: Iconsax.people,
                    dark: dark,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Maximum participants is required';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Please enter a valid number greater than 0';
                      }
                      if (number < event.registeredCount) {
                        return 'Cannot be less than registered count (${event.registeredCount})';
                      }
                      if (number > 1000) {
                        return 'Maximum participants cannot exceed 1000';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'Current Registered: ${event.registeredCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              _EventFormSection(
                title: 'Contact Information',
                dark: dark,
                children: [
                  _buildTextField(
                    controller: controller.contactEmailController,
                    label: 'Contact Email *',
                    icon: Iconsax.sms,
                    dark: dark,
                    keyboardType: TextInputType.emailAddress,
                    validator: FValidator.validateEmail,
                  ),
                  const SizedBox(height: FSizes.spaceBtwInputFields),
                  _buildTextField(
                    controller: controller.contactPhoneController,
                    label: 'Contact Phone Number *',
                    icon: Iconsax.call,
                    dark: dark,
                    keyboardType: TextInputType.phone,
                    validator: FValidator.validatePhoneNumber,
                  ),
                ],
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              // 更新 Event Poster Section - 使用新的 ImageUploader 组件
              _EventFormSection(
                title: 'Event Poster',
                dark: dark,
                children: [
                  Obx(() => ImageUploader(
                    imageBytes: controller.selectedPosterBytes.value,
                    existingImageName: controller.selectedPosterName.value,
                    getImageUrl: (fileName) => EventRepository.instance.getEventPosterUrl(fileName),
                    onSelectImage: controller.selectPoster,
                    onRemoveImage: controller.removePoster,
                    isCompressing: controller.isCompressing.value,
                    dark: dark,
                    required: true,
                    label: 'Event Poster',
                    description: 'Upload an eye-catching poster to promote your event (Required - JPG, PNG, WebP, Max 5MB)',
                  )),
                ],
              ),


              const SizedBox(height: FSizes.spaceBtwSections * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(EditEventController controller, bool dark) {
    return Obx(() => InkWell(
      onTap: () => _showLocationDialog(controller, dark),
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
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
                        ? controller.selectedLocation.value!.fullAddress
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
    ));
  }

  void _showLocationDialog(EditEventController controller, bool dark) {
    Get.dialog(
      LocationInputDialog(
        dark: dark,
        initialLocation: controller.selectedLocation.value,
        onLocationSelected: (location) {
          controller.selectedLocation.value = location;
        },
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildDateTimeRow({
    required BuildContext context,
    required EditEventController controller,
    required bool dark,
    required bool isStart,
  }) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _buildDateTimeField(
            context: context,
            label: isStart ? 'Start Date *' : 'End Date *',
            icon: Iconsax.calendar,
            value: isStart
                ? (controller.selectedStartDate.value != null
                ? controller.formatDate(controller.selectedStartDate.value!)
                : null)
                : (controller.selectedEndDate.value != null
                ? controller.formatDate(controller.selectedEndDate.value!)
                : null),
            onTap: isStart ? controller.selectStartDate : controller.selectEndDate,
            dark: dark,
          )),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: Obx(() => _buildDateTimeField(
            context: context,
            label: isStart ? 'Start Time *' : 'End Time *',
            icon: Iconsax.clock,
            value: isStart
                ? (controller.selectedStartTime.value != null
                ? controller.formatTime(controller.selectedStartTime.value!)
                : null)
                : (controller.selectedEndTime.value != null
                ? controller.formatTime(controller.selectedEndTime.value!)
                : null),
            onTap: isStart ? controller.selectStartTime : controller.selectEndTime,
            dark: dark,
          )),
        ),
      ],
    );
  }

  Widget _buildDeadlineRow({
    required BuildContext context,
    required EditEventController controller,
    required bool dark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _buildDateTimeField(
            context: context,
            label: 'Registration Deadline Date *',
            icon: Iconsax.calendar,
            value: controller.selectedRegistrationDeadlineDate.value != null
                ? controller.formatDate(controller.selectedRegistrationDeadlineDate.value!)
                : null,
            onTap: controller.selectRegistrationDeadlineDate,
            dark: dark,
          )),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: Obx(() => _buildDateTimeField(
            context: context,
            label: 'Deadline Time *',
            icon: Iconsax.clock,
            value: controller.selectedRegistrationDeadlineTime.value != null
                ? controller.formatTime(controller.selectedRegistrationDeadlineTime.value!)
                : null,
            onTap: controller.selectRegistrationDeadlineTime,
            dark: dark,
          )),
        ),
      ],
    );
  }

  // 删除旧的 _buildPosterSection 方法，因为现在使用 ImageUploader 组件

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool dark,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon, dark),
      style: _inputTextStyle(dark),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateTimeField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
    required bool dark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
          border: Border.all(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
          ),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  ),
                  Text(
                    value ?? 'Select ${label.toLowerCase()}',
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
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool dark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
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

class _EventFormSection extends StatelessWidget {
  final String title;
  final bool dark;
  final List<Widget> children;

  const _EventFormSection({
    required this.title,
    required this.dark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
        Container(
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
            children: children,
          ),
        ),
      ],
    );
  }
}