import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/device/device_utility.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class FSearchContainer extends StatelessWidget {
  const FSearchContainer({
    super.key, required this.text, this.icon, this.showBackground = true, this.showBorder = true,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Container(
        width: FDeviceUtils.getScreenWidth(),
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: showBackground ? dark ? FColors.dark : FColors.light : Colors.transparent,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: showBorder ? Border.all(color: FColors.grey) : null,
        ),
        child: Row(
          children: [
            const Icon(Iconsax.search_normal, color: FColors.grey),
            const SizedBox(width: FSizes.spaceBtwItems),
            Text(text, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}