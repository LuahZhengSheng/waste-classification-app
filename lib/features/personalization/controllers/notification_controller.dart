import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';
import 'package:fyp/features/personalization/screens/notification/notification_detail.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // Make these reactive with RxList instead of regular lists
  final RxList<NotificationModel> _allNotifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  // Getter methods that return reactive lists
  RxList<NotificationModel> get allNotifications => _allNotifications;

  List<NotificationModel> get unreadNotifications =>
      _allNotifications.where((notification) => !notification.isRead).toList();

  List<NotificationModel> get readNotifications =>
      _allNotifications.where((notification) => notification.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    loadNotifications();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      // Simulate loading from API/Database
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with your actual API call
      final notifications = [
        NotificationModel(
          notificationId: '1',
          title: 'System Update',
          message: 'Your system has been updated to the latest version with new features and bug fixes.',
          type: 'system',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        NotificationModel(
          notificationId: '2',
          title: 'Access Request',
          message: 'John Doe requested access to Project Alpha documents.',
          type: 'request',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        NotificationModel(
          notificationId: '3',
          title: 'New Comment',
          message: 'Sarah commented on your shared file "Budget Report Q4".',
          type: 'comment',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        NotificationModel(
          notificationId: '4',
          title: 'File Shared',
          message: 'Mike shared "Project Proposal.pdf" with you.',
          type: 'file_share',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      // Use assignAll to trigger reactivity
      _allNotifications.assignAll(notifications);

    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  void markAsRead(String notificationId) {
    final index = _allNotifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      // Create a new instance with isRead = true and update the list
      _allNotifications[index] = _allNotifications[index].copyWith(isRead: true);

      // Force update to trigger reactive UI
      _allNotifications.refresh();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _allNotifications.length; i++) {
      if (!_allNotifications[i].isRead) {
        _allNotifications[i] = _allNotifications[i].copyWith(isRead: true);
      }
    }

    // Force update to trigger reactive UI
    _allNotifications.refresh();
  }

  void deleteNotification(String notificationId) {
    _allNotifications.removeWhere((n) => n.notificationId == notificationId);
  }

  void viewNotificationDetails(NotificationModel notification) {
    // Mark as read when viewing details
    if (!notification.isRead) {
      markAsRead(notification.notificationId);
    }

    // Navigate to details screen
    Get.to(() => NotificationDetailScreen(), arguments: notification);
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}