import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/common/widgets/admin/admin_lightbox.dart';

import '../../controllers/admin_layout/topbar_controller.dart';

class AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AdminTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminTopBarController());
    final dark = FHelperFunctions.isDarkMode(context);
    final userRepo = Get.find<UserRepository>();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
        border: Border(
          bottom: BorderSide(
            color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const Spacer(),

          // Theme Toggle
          IconButton(
            onPressed: () {
              Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
            },
            icon: Icon(
              dark ? Iconsax.sun_1 : Iconsax.moon,
              color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon,
            ),
          ),
          const SizedBox(width: FSizes.sm),

          // Profile Section
          Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(
                width: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final user = controller.currentUser.value;
            if (user == null) return const SizedBox.shrink();

            final cachedImageUrl = userRepo.getCachedProfileImageUrl(user.profileImg);

            return PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              onSelected: (value) => controller.onMenuItemSelected(value, context),
              itemBuilder: (context) => controller.getMenuItems(dark),
              child: Row(
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: () {
                      if (cachedImageUrl != null && cachedImageUrl.isNotEmpty) {
                        Get.to(() => ImageLightbox(
                          imageUrl: cachedImageUrl,
                          title: user.username,
                        ));
                      }
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      backgroundImage: cachedImageUrl != null && cachedImageUrl.isNotEmpty
                          ? NetworkImage(cachedImageUrl)
                          : null,
                      child: cachedImageUrl == null || cachedImageUrl.isEmpty
                          ? Icon(
                        Iconsax.user,
                        size: 18,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: FSizes.sm),

                  // User Info
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        controller.getRoleDisplayName(user.role),
                        style: TextStyle(
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: FSizes.xs),
                  Icon(
                    Iconsax.arrow_down_1,
                    size: 16,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}