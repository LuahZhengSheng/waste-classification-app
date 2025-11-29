import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/data/repositories/reward_redemption/reward_repository.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/validators/validation.dart';

import '../../../../utils/helpers/image_compressor.dart';
import '../../../../utils/popups/admin_loaders.dart';

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
  final RxBool imageChanged = false.obs;

  // Original reward data
  final Rxn<RewardModel> originalReward = Rxn<RewardModel>();

  // 原始文件名（Firestore 里的值）
  String? _originalImageFileName;

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

    final titleChanged =
        titleController.text != originalReward.value!.title;
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

    // 与原始文件名比较，而不是与 URL 比较
    final imageChangedFlag = selectedImageBytes.value != null ||
        (existingImageName.value != null &&
            existingImageName.value!.isNotEmpty &&
            _originalImageFileName != null &&
            existingImageName.value != _originalImageFileName);

    print('change: $existingImageName');

    hasChanges.value = titleChanged ||
        descChanged ||
        termsChanged ||
        pointsChanged ||
        qtyChanged ||
        dateChanged ||
        imageChangedFlag;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
      isActive.value = reward.status == 'active';

      // 原始文件名 & existingImage
      _originalImageFileName = null;
      existingImageName.value = null;

      if (reward.rewardImage.isNotEmpty) {
        String imageName = reward.rewardImage;
        print('imageName0: $imageName');

        if (imageName.startsWith('http')) {
          // 解析 URL -> 提取最后一个带扩展名的 segment
          try {
            final uri = Uri.parse(imageName);
            final segments = uri.pathSegments;

            // 找第一个包含图片扩展名的 segment
            final candidate = segments.firstWhere(
                  (s) =>
              s.contains('.webp') ||
                  s.contains('.jpg') ||
                  s.contains('.png') ||
                  s.contains('.jpeg'),
              orElse: () => segments.isNotEmpty ? segments.last : imageName,
            );

            imageName = candidate;
            print('imageName1: $imageName');
          } catch (e) {
            print('Error parsing URL: $e');
          }
        }

        // 不管是 URL 解析后，还是本来就是 "rewards/xxx.webp" 这种路径，这里统一再截一次
        if (imageName.contains('/')) {
          print('imageName-before-split: $imageName');
          imageName = imageName.split('/').last;
          print('imageName-after-split: $imageName');
        }

        _originalImageFileName = imageName;
        existingImageName.value = imageName;
      }

      hasChanges.value = false;
      imageChanged.value = false;
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
    if (selectedImageBytes.value != null ||
        (existingImageName.value != null &&
            existingImageName.value!.isNotEmpty &&
            _originalImageFileName != null &&
            existingImageName.value != _originalImageFileName)) {
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
    final tomorrowMidnight =
    DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    if (selectedDate.isBefore(tomorrowMidnight)) {
      return 'Valid until must be at least 1 day from now';
    }

    return null;
  }

  // 验证图片
  String? validateImage() {
    if ((existingImageName.value == null ||
        existingImageName.value!.isEmpty) &&
        selectedImageBytes.value == null) {
      return 'Reward image is required';
    }
    return null;
  }

  // Date selection with time picker
  Future<void> selectValidUntilDate() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    DateTime? initialDate = selectedValidUntilDate.value;
    DateTime firstDate = tomorrow;

    if (initialDate == null || initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (pickedDate != null) {
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
      imageChanged.value = true;
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

      late File imageFile;
      if (file.path != null && file.path!.isNotEmpty) {
        imageFile = File(file.path!);
      } else if (file.bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/${file.name}';
        imageFile = await File(tempPath).writeAsBytes(file.bytes!);
      } else {
        throw 'No file data available';
      }

      final compressedFile =
      await ImageCompressor.compressAndConvertToWebP(imageFile);

      final compressedBytes = await compressedFile.readAsBytes();

      isCompressing.value = false;
      return compressedBytes;
    } catch (e) {
      isCompressing.value = false;
      if (file.bytes != null) {
        return file.bytes!;
      } else if (file.path != null && file.path!.isNotEmpty) {
        final fallbackFile = File(file.path!);
        return await fallbackFile.readAsBytes();
      } else {
        throw 'No file data available';
      }
    }
  }

  void removeImage() {
    selectedImageBytes.value = null;
    newImageName.value = null;
    existingImageName.value = null;
    imageChanged.value = true;
    _checkForChanges();

    FAdminLoaders.successSnackBar(
      title: 'Image Removed',
      message: 'Reward image will be removed when you save changes',
    );
  }

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

  // 验证表单
  bool _validateForm() {
    final imageError = validateImage();
    if (imageError != null) {
      FAdminLoaders.errorSnackBar(
        title: 'Image Required',
        message: imageError,
      );
      return false;
    }

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

    final changedFields = getChangedFields();

    FAdminLoaders.showRewardUpdateDialog(
      changedFields: changedFields,
      onConfirm: () {
        _performUpdate();
      },
    );
  }

  Future<void> _performUpdate() async {
    try {
      isLoading.value = true;

      // 只用文件名，不加 rewards/
      String finalImageName = existingImageName.value ?? '';
      print('finalImageName: $finalImageName');

      if (selectedImageBytes.value != null && newImageName.value != null) {
        finalImageName = await _rewardRepo.uploadRewardImage(
          selectedImageBytes.value!,
          newImageName.value!,
        );

        if (_originalImageFileName != null &&
            _originalImageFileName!.isNotEmpty) {
          await _rewardRepo.deleteRewardImage(_originalImageFileName!);
        }
      } else if (selectedImageBytes.value == null &&
          existingImageName.value == null) {
        if (_originalImageFileName != null &&
            _originalImageFileName!.isNotEmpty) {
          await _rewardRepo.deleteRewardImage(_originalImageFileName!);
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

      Navigator.of(Get.context!).pop();
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
