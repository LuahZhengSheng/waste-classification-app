import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../personalization/models/recycle_activity_model.dart';
import '../models/waste_category_model.dart';

class AddActivityFormController extends GetxController {
  final bool isEditing;
  final RecyclingActivity? existingActivity;
  final RxList<WasteCategory> wasteCategories;

  AddActivityFormController({
    required this.isEditing,
    this.existingActivity,
    required this.wasteCategories,
  });

  // Form key and controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController wasteObjectController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Observables
  final Rx<WasteCategory?> selectedCategory = Rx<WasteCategory?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString selectedImagePath = ''.obs;
  final RxInt calculatedPoints = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (isEditing && existingActivity != null) {
      _populateFields();
    }
  }

  @override
  void onClose() {
    wasteObjectController.dispose();
    weightController.dispose();
    super.onClose();
  }

  /// Populate fields when editing
  void _populateFields() {
    if (existingActivity != null) {
      wasteObjectController.text = existingActivity!.wasteObject;
      weightController.text = existingActivity!.weight.toString();
      selectedImagePath.value = existingActivity!.supportImage;
      calculatedPoints.value = existingActivity!.pointsEarned;

      // Find and select the category
      final category = wasteCategories.firstWhereOrNull(
            (cat) => cat.categoryId == existingActivity!.wasteCategoryId,
      );
      if (category != null) {
        selectedCategory.value = category;
      }
    }
  }

  /// Select waste category
  void selectCategory(WasteCategory category) {
    selectedCategory.value = category;
    calculatePoints();
  }

  /// Calculate points based on weight and category
  void calculatePoints() {
    final weight = double.tryParse(weightController.text) ?? 0.0;

    if (weight <= 0 || selectedCategory.value == null) {
      calculatedPoints.value = 0;
      return;
    }

    final basePoints = selectedCategory.value!.basePoints;
    final totalPoints = (weight * basePoints).round();
    calculatedPoints.value = totalPoints;
  }

  /// Pick image from gallery or camera
  void pickImage() async {
    try {
      // Mock image selection - replace with actual image picker
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock image path
      selectedImagePath.value = 'mock_image_path.jpg';

      Get.snackbar(
        'Success',
        'Image selected successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  /// Remove selected image
  void removeImage() {
    selectedImage.value = null;
    selectedImagePath.value = '';
  }

  /// Validate waste object input
  String? validateWasteObject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe the waste item';
    }
    if (value.trim().length < 3) {
      return 'Description must be at least 3 characters';
    }
    return null;
  }

  /// Validate weight input
  String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter weight';
    }

    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }

    if (weight > 1000) {
      return 'Weight cannot exceed 1000 kg';
    }

    return null;
  }

  /// Validate category selection
  String? validateCategory() {
    if (selectedCategory.value == null) {
      return 'Please select a waste category';
    }
    return null;
  }

  /// Validate image selection
  String? validateImage() {
    if (selectedImagePath.value.isEmpty) {
      return 'Please upload a support image';
    }
    return null;
  }

  /// Validate entire form
  bool validateForm() {
    bool isValid = true;
    String errorMessage = '';

    // Validate form fields
    if (!formKey.currentState!.validate()) {
      isValid = false;
    }

    // Validate category
    if (selectedCategory.value == null) {
      isValid = false;
      errorMessage = 'Please select a waste category';
    }

    // Validate image
    if (selectedImagePath.value.isEmpty) {
      isValid = false;
      errorMessage = 'Please upload a support image';
    }

    if (!isValid && errorMessage.isNotEmpty) {
      Get.snackbar(
        'Validation Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    return isValid;
  }

  /// Create recycling activity from form data
  RecyclingActivity createActivity(String userId, String centerStaffId) {
    return RecyclingActivity.createNew(
      userId: userId,
      centerStaffId: centerStaffId,
      wasteObject: wasteObjectController.text.trim(),
      wasteCategoryId: selectedCategory.value!.categoryId,
      weight: double.parse(weightController.text.trim()),
      supportImage: selectedImagePath.value,
      customPoints: calculatedPoints.value,
    );
  }

  /// Reset form
  void resetForm() {
    formKey.currentState?.reset();
    wasteObjectController.clear();
    weightController.clear();
    selectedCategory.value = null;
    selectedImage.value = null;
    selectedImagePath.value = '';
    calculatedPoints.value = 0;
  }

  /// Show image selection dialog
  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image from camera
  void _pickImageFromCamera() async {
    try {
      // Mock camera capture - replace with actual camera functionality
      await Future.delayed(const Duration(milliseconds: 800));

      selectedImagePath.value = 'camera_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Get.snackbar(
        'Success',
        'Photo captured successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to capture photo: $e');
    }
  }

  /// Pick image from gallery
  void _pickImageFromGallery() async {
    try {
      // Mock gallery selection - replace with actual gallery functionality
      await Future.delayed(const Duration(milliseconds: 500));

      selectedImagePath.value = 'gallery_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Get.snackbar(
        'Success',
        'Image selected from gallery!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to select image: $e');
    }
  }

  /// Check if form has unsaved changes
  bool get hasUnsavedChanges {
    if (isEditing && existingActivity != null) {
      return wasteObjectController.text != existingActivity!.wasteObject ||
          weightController.text != existingActivity!.weight.toString() ||
          selectedCategory.value?.categoryId != existingActivity!.wasteCategoryId ||
          selectedImagePath.value != existingActivity!.supportImage;
    } else {
      return wasteObjectController.text.isNotEmpty ||
          weightController.text.isNotEmpty ||
          selectedCategory.value != null ||
          selectedImagePath.value.isNotEmpty;
    }
  }

  /// Show unsaved changes dialog
  void showUnsavedChangesDialog(VoidCallback onConfirm) {
    if (!hasUnsavedChanges) {
      onConfirm();
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  /// Get category display name with icon
  String getCategoryDisplayName() {
    if (selectedCategory.value == null) return 'Select Category';
    return selectedCategory.value!.name;
  }

  /// Get estimated processing time based on category
  String getEstimatedProcessingTime() {
    if (selectedCategory.value == null) return '';

    switch (selectedCategory.value!.name.toLowerCase()) {
      case 'electronics':
        return '3-5 business days';
      case 'plastic':
        return '1-2 business days';
      case 'paper':
        return '1 business day';
      case 'glass':
        return '2-3 business days';
      case 'metal':
        return '2-4 business days';
      default:
        return '1-3 business days';
    }
  }

  /// Get recycling tips for selected category
  String getRecyclingTips() {
    if (selectedCategory.value == null) return '';

    switch (selectedCategory.value!.name.toLowerCase()) {
      case 'electronics':
        return 'Remove batteries and personal data before recycling';
      case 'plastic':
        return 'Clean containers and remove labels when possible';
      case 'paper':
        return 'Keep paper dry and remove any plastic parts';
      case 'glass':
        return 'Rinse containers and separate by color if possible';
      case 'metal':
        return 'Clean cans and remove any food residue';
      default:
        return 'Follow local recycling guidelines';
    }
  }
}