import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/data/repositories/reward_redemption/reward_repository.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import 'package:fyp/utils/validators/validation.dart';

import '../../../../utils/constants/colors.dart';

class AddRewardController extends GetxController {
  static AddRewardController get instance => Get.find();

  final RewardRepository _rewardRepo = Get.put(RewardRepository());
  final _uuid = const Uuid();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController termsController;
  late TextEditingController pointsController;
  late TextEditingController quantityController;
  late TextEditingController validUntilController;

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isCompressing = false.obs;
  final RxBool isActive = false.obs;
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxnString selectedImageName = RxnString();
  final Rx<DateTime?> selectedValidUntilDate = Rx<DateTime?>(null);

  // Image compression settings
  static const int imageQuality = 85;
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setDefaultValidUntilDate();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    termsController = TextEditingController();
    pointsController = TextEditingController();
    quantityController = TextEditingController();
    validUntilController = TextEditingController();
  }

  void _setDefaultValidUntilDate() {
    // Default: tomorrow at 11:59 PM
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final defaultDate = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      23,
      59,
      0,
    );
    selectedValidUntilDate.value = defaultDate;
    validUntilController.text = _formatDateTime(defaultDate);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Validation methods
  String? validateTitle(String? value) {
    return FValidator.validateEmptyText('Reward title', value);
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  String? validateTerms(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Terms & conditions are required';
    }
    if (value.trim().length < 10) {
      return 'Terms must be at least 10 characters';
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

    if (points > 9999) {
      return 'Points cannot exceed 9999';
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
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowMidnight =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    if (selectedDate.isBefore(tomorrowMidnight)) {
      return 'Valid until must be at least 1 day from now';
    }

    return null;
  }

  // Date selection with time picker
  Future<void> selectValidUntilDate() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // Pick date
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: selectedValidUntilDate.value ?? tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (pickedDate != null) {
      // Pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: const TimeOfDay(hour: 23, minute: 59),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        selectedValidUntilDate.value = selectedDateTime;
        validUntilController.text = _formatDateTime(selectedDateTime);
      }
    }
  }

  // Image handling
  Future<void> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      PlatformFile file = result.files.first;

      if (file.size > maxImageSizeBytes) {
        FAdminLoaders.errorSnackBar(
          title: 'File Too Large',
          message: 'Image size must be less than ${maxImageSizeMB}MB',
        );
        return;
      }

      final extension = file.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Format',
          message: 'Only JPG, PNG, and WebP formats are supported',
        );
        return;
      }

      final compressedBytes = await _processAndCompressImage(file);

      selectedImageBytes.value = compressedBytes;
      selectedImageName.value = '${_uuid.v4()}.webp';

      FAdminLoaders.successSnackBar(
        title: 'Image Selected',
        message: 'Reward image selected successfully',
      );
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to select image: ${e.toString()}',
      );
    }
  }

  Future<Uint8List> _processAndCompressImage(PlatformFile file) async {
    try {
      isCompressing.value = true;

      Uint8List imageBytes;
      if (file.bytes != null) {
        imageBytes = file.bytes!;
      } else if (file.path != null) {
        final originalFile = File(file.path!);
        imageBytes = await originalFile.readAsBytes();
      } else {
        throw 'No file data available';
      }

      final result = await FlutterImageCompress.compressWithList(
        imageBytes,
        format: CompressFormat.webp,
        quality: imageQuality,
        minWidth: 800,
        minHeight: 800,
        autoCorrectionAngle: true,
      );

      isCompressing.value = false;
      return result;
    } catch (e) {
      isCompressing.value = false;
      if (file.bytes != null) {
        return file.bytes!;
      } else if (file.path != null) {
        final originalFile = File(file.path!);
        return await originalFile.readAsBytes();
      } else {
        throw 'No file data available';
      }
    }
  }

  void removeImage() {
    selectedImageBytes.value = null;
    selectedImageName.value = null;
  }

  // Status toggle
  void toggleStatus() {
    isActive.value = !isActive.value;
  }

  // Validation
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      FAdminLoaders.errorSnackBar(
        title: 'Form Error',
        message: 'Please fix all form errors before proceeding',
      );
      return false;
    }

    return true;
  }

  // Create reward with confirmation
  Future<void> createReward() async {
    if (!_validateForm()) return;

    // Show confirmation dialog
    await Get.dialog(
      _buildConfirmationDialog(),
      barrierDismissible: false,
    );
  }

  Widget _buildConfirmationDialog() {
    return Dialog(
        backgroundColor: Get.isDarkMode
            ? FColors.adminDarkSurface
            : FColors.adminLightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 450, // 设置最大宽度
            minWidth: 350, // 设置最小宽度
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (Get.isDarkMode
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 40,
                    color: Get.isDarkMode
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create New Reward?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Get.isDarkMode
                        ? FColors.adminDarkText
                        : FColors.adminLightText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to create this reward? It will be ${isActive.value ? "active" : "inactive"} after creation.',
                  style: TextStyle(
                    color: Get.isDarkMode
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Get.isDarkMode
                                ? FColors.adminDarkBorder
                                : FColors.adminLightBorder,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Get.isDarkMode
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _performCreate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.isDarkMode
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<void> _performCreate() async {
    try {
      isLoading.value = true;

      // Upload image if exists
      String uploadedImageName = '';
      if (selectedImageBytes.value != null && selectedImageName.value != null) {
        uploadedImageName = await _rewardRepo.uploadRewardImage(
          selectedImageBytes.value!,
          selectedImageName.value!,
        );
      }

      final reward = RewardModel(
        rewardId: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        termsConditions: termsController.text.trim(),
        rewardImage: uploadedImageName,
        pointsNeeded: int.parse(pointsController.text.trim()),
        quantity: int.parse(quantityController.text.trim()),
        validUntil: selectedValidUntilDate.value!,
        redemptionCount: 0,
        createdAt: DateTime.now(),
        status: isActive.value ? 'active' : 'inactive',
      );

      await _rewardRepo.createReward(reward);

      isLoading.value = false;

      FAdminLoaders.successSnackBar(
        title: 'Reward Created',
        message: 'Reward "${reward.title}" created successfully',
      );

      Get.back(result: true);
    } catch (e) {
      isLoading.value = false;
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create reward: ${e.toString()}',
      );
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    termsController.dispose();
    pointsController.dispose();
    quantityController.dispose();
    validUntilController.dispose();
    super.onClose();
  }
}
