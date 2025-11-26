import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/admin/screens/recycling_center_management/recycling_center_management/recycling_center_management.dart';
import 'package:fyp/features/admin/screens/topbar.dart';
import 'package:fyp/features/admin/screens/user_management/user_management.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../recycling_center/screens/profile/staff_profile.dart';
import '../../recycling_center/screens/staff_home/staff_home.dart';
import 'achievement_management/achievement_management/achievement_management.dart';
import 'authentication/admin_login.dart';
import 'authentication/admin_logout.dart';
import 'center_staff_management/center_staff_management.dart';
import 'community_management/community_management/community_management.dart';
import 'dashboard/dashboard.dart';
import 'event_management/event_management/event_management.dart';
import 'manager_management/manager_management.dart';
import 'reward_management/reward_management/reward_management.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Row(
        children: [
          // Sidebar
          AdminSidebarMenu(currentRoute: currentRoute),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                AdminTopBar(title: title),

                // Page Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Dashboard',
      currentRoute: 'dashboard',
      child: AdminDashboardScreen(),
    );
  }
}

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'User Management',
      currentRoute: 'user_management',
      child: UserManagementScreen(),
    );
  }
}

class ManagerManagementPage extends StatelessWidget {
  const ManagerManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Manager Management',
      currentRoute: 'manager_management',
      child: ManagerManagementScreen(),
    );
  }
}

class CenterStaffManagementPage extends StatelessWidget {
  const CenterStaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Recycling Center Staff Management',
      currentRoute: 'center_staff_management',
      child: StaffManagementScreen(),
    );
  }
}

class EventManagementPage extends StatelessWidget {
  const EventManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Event Management',
      currentRoute: 'event_management',
      child: EventManagementScreen(),
    );
  }
}

class CommunityManagementPage extends StatelessWidget {
  const CommunityManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Community Management',
      currentRoute: 'community_management',
      child: CommunityManagementScreen(),
    );
  }
}

class RewardManagementPage extends StatelessWidget {
  const RewardManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Reward Management',
      currentRoute: 'reward_management',
      child: RewardManagementScreen(),
    );
  }
}

class PartnerCenterManagementPage extends StatelessWidget {
  const PartnerCenterManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Partner Recycling Center Management',
      currentRoute: 'partner_centers',
      child: PartnerCenterManagementScreen(),
    );
  }
}

class AchievementManagementPage extends StatelessWidget {
  const AchievementManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Achievement Management',
      currentRoute: 'achievement_management',
      child: AchievementManagementScreen(),
    );
  }
}

class AdminSidebarMenu extends StatelessWidget {
  final String currentRoute;

