import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class FVerticalImageText extends StatelessWidget {
  const FVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = FColors.white,
    this.backgroundColor = FColors.white,
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: FSizes.spaceBtwItems),
        child: Column(
            children: [
              /// Circular Icon
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: backgroundColor ?? (FHelperFunctions.isDarkMode(context) ? FColors.black : FColors.white),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Image(image: AssetImage(image), fit: BoxFit.cover, color: dark ? FColors.light : FColors.dark),
                ),
              ),

              /// Text
              const SizedBox(height: FSizes.spaceBtwItems / 2),
              SizedBox(
                width: 55,
                child: Center(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }
}