import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/images/circular_image.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:iconsax/iconsax.dart';

class FUserProfileTile extends StatelessWidget {
  const FUserProfileTile({
    super.key, required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FCircularImage(image: FImages.user, width: 50, height: 50, padding: 0),
      title: Text('Coding with T', style: Theme.of(context).textTheme.headlineSmall!.apply(color: FColors.white)),
      subtitle: Text('zhengsheng0910@gmail.com', style: Theme.of(context).textTheme.bodyMedium!.apply(color: FColors.white)),
      trailing: IconButton(onPressed: onPressed, icon: const Icon(Iconsax.edit, color: FColors.white)),
    );
  }
}