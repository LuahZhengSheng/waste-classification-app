import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/notification_controller.dart';
import 'package:fyp/features/personalization/screens/notification/notification.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotificationIcon extends StatelessWidget {
  final double? size;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? badgeColor;

  const NotificationIcon({
    super.key,
    this.size = 24,
    this.onTap,
    this.iconColor,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    Get.put(NotificationController());

    return GetX<NotificationController>(
      builder: (controller) {
        final unreadCount = controller.unreadCount.value;

        return GestureDetector(
          onTap: onTap ?? () => Get.to(() => const NotificationScreen()),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Iconsax.notification,
                  size: size,
                  color: iconColor ?? FColors.primary,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: badgeColor ?? FColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: FColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Alternative notification icon with outline style
class NotificationIconOutline extends StatelessWidget {
  final double? size;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? badgeColor;

  const NotificationIconOutline({
    super.key,
    this.size = 24,
    this.onTap,
    this.iconColor,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationController());

    return GetX<NotificationController>(
      builder: (controller) {
        final unreadCount = controller.unreadCount.value;

        return IconButton(
          onPressed: onTap ?? () => Get.to(() => const NotificationScreen()),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Iconsax.notification,
                size: size,
                color: iconColor ?? FColors.primary,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? FColors.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: FColors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Notification bell icon with animation
class AnimatedNotificationIcon extends StatelessWidget {
  final double? size;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? badgeColor;

  const AnimatedNotificationIcon({
    super.key,
    this.size = 24,
    this.onTap,
    this.iconColor,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationController());

    return GetX<NotificationController>(
      builder: (controller) {
        final unreadCount = controller.unreadCount.value;

        return GestureDetector(
          onTap: onTap ?? () => Get.to(() => const NotificationScreen()),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: unreadCount > 0 ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 0.1,
                      child: Icon(
                        Iconsax.notification_bing,
                        size: size,
                        color: iconColor ?? FColors.primary,
                      ),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: badgeColor ?? FColors.error,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: (badgeColor ?? FColors.error)
                                .withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: FColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}