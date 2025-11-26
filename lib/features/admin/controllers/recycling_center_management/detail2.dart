// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:fyp/utils/helpers/helper_functions.dart';
// import 'package:fyp/features/admin/controllers/recycling_center_management/recycling_center_detail_controller.dart';
// import 'package:intl/intl.dart';
//
// class RecyclingCenterDetailsScreen extends StatelessWidget {
//   final String centerId;
//
//   const RecyclingCenterDetailsScreen({
//     super.key,
//     required this.centerId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(RecyclingCenterDetailsController(centerId: centerId));
//     final dark = FHelperFunctions.isDarkMode(context);
//
//     return Scaffold(
//       backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
//       appBar: AppBar(
//         backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: Icon(Iconsax.arrow_left, color: dark ? FColors.adminDarkText : FColors.adminLightText),
//         ),
//         title: Text(
//           'Center Details',
//           style: TextStyle(
//             color: dark ? FColors.adminDarkText : FColors.adminLightText,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: CircularProgressIndicator(
//               color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
//             ),
//           );
//         }
//
//         final center = controller.center.value;
//         if (center == null) {
//           return Center(child: Text('Center not found'));
//         }
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(FSizes.lg),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // New Activity Notification
//               Obx(() {
//                 if (controller.showNewActivityNotification.value) {
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: FSizes.md),
//                     padding: const EdgeInsets.all(FSizes.md),
//                     decoration: BoxDecoration(
//                       color: dark ? FColors.adminDarkInfo.withOpacity(0.1) : FColors.adminLightInfo.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//                       border: Border.all(
//                         color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Iconsax.info_circle, color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo),
//                         const SizedBox(width: FSizes.sm),
//                         Expanded(
//                           child: Text(
//                             'New activities have been added',
//                             style: TextStyle(
//                               color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: controller.refreshActivities,
//                           child: Text(
//                             'Refresh',
//                             style: TextStyle(
//                               color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               }),
//
//               // Center Header Card
//               _buildCenterHeaderCard(center, controller, dark),
//               const SizedBox(height: FSizes.spaceBtwSections),
//
//               // Statistics Cards
//               _buildStatisticsCards(controller, dark),
//               const SizedBox(height: FSizes.spaceBtwSections),
//
//               // Category Statistics
//               _buildCategoryStatistics(controller, dark),
//               const SizedBox(height: FSizes.spaceBtwSections),
//
//               // Operating Hours
//               _buildOperatingHours(controller, dark),
//               const SizedBox(height: FSizes.spaceBtwSections),
//
//               // Staff Section
//               _buildStaffSection(controller, dark),
//               const SizedBox(height: FSizes.spaceBtwSections),
//
//               // Activities Section
//               _buildActivitiesSection(controller, dark),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildCenterHeaderCard(center, RecyclingCenterDetailsController controller, bool dark) {
//     return Container(
//       padding: const EdgeInsets.all(FSizes.lg),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               // Center Image
//               GestureDetector(
//                 onTap: () => _showImageDialog(center.image, center.name, dark),
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//                     border: Border.all(
//                       color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//                     ),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//                     child: Image.network(
//                       center.image,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Icon(
//                         Iconsax.building_4,
//                         size: 40,
//                         color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: FSizes.md),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       center.name,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                       ),
//                     ),
//                     const SizedBox(height: FSizes.xs),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: FSizes.sm,
//                             vertical: FSizes.xs,
//                           ),
//                           decoration: BoxDecoration(
//                             color: controller.getCenterStatusColor(dark).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
//                           ),
//                           child: Text(
//                             controller.centerStatusText,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: controller.getCenterStatusColor(dark),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: FSizes.sm),
//                         Text(
//                           center.formattedCreatedAt,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: FSizes.md),
//           Divider(color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider),
//           const SizedBox(height: FSizes.md),
//           _buildInfoRow(Iconsax.sms, center.email, dark),
//           const SizedBox(height: FSizes.sm),
//           _buildInfoRow(Iconsax.call, center.formattedPhoneNo, dark),
//           const SizedBox(height: FSizes.sm),
//           _buildInfoRow(Iconsax.global, center.website, dark),
//           const SizedBox(height: FSizes.sm),
//           _buildInfoRow(
//             Iconsax.location,
//             '${center.centerLocation.address.city}, ${center.centerLocation.address.state}',
//             dark,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String text, bool dark) {
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
//         const SizedBox(width: FSizes.sm),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: 14,
//               color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatisticsCards(RecyclingCenterDetailsController controller, bool dark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Statistics',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: dark ? FColors.adminDarkText : FColors.adminLightText,
//           ),
//         ),
//         const SizedBox(height: FSizes.md),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 'Today',
//                 controller.totalActivitiesToday,
//                 Iconsax.calendar,
//                 dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
//                 dark,
//               ),
//             ),
//             const SizedBox(width: FSizes.md),
//             Expanded(
//               child: _buildStatCard(
//                 'This Week',
//                 controller.totalActivitiesThisWeek,
//                 Iconsax.calendar_2,
//                 dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//                 dark,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: FSizes.md),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 'Total Weight',
//                 controller.totalWeightProcessed,
//                 Iconsax.weight,
//                 dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
//                 dark,
//               ),
//             ),
//             const SizedBox(width: FSizes.md),
//             Expanded(
//               child: _buildStatCard(
//                 'Total Activities',
//                 controller.totalActivities,
//                 Iconsax.activity,
//                 dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
//                 dark,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: FSizes.md),
//         _buildStatCard(
//           'Total Points Assigned',
//           controller.totalPointsAssigned,
//           Iconsax.coin,
//           dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
//           dark,
//           fullWidth: true,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatCard(String label, String value, IconData icon, Color color, bool dark, {bool fullWidth = false}) {
//     return Container(
//       padding: const EdgeInsets.all(FSizes.md),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//         border: Border.all(
//           color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(FSizes.sm),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           const SizedBox(width: FSizes.md),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                   ),
//                 ),
//                 const SizedBox(height: FSizes.xs),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoryStatistics(RecyclingCenterDetailsController controller, bool dark) {
//     final categoryStats = controller.categoryStatistics;
//
//     if (categoryStats.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Waste Category Statistics',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: dark ? FColors.adminDarkText : FColors.adminLightText,
//           ),
//         ),
//         const SizedBox(height: FSizes.md),
//         ...categoryStats.entries.map((entry) {
//           final category = controller.getCategoryById(entry.key);
//           final stats = entry.value;
//
//           return Container(
//             margin: const EdgeInsets.only(bottom: FSizes.md),
//             padding: const EdgeInsets.all(FSizes.md),
//             decoration: BoxDecoration(
//               color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//               borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//               border: Border.all(
//                 color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     if (category != null)
//                       Container(
//                         padding: const EdgeInsets.all(FSizes.xs),
//                         decoration: BoxDecoration(
//                           color: category.color.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
//                         ),
//                         child: Icon(
//                           category.icon,
//                           color: category.color,
//                           size: 20,
//                         ),
//                       ),
//                     const SizedBox(width: FSizes.sm),
//                     Expanded(
//                       child: Text(
//                         category?.name ?? 'Unknown Category',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: FSizes.md),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildCategoryStatItem(
//                         'Activities',
//                         '${stats['count']}',
//                         Iconsax.activity,
//                         dark,
//                       ),
//                     ),
//                     Expanded(
//                       child: _buildCategoryStatItem(
//                         'Weight',
//                         '${(stats['weight'] as double).toStringAsFixed(2)} kg',
//                         Iconsax.weight,
//                         dark,
//                       ),
//                     ),
//                     Expanded(
//                       child: _buildCategoryStatItem(
//                         'Points',
//                         '${stats['points']}',
//                         Iconsax.coin,
//                         dark,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   Widget _buildCategoryStatItem(String label, String value, IconData icon, bool dark) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           size: 20,
//           color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//         ),
//         const SizedBox(height: FSizes.xs),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: dark ? FColors.adminDarkText : FColors.adminLightText,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOperatingHours(RecyclingCenterDetailsController controller, bool dark) {
//     return Container(
//       padding: const EdgeInsets.all(FSizes.lg),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//         border: Border.all(
//           color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Operating Hours',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: dark ? FColors.adminDarkText : FColors.adminLightText,
//             ),
//           ),
//           const SizedBox(height: FSizes.md),
//           ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
//             return Padding(
//               padding: const EdgeInsets.only(bottom: FSizes.sm),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     day,
//                     style: TextStyle(
//                       color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//                     ),
//                   ),
//                   Text(
//                     controller.formatOpeningHours(day),
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStaffSection(RecyclingCenterDetailsController controller, bool dark) {
//     return Container(
//       padding: const EdgeInsets.all(FSizes.lg),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//         border: Border.all(
//           color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Staff Members',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: FSizes.sm,
//                   vertical: FSizes.xs,
//                 ),
//                 decoration: BoxDecoration(
//                   color: (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
//                 ),
//                 child: Text(
//                   '${controller.allStaff.length} Staff',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: FSizes.md),
//           Obx(() {
//             if (controller.allStaff.isEmpty) {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(FSizes.lg),
//                   child: Text(
//                     'No staff members',
//                     style: TextStyle(
//                       color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                     ),
//                   ),
//                 ),
//               );
//             }
//
//             return Column(
//               children: controller.allStaff.map((staff) {
//                 final activityCount = controller.staffActivityCounts[staff.userId] ?? 0;
//                 return FutureBuilder<String?>(
//                   future: controller.getStaffProfileImageUrl(staff.profileImg),
//                   builder: (context, snapshot) {
//                     final imageUrl = snapshot.data;
//                     return _buildStaffCard(staff, activityCount, imageUrl, dark);
//                   },
//                 );
//               }).toList(),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStaffCard(staff, int activityCount, String? imageUrl, bool dark) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: FSizes.md),
//       padding: const EdgeInsets.all(FSizes.md),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => _showImageDialog(imageUrl, staff.username, dark),
//             child: CircleAvatar(
//               radius: 25,
//               backgroundColor: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//               backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
//               child: imageUrl == null
//                   ? Icon(Iconsax.user, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted)
//                   : null,
//             ),
//           ),
//           const SizedBox(width: FSizes.md),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   staff.username,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                   ),
//                 ),
//                 Text(
//                   staff.email,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: FSizes.sm,
//               vertical: FSizes.xs,
//             ),
//             decoration: BoxDecoration(
//               color: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
//             ),
//             child: Text(
//               '$activityCount activities',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActivitiesSection(RecyclingCenterDetailsController controller, bool dark) {
//     return Container(
//       padding: const EdgeInsets.all(FSizes.lg),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//         border: Border.all(
//           color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Recent Activities',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                 ),
//               ),
//               // Filter and Sort Options
//               Row(
//                 children: [
//                   Obx(() => DropdownButton<String>(
//                     value: controller.selectedStaffFilter.value,
//                     onChanged: (value) => controller.changeStaffFilter(value!),
//                     items: [
//                       DropdownMenuItem(value: 'all', child: Text('All Staff')),
//                       ...controller.allStaff.map((staff) => DropdownMenuItem(
//                         value: staff.userId,
//                         child: Text(staff.username),
//                       )),
//                     ],
//                     underline: const SizedBox(),
//                     style: TextStyle(color: dark ? FColors.adminDarkText : FColors.adminLightText),
//                   )),
//                   const SizedBox(width: FSizes.sm),
//                   Obx(() => IconButton(
//                     onPressed: () {
//                       controller.changeSorting(
//                         controller.sortBy.value == 'newest' ? 'oldest' : 'newest',
//                       );
//                     },
//                     icon: Icon(
//                       controller.sortBy.value == 'newest' ? Iconsax.arrow_down : Iconsax.arrow_up,
//                       color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//                     ),
//                   )),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: FSizes.md),
//           Obx(() {
//             if (controller.filteredActivities.isEmpty) {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(FSizes.lg),
//                   child: Text(
//                     'No activities yet',
//                     style: TextStyle(
//                       color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                     ),
//                   ),
//                 ),
//               );
//             }
//
//             return Column(
//               children: controller.filteredActivities.take(10).map((activity) {
//                 final user = controller.getUserById(activity.userId);
//                 final staff = controller.getStaffById(activity.centerStaffId);
//                 final category = controller.getCategoryById(activity.wasteCategoryId);
//
//                 return FutureBuilder<List<String?>>(
//                   future: Future.wait([
//                     controller.getUserProfileImageUrl(user?.profileImg),
//                     controller.getActivityImageUrl(activity.userId, activity.supportImage),
//                   ]),
//                   builder: (context, snapshot) {
//                     final userImageUrl = snapshot.data?[0];
//                     final activityImageUrl = snapshot.data?[1];
//
//                     return _buildActivityCard(
//                       activity,
//                       user,
//                       staff,
//                       category,
//                       userImageUrl,
//                       activityImageUrl,
//                       dark,
//                     );
//                   },
//                 );
//               }).toList(),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActivityCard(
//       activity,
//       user,
//       staff,
//       category,
//       String? userImageUrl,
//       String? activityImageUrl,
//       bool dark,
//       ) {
//     final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
//     final formattedDate = dateFormat.format(activity.createdAt);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: FSizes.md),
//       padding: const EdgeInsets.all(FSizes.md),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               // User Avatar
//               GestureDetector(
//                 onTap: () => _showImageDialog(userImageUrl, user?.username ?? 'User', dark),
//                 child: CircleAvatar(
//                   radius: 20,
//                   backgroundColor: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//                   backgroundImage: userImageUrl != null ? NetworkImage(userImageUrl) : null,
//                   child: userImageUrl == null
//                       ? Icon(Iconsax.user, size: 16, color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted)
//                       : null,
//                 ),
//               ),
//               const SizedBox(width: FSizes.sm),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user?.username ?? 'Unknown User',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                       ),
//                     ),
//                     Text(
//                       'Processed by ${staff?.username ?? 'Unknown Staff'}',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: FSizes.md),
//
//           // Activity Image
//           if (activityImageUrl != null)
//             GestureDetector(
//               onTap: () => _showImageDialog(activityImageUrl, 'Activity Image', dark),
//               child: Container(
//                 height: 150,
//                 width: double.infinity,
//                 margin: const EdgeInsets.only(bottom: FSizes.md),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//                   border: Border.all(
//                     color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//                   ),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//                   child: Image.network(
//                     activityImageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Center(
//                       child: Icon(
//                         Iconsax.image,
//                         size: 40,
//                         color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//           // Activity Details
//           Row(
//             children: [
//               if (category != null)
//                 Container(
//                   padding: const EdgeInsets.all(FSizes.xs),
//                   decoration: BoxDecoration(
//                     color: category.color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
//                   ),
//                   child: Icon(category.icon, color: category.color, size: 16),
//                 ),
//               const SizedBox(width: FSizes.sm),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       activity.wasteObject,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                       ),
//                     ),
//                     Text(
//                       category?.name ?? 'Unknown Category',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: FSizes.md),
//
//           Row(
//             children: [
//               _buildDetailChip(
//                 '${activity.weight.toStringAsFixed(2)} kg',
//                 Iconsax.weight,
//                 dark,
//               ),
//               const SizedBox(width: FSizes.sm),
//               _buildDetailChip(
//                 '${activity.pointsEarned} pts',
//                 Iconsax.coin,
//                 dark,
//               ),
//             ],
//           ),
//           const SizedBox(height: FSizes.sm),
//
//           // Date and Status
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 formattedDate,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: FSizes.sm,
//                   vertical: FSizes.xs,
//                 ),
//                 decoration: BoxDecoration(
//                   color: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
//                 ),
//                 child: Text(
//                   activity.statusDisplayText,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailChip(String text, IconData icon, bool dark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: FSizes.sm,
//         vertical: FSizes.xs,
//       ),
//       decoration: BoxDecoration(
//         color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
//           const SizedBox(width: FSizes.xs),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: dark ? FColors.adminDarkText : FColors.adminLightText,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showImageDialog(String? imageUrl, String title, bool dark) {
//     if (imageUrl == null || imageUrl.isEmpty) return;
//
//     Get.dialog(
//       Dialog(
//         backgroundColor: Colors.transparent,
//         child: GestureDetector(
//           onTap: () => Get.back(),
//           child: Container(
//             padding: const EdgeInsets.all(FSizes.lg),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   constraints: BoxConstraints(
//                     maxWidth: Get.width * 0.9,
//                     maxHeight: Get.height * 0.8,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         height: 300,
//                         width: 300,
//                         color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
//                         child: Center(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Iconsax.image,
//                                 color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                                 size: 48,
//                               ),
//                               const SizedBox(height: FSizes.sm),
//                               Text(
//                                 'Image not available',
//                                 style: TextStyle(
//                                   color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: FSizes.md),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: FSizes.lg,
//                     vertical: FSizes.sm,
//                   ),
//                   decoration: BoxDecoration(
//                     color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//                     borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//                   ),
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       color: dark ? FColors.adminDarkText : FColors.adminLightText,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }