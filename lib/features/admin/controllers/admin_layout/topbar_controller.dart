import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/admin/models/admin_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import '../../screens/admin_layout/admin_profile_dialog.dart';
import '../../screens/admin_layout/change_password_dialog.dart';
import '../../screens/authentication/admin_logout.dart';

class AdminTopBarController extends GetxController {
  static AdminTopBarController get instance => Get.find();

  final UserRepository _userRepository = Get.find<UserRepository>();
  final AuthenticationRepository _authRepository = Get.find<AuthenticationRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    try {
      isLoading.value = true;
      final userId = _authRepository.authUser?.uid;

      if (userId != null) {
        _userRepository.getUserDetailsStream(userId).listen((user) {
          currentUser.value = user;
          isLoading.value = false;
        });
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      print('Error loading current user: $e');
      isLoading.value = false;
    }
  }

  String getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Super Admin';
      case 'community_manager':
        return 'Community Manager';
      case 'event_manager':
        return 'Event Manager';
      case 'reward_manager':
        return 'Reward Manager';
      default:
        return role;
    }
  }

  List<PopupMenuEntry<String>> getMenuItems(bool dark) {
    final user = currentUser.value;
    if (user == null) return [];

    final items = <PopupMenuEntry<String>>[];

    // Profile item (always shown)
    items.add(
      PopupMenuItem<String>(
        value: 'profile',
        child: Row(
          children: [
            Icon(
              Iconsax.user,
              size: 18,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
            const SizedBox(width: FSizes.sm),
            Text(
              'Profile',
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
          ],
        ),
      ),
    );

    // Change Password (only for managers)
    if (user.role != 'admin') {
      items.add(
        PopupMenuItem<String>(
          value: 'change_password',
          child: Row(
            children: [
              Icon(
                Iconsax.lock,
                size: 18,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Change Password',
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Divider
    items.add(const PopupMenuDivider());

    // Logout
    items.add(
      PopupMenuItem<String>(
        value: 'logout',
        child: Row(
          children: [
            Icon(
              Iconsax.logout,
              size: 18,
              color: dark ? FColors.adminDarkError : FColors.adminLightError,
            ),
            const SizedBox(width: FSizes.sm),
            Text(
              'Logout',
              style: TextStyle(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
              ),
            ),
          ],
        ),
      ),
    );

    return items;
  }

  void onMenuItemSelected(String value, BuildContext context) {
    switch (value) {
      case 'profile':
        _showProfile();
        break;
      case 'change_password':
        _showChangePassword();
        break;
      case 'logout':
        _logout();
        break;
    }
  }

  void _showProfile() {
    final user = currentUser.value;
    if (user == null) return;

    Get.dialog(
      AdminProfileDialog(user: user),
      barrierDismissible: false,
    );
  }

  void _showChangePassword() {
    Get.dialog(
      const ChangePasswordDialog(),
      barrierDismissible: false,
    );
  }

  void _logout() {
    Get.dialog(
      const LogoutConfirmationDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> refreshUserData() async {
    await loadCurrentUser();
  }
}