import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';

import '../../../utils/popups/loaders.dart';
import '../../../utils/helpers/image_compressor.dart';
import '../../waste_classification/models/waste_category_model.dart';

class AddActivityFormController extends GetxController {
  final bool isEditing;
  final RecyclingActivity? existingActivity;
  final List<WasteCategory> wasteCategories;
  final File? existingImageFile; // Add this parameter

  AddActivityFormController({
    required this.isEditing,
    this.existingActivity,
    required this.wasteCategories,
    this.existingImageFile, // Add this parameter
  });

  // Form key and controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController wasteObjectController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Observables
  final Rx<WasteCategory?> selectedCategory = Rx<WasteCategory?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString uploadedImageFileName = ''.obs;
  final RxInt calculatedPoints = 0.obs;
  final RxBool isLoading = false.obs;

  // Track if image was changed during editing
  final RxBool imageChanged = false.obs;

  // Computed property to check if there's an existing image
  RxBool get hasExistingImage {
    return RxBool(
        uploadedImageFileName.value.isNotEmpty &&
            !uploadedImageFileName.value.startsWith('temp_')
    );
  }

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Image validation constants
  static const int maxImageSizeInBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp', 'heic'];

  @override
  void onInit() {
    super.onInit();
    if (isEditing && existingActivity != null) {
      _populateFields();

      // Set the existing image file if provided
      if (existingImageFile != null) {
        selectedImage.value = existingImageFile;
        imageChanged.value = false; // Not changed yet
        print('📸 Loaded existing image file for editing');
      }
    }
  }

  @override
  void onClose() {
    wasteObjectController.dispose();
    weightController.dispose();
    super.onClose();
  }

  void _populateFields() {
    if (existingActivity != null) {
      wasteObjectController.text = existingActivity!.wasteObject;
      weightController.text = existingActivity!.weight.toString();

      print('🔍 Populating fields for existing activity');
      print('Existing activity supportImage: ${existingActivity!.supportImage}');
      print('Existing activity wasteObject: ${existingActivity!.wasteObject}');
      print('Existing activity weight: ${existingActivity!.weight}');

      // In edit mode, we don't rely on supportImage filename
      // The image file will be provided through the existingImageFile parameter
      // This is because before submission, images are stored as File objects
      uploadedImageFileName.value = existingActivity!.supportImage;
      imageChanged.value = false; // Image not changed yet

      if (existingActivity!.supportImage.startsWith('temp_')) {
        print('📝 Activity has temporary image (not yet uploaded to Firebase)');
      } else {
        print('☁️ Activity has uploaded image: ${existingActivity!.supportImage}');
      }

      calculatedPoints.value = existingActivity!.pointsEarned;

      final category = wasteCategories.firstWhereOrNull(
            (cat) => cat.categoryId == existingActivity!.wasteCategoryId,
      );
      if (category != null) {
        selectedCategory.value = category;
        print('✅ Set category to: ${category.name}');
      }
    }
  }

  void selectCategory(WasteCategory category) {
    selectedCategory.value = category;
    calculatePoints();
  }

  void calculatePoints() {
    final weight = double.tryParse(weightController.text) ?? 0.0;

    if (weight <= 0 || selectedCategory.value == null) {
      calculatedPoints.value = 0;
      return;
    }

    final basePoints = selectedCategory.value!.basePoints;
    final totalPoints = (weight * basePoints!).round();
    calculatedPoints.value = totalPoints;
  }

