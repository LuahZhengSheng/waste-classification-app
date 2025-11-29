import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/features/waste_classification/models/waste_category_model.dart';
import 'package:fyp/features/event/models/location_model.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import 'package:fyp/utils/validators/validation.dart';
import '../../../../data/repositories/recycling_center/waste_category_repository.dart';

class AddCenterController extends GetxController {
  static AddCenterController get instance => Get.find();

  final RecyclingCenterRepository _centerRepo = Get.put(RecyclingCenterRepository());
  final WasteCategoryRepository _categoryRepo = Get.put(WasteCategoryRepository());
  final _uuid = const Uuid();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isCompressing = false.obs;
  final Rx<Location?> selectedLocation = Rx<Location?>(null);

  // Updated: Opening hours now includes isOpen status
  final RxMap<String, Map<String, dynamic>> openingHours = <String, Map<String, dynamic>>{}.obs;

  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxnString selectedImageName = RxnString();
  final RxList<String> selectedMaterials = <String>[].obs;
  final RxList<WasteCategory> availableCategories = <WasteCategory>[].obs;

  // Image compression settings
  static const int imageQuality = 85;
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadWasteCategories();
    _initializeOpeningHours();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    websiteController = TextEditingController();
  }

  Future<void> _loadWasteCategories() async {
    try {
      final categories = await _categoryRepo.getAllWasteCategories();
      availableCategories.assignAll(categories);
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load waste categories: ${e.toString()}',
      );
    }
  }

  void _initializeOpeningHours() {
    final daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    for (final day in daysOfWeek) {
      // Default: Weekdays open, weekends closed
      final isWeekend = day == 'saturday' || day == 'sunday';

      openingHours[day] = {
        'open': const TimeOfDay(hour: 9, minute: 0),
        'close': const TimeOfDay(hour: 17, minute: 0),
        'isOpen': !isWeekend, // Weekdays open by default
      };
    }
  }

  // Validation methods
  String? validateName(String? value) {
    return FValidator.validateEmptyText('Center name', value);
  }

  String? validateEmail(String? value) {
    return FValidator.validateEmail(value);
  }

  String? validatePhone(String? value) {
    return FValidator.validatePhoneNumber(value);
  }

  String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Website is required';
    }
    final urlPattern = RegExp(
      r'^(https?:\/\/)[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
      caseSensitive: false,
    );
    if (!urlPattern.hasMatch(value.trim())) {
      return 'Please enter a valid website URL';
    }
    return null;
  }

  // Location methods
  void setLocation(Location location) {
    selectedLocation.value = location;
    FAdminLoaders.successSnackBar(
      title: 'Location Set',
      message: 'Center location has been saved successfully',
    );
  }

  void clearLocation() {
    selectedLocation.value = null;
    FAdminLoaders.customToast(message: 'Location cleared');
  }

  // Opening Hours methods
  void updateOpeningHours(String day, String type, TimeOfDay time) {
    if (openingHours.containsKey(day)) {
      // Create a new map to trigger reactivity
      final updatedHours = Map<String, Map<String, dynamic>>.from(openingHours);
      updatedHours[day] = Map<String, dynamic>.from(updatedHours[day]!);
      updatedHours[day]![type] = time;
      openingHours.value = updatedHours;
    }
  }

  // Toggle day open/close status
  void toggleDayStatus(String day, bool isOpen) {
    if (openingHours.containsKey(day)) {
      // Create a new map to trigger reactivity
      final updatedHours = Map<String, Map<String, dynamic>>.from(openingHours);
      updatedHours[day] = Map<String, dynamic>.from(updatedHours[day]!);
      updatedHours[day]!['isOpen'] = isOpen;
      openingHours.value = updatedHours;
    }
  }

  // Batch update opening hours for all open days
  void batchUpdateOpeningHours(TimeOfDay openTime, TimeOfDay closeTime) {
    // Create a new map to trigger reactivity
    final updatedHours = Map<String, Map<String, dynamic>>.from(openingHours);

    updatedHours.forEach((day, data) {
      if (data['isOpen'] == true) {
        updatedHours[day] = Map<String, dynamic>.from(data);
        updatedHours[day]!['open'] = openTime;
        updatedHours[day]!['close'] = closeTime;
      }
    });

    openingHours.value = updatedHours;
  }

  // Convert Opening Hours to Map (only include open days)
  Map<String, Map<String, String>> _convertOpeningHoursToMap() {
    final Map<String, Map<String, String>> result = {};

    openingHours.forEach((day, data) {
      if (data['isOpen'] == true) {
        result[day] = {
          'open': _timeOfDayToString(data['open'] as TimeOfDay),
          'close': _timeOfDayToString(data['close'] as TimeOfDay),
        };
      }
    });

    return result;
  }

  String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Image methods
  Future<void> selectImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      PlatformFile file = result.files.first;

      // Check file size
      if (file.size > maxImageSizeBytes) {
        FAdminLoaders.errorSnackBar(
          title: 'File Too Large',
          message: 'Image size must be less than ${maxImageSizeMB}MB',
        );
        return;
      }

      // Check file type
      final extension = file.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Format',
          message: 'Only JPG, PNG, and WebP formats are supported',
        );
        return;
      }

      // Process and compress image
      final compressedBytes = await _processAndCompressImage(file);

      selectedImageBytes.value = compressedBytes;
      selectedImageName.value = '${_uuid.v4()}.webp';

      FAdminLoaders.successSnackBar(
        title: 'Image Selected',
        message: 'Center image has been selected successfully',
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
        minWidth: 1080,
        minHeight: 1080,
        autoCorrectionAngle: true,
      );

      isCompressing.value = false;
      return result;
    } catch (e) {
      isCompressing.value = false;
      print('Image compression failed: $e');

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

  // Materials methods
  void toggleMaterial(String materialName) {
    if (selectedMaterials.contains(materialName)) {
      selectedMaterials.remove(materialName);
    } else {
      selectedMaterials.add(materialName);
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

    if (selectedLocation.value == null) {
      FAdminLoaders.errorSnackBar(
        title: 'Location Required',
        message: 'Please set the center location',
      );
      return false;
    }

    // Check if at least one day is open
    final hasOpenDays = openingHours.values.any((data) => data['isOpen'] == true);
    if (!hasOpenDays) {
      FAdminLoaders.errorSnackBar(
        title: 'Opening Hours Required',
        message: 'Please set at least one day as open',
      );
      return false;
    }

    if (selectedMaterials.isEmpty) {
      FAdminLoaders.errorSnackBar(
        title: 'Materials Required',
        message: 'Please select at least one accepted material',
      );
      return false;
    }

    return true;
  }

  // Create center
  Future<void> createCenter() async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;

      // Upload image if exists
      String uploadedFileName = '';
      if (selectedImageBytes.value != null && selectedImageName.value != null) {
        try {
          print('Uploading center image...');
          uploadedFileName = await _centerRepo.uploadCenterImage(
            selectedImageBytes.value!,
            selectedImageName.value!,
          );
          print('Image uploaded successfully: $uploadedFileName');
        } catch (e) {
          print('Image upload failed: $e');
          rethrow;
        }
      }

      // Convert opening hours (only includes open days)
      final openingHoursMap = _convertOpeningHoursToMap();

      final center = PartnerRecyclingCenter.createNew(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNo: phoneController.text.trim(),
        website: websiteController.text.trim(),
        centerLocation: selectedLocation.value!,
        image: uploadedFileName,
        openingHours: openingHoursMap,
        acceptedMaterials: selectedMaterials.toList(),
        numberOfStaff: 0,
        status: 'active',
      );

      print('Creating center in Firestore...');
      await _centerRepo.createCenter(center);
      print('Center created successfully');

      isLoading.value = false;

      FAdminLoaders.successSnackBar(
        title: 'Center Created',
        message: 'Recycling center created successfully',
      );

      Navigator.of(Get.context!).pop();
    } catch (e) {
      isLoading.value = false;
      print('=== CENTER CREATION ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=== END ERROR ===');

      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create center: ${e.toString()}',
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    super.onClose();
  }
}