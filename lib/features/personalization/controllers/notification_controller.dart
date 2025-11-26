import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';
import 'package:fyp/features/personalization/screens/notification/notification_detail.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

import '../../../data/repositories/personalization/notification_repository.dart';

class NotificationController extends GetxController with GetSingleTickerProviderStateMixin {
  static NotificationController get instance => Get.find();

  final NotificationRepository _repository = Get.put(NotificationRepository());

  // Tab Controller
  late TabController tabController;

  // Reactive variables
  final allNotifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final unreadCount = 0.obs;

  // Batch delete
  final isSelectionMode = false.obs;
  final selectedNotifications = <String>[].obs;

  // Pagination
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 15;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _unreadCountSubscription;

  // Getters for filtered lists
  List<NotificationModel> get unreadNotifications =>
      allNotifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      allNotifications.where((n) => n.isRead).toList();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    _initializeNotifications();
    _listenToUnreadCount();
  }

  @override
  void onClose() {
    resetSelectionState(); // 重置选择状态
    tabController.dispose();
    _notificationSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.onClose();
  }

  /// Initialize notifications with real-time stream
  void _initializeNotifications() {
    try {
      isLoading.value = true;
      _loadNotifications();
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Load notifications with real-time stream
  Future<void> _loadNotifications() async {
    try {
      _notificationSubscription?.cancel();

      _notificationSubscription = _repository
          .getNotificationsStream(limit: _pageSize)
          .listen((notifications) {
        print('🔄 Real-time update received: ${notifications.length} notifications');

        // Update the notifications list
        allNotifications.assignAll(notifications);
        hasMoreData.value = notifications.length >= _pageSize;

        // Update last document for pagination
        if (notifications.isNotEmpty) {
          _repository.getLastDocument(notifications).then((doc) {
            _lastDocument = doc;
          });
        }

        // Clear selection if notifications are removed
        _cleanUpSelectedNotifications();
      }, onError: (error) {
        FLoaders.errorSnackBar(title: 'Error', message: error.toString());
      });
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Clean up selected notifications that no longer exist
  void _cleanUpSelectedNotifications() {
    final existingIds = allNotifications.map((n) => n.notificationId).toSet();
    selectedNotifications.removeWhere((id) => !existingIds.contains(id));

    // Exit selection mode if no selections left
    if (selectedNotifications.isEmpty && isSelectionMode.value) {
      isSelectionMode.value = false;
    }
  }

  /// Load more notifications
  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;

      final newNotifications = await _repository.getNotifications(
        limit: _pageSize,
        lastDocument: _lastDocument,
      );

      if (newNotifications.isEmpty) {
        hasMoreData.value = false;
      } else {
        allNotifications.addAll(newNotifications);
        _lastDocument = await _repository.getLastDocument(newNotifications);
        hasMoreData.value = newNotifications.length >= _pageSize;
      }
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Listen to unread count for real-time updates
  void _listenToUnreadCount() {
    _unreadCountSubscription = _repository.getUnreadCountStream().listen((count) {
      unreadCount.value = count;
      print('🔔 Unread count updated: $count');
    });
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    try {
      _lastDocument = null;
      hasMoreData.value = true;
      await _loadNotifications();
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      // Local state will be updated automatically via stream
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      FLoaders.showLoading('Marking all as read...');
      await _repository.markAllAsRead();

      // Local state will be updated automatically via stream

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'All notifications marked as read',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Delete notification - real-time update handled by stream
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      // The stream will automatically update the UI
      FLoaders.successSnackBar(
        title: 'Deleted',
        message: 'Notification deleted successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Toggle selection mode
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedNotifications.clear();
    }
  }

  /// Toggle notification selection
  void toggleNotificationSelection(String notificationId) {
    if (selectedNotifications.contains(notificationId)) {
      selectedNotifications.remove(notificationId);
    } else {
      selectedNotifications.add(notificationId);
    }
  }

  /// Select all notifications in current tab
  void selectAllInCurrentTab() {
    List<NotificationModel> currentTabNotifications;

    switch (tabController.index) {
      case 0:
        currentTabNotifications = allNotifications.toList();
        break;
      case 1:
        currentTabNotifications = unreadNotifications;
        break;
      case 2:
        currentTabNotifications = readNotifications;
        break;
      default:
        currentTabNotifications = allNotifications.toList();
    }

    selectedNotifications.assignAll(
      currentTabNotifications.map((n) => n.notificationId).toList(),
    );
  }

  /// Batch delete selected notifications - real-time update handled by stream
  Future<void> batchDeleteSelected() async {
    if (selectedNotifications.isEmpty) return;

    final confirmed = await FLoaders.showConfirmationDialog(
      title: 'Delete Notifications',
      message: 'Are you sure you want to delete ${selectedNotifications.length} notification(s)?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (confirmed != true) return;

    try {
      FLoaders.showLoading('Deleting notifications...');
      await _repository.batchDeleteNotifications(selectedNotifications.toList());

      // Clear selection - UI will update automatically via stream
      selectedNotifications.clear();
      isSelectionMode.value = false;

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Notifications deleted successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// View notification details
  void viewNotificationDetails(NotificationModel notification) {
    if (!notification.isRead) {
      markAsRead(notification.notificationId);
    }
    Get.to(() => const NotificationDetailScreen(), arguments: notification);
  }

  /// Reset selection state when leaving the screen
  void resetSelectionState() {
    isSelectionMode.value = false;
    selectedNotifications.clear();
  }
}