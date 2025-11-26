import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/community/screens/create_post/widgets/media_lightbox.dart';

/// Reusable user profile preview widget for admin side
class UserProfilePreview extends StatelessWidget {
  final String userId;
  final String username;
  final String email;
  final String? profileImageFileName;
  final bool dark;
  final bool showEmail;
  final double avatarSize;

  const UserProfilePreview({
    super.key,
    required this.userId,
    required this.username,
    required this.email,
    this.profileImageFileName,
    required this.dark,
    this.showEmail = true,
    this.avatarSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepository.instance;
    final cachedUrl = userRepo.getCachedProfileImageUrl(profileImageFileName);

    return Row(
      children: [
        // Profile Image
        GestureDetector(
          onTap: () {
            if (cachedUrl != null && cachedUrl.isNotEmpty) {
              Get.to(() => UnifiedMediaLightbox(
                mediaItems: [
                  UnifiedMediaItem.network(
                    id: userId,
                    networkUrl: cachedUrl,
                    isVideo: false,
                  ),
                ],
                initialIndex: 0,
              ));
            }
          },
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: dark
                ? FColors.adminDarkPrimary
                : FColors.adminLightPrimary,
            backgroundImage: cachedUrl != null && cachedUrl.isNotEmpty
                ? NetworkImage(cachedUrl)
                : null,
            child: cachedUrl == null || cachedUrl.isEmpty
                ? Icon(
              Iconsax.user,
              color: Colors.white,
              size: avatarSize / 2,
            )
                : null,
          ),
        ),
        const SizedBox(width: FSizes.sm),
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                username,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: dark
                      ? FColors.adminDarkText
                      : FColors.adminLightText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showEmail) ...[
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 11,
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}