  const AdminSidebarMenu({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSidebarMenuController());
    final dark = FHelperFunctions.isDarkMode(context);

    // 在构建时更新当前选中的路由
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSelectedRoute(currentRoute);
    });

    return Obx(() => MouseRegion(
      onEnter: (_) => controller.onHover(true),
      onExit: (_) => controller.onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: controller.shouldShowExpanded ? 280 : 70,
        height: double.infinity,
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          border: Border(
            right: BorderSide(
              color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: FColors.adminShadow,
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Logo and Pin Button
            Container(
              height: 70,
              padding: const EdgeInsets.all(FSizes.md),
              child: Row(
                children: [
                  // Logo - 始终显示
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.code,
                      color: FColors.white,
                      size: 25,
                    ),
                  ),

                  // 只在实际有足够空间时显示文字和Pin按钮
                  if (controller.shouldShowExpanded && controller.currentWidth > 270) ...[
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    GestureDetector(
                      onTap: controller.togglePin,
                      child: Icon(
                        controller.isPinned.value ? Iconsax.lock : Iconsax.unlock,
                        size: 20,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Divider
            Divider(
              color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
              height: 1,
              thickness: 1,
            ),

            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
                itemCount: controller.menuItems.length,
                itemBuilder: (context, index) {
                  final item = controller.menuItems[index];
                  final isSelected = controller.selectedRoute.value == item.route;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: 2),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => controller.selectRoute(item.route),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.all(FSizes.sm),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (dark ? FColors.adminDarkSelected : FColors.adminLightSelected)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Icon(
                                _getIconData(item.icon),
                                color: isSelected
                                    ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                                    : (dark ? FColors.adminDarkIcon : FColors.adminLightIcon),
                                size: 20,
                              ),

                              // Title (only show when expanded and has enough space)
                              if (controller.shouldShowExpanded && controller.currentWidth > 200) ...[
                                const SizedBox(width: FSizes.md),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isSelected
                                          ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                                          : (dark ? FColors.adminDarkText : FColors.adminLightText),
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom section - 只在展开且有足够空间时显示
            if (controller.shouldShowExpanded && controller.currentWidth > 200) ...[
              Divider(
                color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                height: 1,
                thickness: 1,
              ),

              // Logout Button
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => controller.logout(), // 调用登出方法
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.logout,
                            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: FSizes.md),
                          Expanded(
                            child: Text(
                              'Logout',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard':
        return Iconsax.element_4;
      case 'people':
        return Iconsax.people;
      case 'event':
        return Iconsax.calendar;
      case 'category':
        return Iconsax.category;
      case 'analytics':
        return Iconsax.chart_2;
      case 'settings':
        return Iconsax.setting_2;
      default:
        return Iconsax.element_4;
    }
  }
}

class AdminSidebarMenuController extends GetxController {
  // Observable variables for sidebar state
  final RxBool isExpanded = false.obs;
  final RxBool isPinned = false.obs;
  final RxBool isHovered = false.obs;
  final RxString selectedRoute = 'dashboard'.obs;
  final RxDouble currentWidth = 70.0.obs;

  // Sidebar menu items - 更新路由以匹配实际的页面类
  final List<SidebarItem> menuItems = [
    SidebarItem(
      icon: 'dashboard',
      title: 'Dashboard',
      route: 'dashboard',
    ),
    SidebarItem(
      icon: 'people',
      title: 'User Management',
      route: 'user_management',
    ),
    SidebarItem(
      icon: 'people',
      title: 'Manager Management',
      route: 'manager_management',
    ),
    SidebarItem(
      icon: 'people',
      title: 'Center Staff Management',
      route: 'center_staff_management',
    ),
    SidebarItem(
      icon: 'event',
      title: 'Event Management',
      route: 'event_management',
    ),
    SidebarItem(
      icon: 'category',
      title: 'Reward Management',
      route: 'reward_management',
    ),
    SidebarItem(
      icon: 'analytics',
      title: 'Community Management',
      route: 'community_management',
    ),
    SidebarItem(
      icon: 'settings',
      title: 'Achievement Management',
      route: 'achievement_management',
    ),
    SidebarItem(
      icon: 'settings',
      title: 'Partner Recycling Centers',
      route: 'partner_centers',
    ),
  ];

  // Computed property for sidebar visibility
  bool get shouldShowExpanded => isPinned.value || isHovered.value;

  // Methods
  void onHover(bool hovering) {
    isHovered.value = hovering;
    if (!isPinned.value) {
      isExpanded.value = hovering;
    }
    updateCurrentWidth();
  }

  void togglePin() {
    isPinned.value = !isPinned.value;
    isExpanded.value = isPinned.value;
    updateCurrentWidth();
  }

  void updateCurrentWidth() {
    Future.delayed(const Duration(milliseconds: 50), () {
      currentWidth.value = shouldShowExpanded ? 300 : 70;
    });
  }

  void updateSelectedRoute(String route) {
    selectedRoute.value = route;
  }

  void selectRoute(String route) {
    selectedRoute.value = route;

    // 使用 Get.to() 而不是 Get.offAll() 来保持控制器状态
    switch (route) {
      case 'dashboard':
        Get.to(() => const AdminDashboard());
        break;
      case 'user_management':
        Get.to(() => const UserManagementPage());
        break;
      case 'manager_management':
        Get.to(() => const ManagerManagementPage());
        break;
      case 'center_staff_management':
        Get.to(() => const CenterStaffManagementPage());
        break;
      case 'event_management':
        Get.to(() => const EventManagementPage());
        break;
      case 'reward_management':
        Get.to(() => const RewardManagementPage());
        break;
      case 'community_management':
        Get.to(() => const CommunityManagementPage());
        break;
      case 'achievement_management':
        Get.to(() => const AchievementManagementPage());
        break;
      case 'partner_centers':
        Get.to(() => const PartnerCenterManagementPage());
        break;
      default:
        Get.to(() => const AdminDashboard());
    }
  }

  /// Logout method
  Future<void> logout() async {
    try {
      // Show custom confirmation dialog
      final result = await Get.dialog(
        const LogoutConfirmationDialog(),
        barrierDismissible: false,
      );

      if (result == true) {
        await _performLogout();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  /// Perform the actual logout
  Future<void> _performLogout() async {
    try {
      // Show loading
      FLoaders.showLoading('Logging out...');

      // Clear any local storage or cache
      await _clearLocalData();

      // Sign out from Firebase Authentication
      final authRepo = AuthenticationRepository.instance;
      await authRepo.logout();

      // Clear all GetX controllers
      Get.deleteAll(force: true);

      FLoaders.stopLoading();

      // Navigate to login screen
      Get.offAll(() => const AdminLoginScreen());

      // Show success message
      FLoaders.successSnackBar(title: 'Logged out successfully');

    } catch (e) {
      FLoaders.stopLoading();
      if (kDebugMode) {
        print('Logout error: $e');
      }

      // Even if there's an error, try to navigate to login
      Get.offAll(() => const AdminLoginScreen());
    }
  }

  /// Clear local data
  Future<void> _clearLocalData() async {
    try {
      // Clear any shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing local data: $e');
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    isExpanded.value = isPinned.value;
    updateCurrentWidth();
  }
}

class SidebarItem {
  final String icon;
  final String title;
  final String route;

  SidebarItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}

// 在应用的根级别初始化控制器
class AdminAppController extends GetxController {
  static AdminAppController get instance => Get.find();

  @override
  void onInit() {
    super.onInit();
    // 确保侧边栏控制器被初始化
    Get.put(AdminSidebarMenuController(), permanent: true);
  }
}

// Staff Navigation Menu (保持不变)
class StaffNavigationMenu extends StatelessWidget {
  const StaffNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            controller.selectedIndex.value = index;
          },
          backgroundColor: dark ? FColors.black : FColors.white,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                fontWeight: FontWeight.w600,
              );
            }
            return TextStyle(
              color: FColors.darkGrey,
              fontWeight: FontWeight.normal,
            );
          }),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Iconsax.home,
                color: controller.selectedIndex.value == 0
                    ? dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary
                    : FColors.darkGrey,
              ),
              label: 'Home',
              selectedIcon: Icon(
                Iconsax.home,
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
              ),
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.user,
                color: controller.selectedIndex.value == 1
                    ? dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary
                    : FColors.darkGrey,
              ),
              label: 'Profile',
              selectedIcon: Icon(
                Iconsax.user,
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final screens = [
    const StaffHomeScreen(),
    const StaffProfileScreen(),
  ];
}