import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class AdminSidebarMenu extends StatelessWidget {
  const AdminSidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSidebarMenuController>();
    final dark = FHelperFunctions.isDarkMode(context);

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

                  // 只在实际有足够空间时显示文字和Pin按钮 (关键修复)
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

                    // IconButton(
                    //   onPressed: controller.togglePin,
                    //   icon: Icon(
                    //     controller.isPinned.value ? Iconsax.lock : Iconsax.unlock,
                    //     size: 20,
                    //   ),
                    //   color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    //   // tooltip: controller.isPinned.value ? 'Unpin Sidebar' : 'Pin Sidebar',
                    // ),
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

              Container(
                padding: const EdgeInsets.all(FSizes.md),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      // Add logout logic here
                    },
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
  final RxDouble currentWidth = 70.0.obs; // 添加当前宽度追踪

  // Sidebar menu items
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
      icon: 'event',
      title: 'Event Management',
      route: 'event_management',
    ),
    SidebarItem(
      icon: 'category',
      title: 'Category Management',
      route: 'category_management',
    ),
    SidebarItem(
      icon: 'analytics',
      title: 'Analytics',
      route: 'analytics',
    ),
    SidebarItem(
      icon: 'settings',
      title: 'Settings',
      route: 'settings',
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
    // 更新当前宽度
    updateCurrentWidth();
  }

  void togglePin() {
    isPinned.value = !isPinned.value;
    isExpanded.value = isPinned.value;
    updateCurrentWidth();
  }

  void updateCurrentWidth() {
    // 使用延迟来匹配动画时间
    Future.delayed(const Duration(milliseconds: 50), () {
      currentWidth.value = shouldShowExpanded ? 300 : 70;
    });
  }

  void selectRoute(String route) {
    selectedRoute.value = route;
    // Add navigation logic here
    // Get.toNamed('/admin/$route');
  }

  @override
  void onInit() {
    super.onInit();
    // Set initial expanded state based on pin status
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