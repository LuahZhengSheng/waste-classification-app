import 'package:flutter/material.dart';
import 'package:fyp/features/admin/controllers/user_management_controller.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/sidebar_menu.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/utils/theme/theme.dart';
import 'package:get/get.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());
    final themeController = Get.put(ThemeController());

    return Obx(() {
      return Theme(
        data: themeController.theme,
        child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? FColors.adminDarkBackground
              : FColors.adminLightBackground,
          body: Row(
            children: [
              // Sidebar
              const SidebarMenu(),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Top Bar
                    _buildTopBar(context, themeController),
                    // Main Content
                    Expanded(
                      child: _buildMainContent(controller, context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTopBar(BuildContext context, ThemeController themeController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        boxShadow: [
          BoxShadow(
            color: FColors.adminShadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Page Title
            Text(
              'User Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            // Search Bar
            Container(
              width: 300,
              height: 40,
              child: TextField(
                onChanged: (value) => Get.find<UserManagementController>().updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(
                    color: isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? FColors.adminDarkIcon : FColors.adminLightIcon,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? FColors.adminDarkBackground.withOpacity(0.5)
                      : FColors.adminLightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Notifications
            _buildTopBarIcon(
              icon: Icons.notifications_rounded,
              badge: '3',
              onTap: () {},
              isDark: isDark,
            ),
            const SizedBox(width: 16),
            // Theme Toggle
            _buildTopBarIcon(
              icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              onTap: () => themeController.toggleTheme(),
              isDark: isDark,
            ),
            const SizedBox(width: 16),
            // User Profile
            _buildUserProfile(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarIcon({
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? FColors.adminDarkBackground.withOpacity(0.5)
                    : FColors.adminLightBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDark ? FColors.adminDarkIcon : FColors.adminLightIcon,
                size: 22,
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? FColors.adminDarkError : FColors.adminLightError,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserProfile(bool isDark) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurface,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? FColors.adminDarkBackground.withOpacity(0.5)
              : FColors.adminLightBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              child: const Text(
                'MR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Moni Roy',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? FColors.adminDarkIcon : FColors.adminLightIcon,
              size: 20,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          icon: Icons.person_rounded,
          title: 'Profile',
          value: 'profile',
          isDark: isDark,
        ),
        _buildPopupMenuItem(
          icon: Icons.settings_rounded,
          title: 'Settings',
          value: 'settings',
          isDark: isDark,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          icon: Icons.logout_rounded,
          title: 'Logout',
          value: 'logout',
          isDark: isDark,
          isDestructive: true,
        ),
      ],
      onSelected: (value) {
        // Handle menu selection
      },
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive
                ? (isDark ? FColors.adminDarkError : FColors.adminLightError)
                : (isDark ? FColors.adminDarkIcon : FColors.adminLightIcon),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive
                  ? (isDark ? FColors.adminDarkError : FColors.adminLightError)
                  : (isDark ? FColors.adminDarkText : FColors.adminLightText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(UserManagementController controller, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsCards(controller, isDark),
          const SizedBox(height: 24),
          // Filters and Actions
          _buildFiltersAndActions(controller, isDark),
          const SizedBox(height: 24),
          // Users Table
          Expanded(
            child: _buildUsersTable(controller, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(UserManagementController controller, bool isDark) {
    return Obx(() {
      final totalUsers = controller.users.length;
      final activeUsers = controller.users.where((u) => u.isActive).length;
      final verifiedUsers = controller.users.where((u) => u.isVerified).length;
      final adminUsers = controller.users.where((u) => u.role == 'Admin').length;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total Users',
              value: totalUsers.toString(),
              icon: Icons.people_rounded,
              color: isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Active Users',
              value: activeUsers.toString(),
              icon: Icons.verified_user_rounded,
              color: isDark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Verified',
              value: verifiedUsers.toString(),
              icon: Icons.check_circle_rounded,
              color: isDark ? FColors.adminDarkInfo : FColors.adminLightInfo,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Admins',
              value: adminUsers.toString(),
              icon: Icons.admin_panel_settings_rounded,
              color: isDark ? FColors.adminDarkWarning : FColors.adminLightWarning,
              isDark: isDark,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: FColors.adminShadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndActions(UserManagementController controller, bool isDark) {
    return Row(
      children: [
        // Role Filter
        _buildFilterDropdown(
          title: 'Role',
          value: controller.selectedRole,
          options: controller.roleOptions,
          onChanged: controller.updateRoleFilter,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        // Status Filter
        _buildFilterDropdown(
          title: 'Status',
          value: controller.selectedStatus,
          options: controller.statusOptions,
          onChanged: controller.updateStatusFilter,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        // Verification Filter
        _buildFilterDropdown(
          title: 'Verification',
          value: controller.selectedVerificationStatus,
          options: controller.verificationOptions,
          onChanged: controller.updateVerificationFilter,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        // Clear Filters
        ElevatedButton.icon(
          onPressed: controller.clearFilters,
          icon: const Icon(Icons.clear_rounded, size: 18),
          label: const Text('Clear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            elevation: 0,
            side: BorderSide(
              color: isDark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const Spacer(),
        // Add User Button
        ElevatedButton.icon(
          onPressed: () {
            // Add user functionality
          },
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String title,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
    required bool isDark,
  }) {
    return Container(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              onChanged: (String? newValue) {
                if (newValue != null) onChanged(newValue);
              },
              underline: const SizedBox(),
              isExpanded: true,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(UserManagementController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoading) {
        return Center(
          child: CircularProgressIndicator(
            color: isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: isDark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FColors.adminShadow.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table Header
            _buildTableHeader(controller, isDark),
            // Table Body
            Expanded(
              child: _buildTableBody(controller, isDark),
            ),
            // Pagination
            _buildPagination(controller, isDark),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader(UserManagementController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _buildHeaderCell('User', SortColumn.username, controller, isDark, flex: 3),
          _buildHeaderCell('Role', SortColumn.role, controller, isDark, flex: 2),
          _buildHeaderCell('Status', SortColumn.isActive, controller, isDark, flex: 2),
          _buildHeaderCell('Verified', SortColumn.isVerified, controller, isDark, flex: 2),
          _buildHeaderCell('Join Date', SortColumn.joinDate, controller, isDark, flex: 2),
          _buildHeaderCell('Points', SortColumn.rewardPoint, controller, isDark, flex: 2),
          Container(width: 100, alignment: Alignment.center, child: Text(
            'Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
      String title,
      SortColumn column,
      UserManagementController controller,
      bool isDark,
      {int flex = 1}
      ) {
    final isActive = controller.sortColumn == column;

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => controller.sortBy(column),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                    : (isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive
                  ? (controller.sortDirection == SortDirection.ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded)
                  : Icons.unfold_more_rounded,
              size: 16,
              color: isActive
                  ? (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                  : (isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableBody(UserManagementController controller, bool isDark) {
    return ListView.builder(
      itemCount: controller.paginatedUsers.length,
      itemBuilder: (context, index) {
        final user = controller.paginatedUsers[index];
        final isEven = index % 2 == 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEven
                ? Colors.transparent
                : (isDark
                ? FColors.adminDarkBackground.withOpacity(0.3)
                : FColors.adminLightBackground.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // User Info
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null
                          ? Text(
                        user.username.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Role
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role == 'Admin'
                        ? (isDark ? FColors.adminDarkWarning : FColors.adminLightWarning).withOpacity(0.1)
                        : (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: user.role == 'Admin'
                          ? (isDark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                          : (isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary),
                    ),
                  ),
                ),
              ),
              // Status
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? (isDark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                            : (isDark ? FColors.adminDarkError : FColors.adminLightError),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: user.isActive
                            ? (isDark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                            : (isDark ? FColors.adminDarkError : FColors.adminLightError),
                      ),
                    ),
                  ],
                ),
              ),
              // Verified
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(
                      user.isVerified
                          ? Icons.verified_rounded
                          : Icons.pending_rounded,
                      size: 16,
                      color: user.isVerified
                          ? (isDark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                          : (isDark ? FColors.adminDarkWarning : FColors.adminLightWarning),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: user.isVerified
                            ? (isDark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                            : (isDark ? FColors.adminDarkWarning : FColors.adminLightWarning),
                      ),
                    ),
                  ],
                ),
              ),
              // Join Date
              Expanded(
                flex: 2,
                child: Text(
                  FFormatter.formatDate(user.joinDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ),
              // Points
              Expanded(
                flex: 2,
                child: Text(
                  user.rewardPoint.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ),
              // Actions
              Container(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: user.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      onTap: () => controller.toggleUserStatus(user.userId),
                      color: user.isActive
                          ? (isDark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                          : (isDark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                      tooltip: user.isActive ? 'Deactivate User' : 'Activate User',
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: user.isVerified ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                      onTap: () => controller.toggleUserVerification(user.userId),
                      color: user.isVerified
                          ? (isDark ? FColors.adminDarkInfo : FColors.adminLightInfo)
                          : (isDark ? FColors.adminDarkWarning : FColors.adminLightWarning),
                      tooltip: user.isVerified ? 'Unverify User' : 'Verify User',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(UserManagementController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? FColors.adminDarkDivider : FColors.adminLightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          // Items per page
          Row(
            children: [
              Text(
                'Show:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<int>(
                  value: controller.itemsPerPage,
                  onChanged: (int? newValue) {
                    if (newValue != null) controller.updateItemsPerPage(newValue);
                  },
                  underline: const SizedBox(),
                  items: [10, 25, 50, 100].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? FColors.adminDarkText : FColors.adminLightText,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'entries',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Pagination Info
          Text(
            'Showing ${controller.startIndex + 1}-${controller.endIndex} of ${controller.filteredUsers.length} entries',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(width: 16),
          // Pagination Controls
          Row(
            children: [
              _buildPaginationButton(
                icon: Icons.chevron_left_rounded,
                onTap: controller.currentPage > 1 ? controller.previousPage : null,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  controller.currentPage.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'of ${controller.totalPages}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
              _buildPaginationButton(
                icon: Icons.chevron_right_rounded,
                onTap: controller.currentPage < controller.totalPages ? controller.nextPage : null,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onTap != null
                ? (isDark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null
                ? (isDark ? FColors.adminDarkText : FColors.adminLightText)
                : (isDark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
          ),
        ),
      ),
    );
  }
}

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find();

  final RxBool _isDarkMode = false.obs;
  final RxBool _isAdminMode = true.obs; // Assuming admin panel

  bool get isDarkMode => _isDarkMode.value;
  bool get isAdminMode => _isAdminMode.value;

  ThemeData get theme {
    if (isAdminMode) {
      return isDarkMode ? FAppTheme.adminDarkTheme : FAppTheme.adminLightTheme;
    } else {
      return isDarkMode ? FAppTheme.darkTheme : FAppTheme.lightTheme;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize theme based on system preference
    _isDarkMode.value = Get.isDarkMode;
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(theme);
  }

  void setDarkMode(bool isDark) {
    _isDarkMode.value = isDark;
    Get.changeTheme(theme);
  }

  void setAdminMode(bool isAdmin) {
    _isAdminMode.value = isAdmin;
    Get.changeTheme(theme);
  }
}