import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../personalization/models/recycle_activity_model.dart';
import '../models/waste_category_model.dart';

class StaffHomeController extends GetxController {
  static StaffHomeController get instance => Get.find();

  // Observables
  final RxString userId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isValidUser = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxInt userRewardPoints = 0.obs;

  // Recycling activities for current session
  final RxList<RecyclingActivity> currentActivities = <RecyclingActivity>[].obs;
  final RxList<WasteCategory> wasteCategories = <WasteCategory>[].obs;

  // Form controllers
  final TextEditingController userIdController = TextEditingController();
  final GlobalKey<FormState> userIdFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadWasteCategories();
  }

  @override
  void onClose() {
    userIdController.dispose();
    super.onClose();
  }

  /// Load waste categories from database
  void loadWasteCategories() async {
    try {
      isLoading.value = true;

      // Mock data - replace with actual database call
      wasteCategories.value = [
        WasteCategory(
          categoryId: '1',
          name: 'Plastic',
          description: 'Plastic bottles, containers, bags',
          disposalMethod: 'Recycling',
          icon: Icons.recycling,
          color: Colors.blue,
          basePoints: 5.0,
          examples: ['Bottles', 'Containers', 'Bags'],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '2',
          name: 'Paper',
          description: 'Newspapers, magazines, cardboard',
          disposalMethod: 'Recycling',
          icon: Icons.article,
          color: Colors.brown,
          basePoints: 3.0,
          examples: ['Newspapers', 'Magazines', 'Cardboard'],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        WasteCategory(
          categoryId: '3',
          name: 'Electronics',
          description: 'Old phones, computers, batteries',
          disposalMethod: 'Special handling',
          icon: Icons.devices,
          color: Colors.purple,
          basePoints: 15.0,
          examples: ['Phones', 'Computers', 'Batteries'],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

    } catch (e) {
      Get.snackbar('Error', 'Failed to load waste categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate and search for user by ID
  void searchUser() async {
    if (!userIdFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Mock user validation - replace with actual database call
      await Future.delayed(const Duration(seconds: 1));

      final String inputUserId = userIdController.text.trim();

      // Mock validation logic
      if (inputUserId.isNotEmpty && inputUserId.length >= 3) {
        userId.value = inputUserId;
        userName.value = 'John Doe'; // Mock data
        userEmail.value = 'john.doe@email.com'; // Mock data
        userRewardPoints.value = 1250; // Mock data
        isValidUser.value = true;

        // Clear previous activities
        currentActivities.clear();

        Get.snackbar(
          'Success',
          'User found! You can now add recycling activities.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        isValidUser.value = false;
        Get.snackbar(
          'Error',
          'User not found. Please check the User ID.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      isValidUser.value = false;
      Get.snackbar('Error', 'Failed to search user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new recycling activity to current session
  void addRecyclingActivity(RecyclingActivity activity) {
    currentActivities.add(activity);
    Get.back(); // Return to activities list
    Get.snackbar(
      'Added',
      'Recycling activity added successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Edit existing recycling activity
  void editRecyclingActivity(int index, RecyclingActivity activity) {
    if (index >= 0 && index < currentActivities.length) {
      currentActivities[index] = activity;
      Get.back(); // Return to activities list
      Get.snackbar(
        'Updated',
        'Recycling activity updated successfully!',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  /// Delete recycling activity from current session
  void deleteRecyclingActivity(int index) {
    if (index >= 0 && index < currentActivities.length) {
      currentActivities.removeAt(index);
      Get.snackbar(
        'Deleted',
        'Recycling activity removed!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// Submit all activities to database
  void submitAllActivities() async {
    if (currentActivities.isEmpty) {
      Get.snackbar('Error', 'No activities to submit!');
      return;
    }

    try {
      isLoading.value = true;

      // Mock database submission - replace with actual database calls
      await Future.delayed(const Duration(seconds: 2));

      // Calculate total points
      int totalPoints = currentActivities.fold(0, (sum, activity) => sum + activity.pointsEarned);

      // Mock submission success
      Get.snackbar(
        'Success',
        'All activities submitted! Total points awarded: $totalPoints',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Reset form
      resetForm();

    } catch (e) {
      Get.snackbar('Error', 'Failed to submit activities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset form and clear data
  void resetForm() {
    userIdController.clear();
    userId.value = '';
    userName.value = '';
    userEmail.value = '';
    userRewardPoints.value = 0;
    isValidUser.value = false;
    currentActivities.clear();
  }

  /// Scan QR Code (placeholder)
  void scanQRCode() async {
    try {
      // Mock QR code scanning - replace with actual QR scanner
      await Future.delayed(const Duration(seconds: 1));

      // Mock scanned user ID
      String scannedUserId = 'USER123';
      userIdController.text = scannedUserId;

      Get.snackbar(
        'QR Scanned',
        'User ID captured from QR code',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      // Automatically search for user
      searchUser();

    } catch (e) {
      Get.snackbar('Error', 'Failed to scan QR code: $e');
    }
  }

  /// Get total points for current session
  int get totalSessionPoints {
    return currentActivities.fold(0, (sum, activity) => sum + activity.pointsEarned);
  }

  /// Get total weight for current session
  double get totalSessionWeight {
    return currentActivities.fold(0.0, (sum, activity) => sum + activity.weight);
  }

  /// Validate user ID input
  String? validateUserId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter User ID';
    }
    if (value.trim().length < 3) {
      return 'User ID must be at least 3 characters';
    }
    return null;
  }
}