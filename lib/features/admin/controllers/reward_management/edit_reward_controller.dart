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

class EditRewardController extends GetxController {
  static EditRewardController get instance => Get.find();

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
  final RxBool hasChanges = false.obs;
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxnString existingImageName = RxnString();
  final RxnString newImageName = RxnString();
  final Rx<DateTime?> selectedValidUntilDate = Rx<DateTime?>(null);

  // Original reward data
  final Rxn<RewardModel> originalReward = Rxn<RewardModel>();

  // Image compression settings
  static const int imageQuality = 85;
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    termsController = TextEditingController();
    pointsController = TextEditingController();
    quantityController = TextEditingController();
    validUntilController = TextEditingController();

    // Add listeners for change detection
    titleController.addListener(_checkForChanges);
    descriptionController.addListener(_checkForChanges);
    termsController.addListener(_checkForChanges);
    pointsController.addListener(_checkForChanges);
    quantityController.addListener(_checkForChanges);
    validUntilController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    if (originalReward.value == null) return;

    final titleChanged = titleController.text != originalReward.value!.title;
    final descChanged =
        descriptionController.text != originalReward.value!.description;
    final termsChanged =
        termsController.text != originalReward.value!.termsConditions;
    final pointsChanged =
        pointsController.text != originalReward.value!.pointsNeeded.toString();
    final qtyChanged =
        quantityController.text != originalReward.value!.quantity.toString();
    final dateChanged = selectedValidUntilDate.value != null &&
        selectedValidUntilDate.value != originalReward.value!.validUntil;
    // final statusChanged =
    //     isActive.value != (originalReward.value!.status == 'active');
    final imageChanged = selectedImageBytes.value != null ||
        (existingImageName.value != originalReward.value!.rewardImage);

