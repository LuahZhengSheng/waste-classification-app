import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class LevelUpBanner {
  /// Show level up banner at top of screen
  static void show({
    required String achievementTitle,
    required int level,
    required int rewardPoints,
    required String badgeEmoji,
  }) {
    Get.snackbar(
      '', // Empty title
      '', // Empty message
      titleText: const SizedBox.shrink(),
      messageText: _BannerContent(
        achievementTitle: achievementTitle,
        level: level,
        rewardPoints: rewardPoints,
        badgeEmoji: badgeEmoji,
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.md,
      ),
      margin: EdgeInsets.zero,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 600),
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      forwardAnimationCurve: Curves.elasticOut,
      reverseAnimationCurve: Curves.easeIn,
    );
  }
}

class _BannerContent extends StatefulWidget {
  final String achievementTitle;
  final int level;
  final int rewardPoints;
  final String badgeEmoji;

  const _BannerContent({
    required this.achievementTitle,
    required this.level,
    required this.rewardPoints,
    required this.badgeEmoji,
  });

  @override
  State<_BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends State<_BannerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500), // Orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Badge Emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.badgeEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),

            const SizedBox(width: FSizes.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Level Up!" text
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Level Up!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Achievement Title + Level
                  Text(
                    '${widget.achievementTitle} - Level ${widget.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Reward Points
                  Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${widget.rewardPoints} points earned',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