  void pickImage() {
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

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        await _validateAndSetImage(File(image.path));
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to capture photo: $e',
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        await _validateAndSetImage(File(image.path));
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to select image: $e',
      );
    }
  }

  Future<void> _validateAndSetImage(File imageFile) async {
    // Validate format
    if (!ImageCompressor.isValidImageFormat(imageFile)) {
      FLoaders.errorSnackBar(
        title: 'Invalid Format',
        message: 'Please select a valid image format (JPG, PNG, WEBP, HEIC)',
      );
      return;
    }

    // Validate size
    final fileSize = await imageFile.length();
    if (fileSize > maxImageSizeInBytes) {
      FLoaders.errorSnackBar(
        title: 'File Too Large',
        message: 'Image size must be less than 10MB',
      );
      return;
    }

    // Check if already has image (limit to 1)
    if (selectedImage.value != null || uploadedImageFileName.value.isNotEmpty) {
      FLoaders.warningSnackBar(
        title: 'Replace Image',
        message: 'Replacing existing image',
      );
    }

    selectedImage.value = imageFile;
    imageChanged.value = true; // Mark that image was changed
    // Don't clear uploadedImageFileName yet - we need it for deletion

    FLoaders.customToast(message: 'Image selected successfully!');
  }

  void removeImage() {
    selectedImage.value = null;
    uploadedImageFileName.value = '';
    imageChanged.value = true; // Mark that image was changed

    FLoaders.warningSnackBar(
      title: 'Image Removed',
      message: 'Please select a new image',
    );
  }

  String? validateWasteObject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe the waste item';
    }
    if (value.trim().length < 3) {
      return 'Description must be at least 3 characters';
    }
    return null;
  }

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

  bool validateForm() {
    bool isValid = true;
    String errorMessage = '';

    if (!formKey.currentState!.validate()) {
      isValid = false;
    }

    if (selectedCategory.value == null) {
      isValid = false;
      errorMessage = 'Please select a waste category';
    }

    // Must have an image (either existing or newly selected)
    if (selectedImage.value == null) {
      isValid = false;
      errorMessage = 'Please upload a support image';
    }

    if (!isValid && errorMessage.isNotEmpty) {
      FLoaders.errorSnackBar(
        title: 'Validation Error',
        message: errorMessage,
      );
    }

    return isValid;
  }

  /// Create recycling activity (image will be uploaded later during submission)
  RecyclingActivity createActivity(String userId, String centerStaffId) {
    String finalImageFileName;

    if (isEditing && existingActivity != null) {
      if (imageChanged.value) {
        // Image was changed - use new temp filename
        print('📸 Image changed during edit, will upload new image');
        finalImageFileName = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // Image not changed - preserve existing filename
        finalImageFileName = existingActivity!.supportImage;
        print('♻️ Preserving existing image filename: $finalImageFileName');
      }
    } else {
      // New activity
      finalImageFileName = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      print('Creating new activity with temp filename');
    }

    // Create activity
    final activity = RecyclingActivity.createNew(
      userId: userId,
      centerStaffId: centerStaffId,
      wasteObject: wasteObjectController.text.trim(),
      wasteCategoryId: selectedCategory.value!.categoryId,
      weight: double.parse(weightController.text.trim()),
      supportImage: finalImageFileName,
      customPoints: calculatedPoints.value,
    );

    print('✅ Created activity with supportImage: $finalImageFileName');
    return activity;
  }

  /// Get the selected image file (for upload during submission)
  File? getImageFile() {
    // Always return the current image
    // If it was changed, it's the new image
    // If it wasn't changed, it's the existing image
    return selectedImage.value;
  }

  void resetForm() {
    formKey.currentState?.reset();
    wasteObjectController.clear();
    weightController.clear();
    selectedCategory.value = null;
    selectedImage.value = null;
    uploadedImageFileName.value = '';
    calculatedPoints.value = 0;
    imageChanged.value = false; // Reset image changed flag
  }

  bool get hasUnsavedChanges {
    if (isEditing && existingActivity != null) {
      return wasteObjectController.text != existingActivity!.wasteObject ||
          weightController.text != existingActivity!.weight.toString() ||
          selectedCategory.value?.categoryId != existingActivity!.wasteCategoryId ||
          imageChanged.value; // Check if image was changed
    } else {
      return wasteObjectController.text.isNotEmpty ||
          weightController.text.isNotEmpty ||
          selectedCategory.value != null ||
          selectedImage.value != null;
    }
  }

  String getCategoryDisplayName() {
    if (selectedCategory.value == null) return 'Select Category';
    return selectedCategory.value!.name;
  }

  String getRecyclingTips() {
    if (selectedCategory.value == null) return '';
    return selectedCategory.value!.disposalMethodWithEmoji;
  }
}