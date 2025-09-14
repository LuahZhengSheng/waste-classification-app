// admin_topbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AdminTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
        border: Border(bottom: BorderSide(color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder, width: 1)),
      ),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText)),
          const Spacer(),
          IconButton(
            onPressed: () {
              Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
            },
            icon: Icon(dark ? Iconsax.sun_1 : Iconsax.moon,
                color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon),
          ),
          // const SizedBox(width: FSizes.sm),
          // Stack(
          //   children: [
          //     IconButton(
          //       onPressed: () {},
          //       icon: Icon(Iconsax.notification,
          //           color: dark ? FColors.adminDarkIcon : FColors.adminLightIcon),
          //     ),
          //     Positioned(
          //       right: 8,
          //       top: 8,
          //       child: Container(
          //         width: 8,
          //         height: 8,
          //         decoration: BoxDecoration(
          //             color: dark ? FColors.adminDarkError : FColors.adminLightError,
          //             borderRadius: BorderRadius.circular(4)),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(width: FSizes.sm),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                child: const Text('JA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: FSizes.sm),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Admin',
                      style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text('Super Admin',
                      style: TextStyle(
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                          fontSize: 12)),
                ],
              ),
              const SizedBox(width: FSizes.xs),
              Icon(Iconsax.arrow_down_1,
                  size: 16,
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
            ],
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
