import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../utils/popups/loaders.dart';
import '../../../event/models/location_model.dart';
import '../../../recycling_center/models/partner_recycling_center_model.dart';

class AddPartnerCenterController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;
  final formProgress = 0.0.obs;

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;
  late TextEditingController staffCountController;

  // Selected values
  final selectedLocation = Rxn<Location>();
  final selectedImage = RxnString();
  final selectedStatus = 'active'.obs;

  // Operating hours map
  final RxMap<String, Map<String, DateTime?>> operatingHours = <String, Map<String, DateTime?>>{}.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Days of the week
  final List<String> daysOfWeek = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _initializeOperatingHours();
    _setupFormProgressListener();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    websiteController = TextEditingController();
    staffCountController = TextEditingController();
  }

  void _initializeOperatingHours() {
    for (String day in daysOfWeek) {
      operatingHours[day] = {'open': null, 'close': null};
    }
  }

  void _setupFormProgressListener() {
    // Listen to all form fields and update progress
    nameController.addListener(_updateFormProgress);
    emailController.addListener(_updateFormProgress);
    phoneController.addListener(_updateFormProgress);
    websiteController.addListener(_updateFormProgress);
    staffCountController.addListener(_updateFormProgress);

    // Listen to reactive variables
    ever(selectedLocation, (_) => _updateFormProgress());
    ever(selectedImage, (_) => _updateFormProgress());
    ever(selectedStatus, (_) => _updateFormProgress());
  }

  void _updateFormProgress() {
    double progress = 0.0;
    int totalFields = 8; // Total required fields

    // Basic information (4 fields)
    if (nameController.text.isNotEmpty) progress += 1;
    if (emailController.text.isNotEmpty) progress += 1;
    if (phoneController.text.isNotEmpty) progress += 1;
    if (websiteController.text.isNotEmpty) progress += 1;

    // Location
    if (selectedLocation.value != null) progress += 1;

    // Image
    if (selectedImage.value != null) progress += 1;

    // Staff count
    if (staffCountController.text.isNotEmpty) progress += 1;

    // Operating hours (check if at least one day is set)
    bool hasOperatingHours = operatingHours.values.any((hours) =>
    hours['open'] != null && hours['close'] != null);
    if (hasOperatingHours) progress += 1;

    formProgress.value = progress / totalFields;
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Center name is required';
    }
    if (value.trim().length < 3) {
      return 'Center name must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove all non-digit characters for validation
    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Website is required';
    }
    if (!GetUtils.isURL(value.trim())) {
      return 'Please enter a valid website URL';
    }
    return null;
  }

  String? validateStaffCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Staff count is required';
    }
    final count = int.tryParse(value.trim());
    if (count == null || count < 1) {
      return 'Please enter a valid staff count';
    }
    return null;
  }

  String? validateStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Status is required';
    }
    return null;
  }

  // Location methods
  void setLocation(Location location) {
    selectedLocation.value = location;
    FLoaders.successSnackBar(
      title: 'Location Set',
      message: 'Center location has been saved successfully',
    );
  }

  void clearLocation() {
    selectedLocation.value = null;
    FLoaders.customToast(message: 'Location cleared');
  }

  // Image methods
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = image.path;
        FLoaders.successSnackBar(
          title: 'Image Selected',
          message: 'Center image has been added successfully',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  void clearImage() {
    selectedImage.value = null;
    FLoaders.customToast(message: 'Image removed');
  }

  // Operating hours methods
  Future<void> selectTime(String day, String timeType) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final isDark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark().copyWith(
              primary: Color(0xFF7B8CFF), // adminDarkPrimary
            )
                : const ColorScheme.light().copyWith(
              primary: Color(0xFF5E72E4), // adminLightPrimary
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // Update the operating hours
      Map<String, DateTime?> dayHours = Map.from(operatingHours[day]!);
      dayHours[timeType] = selectedTime;
      operatingHours[day] = dayHours;

      // Validate time logic
      if (dayHours['open'] != null && dayHours['close'] != null) {
        if (dayHours['close']!.isBefore(dayHours['open']!) ||
            dayHours['close']!.isAtSameMomentAs(dayHours['open']!)) {
          FLoaders.warningSnackBar(
            title: 'Invalid Time',
            message: 'Close time must be after open time',
          );
          // Reset the close time
          dayHours['close'] = null;
          operatingHours[day] = dayHours;
        }
      }

      _updateFormProgress();
    }
  }

  String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Save draft functionality
  void saveDraft() {
    // In real implementation, save to local storage or database
    FLoaders.successSnackBar(
      title: 'Draft Saved',
      message: 'Your progress has been saved as draft',
    );
  }

  // Create center method
  Future<void> createCenter() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Create PartnerRecyclingCenter object
      final center = PartnerRecyclingCenter.createNew(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNo: phoneController.text.trim(),
        website: websiteController.text.trim(),
        centerLocation: selectedLocation.value!,
        image: selectedImage.value ?? '', // In real app, upload image first
        operatingHours: _convertOperatingHours(),
        numberOfStaff: int.parse(staffCountController.text.trim()),
        status: selectedStatus.value,
      );

      // In real implementation, save to database
      await _saveCenterToDatabase(center);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Partner recycling center created successfully',
      );

      // Clear form and go back
      _resetForm();
      Get.back(result: true); // Return true to indicate success

    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create center: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    // Basic form validation
    if (!formKey.currentState!.validate()) {
      FLoaders.errorSnackBar(
        title: 'Form Error',
        message: 'Please fix all form errors before proceeding',
      );
      return false;
    }

    // Location validation
    if (selectedLocation.value == null) {
      FLoaders.errorSnackBar(
        title: 'Location Required',
        message: 'Please set the center location',
      );
      return false;
    }

    // Image validation (optional but recommended)
    if (selectedImage.value == null) {
      FLoaders.warningSnackBar(
        title: 'No Image',
        message: 'Consider adding a center image for better visibility',
      );
    }

    // Operating hours validation
    bool hasValidOperatingHours = operatingHours.values.any((hours) =>
    hours['open'] != null && hours['close'] != null);

    if (!hasValidOperatingHours) {
      FLoaders.errorSnackBar(
        title: 'Operating Hours Required',
        message: 'Please set operating hours for at least one day',
      );
      return false;
    }

    return true;
  }

  Map<String, Map<String, DateTime>> _convertOperatingHours() {
    Map<String, Map<String, DateTime>> result = {};

    operatingHours.forEach((day, hours) {
      if (hours['open'] != null && hours['close'] != null) {
        result[day] = {
          'open': hours['open']!,
          'close': hours['close']!,
        };
      }
    });

    return result;
  }

  Future<void> _saveCenterToDatabase(PartnerRecyclingCenter center) async {
    // Simulate database save
    // In real implementation, use Firebase or other backend service
    await Future.delayed(const Duration(milliseconds: 500));

    // Here you would typically:
    // 1. Upload the image to storage and get URL
    // 2. Save center data to Firestore
    // 3. Handle any errors

    print('Saving center: ${center.toJson()}');
  }

  void _resetForm() {
    // Clear all controllers
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    websiteController.clear();
    staffCountController.clear();

    // Reset reactive variables
    selectedLocation.value = null;
    selectedImage.value = null;
    selectedStatus.value = 'active';

    // Reset operating hours
    _initializeOperatingHours();

    // Reset progress
    formProgress.value = 0.0;
  }

  // Lifecycle methods
  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    staffCountController.dispose();
    super.onClose();
  }

  // Helper method to check if form has unsaved changes
  bool get hasUnsavedChanges {
    return nameController.text.isNotEmpty ||
        emailController.text.isNotEmpty ||
        phoneController.text.isNotEmpty ||
        websiteController.text.isNotEmpty ||
        staffCountController.text.isNotEmpty ||
        selectedLocation.value != null ||
        selectedImage.value != null ||
        operatingHours.values.any((hours) =>
        hours['open'] != null || hours['close'] != null);
  }

  // Method to handle back navigation with confirmation
  Future<bool> onWillPop() async {
    if (!hasUnsavedChanges) return true;

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: FHelperFunctions.isDarkMode(Get.context!)
            ? Color(0xFF111B2B) // adminDarkSurface
            : Colors.white,
        title: Text(
          'Discard Changes?',
          style: TextStyle(
            color: FHelperFunctions.isDarkMode(Get.context!)
                ? Color(0xFFE2E8F0) // adminDarkText
                : Color(0xFF32325D), // adminLightText
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: TextStyle(
            color: FHelperFunctions.isDarkMode(Get.context!)
                ? Color(0xFF94A3B8) // adminDarkTextSecondary
                : Color(0xFF8898AA), // adminLightTextSecondary
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: FHelperFunctions.isDarkMode(Get.context!)
                    ? Color(0xFF94A3B8) // adminDarkTextSecondary
                    : Color(0xFF8898AA), // adminLightTextSecondary
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Discard',
              style: TextStyle(
                color: FHelperFunctions.isDarkMode(Get.context!)
                    ? Color(0xFFFC7C8A) // adminDarkError
                    : Color(0xFFF5365C), // adminLightError
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}