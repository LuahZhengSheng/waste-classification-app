import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../../data/repositories/personalization/notification_repository.dart';

enum PostStatusFilter { active, disabled }

class CommunityManagementController extends GetxController {
  static CommunityManagementController get instance => Get.find();

  final PostRepository _postRepository = Get.put(PostRepository());
  final UserRepository _userRepository = Get.put(UserRepository());
  final NotificationRepository _notificationRepository = Get.put(NotificationRepository());
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<PostModel> allPosts = <PostModel>[].obs;
  final RxList<PostModel> filteredPosts = <PostModel>[].obs;
  final RxMap<String, UserModel> usersCache = <String, UserModel>{}.obs;
  final RxString searchQuery = ''.obs;
  final Rx<PostStatusFilter> currentFilter = PostStatusFilter.active.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 4.obs; // 默认按 reporters (column 4) 排序
  final RxBool sortAscending = false.obs; // 默认降序（高到低）
  final RxBool isLoading = true.obs;
  final RxBool hasNewPosts = false.obs;
  final RxString newPostsMessage = ''.obs;

  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'postType': null,
    'mediaType': null,
    'dateRange': null,
  }.obs;

  // For tracking post count changes
  int _previousPostCount = 0;
  bool _isInitialLoad = true;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    _setupPostsCountListener();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(),
        time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
    ever(currentFilter, (_) => applyFiltersAndSearch());
  }

  void _setupPostsCountListener() {
    _postRepository.getPostsCountStream().listen((newCount) {
      if (_isInitialLoad) {
        _previousPostCount = newCount;
        _isInitialLoad = false;
        return;
      }

      if (newCount != _previousPostCount) {
        final difference = newCount - _previousPostCount;
        if (difference > 0) {
          newPostsMessage.value = '$difference new post${difference > 1 ? 's' : ''} available';
        } else if (difference < 0) {
          newPostsMessage.value = '${difference.abs()} post${difference.abs() > 1 ? 's' : ''} deleted';
        }
        hasNewPosts.value = true;
        _previousPostCount = newCount;
      }
    }, onError: (error) {
      print('Error listening to posts count: $error');
    });
  }

  Future<void> loadPosts() async {
    isLoading.value = true;

    try {
      final posts = await _postRepository.getAllPosts();
      allPosts.value = posts;

      final userIds = posts.map((post) => post.userId).toSet();
      await _loadUsersData(userIds);

      applyFiltersAndSearch();

      hasNewPosts.value = false;
      newPostsMessage.value = '';

    } catch (error) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load posts: $error',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUsersData(Set<String> userIds) async {
    try {
      final newUserIds = userIds.where((id) => !usersCache.containsKey(id)).toSet();

      if (newUserIds.isNotEmpty) {
        final usersData = await _userRepository.getUsersProfileData(newUserIds);
        usersCache.addAll(usersData);
      }
    } catch (e) {
      print('Failed to load users data: $e');
    }
  }

  void refreshPosts() {
    loadPosts();
  }

  void changeFilter(PostStatusFilter filter) {
    currentFilter.value = filter;
  }

  void applyFiltersAndSearch() {
    List<PostModel> result = List.from(allPosts);

    // Apply status filter
    switch (currentFilter.value) {
      case PostStatusFilter.active:
        result = result.where((post) => !post.isDisabled).toList();
        break;
      case PostStatusFilter.disabled:
        result = result.where((post) => post.isDisabled).toList();
        break;
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((post) {
        final user = usersCache[post.userId];
        return post.content.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            post.postType.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            post.postId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (user?.username.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
            (user?.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply post type filter
    if (activeFilters['postType'] != null) {
      result = result.where((post) => post.postType == activeFilters['postType']).toList();
    }

    // Apply media type filter
    if (activeFilters['mediaType'] != null) {
      switch (activeFilters['mediaType']) {
        case 'hasMedia':
          result = result.where((post) => post.media.isNotEmpty).toList();
          break;
        case 'noMedia':
          result = result.where((post) => post.media.isEmpty).toList();
          break;
      }
    }

    // Apply date range filter
    if (activeFilters['dateRange'] != null) {
      final now = DateTime.now();
      DateTime? startDate;

      switch (activeFilters['dateRange']) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'last7days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'last30days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'thisMonth':
          startDate = DateTime(now.year, now.month, 1);
          break;
      }

      if (startDate != null) {
        result = result.where((post) => post.createdAt.isAfter(startDate!)).toList();
      }
    }

    filteredPosts.value = result;
    currentPage.value = 1;

    // 应用初始排序
    sortPosts(sortColumnIndex.value, sortAscending.value);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  bool get hasActiveFilters {
    return activeFilters['postType'] != null ||
        activeFilters['mediaType'] != null ||
        activeFilters['dateRange'] != null;
  }

  void sortPosts(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredPosts.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Post ID
          aValue = a.postId;
          bValue = b.postId;
          break;
        case 1: // Username
          aValue = usersCache[a.userId]?.username ?? '';
          bValue = usersCache[b.userId]?.username ?? '';
          break;
        case 2: // Post Type
          aValue = a.postType;
          bValue = b.postType;
          break;
        case 3: // Media count
          aValue = a.media.length;
          bValue = b.media.length;
          break;
        case 4: // Reporters count
          aValue = a.reportCount;
          bValue = b.reportCount;
          break;
        case 5: // Likes count
          aValue = a.likes.length;
          bValue = b.likes.length;
          break;
        case 6: // Comments count
          aValue = a.commentCount;
          bValue = b.commentCount;
          break;
        case 7: // Created At
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 8: // Updated At
          aValue = a.updatedAt ?? DateTime(1970);
          bValue = b.updatedAt ?? DateTime(1970);
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });
  }

  Future<void> togglePostStatus(PostModel post) async {
    try {
      final isDisabling = !post.isDisabled;

      final updatedPost = post.copyWith(
        isDisabled: isDisabling,
      );

      await _postRepository.savePost(updatedPost);

      await _createPostStatusNotification(
        userId: post.userId,
        postId: post.postId,
        postContent: post.content,
        isDisabled: isDisabling,
      );

      _updateLocalPost(updatedPost);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Post ${isDisabling ? 'disabled' : 'recovered'} successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update post: $e',
      );
    }
  }

  /// 🆕 清空 post 的所有 reports
  Future<void> clearPostReports(PostModel post) async {
    try {
      // 创建一个清空 reports 的 post
      final updatedPost = post.copyWith(
        reports: {},
        reporters: [],
      );

      await _postRepository.savePost(updatedPost);

      _updateLocalPost(updatedPost);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'All reports have been cleared for this post',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to clear reports: $e',
      );
    }
  }

  Future<void> _createPostStatusNotification({
    required String userId,
    required String postId,
    required String postContent,
    required bool isDisabled,
  }) async {
    try {
      final contentPreview = postContent.length > 50
          ? '${postContent.substring(0, 50)}...'
          : postContent;

      if (isDisabled) {
        await _notificationRepository.createNotificationForUser(
          userId: userId,
          title: 'Post Disabled',
          message: 'Your post "$contentPreview" has been disabled by an administrator.',
          type: 'community_post',
        );
      } else {
        await _notificationRepository.createNotificationForUser(
          userId: userId,
          title: 'Post Recovered',
          message: 'Your post "$contentPreview" has been recovered and is now visible.',
          type: 'community_post',
          eventId: postId,
        );
      }
    } catch (e) {
      print('Failed to create notification: $e');
    }
  }

  void _updateLocalPost(PostModel updatedPost) {
    final index = allPosts.indexWhere((p) => p.postId == updatedPost.postId);
    if (index != -1) {
      allPosts[index] = updatedPost;
    }

    final filteredIndex = filteredPosts.indexWhere((p) => p.postId == updatedPost.postId);
    if (filteredIndex != -1) {
      filteredPosts[filteredIndex] = updatedPost;
    }

    applyFiltersAndSearch();
  }

  // Pagination
  List<PostModel> get paginatedPosts {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredPosts.length);

    if (startIndex >= filteredPosts.length) {
      return [];
    }

    return filteredPosts.sublist(startIndex, endIndex);
  }

  int get totalPosts => filteredPosts.length;
  int get totalPages => (totalPosts / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalPosts);

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => currentPage.value < totalPages;

  void previousPage() {
    if (canGoPreviousPage) currentPage.value--;
  }

  void nextPage() {
    if (canGoNextPage) currentPage.value++;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}