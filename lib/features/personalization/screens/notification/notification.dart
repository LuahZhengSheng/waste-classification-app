import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/notification_controller.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/formatters/formatter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  final NotificationController controller = Get.put(NotificationController());
  late bool dark;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.tabController.animateTo(0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dark = FHelperFunctions.isDarkMode(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        final controller = Get.find<NotificationController>();
        if (controller.isSelectionMode.value) {
          controller.toggleSelectionMode();
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: dark ? FColors.dark : FColors.light,
        appBar: FAppBar(
          showBackArrow: true,
          title: const Text('Notifications'),
          actions: _buildAppBarActions(controller, dark),
          leadingOnPressed: () {
            final controller = Get.find<NotificationController>();
            if (controller.isSelectionMode.value) {
              controller.toggleSelectionMode();
            } else {
              Get.back();
            }
          },
        ),
        body: Column(
          children: [
            _buildTabBar(controller, dark),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _NotificationsList(
                    controller: controller,
                    dark: dark,
                    filterType: NotificationFilterType.all,
                  ),
                  _NotificationsList(
                    controller: controller,
                    dark: dark,
                    filterType: NotificationFilterType.unread,
                  ),
                  _NotificationsList(
                    controller: controller,
                    dark: dark,
                    filterType: NotificationFilterType.read,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Obx(() {
          if (!controller.isSelectionMode.value) return const SizedBox();

          return FloatingActionButton.extended(
            onPressed: controller.batchDeleteSelected,
            backgroundColor: FColors.error,
            icon: const Icon(Iconsax.trash, color: FColors.white),
            label: Text(
              'Delete (${controller.selectedNotifications.length})',
              style: const TextStyle(
                color: FColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildAppBarActions(NotificationController controller, bool dark) {
    return [
      Obx(() {
        if (controller.isSelectionMode.value) {
          return _buildSelectAllButton(controller);
        } else {
          return _buildNormalModeActions(controller, dark);
        }
      }),
    ];
  }

  Widget _buildSelectAllButton(NotificationController controller) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: FColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: controller.selectAllInCurrentTab,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Select All',
              style: TextStyle(
                color: FColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalModeActions(NotificationController controller, bool dark) {
    return Row(
      children: [
        Obx(() {
          if (controller.unreadCount.value > 0) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: controller.markAllAsRead,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Mark all read',
                      style: TextStyle(
                        color: FColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        IconButton(
          onPressed: controller.toggleSelectionMode,
          icon: Icon(
            Iconsax.edit_2,
            color: dark ? FColors.darkText : FColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(NotificationController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace, vertical: 12),
      color: dark ? FColors.dark : FColors.white,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        // 【关键】使用 Obx 监听 allNotifications 变化
        child: Obx(() {
          // 强制重新计算 count
          final allCount = controller.allNotifications.length;
          final unreadCount = controller.unreadNotifications.length;
          final readCount = controller.readNotifications.length;

          return AnimatedBuilder(
            animation: controller.tabController.animation!,
            builder: (context, child) {
              final currentIndex = controller.tabController.animation!.value.round();

              return TabBar(
                controller: controller.tabController,
                labelColor: FColors.white,
                unselectedLabelColor: dark ? FColors.darkGrey : FColors.grey,
                indicator: BoxDecoration(
                  color: FColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: FColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    child: _buildTabLabel('All', allCount, currentIndex == 0, dark),
                  ),
                  Tab(
                    child: _buildTabLabel('Unread', unreadCount, currentIndex == 1, dark),
                  ),
                  Tab(
                    child: _buildTabLabel('Read', readCount, currentIndex == 2, dark),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildTabLabel(String text, int count, bool isSelected, bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? FColors.white : (dark ? FColors.darkGrey : FColors.grey),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? FColors.white.withOpacity(0.3)
                    : FColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? FColors.white : FColors.primary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

enum NotificationFilterType { all, unread, read }

class _NotificationsList extends StatefulWidget {
  final NotificationController controller;
  final bool dark;
  final NotificationFilterType filterType;

  const _NotificationsList({
    required this.controller,
    required this.dark,
    required this.filterType,
  });

  @override
  State<_NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<_NotificationsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      widget.controller.loadMoreNotifications();
    }
  }

  List<NotificationModel> _getFilteredNotifications() {
    switch (widget.filterType) {
      case NotificationFilterType.all:
        return widget.controller.allNotifications;
      case NotificationFilterType.unread:
        return widget.controller.unreadNotifications;
      case NotificationFilterType.read:
        return widget.controller.readNotifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notifications = _getFilteredNotifications();

      if (widget.controller.isLoading.value && notifications.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: FColors.primary),
        );
      }

      if (notifications.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        color: FColors.primary,
        onRefresh: widget.controller.refreshNotifications,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: notifications.length +
              (widget.controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == notifications.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: FColors.primary),
                ),
              );
            }

            final notification = notifications[index];
            // 【关键修复】使用 StreamBuilder 监听每个通知的实时更新
            return StreamBuilder<NotificationModel?>(
              stream: widget.controller.getNotificationStream(notification.notificationId),
              initialData: notification,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final updatedNotification = snapshot.data!;
                return _NotificationTile(
                  notification: updatedNotification,
                  controller: widget.controller,
                  dark: widget.dark,
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.notification_bing,
              size: 64,
              color: FColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.dark ? FColors.darkText : FColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: widget.dark ? FColors.darkTextSecondary : FColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final NotificationController controller;
  final bool dark;

  const _NotificationTile({
    required this.notification,
    required this.controller,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedNotifications.contains(notification.notificationId);
      final isSelectionMode = controller.isSelectionMode.value;

      return InkWell(
        onTap: () {
          if (isSelectionMode) {
            controller.toggleNotificationSelection(notification.notificationId);
          } else {
            controller.viewNotificationDetails(notification);
          }
        },
        onLongPress: () {
          if (!isSelectionMode) {
            controller.toggleSelectionMode();
            controller.toggleNotificationSelection(notification.notificationId);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? FColors.primary.withOpacity(0.1)
                : notification.isRead
                ? Colors.transparent
                : FColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (isSelectionMode)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? FColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dark ? FColors.darkGrey : FColors.borderPrimary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: FColors.white)
                      : null,
                )
              else
                _buildAvatar(),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                              color: dark ? FColors.darkText : FColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FFormatter.formatTimeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: dark ? FColors.darkText : FColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (!notification.isRead && !isSelectionMode)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: FColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getAvatarColor().withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(),
        color: _getAvatarColor(),
        size: 20,
      ),
    );
  }

  Color _getAvatarColor() {
    switch (notification.type) {
      case 'system':
        return FColors.primary;
      case 'achievement':
        return FColors.success;
      case 'reminder':
        return FColors.warning;
      default:
        return FColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'system':
        return Iconsax.info_circle;
      case 'achievement':
        return Iconsax.medal_star;
      case 'reminder':
        return Iconsax.timer;
      default:
        return Iconsax.notification;
    }
  }
}
