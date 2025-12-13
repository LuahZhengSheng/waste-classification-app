import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/recycling_center/models/recycle_activity_model.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/recycling_center/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/services/qr_code/jwt_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/activity_image.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../waste_classification/models/waste_category_model.dart';
import '../screens/add_recyling_activity/widgets/submission_success.dart';

class StaffHomeController extends GetxController {
  static StaffHomeController get instance => Get.find();

  // Repositories
  final UserRepository _userRepository = Get.put(UserRepository());
  final RecyclingActivityRepository _activityRepository = Get.put(RecyclingActivityRepository());
  final WasteCategoryRepository _wasteCategoryRepository = Get.put(WasteCategoryRepository());
  final JWTService _jwtService = Get.put(JWTService());

  // Observables
  final RxString userId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isValidUser = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxInt userRewardPoints = 0.obs;
  final RxString userProfileImage = ''.obs;
  final Rx<UserSearchMethod> searchMethod = UserSearchMethod.username.obs;

  // Recycling activities with their images
  final RxList<ActivityWithImage> currentActivitiesWithImages = <ActivityWithImage>[].obs;
  final RxList<WasteCategory> wasteCategories = <WasteCategory>[].obs;

  // Form controllers
  final TextEditingController userIdController = TextEditingController();
  final GlobalKey<FormState> userIdFormKey = GlobalKey<FormState>();

  // Staff info
  final RxString staffId = ''.obs;

  // Computed properties for compatibility
  List<RecyclingActivity> get currentActivities =>
      currentActivitiesWithImages.map((e) => e.activity).toList();

  @override
  void onInit() {
    super.onInit();
    _initializeStaffInfo();
    loadWasteCategories();
  }

  @override
  void onClose() {
    userIdController.dispose();
    super.onClose();
  }

  void _initializeStaffInfo() {
    final authUser = AuthenticationRepository.instance.authUser;
    if (authUser != null) {
      staffId.value = authUser.uid;
    }
  }

