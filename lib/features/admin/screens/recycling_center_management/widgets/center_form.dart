import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/recycling_center/models/waste_category_model.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/features/event/models/location_model.dart';
import 'package:fyp/common/widgets/inputs/location_input_dialog.dart';
import 'package:fyp/data/repositories/event/event_repository.dart';

/// Shared section card widget
class CenterFormSection extends StatelessWidget {
  final String title;
  final bool dark;
  final List<Widget> children;

  const CenterFormSection({
    super.key,
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
                blurRadius: 20,
                offset: const Offset(0, 4),
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

/// Shared text field widget
class CenterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool dark;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const CenterTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.dark,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
          decoration: InputDecoration(
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
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
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
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Location selector widget
class CenterLocationSelector extends StatelessWidget {
  final Location? selectedLocation;
  final Function(Location) onLocationSelected;
  final VoidCallback onClear;
  final bool dark;

  const CenterLocationSelector({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
    required this.onClear,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedLocation == null) {
      return _buildLocationPrompt(context);
    }
    return _buildLocationDisplay(context);
  }

  Widget _buildLocationPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLocationDialog(context),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark
                ? FColors.adminDarkBorder.withOpacity(0.3)
                : FColors.adminLightBorder.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.location_add,
              size: 32,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Add Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Tap to set the center location',
              style: TextStyle(
                fontSize: 12,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.location_tick,
                color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                size: 20,
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  'Location Set',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showLocationDialog(context),
                icon: Icon(
                  Iconsax.edit,
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  size: 18,
                ),
              ),
              IconButton(
                onPressed: onClear,
                icon: Icon(
                  Iconsax.trash,
                  color: dark ? FColors.adminDarkError : FColors.adminLightError,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            selectedLocation!.fullAddress,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    Get.dialog(
      LocationInputDialog(
        dark: dark,
        initialLocation: selectedLocation,
        onLocationSelected: onLocationSelected,
      ),
      barrierDismissible: false,
    );
  }
}

/// Opening hours selector widget
class OpeningHoursSelector extends StatelessWidget {
  final Map<String, Map<String, dynamic>> openingHours;
  final Function(String, String, TimeOfDay) onTimeUpdated;
  final Function(String, bool) onDayToggle;
  final Function(TimeOfDay, TimeOfDay) onBatchUpdate;
  final bool dark;

  const OpeningHoursSelector({
    super.key,
    required this.openingHours,
    required this.onTimeUpdated,
    required this.onDayToggle,
    required this.onBatchUpdate,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Batch Update Section
        _buildBatchUpdateSection(),
        const SizedBox(height: FSizes.spaceBtwItems),

        // Individual Days
        ...daysOfWeek.map((day) {
          // Get data directly from the map
          final dayData = openingHours[day];

          // Skip if no data (shouldn't happen but safety check)
          if (dayData == null) return const SizedBox.shrink();

          final isOpen = dayData['isOpen'] as bool? ?? true;
          final openTime = dayData['open'] as TimeOfDay? ?? const TimeOfDay(hour: 9, minute: 0);
          final closeTime = dayData['close'] as TimeOfDay? ?? const TimeOfDay(hour: 17, minute: 0);

          return Container(
            margin: const EdgeInsets.only(bottom: FSizes.md),
            decoration: BoxDecoration(
              color: isOpen
                  ? (dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant)
                  : (dark
                  ? FColors.adminDarkSurface.withOpacity(0.5)
                  : FColors.adminLightSurface.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: isOpen
                    ? (dark
                    ? FColors.adminDarkBorder
                    : FColors.adminLightBorder)
                    : (dark
                    ? FColors.adminDarkBorder.withOpacity(0.3)
                    : FColors.adminLightBorder.withOpacity(0.3)),
              ),
            ),
            child: Column(
              children: [
                // Day Header with Toggle
                InkWell(
                  onTap: () => onDayToggle(day, !isOpen),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(FSizes.cardRadiusMd),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    child: Row(
                      children: [
                        // Checkbox
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isOpen
                                ? (dark
                                ? FColors.adminDarkPrimary
                                : FColors.adminLightPrimary)
                                : Colors.transparent,
                            border: Border.all(
                              color: isOpen
                                  ? (dark
                                  ? FColors.adminDarkPrimary
                                  : FColors.adminLightPrimary)
                                  : (dark
                                  ? FColors.adminDarkTextMuted
                                  : FColors.adminLightTextMuted),
                              width: 2,
                            ),
                            borderRadius:
                            BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                          child: isOpen
                              ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                              : null,
                        ),
                        const SizedBox(width: FSizes.md),

                        // Day Name
                        Expanded(
                          child: Text(
                            _getDayDisplayName(day),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isOpen
                                  ? (dark
                                  ? FColors.adminDarkText
                                  : FColors.adminLightText)
                                  : (dark
                                  ? FColors.adminDarkTextMuted
                                  : FColors.adminLightTextMuted),
                            ),
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOpen
                                ? (dark
                                ? FColors.adminDarkSuccess.withOpacity(0.2)
                                : FColors.adminLightSuccess
                                .withOpacity(0.2))
                                : (dark
                                ? FColors.adminDarkError.withOpacity(0.2)
                                : FColors.adminLightError.withOpacity(0.2)),
                            borderRadius:
                            BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                          child: Text(
                            isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOpen
                                  ? (dark
                                  ? FColors.adminDarkSuccess
                                  : FColors.adminLightSuccess)
                                  : (dark
                                  ? FColors.adminDarkError
                                  : FColors.adminLightError),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Time Selectors (only show if day is open)
                if (isOpen) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(FSizes.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimeSelector(
                            label: 'Opening Time',
                            time: openTime,
                            icon: Iconsax.clock,
                            onTimeSelected: (time) =>
                                onTimeUpdated(day, 'open', time),
                            dark: dark,
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: FSizes.sm),
                          child: Icon(
                            Iconsax.arrow_right_3,
                            size: 20,
                            color: dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                        ),
                        Expanded(
                          child: _buildTimeSelector(
                            label: 'Closing Time',
                            time: closeTime,
                            icon: Iconsax.clock,
                            onTimeSelected: (time) =>
                                onTimeUpdated(day, 'close', time),
                            dark: dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBatchUpdateSection() {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkPrimary.withOpacity(0.1)
            : FColors.adminLightPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark
              ? FColors.adminDarkPrimary.withOpacity(0.3)
              : FColors.adminLightPrimary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.adminDarkPrimary
                      : FColors.adminLightPrimary,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: const Icon(
                  Iconsax.timer_1,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Setup',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: dark
                            ? FColors.adminDarkText
                            : FColors.adminLightText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Apply same hours to all open days',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark
                            ? FColors.adminDarkTextSecondary
                            : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildBatchTimeButton(
                  label: 'Set Opening',
                  icon: Iconsax.timer_start,
                  onPressed: () => _selectBatchTime(true),
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: _buildBatchTimeButton(
                  label: 'Set Closing',
                  icon: Iconsax.timer_pause,
                  onPressed: () => _selectBatchTime(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchTimeButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor:
        dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
        side: BorderSide(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
        ),
      ),
    );
  }

  Future<void> _selectBatchTime(bool isOpening) async {
    final selectedTime = await showTimePicker(
      context: Get.context!,
      initialTime: isOpening
          ? const TimeOfDay(hour: 9, minute: 0)
          : const TimeOfDay(hour: 17, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: dark
              ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: FColors.adminDarkPrimary,
              onPrimary: FColors.adminDarkText,
              surface: FColors.adminDarkSurface,
              onSurface: FColors.adminDarkText,
            ),
          )
              : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: FColors.adminLightPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: FColors.adminLightText,
            ),
          ),
          child: child!,
        );
      },
      helpText: isOpening ? 'Select Opening Time' : 'Select Closing Time',
    );

    if (selectedTime != null) {
      // Get the other time (opening or closing) from first open day
      TimeOfDay? otherTime;
      for (var dayData in openingHours.values) {
        if (dayData['isOpen'] == true) {
          otherTime = isOpening
              ? (dayData['close'] as TimeOfDay)
              : (dayData['open'] as TimeOfDay);
          break;
        }
      }

      otherTime ??= isOpening
          ? const TimeOfDay(hour: 17, minute: 0)
          : const TimeOfDay(hour: 9, minute: 0);

      // Apply to all open days
      if (isOpening) {
        onBatchUpdate(selectedTime, otherTime);
      } else {
        onBatchUpdate(otherTime, selectedTime);
      }

      Get.snackbar(
        'Hours Updated',
        'Applied ${isOpening ? 'opening' : 'closing'} time to all open days',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
        dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(FSizes.md),
        borderRadius: FSizes.borderRadiusMd,
      );
    }
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required IconData icon,
    required Function(TimeOfDay) onTimeSelected,
    required bool dark,
  }) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: Get.context!,
          initialTime: time,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: dark
                  ? ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: FColors.adminDarkPrimary,
                  onPrimary: FColors.adminDarkText,
                  surface: FColors.adminDarkSurface,
                  onSurface: FColors.adminDarkText,
                ),
              )
                  : ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: FColors.adminLightPrimary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: FColors.adminLightText,
                ),
              ),
              child: child!,
            );
          },
        );

        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
          border: Border.all(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color: dark
                      ? FColors.adminDarkTextSecondary
                      : FColors.adminLightTextSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDayDisplayName(String day) {
    switch (day) {
      case 'monday':
        return 'Monday';
      case 'tuesday':
        return 'Tuesday';
      case 'wednesday':
        return 'Wednesday';
      case 'thursday':
        return 'Thursday';
      case 'friday':
        return 'Friday';
      case 'saturday':
        return 'Saturday';
      case 'sunday':
        return 'Sunday';
      default:
        return day;
    }
  }
}

/// Image uploader widget
class CenterImageUploader extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingImageName;
  final Future<String?> Function(String)? getImageUrl;
  final VoidCallback onSelectImage;
  final VoidCallback onRemoveImage;
  final bool isCompressing;
  final bool dark;

  const CenterImageUploader({
    super.key,
    required this.imageBytes,
    required this.existingImageName,
    this.getImageUrl,
    required this.onSelectImage,
    required this.onRemoveImage,
    required this.isCompressing,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompressing) {
      return _buildLoadingWidget();
    }

    if (imageBytes != null) {
      return _buildImagePreview(context);
    }

    if (existingImageName != null && existingImageName!.isNotEmpty) {
      return _buildExistingImagePreview(context);
    }

    return _buildUploadPrompt();
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Compressing image...',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageLightbox(context, imageBytes: imageBytes!),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
          ),
        ),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(FSizes.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd - 2),
                child: Image.memory(
                  imageBytes!,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: FSizes.sm,
              right: FSizes.sm,
              child: GestureDetector(
                onTap: onRemoveImage,
                child: Container(
                  padding: const EdgeInsets.all(FSizes.xs),
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkError : FColors.adminLightError,
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
      ),
    );
  }

  Widget _buildExistingImagePreview(BuildContext context) {
    print('🖼️ Building existing image preview for: $existingImageName');

    return FutureBuilder<String?>(
      future: getImageUrl?.call(existingImageName!) ?? _getImageUrl(existingImageName!),
      builder: (context, snapshot) {
        print('🖼️ FutureBuilder state: ${snapshot.connectionState}');
        print('🖼️ FutureBuilder has data: ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('🖼️ Image URL: ${snapshot.data}');
        }
        if (snapshot.hasError) {
          print('🖼️ Image URL error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('🖼️ Loading image URL...');
          return Container(
            height: 250,
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          print('🖼️ No image URL available, showing upload prompt');
          return _buildUploadPrompt();
        }

        print('🖼️ Displaying image from URL');
        return GestureDetector(
          onTap: () => _showImageLightbox(context, imageUrl: snapshot.data!),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(FSizes.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd - 2),
                    child: Image.network(
                      snapshot.data!,
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          print('🖼️ Image loaded successfully');
                          return child;
                        }
                        print('🖼️ Image loading progress: $loadingProgress');
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('🖼️ Image load error: $error');
                        return _buildErrorWidget();
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: FSizes.sm,
                  right: FSizes.sm,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onSelectImage,
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.xs),
                          decoration: BoxDecoration(
                            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                            borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                          ),
                          child: const Icon(
                            Iconsax.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: FSizes.xs),
                      GestureDetector(
                        onTap: onRemoveImage,
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.xs),
                          decoration: BoxDecoration(
                            color: dark ? FColors.adminDarkError : FColors.adminLightError,
                            borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                          ),
                          child: const Icon(
                            Iconsax.trash,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadPrompt() {
    return GestureDetector(
      onTap: onSelectImage,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark
                ? FColors.adminDarkBorder.withOpacity(0.3)
                : FColors.adminLightBorder.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
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
              'Upload Center Image',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Tap to select image from gallery or take photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
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
            'Failed to load image',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getImageUrl(String fileName) async {
    try {
      // This would call your repository method to get image URL
      // For now, return null as placeholder
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showImageLightbox(BuildContext context, {Uint8List? imageBytes, String? imageUrl}) {
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
                width: Get.width * 0.7,
                height: Get.height * 0.7,
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: imageBytes != null
                      ? Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  )
                      : Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Center Image Preview - Pinch to zoom',
                    style: TextStyle(
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

/// Materials selector widget
class MaterialsSelector extends StatelessWidget {
  final List<String> selectedMaterials;
  final List<WasteCategory> availableCategories;
  final Function(String) onToggleMaterial;
  final bool dark;

  const MaterialsSelector({
    super.key,
    required this.selectedMaterials,
    required this.availableCategories,
    required this.onToggleMaterial,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accepted Materials *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        if (availableCategories.isEmpty)
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Text(
              'Loading waste categories...',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          )
        else
          Wrap(
            spacing: FSizes.sm,
            runSpacing: FSizes.sm,
            children: availableCategories.map((category) {
              final isSelected = selectedMaterials.contains(category.name);
              return FilterChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (_) => onToggleMaterial(category.name),
                backgroundColor: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                selectedColor: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.2),
                checkmarkColor: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                labelStyle: TextStyle(
                  color: isSelected
                      ? (dark ? FColors.adminDarkText : FColors.adminLightText)
                      : (dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                ),
                side: BorderSide(
                  color: isSelected
                      ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                      : (dark ? FColors.adminDarkBorder : FColors.adminLightBorder),
                ),
              );
            }).toList(),
          ),
        if (selectedMaterials.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: FSizes.xs),
            child: Text(
              'Please select at least one material',
              style: TextStyle(
                fontSize: 12,
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
              ),
            ),
          ),
      ],
    );
  }
}