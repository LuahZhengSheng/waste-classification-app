import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/inputs/location_input_dialog.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/event_management/add_event_controller.dart';

class AddEventScreen extends StatelessWidget {
  const AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEventController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor:
          dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
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
          'Add New Event',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.createEvent,
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
                        'Create Event',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
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
                    validator: (value) =>
                        FValidator.validateEmptyText('Event title', value),
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
                    label: 'Maximum Participants * (Max: 1000)',
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
                      if (number > 1000) {
                        return 'Maximum participants cannot exceed 1000';
                      }
                      return null;
                    },
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
              _EventFormSection(
                title: 'Event Poster',
                dark: dark,
                children: [
                  _buildPosterSection(controller, dark),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwSections * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector(AddEventController controller, bool dark) {
    return Obx(() => InkWell(
          onTap: () => _showLocationDialog(controller, dark),
          child: Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              border: Border.all(
                color:
                    dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.location,
                  color: dark
                      ? FColors.adminDarkTextSecondary
                      : FColors.adminLightTextSecondary,
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
                          color: dark
                              ? FColors.adminDarkTextMuted
                              : FColors.adminLightTextMuted,
                        ),
                      ),
                      Text(
                        controller.selectedLocation.value != null
                            ? controller.selectedLocation.value!.fullAddress
                            : 'Add event location',
                        style: TextStyle(
                          color: dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: dark
                      ? FColors.adminDarkTextSecondary
                      : FColors.adminLightTextSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ));
  }

  void _showLocationDialog(AddEventController controller, bool dark) {
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
    required AddEventController controller,
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
                        ? controller
                            .formatDate(controller.selectedStartDate.value!)
                        : null)
                    : (controller.selectedEndDate.value != null
                        ? controller
                            .formatDate(controller.selectedEndDate.value!)
                        : null),
                onTap: isStart
                    ? controller.selectStartDate
                    : controller.selectEndDate,
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
                        ? controller
                            .formatTime(controller.selectedStartTime.value!)
                        : null)
                    : (controller.selectedEndTime.value != null
                        ? controller
                            .formatTime(controller.selectedEndTime.value!)
                        : null),
                onTap: isStart
                    ? controller.selectStartTime
                    : controller.selectEndTime,
                dark: dark,
              )),
        ),
      ],
    );
  }

  Widget _buildDeadlineRow({
    required BuildContext context,
    required AddEventController controller,
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
                    ? controller.formatDate(
                        controller.selectedRegistrationDeadlineDate.value!)
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
                    ? controller.formatTime(
                        controller.selectedRegistrationDeadlineTime.value!)
                    : null,
                onTap: controller.selectRegistrationDeadlineTime,
                dark: dark,
              )),
        ),
      ],
    );
  }

  Widget _buildPosterSection(AddEventController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Event Poster * (Required - JPG, PNG, WebP, Max 5MB)',
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
            color:
                dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
        Obx(() {
          if (controller.isCompressing.value) {
            return Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkSurfaceVariant
                    : FColors.adminLightSurfaceVariant,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(
                  color:
                      dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: dark
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'Compressing image...',
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

          if (controller.selectedPosterBytes.value != null) {
            return GestureDetector(
              onTap: () => _showPosterLightbox(controller, dark),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  border: Border.all(
                    color: dark
                        ? FColors.adminDarkBorder
                        : FColors.adminLightBorder,
                  ),
                ),
                child: Stack(
                  children: [
                    // 图片容器 - 使用 contain 保持比例
                    Container(
                      margin: const EdgeInsets.all(FSizes.sm),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(FSizes.cardRadiusMd - 2),
                        child: Image.memory(
                          controller.selectedPosterBytes.value!,
                          height: 230,
                          width: double.infinity,
                          fit: BoxFit.contain, // 改为 contain 保持比例
                        ),
                      ),
                    ),
                    // 删除按钮
                    Positioned(
                      top: FSizes.sm,
                      right: FSizes.sm,
                      child: GestureDetector(
                        onTap: controller.removePoster,
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.xs),
                          decoration: BoxDecoration(
                            color: dark
                                ? FColors.adminDarkError
                                : FColors.adminLightError,
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusXs),
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
              ),
            );
          }

          return InkWell(
            onTap: controller.selectPoster,
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: dark
                    ? FColors.adminDarkSurfaceVariant
                    : FColors.adminLightSurfaceVariant,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(
                  color:
                      dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.gallery_add,
                    size: 48,
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'Click to upload poster *', // 添加星号表示必需
                    style: TextStyle(
                      color: dark
                          ? FColors.adminDarkTextSecondary
                          : FColors.adminLightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'PNG, JPG, WebP up to 5MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark
                          ? FColors.adminDarkTextMuted
                          : FColors.adminLightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showPosterLightbox(AddEventController controller, bool dark) {
    if (controller.selectedPosterBytes.value != null) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  color: Colors.transparent,
                ),
              ),
              Center(
                child: Container(
                  width: Get.width * 0.7, // 固定宽度为屏幕70%
                  height: Get.height * 0.7, // 固定高度为屏幕70%
                  child: InteractiveViewer(
                    panEnabled: true,
                    scaleEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      controller.selectedPosterBytes.value!,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: dark
                            ? FColors.adminDarkSurfaceVariant
                            : FColors.adminLightSurfaceVariant,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.image,
                              size: 64,
                              color: dark
                                  ? FColors.adminDarkTextMuted
                                  : FColors.adminLightTextMuted,
                            ),
                            const SizedBox(height: FSizes.md),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: dark
                                    ? FColors.adminDarkTextMuted
                                    : FColors.adminLightTextMuted,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 关闭按钮
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // 底部标题
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Event Poster Preview - Pinch to zoom',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

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
          color: dark
              ? FColors.adminDarkSurfaceVariant
              : FColors.adminLightSurfaceVariant,
          border: Border.all(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
          ),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
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
                      color: dark
                          ? FColors.adminDarkTextMuted
                          : FColors.adminLightTextMuted,
                    ),
                  ),
                  Text(
                    value ?? 'Select ${label.toLowerCase()}',
                    style: TextStyle(
                      color:
                          dark ? FColors.adminDarkText : FColors.adminLightText,
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
        color: dark
            ? FColors.adminDarkTextSecondary
            : FColors.adminLightTextSecondary,
      ),
      prefixIcon: Icon(
        icon,
        color: dark
            ? FColors.adminDarkTextSecondary
            : FColors.adminLightTextSecondary,
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
      fillColor: dark
          ? FColors.adminDarkSurfaceVariant
          : FColors.adminLightSurfaceVariant,
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