  Future<void> loadWasteCategories() async {
    try {
      isLoading.value = true;
      final categories = await _wasteCategoryRepository.getRecyclableCategories();
      wasteCategories.value = categories;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load waste categories: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUser() async {
    if (!userIdFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      searchMethod.value = UserSearchMethod.username;

      final username = userIdController.text.trim();
      final user = await _userRepository.getUserByUsername(username);

      if (user != null && user.userId.isNotEmpty) {
        await _setUserInfo(
          user.userId,
          user.username,
          user.email,
          user.rewardPoint,
          user.profileImg,
        );

        FLoaders.successSnackBar(
          title: 'Success',
          message: 'User found! You can now add recycling activities.',
        );
      } else {
        isValidUser.value = false;
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not found. Please check the username.',
        );
      }
    } catch (e) {
      isValidUser.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to search user: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateAndSetUserFromQR(String scannedResult) async {
    try {
      isLoading.value = true;
      searchMethod.value = UserSearchMethod.qrCode;

      String userId;

      if (scannedResult.length == 28) {
        userId = scannedResult;
      } else {
        final extractedUserId = _jwtService.validateQRToken(scannedResult);
        if (extractedUserId != null) {
          userId = extractedUserId;
        } else {
          throw Exception('Invalid QR code format');
        }
      }

      final user = await _userRepository.fetchOtherUserDetails(userId);

      if (user.userId.isNotEmpty) {
        await _setUserInfo(
          user.userId,
          user.username,
          user.email,
          user.rewardPoint,
          user.profileImg,
        );

        FLoaders.customToast(
          message: 'QR scan successful! User verified.',
        );
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not found in database.',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to process QR code: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _setUserInfo(
      String id,
      String name,
      String email,
      int points,
      String? profileImg,
      ) async {
    userId.value = id;
    userName.value = name;
    userEmail.value = email;
    userRewardPoints.value = points;
    userProfileImage.value = profileImg ?? '';
    isValidUser.value = true;
    currentActivitiesWithImages.clear();
  }

  Future<String?> getUserProfileImageUrl() async {
    if (userProfileImage.value.isEmpty) return null;

    try {
      final cachedUrl = _userRepository.getCachedProfileImageUrl(userProfileImage.value);
      if (cachedUrl != null) {
        return cachedUrl;
      }
      return await _userRepository.getProfileImageUrl(userProfileImage.value);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addRecyclingActivity(RecyclingActivity activity, File? imageFile) async {
    try {
      currentActivitiesWithImages.add(
          ActivityWithImage(activity: activity, imageFile: imageFile)
      );
      return true;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to add activity: $e',
      );
      return false;
    }
  }

  Future<bool> editRecyclingActivity(int index, RecyclingActivity activity, File? imageFile) async {
    try {
      print('🔧 Editing activity at index: $index');
      print('  Activity ID: ${activity.activityId}');
      print('  Support Image: ${activity.supportImage}');
      print('  Has new image file: ${imageFile != null}');

      if (index >= 0 && index < currentActivitiesWithImages.length) {
        final oldActivity = currentActivitiesWithImages[index];

        print('  Old activity support image: ${oldActivity.activity.supportImage}');

        // 🆕 If there's a new image, mark the old one for potential deletion
        // But don't delete yet - only delete when submitting or if user cancels

        currentActivitiesWithImages[index] = ActivityWithImage(
          activity: activity,
          imageFile: imageFile,
        );

        print('✅ Activity updated successfully');
        print('  New support image: ${activity.supportImage}');

        return true;
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Invalid activity index',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error editing activity: $e');
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to edit activity: $e',
      );
      return false;
    }
  }

  Future<bool> deleteRecyclingActivity(int index) async {
    try {
      if (index >= 0 && index < currentActivitiesWithImages.length) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Activity'),
            content: const Text('Are you sure you want to delete this activity?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          currentActivitiesWithImages.removeAt(index);
          FLoaders.warningSnackBar(
            title: 'Deleted',
            message: 'Recycling activity removed!',
          );
          return true;
        }
        return false;
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Invalid activity index',
        );
        return false;
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity: $e',
      );
      return false;
    }
  }

  Future<void> submitAllActivities() async {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    // Show modern confirmation dialog
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: dark ? FColors.darkSurface : FColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FColors.staffLightPrimary,
                      FColors.staffLightAccent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row( // ✅ 改为 Row
                  children: [
                    // Icon
                    Container(
                      width: 56, // ✅ 稍微缩小一点
                      height: 56,
                      decoration: BoxDecoration(
                        color: FColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.document_upload,
                        size: 28,
                        color: FColors.white,
                      ),
                    ),
                    const SizedBox(width: 16), // ✅ 横向间距
                    const Expanded( // ✅ 让文字占据剩余空间
                      child: Text(
                        'Submit Activities',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: FColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Summary cards
                    _buildSummaryCard(
                      icon: Iconsax.clipboard_text,
                      label: 'Activities',
                      value: '${currentActivitiesWithImages.length}',
                      color: FColors.staffLightInfo,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      icon: Iconsax.weight,
                      label: 'Total Weight',
                      value: '${totalSessionWeight.toStringAsFixed(1)} kg',
                      color: FColors.staffLightSecondary,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      icon: Iconsax.coin_1,
                      label: 'Total Points',
                      value: '$totalSessionPoints pts',
                      color: FColors.staffLightWarning,
                      dark: dark,
                    ),
                    const SizedBox(height: 20),

                    // Warning message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            size: 20,
                            color: FColors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This action cannot be undone',
                              style: TextStyle(
                                fontSize: 13,
                                color: dark ? FColors.darkText : FColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: dark
                                ? FColors.staffDarkBorder
                                : FColors.staffLightBorder,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: dark
                                ? FColors.staffDarkText
                                : FColors.staffLightText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FColors.staffLightSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    try {
      // Store values before clearing
      final submittedActivitiesCount = currentActivitiesWithImages.length;
      final submittedWeight = totalSessionWeight;
      final submittedPoints = totalSessionPoints;
      final submittedUserName = userName.value;

      FFullScreenLoader.openLoadingDialog(
        'Submitting activities...',
        'assets/images/animations/loader-animation.json',
      );

      // Submit through repository with images
      await _activityRepository.submitActivitiesWithImages(
        currentActivitiesWithImages.toList(),
        userId.value,
      );

      FFullScreenLoader.stopLoading();

      // Reset form
      resetForm();

      // Navigate to success screen with data
      Get.off(() => SubmissionSuccessScreen(
        activitiesCount: submittedActivitiesCount,
        totalWeight: submittedWeight,
        totalPoints: submittedPoints,
        userName: submittedUserName,
      ));
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to submit activities: $e',
      );
    }
  }

// Helper widget for summary cards
  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.darkText : FColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void resetForm() {
    userIdController.clear();
    userId.value = '';
    userName.value = '';
    userEmail.value = '';
    userRewardPoints.value = 0;
    userProfileImage.value = '';
    isValidUser.value = false;
    currentActivitiesWithImages.clear();
    searchMethod.value = UserSearchMethod.username;
  }

  int get totalSessionPoints {
    return currentActivitiesWithImages.fold(
        0,
            (sum, item) => sum + item.activity.pointsEarned
    );
  }

  double get totalSessionWeight {
    return currentActivitiesWithImages.fold(
        0.0,
            (sum, item) => sum + item.activity.weight
    );
  }

  String? validateUserId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter username';
    }
    return null;
  }
}