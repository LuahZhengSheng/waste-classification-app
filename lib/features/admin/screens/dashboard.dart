

// import 'package:fyp/sidebar_menu.dart';
// import 'package:fyp/utils/theme/theme.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:fyp/utils/constants/colors.dart';
//
// class AdminLayout extends StatelessWidget {
//   final Widget child;
//
//   const AdminLayout({
//     super.key,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // 使用 SidebarController 而不是 AdminLayoutController
//     final sidebarController = Get.find<SidebarController>();
//
//     return Obx(() => Theme(
//       data: sidebarController.isDarkMode
//           ? FAppTheme.adminDarkTheme
//           : FAppTheme.adminLightTheme,
//       child: Scaffold(
//         body: Row(
//           children: [
//             // Sidebar
//             SidebarMenu(),
//
//             // Main Content
//             Expanded(
//               child: Column(
//                 children: [
//                   // App Bar
//                   _buildAppBar(context, sidebarController),
//
//                   // Content
//                   Expanded(
//                     child: child,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildAppBar(BuildContext context, SidebarController controller) {
//     final isDark = controller.isDarkMode;
//     final backgroundColor = isDark ? FColors.adminDarkSurface : FColors.adminLightSurface;
//     final borderColor = isDark ? FColors.adminDarkBorder : FColors.adminLightBorder;
//
//     return Container(
//       height: 70,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         border: Border(
//           bottom: BorderSide(color: borderColor, width: 1),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Row(
//         children: [
//           // Breadcrumbs or Page Title
//           Expanded(
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.home_outlined,
//                   size: 16,
//                   color: isDark ? FColors.adminDarkDisabled : FColors.adminLightDisabled,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Admin',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: isDark ? FColors.adminDarkDisabled : FColors.adminLightDisabled,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   Icons.chevron_right,
//                   size: 16,
//                   color: isDark ? FColors.adminDarkDisabled : FColors.adminLightDisabled,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _getCurrentPageTitle(controller.currentRoute),
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: isDark ? FColors.adminDarkOnSurface : FColors.adminLightOnSurface,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Search Bar
//           Container(
//             width: 300,
//             height: 40,
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search...',
//                 prefixIcon: const Icon(Icons.search, size: 20),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: isDark
//                     ? FColors.adminDarkBackground
//                     : FColors.adminLightBackground,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//             ),
//           ),
//
//           const SizedBox(width: 16),
//
//           // Theme Toggle
//           IconButton(
//             onPressed: controller.toggleTheme,
//             icon: Icon(
//               controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//               color: isDark ? FColors.adminDarkOnSurface : FColors.adminLightOnSurface,
//             ),
//             tooltip: controller.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
//           ),
//
//           // Notifications
//           IconButton(
//             onPressed: () {
//               // Show notifications
//             },
//             icon: Stack(
//               children: [
//                 Icon(
//                   Icons.notifications_outlined,
//                   color: isDark ? FColors.adminDarkOnSurface : FColors.adminLightOnSurface,
//                 ),
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: FColors.adminLightError,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             tooltip: 'Notifications',
//           ),
//
//           const SizedBox(width: 16),
//
//           // User Profile
//           PopupMenuButton(
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundColor: isDark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
//                   child: const Text(
//                     'MR',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Moni Roy',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: isDark ? FColors.adminDarkOnSurface : FColors.adminLightOnSurface,
//                       ),
//                     ),
//                     Text(
//                       'Admin',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: isDark ? FColors.adminDarkDisabled : FColors.adminLightDisabled,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   Icons.keyboard_arrow_down,
//                   size: 16,
//                   color: isDark ? FColors.adminDarkOnSurface : FColors.adminLightOnSurface,
//                 ),
//               ],
//             ),
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 child: Row(
//                   children: [
//                     const Icon(Icons.person_outline, size: 16),
//                     const SizedBox(width: 12),
//                     const Text('Profile'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 child: Row(
//                   children: [
//                     const Icon(Icons.settings_outlined, size: 16),
//                     const SizedBox(width: 12),
//                     const Text('Settings'),
//                   ],
//                 ),
//               ),
//               const PopupMenuDivider(),
//               PopupMenuItem(
//                 child: Row(
//                   children: [
//                     const Icon(Icons.logout, size: 16),
//                     const SizedBox(width: 12),
//                     const Text('Logout'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getCurrentPageTitle(String currentRoute) {
//     switch (currentRoute) {
//       case '/admin/dashboard':
//         return 'Dashboard';
//       case '/admin/users':
//         return 'User Management';
//       case '/admin/products':
//         return 'Products';
//       case '/admin/analytics':
//         return 'Analytics';
//       case '/admin/settings':
//         return 'Settings';
//       default:
//         return 'Dashboard';
//     }
//   }
// }