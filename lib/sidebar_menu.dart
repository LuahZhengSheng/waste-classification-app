  import 'package:flutter/material.dart';
  import 'package:fyp/utils/constants/colors.dart';
  import 'package:get/get.dart';

  class SidebarMenu extends StatefulWidget {
    const SidebarMenu({super.key});

    @override
    State<SidebarMenu> createState() => _SidebarMenuState();
  }

  class _SidebarMenuState extends State<SidebarMenu> with SingleTickerProviderStateMixin {
    late AnimationController _animationController;
    late Animation<double> _animation;
    bool _isHovering = false;

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );
    }

    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final controller = Get.put(SidebarController());
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return MouseRegion(
        onEnter: (_) {
          if (!controller.isManuallyExpanded) {
            setState(() => _isHovering = true);
            _animationController.forward();
          }
        },
        onExit: (_) {
          if (!controller.isManuallyExpanded) {
            setState(() => _isHovering = false);
            _animationController.reverse();
          }
        },
        child: Obx(() {
          final isExpanded = controller.isManuallyExpanded || _isHovering;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isExpanded ? 280 : 80, // 增加收起时的宽度到80px
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  FColors.adminDarkSurface,
                  FColors.adminDarkSurface.withOpacity(0.95),
                ]
                    : [
                  FColors.adminLightSurface,
                  FColors.adminLightSurfaceVariant,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: FColors.adminShadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildLogo(controller, isDark, isExpanded),
                Expanded(
                  child: _buildMenuItems(controller, isDark, isExpanded),
                ),
                _buildBottomSection(controller, isDark, isExpanded),
              ],
            ),
          );
        }),
      );
    }

    Widget _buildLogo(SidebarController controller, bool isDark, bool isExpanded) {
      return Container(
        height: 72,
        padding: EdgeInsets.symmetric(horizontal: isExpanded ? 24 : 16),
        child: Row(
          children: [
            // Logo icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    isDark ? FColors.adminDarkAccent : FColors.adminLightAccent,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DashStack',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget _buildMenuItems(SidebarController controller, bool isDark, bool isExpanded) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // 减少水平padding
        itemCount: controller.menuItems.length,
        itemBuilder: (context, index) {
          final item = controller.menuItems[index];
          final isSelected = controller.selectedMenuItem == item.title;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildMenuItem(item, isSelected, isDark, isExpanded, controller),
          );
        },
      );
    }

    Widget _buildMenuItem(
        SidebarMenuItem item,
        bool isSelected,
        bool isDark,
        bool isExpanded,
        SidebarController controller,
        ) {
      return Tooltip(
        message: isExpanded ? '' : item.title,
        waitDuration: const Duration(milliseconds: 500),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectMenuItem(item.title),
            borderRadius: BorderRadius.circular(12),
            hoverColor: isDark
                ? FColors.adminDarkHover.withOpacity(0.5)
                : FColors.adminLightHover.withOpacity(0.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 16 : 8, // 减少收起时的水平padding
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                        .withOpacity(0.1),
                    (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                        .withOpacity(0.05),
                  ],
                )
                    : null,
                color: !isSelected ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                      .withOpacity(0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: isExpanded
                  ? _buildExpandedMenuItem(item, isSelected, isDark)
                  : _buildCollapsedMenuItem(item, isSelected, isDark),
            ),
          ),
        ),
      );
    }

    Widget _buildExpandedMenuItem(SidebarMenuItem item, bool isSelected, bool isDark) {
      return Row(
        children: [
          // Icon with smaller container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                  .withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: isSelected
                  ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                  : (isDark ? FColors.adminDarkIcon : FColors.adminLightIcon),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                    : (isDark ? FColors.adminDarkText : FColors.adminLightText),
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (item.badge != null) ...[
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(
                minWidth: 20,
                maxWidth: 30,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? FColors.adminDarkError : FColors.adminLightError,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      );
    }

    Widget _buildCollapsedMenuItem(SidebarMenuItem item, bool isSelected, bool isDark) {
      return Center(
        child: Container(
          width: 40, // 固定宽度
          height: 40, // 固定高度
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                .withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            size: 20,
            color: isSelected
                ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                : (isDark ? FColors.adminDarkIcon : FColors.adminLightIcon),
          ),
        ),
      );
    }

    Widget _buildBottomSection(SidebarController controller, bool isDark, bool isExpanded) {
      return Container(
        padding: EdgeInsets.all(isExpanded ? 16 : 8), // 减少收起时的padding
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? FColors.adminDarkDivider : FColors.adminLightDivider,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Manual Expand/Collapse Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.toggleManualExpand,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isExpanded ? 12 : 8),
                  child: isExpanded
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.isManuallyExpanded
                            ? Icons.menu_open_rounded
                            : Icons.menu_rounded,
                        size: 20,
                        color: isDark ? FColors.adminDarkIcon : FColors.adminLightIcon,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.isManuallyExpanded ? 'Collapse' : 'Pin Sidebar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )
                      : Center(
                    child: Icon(
                      controller.isManuallyExpanded
                          ? Icons.menu_open_rounded
                          : Icons.menu_rounded,
                      size: 20,
                      color: isDark ? FColors.adminDarkIcon : FColors.adminLightIcon,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  class SidebarController extends GetxController {
    // Sidebar state
    final RxBool _isManuallyExpanded = false.obs;
    bool get isManuallyExpanded => _isManuallyExpanded.value;

    // Selected menu item
    final RxString _selectedMenuItem = 'Dashboard'.obs;
    String get selectedMenuItem => _selectedMenuItem.value;

    // Menu items with optional badges
    final List<SidebarMenuItem> menuItems = [
      SidebarMenuItem(
        title: 'Dashboard',
        icon: Icons.dashboard_rounded,
        route: '/dashboard',
      ),
      SidebarMenuItem(
        title: 'User Management',
        icon: Icons.people_rounded,
        route: '/users',
      ),
      SidebarMenuItem(
        title: 'Products',
        icon: Icons.inventory_2_rounded,
        route: '/products',
      ),
      SidebarMenuItem(
        title: 'Orders',
        icon: Icons.shopping_cart_rounded,
        route: '/orders',
        badge: '12',
      ),
      SidebarMenuItem(
        title: 'Analytics',
        icon: Icons.analytics_rounded,
        route: '/analytics',
      ),
      SidebarMenuItem(
        title: 'Reports',
        icon: Icons.description_rounded,
        route: '/reports',
      ),
      SidebarMenuItem(
        title: 'Settings',
        icon: Icons.settings_rounded,
        route: '/settings',
      ),
    ];

    void toggleManualExpand() {
      _isManuallyExpanded.value = !_isManuallyExpanded.value;
    }

    void selectMenuItem(String title) {
      _selectedMenuItem.value = title;
    }
  }

  class SidebarMenuItem {
    final String title;
    final IconData icon;
    final String route;
    final String? badge;

    SidebarMenuItem({
      required this.title,
      required this.icon,
      required this.route,
      this.badge,
    });
  }