    hasChanges.value = titleChanged ||
        descChanged ||
        termsChanged ||
        pointsChanged ||
        qtyChanged ||
        dateChanged ||
        // statusChanged ||
        imageChanged;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> loadRewardData(String rewardId) async {
    try {
      if (rewardId.isEmpty) {
        FAdminLoaders.errorSnackBar(
          title: 'Error',
          message: 'Invalid reward ID',
        );
        return;
      }

      isLoading.value = true;
      final reward = await _rewardRepo.getRewardById(rewardId);
      originalReward.value = reward;

      // Pre-fill form
      titleController.text = reward.title;
      descriptionController.text = reward.description;
      termsController.text = reward.termsConditions;
      pointsController.text = reward.pointsNeeded.toString();
      quantityController.text = reward.quantity.toString();
      selectedValidUntilDate.value = reward.validUntil;
      validUntilController.text = _formatDateTime(reward.validUntil);
      // isActive.value = reward.status == 'active';

      // Set existing image
      if (reward.rewardImage.isNotEmpty) {
        String imageName = reward.rewardImage;
        if (reward.rewardImage.startsWith('http')) {
          try {
            final uri = Uri.parse(reward.rewardImage);
            final pathSegments = uri.pathSegments;
            for (final segment in pathSegments) {
              if (segment.contains('.webp') ||
                  segment.contains('.jpg') ||
                  segment.contains('.png')) {
                imageName = segment;
                break;
              }
            }
            if (imageName == reward.rewardImage && pathSegments.isNotEmpty) {
              imageName = pathSegments.last;
            }
          } catch (e) {
            print('Error parsing URL: $e');
          }
        }
        existingImageName.value = imageName;
      }

      hasChanges.value = false;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load reward data: ${e.toString()}',
      );
    }
  }

  List<String> getChangedFields() {
    List<String> changes = [];

    if (originalReward.value == null) return changes;

    if (titleController.text != originalReward.value!.title) {
      changes.add('Title');
    }
    if (descriptionController.text != originalReward.value!.description) {
      changes.add('Description');
    }
    if (termsController.text != originalReward.value!.termsConditions) {
      changes.add('Terms & Conditions');
    }
    if (pointsController.text !=
        originalReward.value!.pointsNeeded.toString()) {
      changes.add('Points Required');
    }
    if (quantityController.text != originalReward.value!.quantity.toString()) {
      changes.add('Quantity');
    }
    if (selectedValidUntilDate.value != null &&
        selectedValidUntilDate.value != originalReward.value!.validUntil) {
      changes.add('Valid Until');
    }
    // if (isActive.value != (originalReward.value!.status == 'active')) {
    //   changes.add('Status');
    // }
    if (selectedImageBytes.value != null ||
        (existingImageName.value != originalReward.value!.rewardImage)) {
      changes.add('Reward Image');
    }

    return changes;
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

    // Check against redemption count
    if (originalReward.value != null &&
        quantity < originalReward.value!.redemptionCount) {
      return 'Quantity cannot be less than redemption count (${originalReward.value!.redemptionCount})';
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
    final tomorrowMidnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    if (selectedDate.isBefore(tomorrowMidnight)) {
      return 'Valid until must be at least 1 day from now';
    }

    return null;
  }

  // Date selection with time picker
  Future<void> selectValidUntilDate() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // 确保 initialDate 不小于 firstDate
    DateTime? initialDate = selectedValidUntilDate.value;
    DateTime firstDate = tomorrow; // 最早可选日期是明天

    // 如果 initialDate 早于 firstDate，使用 firstDate
    if (initialDate == null || initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    // Pick date
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: firstDate, // 最早只能选明天
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (pickedDate != null) {
      // Pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay(
          hour: selectedValidUntilDate.value?.hour ?? 23,
          minute: selectedValidUntilDate.value?.minute ?? 59,
        ),
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
        _checkForChanges();
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
      newImageName.value = '${_uuid.v4()}.webp';
      _checkForChanges();

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
    newImageName.value = null;
    existingImageName.value = null;
    _checkForChanges();
  }

  // Status toggle
  // void toggleStatus() {
  //   isActive.value = !isActive.value;
  //   _checkForChanges();
  // }

  Future<String?> getImageUrl(String fileNameOrUrl) async {
    try {
      if (fileNameOrUrl.isEmpty) return null;

      String fileName = fileNameOrUrl;

      if (fileNameOrUrl.startsWith('http')) {
        try {
          final uri = Uri.parse(fileNameOrUrl);
          final pathSegments = uri.pathSegments;
          for (final segment in pathSegments) {
            if (segment.contains('.webp') ||
                segment.contains('.jpg') ||
                segment.contains('.png') ||
                segment.contains('.jpeg')) {
              fileName = segment;
              break;
            }
          }
          if (fileName == fileNameOrUrl && pathSegments.isNotEmpty) {
            fileName = pathSegments.last;
          }
        } catch (e) {
          return fileNameOrUrl;
        }
      }

      final url = await _rewardRepo.getRewardImageUrl(fileName);
      return url;
    } catch (e) {
      if (fileNameOrUrl.startsWith('http')) {
        return fileNameOrUrl;
      }
      return null;
    }
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

  // Update reward with confirmation
  Future<void> updateReward() async {
    if (!_validateForm()) return;

    if (originalReward.value == null) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'No reward data loaded',
      );
      return;
    }

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
                    Icons.edit_outlined,
                    size: 40,
                    color: Get.isDarkMode
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Update Reward?',
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
                  'Are you sure you want to save these changes?',
                  style: TextStyle(
                    color: Get.isDarkMode
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? FColors.adminDarkSurfaceVariant
                        : FColors.adminLightSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Changes detected:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Get.isDarkMode
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...getChangedFields().map((field) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Get.isDarkMode
                                      ? FColors.adminDarkSuccess
                                      : FColors.adminLightSuccess,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  field,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Get.isDarkMode
                                        ? FColors.adminDarkTextSecondary
                                        : FColors.adminLightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
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
                          _performUpdate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.isDarkMode
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Update',
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

  Future<void> _performUpdate() async {
    try {
      isLoading.value = true;

      // Handle image update
      String finalImageName = existingImageName.value ?? '';

      if (selectedImageBytes.value != null && newImageName.value != null) {
        // Upload new image
        finalImageName = await _rewardRepo.uploadRewardImage(
          selectedImageBytes.value!,
          newImageName.value!,
        );

        // Delete old image if exists
        if (existingImageName.value != null &&
            existingImageName.value!.isNotEmpty) {
          await _rewardRepo.deleteRewardImage(existingImageName.value!);
        }
      } else if (selectedImageBytes.value == null &&
          existingImageName.value == null) {
        // Remove image
        if (finalImageName.isNotEmpty) {
          await _rewardRepo.deleteRewardImage(finalImageName);
        }
        finalImageName = '';
      }

      final updatedReward = originalReward.value!.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        termsConditions: termsController.text.trim(),
        rewardImage: finalImageName,
        pointsNeeded: int.parse(pointsController.text.trim()),
        quantity: int.parse(quantityController.text.trim()),
        validUntil: selectedValidUntilDate.value!,
        status: isActive.value ? 'active' : 'inactive',
      );

      await _rewardRepo.updateReward(updatedReward);

      isLoading.value = false;

      FAdminLoaders.successSnackBar(
        title: 'Reward Updated',
        message: 'Reward updated successfully',
      );

      Get.back(result: true);
    } catch (e) {
      isLoading.value = false;
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update reward: ${e.toString()}',
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
