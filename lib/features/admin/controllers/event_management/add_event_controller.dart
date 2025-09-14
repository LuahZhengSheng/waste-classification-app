import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/inputs/location_input_dialog.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../event/models/event_model.dart';
import '../../../event/models/location_model.dart';

class AddEventController extends GetxController {
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController maxParticipantsController;
  late TextEditingController contactEmailController;
  late TextEditingController contactPhoneController;

  // Observables
  final RxBool isLoading = false.obs;
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedStartTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedEndTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> selectedRegistrationDeadlineDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedRegistrationDeadlineTime = Rx<TimeOfDay?>(null);
  final Rx<Location?> selectedLocation = Rx<Location?>(null);
  final RxString selectedPosterPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    maxParticipantsController = TextEditingController();
    contactEmailController = TextEditingController();
    contactPhoneController = TextEditingController();
  }

  // Date and Time Selection Methods
  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedStartDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedStartDate.value = picked;
      // Auto-adjust end date if it's before start date
      if (selectedEndDate.value != null && selectedEndDate.value!.isBefore(picked)) {
        selectedEndDate.value = picked;
      }
      // Auto-adjust registration deadline if it's after start date
      if (selectedRegistrationDeadlineDate.value != null &&
          selectedRegistrationDeadlineDate.value!.isAfter(picked)) {
        selectedRegistrationDeadlineDate.value = picked.subtract(const Duration(days: 1));
      }
    }
  }

  Future<void> selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedStartTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedStartTime.value = picked;
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedEndDate.value ??
          (selectedStartDate.value ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: selectedStartDate.value ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedEndDate.value = picked;
    }
  }

  Future<void> selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedEndTime.value ??
          (selectedStartTime.value ?? TimeOfDay.now()).replacing(
            hour: (selectedStartTime.value?.hour ?? TimeOfDay.now().hour) + 2,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedEndTime.value = picked;
    }
  }

  Future<void> selectRegistrationDeadlineDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedRegistrationDeadlineDate.value ??
          (selectedStartDate.value?.subtract(const Duration(days: 3)) ??
              DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: selectedStartDate.value ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedRegistrationDeadlineDate.value = picked;
    }
  }

  Future<void> selectRegistrationDeadlineTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedRegistrationDeadlineTime.value ??
          const TimeOfDay(hour: 23, minute: 59),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedRegistrationDeadlineTime.value = picked;
    }
  }

  // Location Selection
  void showLocationDialog() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      LocationInputDialog(
        dark: dark,
        initialLocation: selectedLocation.value,
        onLocationSelected: (location) {
          selectedLocation.value = location;
        },
      ),
      barrierDismissible: false,
    );
  }

  // Poster Selection
  Future<void> selectPoster() async {
    // In real implementation, you would use image_picker to select image
    // For now, we'll simulate poster selection
    try {
      // Simulate image picker
      await Future.delayed(const Duration(seconds: 1));

      // Mock image URL - in real app, you'd upload to cloud storage
      selectedPosterPath.value = 'https://via.placeholder.com/400x600/4BAF6F/FFFFFF?text=Event+Poster';

      FLoaders.successSnackBar(
        title: 'Poster Selected',
        message: 'Event poster has been selected successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to select poster: ${e.toString()}',
      );
    }
  }

  void removePoster() {
    selectedPosterPath.value = '';
  }

  // Format helper methods
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Validation methods
  bool _validateDates() {
    if (selectedStartDate.value == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please select start date');
      return false;
    }

    if (selectedStartTime.value == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please select start time');
      return false;
    }

    if (selectedEndDate.value == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please select end date');
      return false;
    }

    if (selectedEndTime.value == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please select end time');
      return false;
    }

    if (selectedRegistrationDeadlineDate.value == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please select registration deadline date');
      return false;
    }

    if (selectedRegistrationDeadlineTime.value == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please select registration deadline time');
      return false;
    }

    // Create full DateTime objects for comparison
    final startDateTime = DateTime(
      selectedStartDate.value!.year,
      selectedStartDate.value!.month,
      selectedStartDate.value!.day,
      selectedStartTime.value!.hour,
      selectedStartTime.value!.minute,
    );

    final endDateTime = DateTime(
      selectedEndDate.value!.year,
      selectedEndDate.value!.month,
      selectedEndDate.value!.day,
      selectedEndTime.value!.hour,
      selectedEndTime.value!.minute,
    );

    final registrationDeadline = DateTime(
      selectedRegistrationDeadlineDate.value!.year,
      selectedRegistrationDeadlineDate.value!.month,
      selectedRegistrationDeadlineDate.value!.day,
      selectedRegistrationDeadlineTime.value!.hour,
      selectedRegistrationDeadlineTime.value!.minute,
    );

    // Validate end time is after start time
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      FLoaders.errorSnackBar(
        title: 'Invalid Date/Time',
        message: 'End date/time must be after start date/time',
      );
      return false;
    }

    // Validate registration deadline is before start time
    if (registrationDeadline.isAfter(startDateTime) || registrationDeadline.isAtSameMomentAs(startDateTime)) {
      FLoaders.errorSnackBar(
        title: 'Invalid Registration Deadline',
        message: 'Registration deadline must be before event start time',
      );
      return false;
    }

    // Validate registration deadline is not in the past
    if (registrationDeadline.isBefore(DateTime.now())) {
      FLoaders.errorSnackBar(
        title: 'Invalid Registration Deadline',
        message: 'Registration deadline cannot be in the past',
      );
      return false;
    }

    return true;
  }

  bool _validateLocation() {
    if (selectedLocation.value == null) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Please add event location');
      return false;
    }
    return true;
  }

  // Create Event Method
  Future<void> createEvent({bool isDraft = false}) async {
    try {
      // Validate form
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Validate dates
      if (!_validateDates()) {
        return;
      }

      // Validate location
      if (!_validateLocation()) {
        return;
      }

      isLoading.value = true;

      // Create DateTime objects
      final startDateTime = DateTime(
        selectedStartDate.value!.year,
        selectedStartDate.value!.month,
        selectedStartDate.value!.day,
        selectedStartTime.value!.hour,
        selectedStartTime.value!.minute,
      );

      final endDateTime = DateTime(
        selectedEndDate.value!.year,
        selectedEndDate.value!.month,
        selectedEndDate.value!.day,
        selectedEndTime.value!.hour,
        selectedEndTime.value!.minute,
      );

      final registrationDeadline = DateTime(
        selectedRegistrationDeadlineDate.value!.year,
        selectedRegistrationDeadlineDate.value!.month,
        selectedRegistrationDeadlineDate.value!.day,
        selectedRegistrationDeadlineTime.value!.hour,
        selectedRegistrationDeadlineTime.value!.minute,
      );

      // Create Event object
      final event = Event(
        eventId: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        contactEmail: contactEmailController.text.trim(),
        contactPhoneNo: contactPhoneController.text.trim(),
        location: selectedLocation.value!,
        poster: selectedPosterPath.value.isNotEmpty ? selectedPosterPath.value : '',
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        registrationDeadline: registrationDeadline,
        maxParticipants: int.parse(maxParticipantsController.text.trim()),
        registeredCount: 0,
        createdAt: DateTime.now(),
        isPublish: !isDraft,
        status: 'active',
        eventRegistrations: [],
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In real implementation, you would save to database/API
      // await eventRepository.createEvent(event);

      isLoading.value = false;

      // Show success message
      FLoaders.successSnackBar(
        title: isDraft ? 'Draft Saved' : 'Event Created',
        message: isDraft
            ? 'Event saved as draft successfully'
            : 'Event created and published successfully',
      );

      // Navigate back or to event management
      Get.back();

    } catch (e) {
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create event: ${e.toString()}',
      );
    }
  }

  // Save as Draft
  Future<void> saveAsDraft() async {
    await createEvent(isDraft: true);
  }

  // Reset form
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    maxParticipantsController.clear();
    contactEmailController.clear();
    contactPhoneController.clear();
    selectedStartDate.value = null;
    selectedStartTime.value = null;
    selectedEndDate.value = null;
    selectedEndTime.value = null;
    selectedRegistrationDeadlineDate.value = null;
    selectedRegistrationDeadlineTime.value = null;
    selectedLocation.value = null;
    selectedPosterPath.value = '';
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    maxParticipantsController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    super.onClose();
  }
}