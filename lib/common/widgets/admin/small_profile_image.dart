import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'admin_lightbox.dart';

class SmallProfileImage extends StatelessWidget {
  final String? profileImg;
  final String username;
  final bool dark;
  final double radius;

  const SmallProfileImage({
    super.key,
    required this.profileImg,
    required this.username,
    required this.dark,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final userRepo = Get.find<UserRepository>();
    final cachedUrl = userRepo.getCachedProfileImageUrl(profileImg);

    return GestureDetector(
      onTap: () {
        if (cachedUrl != null && cachedUrl.isNotEmpty) {
          Get.to(() => ImageLightbox(
            imageUrl: cachedUrl,
            title: username,
          ));
        }
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
        backgroundImage: cachedUrl != null && cachedUrl.isNotEmpty
            ? NetworkImage(cachedUrl)
            : null,
        child: cachedUrl == null || cachedUrl.isEmpty
            ? Icon(
          Iconsax.user,
          color: Colors.white,
          size: radius,
        )
            : null,
      ),
    );
  }
}