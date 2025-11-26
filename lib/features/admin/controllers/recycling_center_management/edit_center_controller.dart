import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/features/recycling_center/models/waste_category_model.dart';
import 'package:fyp/features/event/models/location_model.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import 'package:fyp/utils/validators/validation.dart';
import '../../../../data/repositories/recycling_center/waste_category_repository.dart';

class EditCenterController extends GetxController {
  static EditCenterController get instance => Get.find();

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
  final RxnString existingImageName = RxnString();
  final RxnString newImageName = RxnString();
  final RxList<String> selectedMaterials = <String>[].obs;
  final RxList<WasteCategory> availableCategories = <WasteCategory>[].obs;

  // Track original data for change detection
  final Rxn<PartnerRecyclingCenter> originalCenter = Rxn<PartnerRecyclingCenter>();
  final RxBool hasChanges = false.obs;

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

    // Add listeners to track changes
    nameController.addListener(_checkForChanges);
    emailController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
    websiteController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    if (originalCenter.value != null) {
      final nameChanged = nameController.text != originalCenter.value!.name;
      final emailChanged = emailController.text != originalCenter.value!.email;
      final phoneChanged = phoneController.text != originalCenter.value!.phoneNo;
      final websiteChanged = websiteController.text != originalCenter.value!.website;
      final locationChanged = selectedLocation.value != null &&
          _isLocationChanged(selectedLocation.value!, originalCenter.value!.centerLocation);
      final materialsChanged = !_areListsEqual(selectedMaterials, originalCenter.value!.acceptedMaterials);
      final openingHoursChanged = _isOpeningHoursChanged();
      final imageChanged = selectedImageBytes.value != null ||
          (existingImageName.value != originalCenter.value!.image);

      hasChanges.value = nameChanged ||
          emailChanged ||
          phoneChanged ||
          websiteChanged ||
          locationChanged ||
          materialsChanged ||
          openingHoursChanged ||
          imageChanged;
    }
  }

  bool _isLocationChanged(Location newLocation, Location oldLocation) {
    return newLocation.fullAddress != oldLocation.fullAddress ||
        newLocation.geoPoint.latitude != oldLocation.geoPoint.latitude ||
        newLocation.geoPoint.longitude != oldLocation.geoPoint.longitude;
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final sortedList1 = List<String>.from(list1)..sort();
    final sortedList2 = List<String>.from(list2)..sort();
    for (int i = 0; i < sortedList1.length; i++) {
      if (sortedList1[i] != sortedList2[i]) return false;
    }
    return true;
  }

  bool _isOpeningHoursChanged() {
    if (originalCenter.value?.openingHours == null) return false;

    final originalHours = originalCenter.value!.openingHours!;
    final currentHours = _convertOpeningHoursToMap();

    // Check if keys are different (different open days)
    final originalKeys = originalHours.keys.toSet();
    final currentKeys = currentHours.keys.toSet();
    if (!originalKeys.containsAll(currentKeys) || !currentKeys.containsAll(originalKeys)) {
      return true;
    }

    // Check each day's times
    for (final day in currentHours.keys) {
      if (!originalHours.containsKey(day)) return true;

      final originalOpen = originalHours[day]?['open']?.toString() ?? '';
      final originalClose = originalHours[day]?['close']?.toString() ?? '';
      final currentOpen = currentHours[day]?['open'] ?? '';
      final currentClose = currentHours[day]?['close'] ?? '';

      if (originalOpen != currentOpen || originalClose != currentClose) {
        return true;
      }
    }

    return false;
  }

  /// Get list of changed fields for display
  List<String> getChangedFields() {
    List<String> changes = [];

    if (originalCenter.value == null) return changes;

    if (nameController.text != originalCenter.value!.name) {
      changes.add('Center Name');
    }
    if (emailController.text != originalCenter.value!.email) {
      changes.add('Email Address');
    }
    if (phoneController.text != originalCenter.value!.phoneNo) {
      changes.add('Phone Number');
    }
    if (websiteController.text != originalCenter.value!.website) {
      changes.add('Website');
    }
    if (selectedLocation.value != null &&
        _isLocationChanged(selectedLocation.value!, originalCenter.value!.centerLocation)) {
      changes.add('Location');
    }
    if (!_areListsEqual(selectedMaterials, originalCenter.value!.acceptedMaterials)) {
      changes.add('Accepted Materials');
    }
    if (_isOpeningHoursChanged()) {
      changes.add('Opening Hours');
    }
    if (selectedImageBytes.value != null ||
        (existingImageName.value != originalCenter.value!.image)) {
      changes.add('Center Image');
    }

    return changes;
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
      final isWeekend = day == 'saturday' || day == 'sunday';

      openingHours[day] = {
        'open': const TimeOfDay(hour: 9, minute: 0),
        'close': const TimeOfDay(hour: 17, minute: 0),
        'isOpen': !isWeekend,
      };
    }
  }

  Future<void> loadCenterData(String centerId) async {
    try {
      print('🔍 Loading center data for ID: $centerId');
      if (centerId.isEmpty) {
        FAdminLoaders.errorSnackBar(
          title: 'Error',
          message: 'Invalid center ID',
        );
        return;
      }

      isLoading.value = true;
      final center = await _centerRepo.getCenterById(centerId);
      originalCenter.value = center;

      print('🔍 Center loaded: ${center.name}');
      print('🔍 Center image: "${center.image}"');

      // Pre-fill all form fields
      nameController.text = center.name;
      emailController.text = center.email;
      phoneController.text = center.phoneNo;
      websiteController.text = center.website;
      selectedLocation.value = center.centerLocation;
      selectedMaterials.assignAll(center.acceptedMaterials);

      // Set existing image name - 正确处理URL情况
      if (center.image.isNotEmpty) {
        String imageName = center.image;

        // 如果存储的是URL，提取纯文件名
        if (center.image.startsWith('http')) {
          print('🔍 Extracting filename from URL...');
          try {
            final uri = Uri.parse(center.image);
            final pathSegments = uri.pathSegments;

            // 查找包含 .webp 的文件名
            for (final segment in pathSegments) {
              if (segment.contains('.webp') || segment.contains('.jpg') || segment.contains('.png')) {
                imageName = segment;
                print('🔍 ✅ Extracted filename: $imageName');
                break;
              }
            }

            // 如果没找到，使用最后一个路径段
            if (imageName == center.image && pathSegments.isNotEmpty) {
              imageName = pathSegments.last;
              print('🔍 Using last path segment as filename: $imageName');
            }
          } catch (e) {
            print('🔍 Error parsing URL: $e');
          }
        }

        existingImageName.value = imageName;
        print('🔍 Final existingImageName: "$imageName"');

      } else {
        print('🔍 No existing image found');
      }

      // Pre-fill opening hours if available
      if (center.openingHours != null && center.openingHours!.isNotEmpty) {
        _initializeOpeningHoursFromData(center.openingHours!);
      }

      hasChanges.value = false;
      isLoading.value = false;
      print('🔍 Center data loading completed');
    } catch (e) {
      isLoading.value = false;
      print('🔍 Error loading center data: $e');
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load center data: ${e.toString()}',
      );
    }
  }

  void _initializeOpeningHoursFromData(Map<String, dynamic> openingHoursData) {
    final daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    // Create new map for opening hours
    final Map<String, Map<String, dynamic>> newHours = {};

    for (final day in daysOfWeek) {
      if (openingHoursData.containsKey(day)) {
        final dayData = openingHoursData[day];
        if (dayData is Map<String, dynamic>) {
          final openTimeStr = dayData['open']?.toString() ?? '09:00';
          final closeTimeStr = dayData['close']?.toString() ?? '17:00';

          newHours[day] = {
            'open': _parseTimeString(openTimeStr),
            'close': _parseTimeString(closeTimeStr),
            'isOpen': true, // Day exists in data, so it's open
          };
        }
      } else {
        // Day not in data, mark as closed
        final isWeekend = day == 'saturday' || day == 'sunday';
        newHours[day] = {
          'open': const TimeOfDay(hour: 9, minute: 0),
          'close': const TimeOfDay(hour: 17, minute: 0),
          'isOpen': false, // Not in original data, so closed
        };
      }
    }

    openingHours.value = newHours;
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
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
    _checkForChanges();
    FAdminLoaders.successSnackBar(
      title: 'Location Set',
      message: 'Center location has been updated successfully',
    );
  }

  void clearLocation() {
    selectedLocation.value = null;
    _checkForChanges();
    FAdminLoaders.customToast(message: 'Location cleared');
  }

  // Opening Hours methods
  void updateOpeningHours(String day, String type, TimeOfDay time) {
    if (openingHours.containsKey(day)) {
      final updatedHours = Map<String, Map<String, dynamic>>.from(openingHours);
      updatedHours[day] = Map<String, dynamic>.from(updatedHours[day]!);
      updatedHours[day]![type] = time;
      openingHours.value = updatedHours;
      _checkForChanges();
    }
  }

  // Toggle day open/close status
  void toggleDayStatus(String day, bool isOpen) {
    if (openingHours.containsKey(day)) {
      final updatedHours = Map<String, Map<String, dynamic>>.from(openingHours);
      updatedHours[day] = Map<String, dynamic>.from(updatedHours[day]!);
      updatedHours[day]!['isOpen'] = isOpen;
      openingHours.value = updatedHours;
      _checkForChanges();
    }
  }

  // Batch update opening hours for all open days
  void batchUpdateOpeningHours(TimeOfDay openTime, TimeOfDay closeTime) {
    final updatedHours = Map<String, Map<String, dynamic>>.from(openingHours);

    updatedHours.forEach((day, data) {
      if (data['isOpen'] == true) {
        updatedHours[day] = Map<String, dynamic>.from(data);
        updatedHours[day]!['open'] = openTime;
        updatedHours[day]!['close'] = closeTime;
      }
    });

    openingHours.value = updatedHours;
    _checkForChanges();
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

  // Materials methods
  void toggleMaterial(String materialName) {
    if (selectedMaterials.contains(materialName)) {
      selectedMaterials.remove(materialName);
    } else {
      selectedMaterials.add(materialName);
    }
    _checkForChanges();
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

  // Update center
  Future<void> updateCenter() async {
    try {
      if (!_validateForm()) return;

      if (originalCenter.value == null) {
        FAdminLoaders.errorSnackBar(
          title: 'Error',
          message: 'No center data loaded',
        );
        return;
      }

      isLoading.value = true;

      // Handle image upload/delete
      String finalImageName = existingImageName.value ?? '';

      if (selectedImageBytes.value != null && newImageName.value != null) {
        try {
          finalImageName = await _centerRepo.uploadCenterImage(
            selectedImageBytes.value!,
            newImageName.value!,
          );

          if (existingImageName.value != null && existingImageName.value!.isNotEmpty) {
            await _centerRepo.deleteCenterImage(existingImageName.value!);
          }
        } catch (e) {
          print('Image upload failed: $e');
          rethrow;
        }
      } else if (selectedImageBytes.value == null && existingImageName.value == null) {
        if (finalImageName.isNotEmpty) {
          await _centerRepo.deleteCenterImage(finalImageName);
        }
        finalImageName = '';
      }

      // Convert opening hours (only includes open days)
      final openingHoursMap = _convertOpeningHoursToMap();

      final updatedCenter = originalCenter.value!.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNo: phoneController.text.trim(),
        website: websiteController.text.trim(),
        centerLocation: selectedLocation.value!,
        image: finalImageName,
        openingHours: openingHoursMap,
        acceptedMaterials: selectedMaterials.toList(),
      );

      print('Updating center in Firestore...');
      await _centerRepo.updateCenter(updatedCenter);
      print('Center updated successfully');

      isLoading.value = false;

      FAdminLoaders.successSnackBar(
        title: 'Center Updated',
        message: 'Recycling center updated successfully',
      );

      // Return to management screen
      Get.back();
    } catch (e) {
      isLoading.value = false;
      print('=== CENTER UPDATE ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=== END ERROR ===');

      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update center: ${e.toString()}',
      );
    }
  }

  Future<String?> getImageUrl(String fileNameOrUrl) async {
    try {
      print('🖼️ getImageUrl called with: "$fileNameOrUrl"');

      if (fileNameOrUrl.isEmpty) {
        print('🖼️ File name/URL is empty');
        return null;
      }

      String fileName = fileNameOrUrl;

      // 如果是URL，提取纯文件名
      if (fileNameOrUrl.startsWith('http')) {
        print('🖼️ Extracting filename from URL');
        try {
          final uri = Uri.parse(fileNameOrUrl);
          final pathSegments = uri.pathSegments;

          // 查找实际的文件名（包含扩展名的部分）
          for (final segment in pathSegments) {
            if (segment.contains('.webp') || segment.contains('.jpg') || segment.contains('.png') || segment.contains('.jpeg')) {
              fileName = segment;
              print('🖼️ ✅ Extracted filename: $fileName');
              break;
            }
          }

          // 后备方案：使用最后一个路径段
          if (fileName == fileNameOrUrl && pathSegments.isNotEmpty) {
            fileName = pathSegments.last;
            print('🖼️ Using last path segment: $fileName');
          }
        } catch (e) {
          print('🖼️ Error extracting filename from URL: $e');
          // 如果提取失败，直接返回URL
          return fileNameOrUrl;
        }
      }

      print('🖼️ Getting URL for filename: "$fileName"');
      final url = await _centerRepo.getCenterImageUrl(fileName);
      print('🖼️ ✅ Successfully retrieved image URL: $url');
      return url;

    } catch (e) {
      print('🖼️ ❌ Error in getImageUrl: $e');

      // 如果获取失败，但原始输入是URL，直接返回URL
      if (fileNameOrUrl.startsWith('http')) {
        print('🖼️ Falling back to original URL');
        return fileNameOrUrl;
      }

      return null;
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