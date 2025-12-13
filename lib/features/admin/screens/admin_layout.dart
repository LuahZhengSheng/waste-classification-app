import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/admin/screens/recycling_center_management/recycling_center_management/recycling_center_management.dart';
import 'package:fyp/features/admin/screens/user_management/user_management.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/popups/loaders.dart';
import 'achievement_management/achievement_management/achievement_management.dart';
import 'admin_layout/topbar.dart';
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

// Page Classes
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

// Sidebar Menu
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSelectedRoute(currentRoute);
    });

    return Obx(() {
      // Get menu items based on role
      final menuItems = controller.getMenuItemsForRole();

      return MouseRegion(
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

              Divider(
                color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                height: 1,
                thickness: 1,
              ),

              // Menu Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
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
                                Icon(
                                  _getIconData(item.icon),
                                  color: isSelected
                                      ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                                      : (dark ? FColors.adminDarkIcon : FColors.adminLightIcon),
                                  size: 20,
                                ),
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

              // Logout Button
              if (controller.shouldShowExpanded && controller.currentWidth > 200) ...[
                Divider(
                  color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                  height: 1,
                  thickness: 1,
                ),
                Container(
                  padding: const EdgeInsets.all(FSizes.md),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => controller.logout(),
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
      );
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard':
        return Iconsax.element_4; // Dashboard 仪表盘
      case 'user_management':
        return Iconsax.profile_2user; // 用户管理
      case 'manager_management':
        return Iconsax.personalcard; // 管理员管理
      case 'center_staff':
        return Iconsax.user_tag; // 中心员工管理
      case 'event':
        return Iconsax.calendar_2; // 活动管理
      case 'reward':
        return Iconsax.gift; // 奖励管理
      case 'community':
        return Iconsax.messages_2; // 社区管理
      case 'achievement':
        return Iconsax.medal_star; // 成就管理
      case 'partner_center':
        return Iconsax.building_4; // 合作伙伴中心
      default:
        return Iconsax.element_4;
    }
  }
}

class AdminSidebarMenuController extends GetxController {
  final RxBool isExpanded = false.obs;
  final RxBool isPinned = false.obs;
  final RxBool isHovered = false.obs;
  final RxString selectedRoute = 'dashboard'.obs;
  final RxDouble currentWidth = 70.0.obs;
  final RxString currentUserRole = 'admin'.obs;

  final UserRepository _userRepository = Get.put(UserRepository());

  bool get shouldShowExpanded => isPinned.value || isHovered.value;

  @override
  void onInit() {
    super.onInit();
    isExpanded.value = isPinned.value;
    updateCurrentWidth();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final user = await _userRepository.fetchUserDetails();
      currentUserRole.value = user.role;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      }
    }
  }

  List<SidebarItem> getMenuItemsForRole() {
    switch (currentUserRole.value) {
      case 'community_manager':
        return [
          SidebarItem(icon: 'dashboard', title: 'Dashboard', route: 'dashboard'),
          SidebarItem(icon: 'community', title: 'Community Management', route: 'community_management'),
        ];
      case 'event_manager':
        return [
          SidebarItem(icon: 'dashboard', title: 'Dashboard', route: 'dashboard'),
          SidebarItem(icon: 'event', title: 'Event Management', route: 'event_management'),
        ];
      case 'reward_manager':
        return [
          SidebarItem(icon: 'dashboard', title: 'Dashboard', route: 'dashboard'),
          SidebarItem(icon: 'reward', title: 'Reward Management', route: 'reward_management'),
        ];
      case 'admin':
        return [
          SidebarItem(icon: 'dashboard', title: 'Dashboard', route: 'dashboard'),
          SidebarItem(icon: 'user_management', title: 'User Management', route: 'user_management'),
          SidebarItem(icon: 'manager_management', title: 'Manager Management', route: 'manager_management'),
          SidebarItem(icon: 'center_staff', title: 'Center Staff Management', route: 'center_staff_management'),
          SidebarItem(icon: 'event', title: 'Event Management', route: 'event_management'),
          SidebarItem(icon: 'reward', title: 'Reward Management', route: 'reward_management'),
          SidebarItem(icon: 'community', title: 'Community Management', route: 'community_management'),
          SidebarItem(icon: 'achievement', title: 'Achievement Management', route: 'achievement_management'),
          SidebarItem(icon: 'partner_center', title: 'Partner Recycling Centers', route: 'partner_centers'),
        ];
      default:
        return [
          SidebarItem(icon: 'dashboard', title: 'Dashboard', route: 'dashboard'),
        ];
    }
  }


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
    // Check if user has access to this route
    if (!_hasAccessToRoute(route)) {
      FLoaders.warningSnackBar(
        title: 'Access Denied',
        message: 'You do not have permission to access this page',
      );
      return;
    }

    selectedRoute.value = route;

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

  bool _hasAccessToRoute(String route) {
    final menuItems = getMenuItemsForRole();
    return menuItems.any((item) => item.route == route);
  }

  Future<void> logout() async {
    try {
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

  Future<void> _performLogout() async {
    try {
      FLoaders.showLoading('Logging out...');

      await _clearLocalData();

      final authRepo = AuthenticationRepository.instance;
      await authRepo.logout();

      Get.deleteAll(force: true);

      FLoaders.stopLoading();

      Get.offAll(() => const AdminLoginScreen());

      FLoaders.successSnackBar(title: 'Logged out successfully');
    } catch (e) {
      FLoaders.stopLoading();
      if (kDebugMode) {
        print('Logout error: $e');
      }

      Get.offAll(() => const AdminLoginScreen());
    }
  }

  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing local data: $e');
      }
    }
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