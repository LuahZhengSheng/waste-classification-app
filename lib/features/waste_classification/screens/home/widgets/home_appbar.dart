import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/common/widgets/contents/notification/menu_icon.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/text_strings.dart';

class FHomeAppBar extends StatelessWidget {
  const FHomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(FTexts.homeAppbarTitle, style: Theme.of(context).textTheme.labelMedium!.apply(color: FColors.grey)),
          Text(FTexts.homeAppbarSubTitle, style: Theme.of(context).textTheme.headlineSmall!.apply(color: FColors.white)),
        ],
      ),
      actions: [
        FCartCounterIcon(onPressed: (){}, iconColor: FColors.white),
      ],
    );
  }
}