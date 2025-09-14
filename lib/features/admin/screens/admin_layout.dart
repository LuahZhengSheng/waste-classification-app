import 'package:flutter/material.dart';
import 'package:fyp/features/admin/screens/recycling_center_management/recycling_center_management.dart';
import 'package:fyp/features/admin/screens/topbar.dart';
import 'package:fyp/features/admin/screens/user_management/user_management.dart';
import 'package:get/get.dart';
import '../../../sidebar_menu.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import 'achievement_management/achievement_management_screen.dart';
import 'community_management/community_management.dart';
import 'dashboard/dashboard.dart';
import 'event_management/event_management.dart';
import 'reward_management/reward_management.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarController = Get.put(AdminSidebarMenuController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Row(
        children: [
          // Sidebar
          AdminSidebarMenu(),

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
      child: UserManagementScreen(),
    );
  }
}

class EventManagementPage extends StatelessWidget {
  const EventManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Event Management',
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
      child: AchievementManagementScreen(),
    );
  }
}