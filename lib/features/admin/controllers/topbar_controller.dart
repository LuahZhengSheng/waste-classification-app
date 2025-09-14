import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AdminTopBarController extends GetxController {
  // Observable variables
  final RxBool isDarkMode = false.obs;
  final RxBool showProfileDropdown = false.obs;
  final RxString currentPageTitle = 'Dashboard'.obs;

  // Admin info
  final RxString adminName = 'John Doe'.obs;
  final RxString adminPosition = 'Administrator'.obs;
  final RxString adminAvatar = ''.obs; // URL or empty for default

  // Profile dropdown items
  final List<DropdownMenuItem> profileMenuItems = [
    DropdownMenuItem(
      icon: Icons.person_outline,
      title: 'Profile',
      action: 'profile',
    ),
    DropdownMenuItem(
      icon: Icons.settings_outlined,
      title: 'Settings',
      action: 'settings',
    ),
    DropdownMenuItem(
      icon: Icons.help_outline,
      title: 'Help & Support',
      action: 'help',
    ),
    DropdownMenuItem(
      icon: Icons.logout_outlined,
      title: 'Logout',
      action: 'logout',
      isDestructive: true,
    ),
  ];

  // Methods
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    // Implement theme switching logic here
    // Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }

  void toggleProfileDropdown() {
    showProfileDropdown.value = !showProfileDropdown.value;
  }

  void closeProfileDropdown() {
    showProfileDropdown.value = false;
  }

  void onProfileMenuItemTap(String action) {
    closeProfileDropdown();

    switch (action) {
      case 'profile':
      // Navigate to profile
        break;
      case 'settings':
      // Navigate to settings
        break;
      case 'help':
      // Navigate to help
        break;
      case 'logout':
      // Implement logout logic
        _handleLogout();
        break;
    }
  }

  void _handleLogout() {
    // Implement logout logic
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      onConfirm: () {
        // Perform logout
        Get.back(); // Close dialog
        // Navigate to login page
      },
    );
  }

  void updatePageTitle(String title) {
    currentPageTitle.value = title;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize theme state
    isDarkMode.value = Get.isDarkMode;
  }
}

class DropdownMenuItem {
  final IconData icon;
  final String title;
  final String action;
  final bool isDestructive;

  DropdownMenuItem({
    required this.icon,
    required this.title,
    required this.action,
    this.isDestructive = false,
  });
}