import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class FLoginHeader extends StatelessWidget {
  const FLoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(
          height: 150,
          image: AssetImage(
              dark ? FImages.lightAppLogo : FImages.darkAppLogo),
        ),
      ],
    );
  }
}