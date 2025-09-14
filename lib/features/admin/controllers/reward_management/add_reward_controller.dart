import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import '../../../../utils/constants/colors.dart';
import '../../../reward_redemption/models/reward_model.dart';
import 'package:image_picker/image_picker.dart';

class AddRewardController extends GetxController {
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController termsController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController validUntilController = TextEditingController();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isActive = false.obs; // Default to inactive/deactivated
  final RxString selectedImagePath = ''.obs;
  final Rx<DateTime?> selectedValidUntilDate = Rx<DateTime?>(null);

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Set default valid until date to 30 days from now
    final defaultDate = DateTime.now().add(const Duration(days: 30));
    selectedValidUntilDate.value = defaultDate;
    validUntilController.text = FFormatter.formatDate(defaultDate);
  }

  // Validation methods
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reward title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters long';
    }
    if (value.trim().length > 100) {
      return 'Title must not exceed 100 characters';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters long';
    }
    if (value.trim().length > 500) {
      return 'Description must not exceed 500 characters';
    }
    return null;
  }

  String? validateTerms(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Terms & conditions are required';
    }
    if (value.trim().length < 10) {
      return 'Terms & conditions must be at least 10 characters long';
    }
    if (value.trim().length > 1000) {
      return 'Terms & conditions must not exceed 1000 characters';
    }
    return null;
  }

  String? validatePoints(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Points required is mandatory';
    }

    final points = int.tryParse(value.trim());
    if (points == null) {
      return 'Please enter a valid number';
    }

    if (points <= 0) {
      return 'Points must be greater than 0';
    }

    if (points > 100000) {
      return 'Points cannot exceed 100,000';
    }

    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    if (quantity > 10000) {
      return 'Quantity cannot exceed 10,000';
    }

    return null;
  }

  String? validateValidUntil(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Valid until date is required';
    }

    if (selectedValidUntilDate.value == null) {
      return 'Please select a valid date';
    }

    final selectedDate = selectedValidUntilDate.value!;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (selectedDateOnly.isBefore(todayOnly)) {
      return 'Valid until date cannot be in the past';
    }

    // Check if date is too far in the future (max 2 years)
    final maxDate = today.add(const Duration(days: 730)); // 2 years
    if (selectedDateOnly.isAfter(maxDate)) {
      return 'Valid until date cannot exceed 2 years from today';
    }

    return null;
  }

  // Date selection
  Future<void> selectValidUntilDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedValidUntilDate.value ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)), // 2 years from now
      builder: (context, child) {
        final dark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              onPrimary: Colors.white,
              surface: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              onSurface: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedValidUntilDate.value) {
      selectedValidUntilDate.value = picked;
      validUntilController.text = FFormatter.formatDate(picked);
    }
  }

  // Image handling
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
        FHelperFunctions.showSnackBar('Image selected successfully');
      }
    } catch (e) {
      FHelperFunctions.showAlert('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  void removeImage() {
    selectedImagePath.value = '';
    FHelperFunctions.showSnackBar('Image removed');
  }

  // Status toggle
  void toggleStatus() {
    isActive.value = !isActive.value;
  }

  // Validation helpers
  bool _validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  bool _validateRequiredFields() {
    // Check if all required fields have values
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final terms = termsController.text.trim();
    final points = pointsController.text.trim();
    final quantity = quantityController.text.trim();
    final validUntil = validUntilController.text.trim();

    if (title.isEmpty || description.isEmpty || terms.isEmpty ||
        points.isEmpty || quantity.isEmpty || validUntil.isEmpty) {
      FHelperFunctions.showAlert('Validation Error',
          'Please fill in all required fields before saving.');
      return false;
    }

    return true;
  }

  // Reset form
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    termsController.clear();
    pointsController.clear();
    quantityController.clear();
    validUntilController.clear();
    selectedImagePath.value = '';
    isActive.value = false;
    selectedValidUntilDate.value = null;

    // Set default date again
    final defaultDate = DateTime.now().add(const Duration(days: 30));
    selectedValidUntilDate.value = defaultDate;
    validUntilController.text = FFormatter.formatDate(defaultDate);
  }

  // Save reward
  Future<void> saveReward() async {
    // Validate form first
    if (!_validateRequiredFields()) {
      return;
    }

    if (!_validateForm()) {
      FHelperFunctions.showAlert('Validation Error',
          'Please correct the errors in the form before saving.');
      return;
    }

    try {
      isLoading.value = true;

      // Parse numeric values
      final points = int.parse(pointsController.text.trim());
      final quantity = int.parse(quantityController.text.trim());

      // Create reward model
      final newReward = RewardModel(
        rewardId: '', // Will be generated by the backend/database
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        termsConditions: termsController.text.trim(),
        rewardImage: selectedImagePath.value, // In real app, this would be uploaded and URL returned
        pointsNeeded: points,
        quantity: quantity,
        validUntil: selectedValidUntilDate.value!,
        redemptionCount: 0, // New reward starts with 0 redemptions
        createdAt: DateTime.now(),
        status: isActive.value ? 'active' : 'inactive',
      );

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call your API service here
      // final result = await RewardService.createReward(newReward);

      // For now, we'll just show success message
      FHelperFunctions.showSnackBar(
          'Reward "${newReward.title}" created successfully!'
      );

      // Navigate back with success result
      Get.back(result: {
        'success': true,
        'reward': newReward,
        'message': 'Reward created successfully'
      });

    } catch (e) {
      FHelperFunctions.showAlert('Error',
          'Failed to create reward: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Save as draft (inactive reward)
  Future<void> saveAsDraft() async {
    // Temporarily set as inactive and save
    final wasActive = isActive.value;
    isActive.value = false;

    await saveReward();

    // Restore original state if save failed
    if (isLoading.value == false) {
      isActive.value = wasActive;
    }
  }

  // Preview reward data
  Map<String, dynamic> getRewardPreview() {
    return {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'termsConditions': termsController.text.trim(),
      'pointsNeeded': int.tryParse(pointsController.text.trim()) ?? 0,
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      'validUntil': selectedValidUntilDate.value?.toIso8601String() ?? '',
      'status': isActive.value ? 'active' : 'inactive',
      'hasImage': selectedImagePath.value.isNotEmpty,
      'imagePath': selectedImagePath.value,
    };
  }

  // Confirmation dialog before leaving
  Future<bool> confirmExit() async {
    // Check if form has any data
    final hasData = titleController.text.trim().isNotEmpty ||
        descriptionController.text.trim().isNotEmpty ||
        termsController.text.trim().isNotEmpty ||
        pointsController.text.trim().isNotEmpty ||
        quantityController.text.trim().isNotEmpty ||
        selectedImagePath.value.isNotEmpty;

    if (!hasData) {
      return true; // Allow exit if no data entered
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave? All changes will be lost.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Auto-save draft functionality (could be called periodically)
  void autoSaveDraft() {
    // In a real app, you might want to auto-save drafts
    // This is just a placeholder for that functionality
    final draftData = getRewardPreview();
    // Save to local storage or temporary backend storage
    print('Auto-saving draft: $draftData');
  }

  // Validate individual fields for real-time feedback
  void validateTitleField() {
    final result = validateTitle(titleController.text);
    if (result != null) {
      // Could show inline error or update UI state
    }
  }

  void validatePointsField() {
    final result = validatePoints(pointsController.text);
    if (result != null) {
      // Could show inline error or update UI state
    }
  }

  void validateQuantityField() {
    final result = validateQuantity(quantityController.text);
    if (result != null) {
      // Could show inline error or update UI state
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    titleController.dispose();
    descriptionController.dispose();
    termsController.dispose();
    pointsController.dispose();
    quantityController.dispose();
    validUntilController.dispose();
    super.onClose();
  }
}