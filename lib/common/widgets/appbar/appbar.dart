import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/device/device_utility.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FAppBar({super.key, this.title, this.showBackArrow = true, this.leadingIcon, this.actions, this.leadingOnPressed, this.backArrowColor});

  final Widget? title;
  final bool showBackArrow;
  final Color? backArrowColor;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(onPressed: () => Get.back(), icon: Icon(Iconsax.arrow_left, color: backArrowColor,))
            : leadingIcon != null ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon)) : null,
        title: title is Text
            ? Text(
          (title as Text).data!,
          style: (title as Text).style?.copyWith(fontSize: FSizes.appBarFontSize) ??
              const TextStyle(fontSize: FSizes.appBarFontSize),
        )
            : title,
        actions: actions,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(FDeviceUtils.getAppBarHeight());
}
