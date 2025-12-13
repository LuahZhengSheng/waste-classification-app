import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/create_post/create_post.dart';
import 'package:fyp/features/community/screens/view_post/post_detail.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

class PostsController extends GetxController with SingleGetTickerProviderMixin {
  static PostsController get instance => Get.find();

  // Repositories
  final PostRepository _postRepository = Get.put(PostRepository());

  // Controllers
  late TabController tabController;
  final searchController = TextEditingController();

  // Reactive variables
  final selectedTimeFilter = TimeFilter.allTime.obs;
  final searchQuery = ''.obs;
  final isLoading = true.obs; // 初始设为 true

  // Posts streams for different tabs
  final allPosts = <PostModel>[].obs;
  final tipPosts = <PostModel>[].obs;
  final questionPosts = <PostModel>[].obs;
  final discussionPosts = <PostModel>[].obs;

  // Combined filtered posts for current tab
  final filteredPosts = <PostModel>[].obs;

  // 添加一个标志来跟踪是否已经收到数据
  final _hasReceivedInitialData = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    _initializePosts();
    _setupTabListener();
    _setupSearchListener();
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Initialize posts streams
  void _initializePosts() {
    try {
      // 设置初始加载状态
      isLoading.value = true;
      _hasReceivedInitialData.value = false;

      // 监听所有相关列表的变化
      ever(allPosts, (_) => _filterPosts());

      _postRepository.getAllPostsStream().listen((posts) {
        // 标记已经收到初始数据
        _hasReceivedInitialData.value = true;

        allPosts.assignAll(posts);
        _categorizePosts(posts);

        // 数据加载完成后，停止加载状态
        isLoading.value = false;
      }, onError: (error) {
        // 出错时也停止加载状态
        _hasReceivedInitialData.value = true;
        isLoading.value = false;
        FLoaders.errorSnackBar(title: 'Error', message: error.toString());
      });

      // 添加超时保护，防止一直显示loading
      Future.delayed(const Duration(seconds: 10), () {
        if (!_hasReceivedInitialData.value) {
          _hasReceivedInitialData.value = true;
          isLoading.value = false;
          FLoaders.errorSnackBar(title: 'Timeout', message: 'Failed to load posts');
        }
      });
    } catch (e) {
      // 出错时停止加载状态
      _hasReceivedInitialData.value = true;
      isLoading.value = false;
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Categorize posts by type using enum
  void _categorizePosts(List<PostModel> posts) {
    tipPosts.assignAll(
        posts.where((post) => PostType.fromString(post.postType) == PostType.tip).toList());
    questionPosts.assignAll(
        posts.where((post) => PostType.fromString(post.postType) == PostType.question).toList());
    discussionPosts.assignAll(
        posts.where((post) => PostType.fromString(post.postType) == PostType.discussion).toList());
  }

  /// Setup tab listener
  void _setupTabListener() {
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        _filterPosts();
      }
    });
  }

  /// Setup search listener
  void _setupSearchListener() {
    ever(searchQuery, (_) => _filterPosts());
    ever(selectedTimeFilter, (_) => _filterPosts());
  }

  /// Filter posts based on current tab, search query and time filter
  void _filterPosts() {
    // 如果还在初始加载中，不进行过滤
    if (isLoading.value && !_hasReceivedInitialData.value) return;

    try {
      List<PostModel> sourcePosts;

      // Get posts based on current tab
      switch (tabController.index) {
        case 0: // All
          sourcePosts = List.from(allPosts);
          break;
        case 1: // Tips
          sourcePosts = List.from(tipPosts);
          break;
        case 2: // Questions
          sourcePosts = List.from(questionPosts);
          break;
        case 3: // Discussion
          sourcePosts = List.from(discussionPosts);
          break;
        default:
          sourcePosts = List.from(allPosts);
      }

      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        sourcePosts = sourcePosts
            .where((post) =>
            post.content.toLowerCase().contains(searchQuery.value.toLowerCase()))
            .toList();
      }

      // Apply time filter
      sourcePosts = _applyTimeFilter(sourcePosts);

      // Update filtered posts
      filteredPosts.assignAll(sourcePosts);
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Apply time filter to posts using enum
  List<PostModel> _applyTimeFilter(List<PostModel> posts) {
    final now = DateTime.now();

    switch (selectedTimeFilter.value) {
      case TimeFilter.today:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 1))))
            .toList();
      case TimeFilter.thisWeek:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 7))))
            .toList();
      case TimeFilter.thisMonth:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 30))))
            .toList();
      case TimeFilter.thisYear:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 365))))
            .toList();
      case TimeFilter.allTime:
        return posts;
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set time filter using enum
  void setTimeFilter(TimeFilter filter) {
    selectedTimeFilter.value = filter;
  }

  /// Get current user ID
  String getCurrentUserId() {
    return AuthenticationRepository.instance.authUser?.uid ?? '';
  }

  /// Check if post belongs to current user
  bool isUserPost(PostModel post) {
    return post.userId == getCurrentUserId();
  }

  /// Toggle like
  Future<void> toggleLike(String postId) async {
    try {
      // 1. ✅ 找到当前 post
      final postIndex = allPosts.indexWhere((p) => p.postId == postId);
      if (postIndex == -1) return;

      final originalPost = allPosts[postIndex]; // 保存原始状态用于回滚
      final currentUserId = getCurrentUserId();

      // 2. ✅ 计算新的 likes 列表
      final newLikes = List<String>.from(originalPost.likes);
      final isCurrentlyLiked = newLikes.contains(currentUserId);

      if (isCurrentlyLiked) {
        newLikes.remove(currentUserId);
      } else {
        newLikes.add(currentUserId);
      }

      // 3. ✅ 乐观更新：立即更新本地 UI
      allPosts[postIndex] = originalPost.copyWith(likes: newLikes);
      allPosts.refresh();
      _categorizePosts(allPosts);
      _filterPosts(); // 重新过滤以更新 filteredPosts

      // 4. ✅ 异步更新 Firestore
      try {
        await _postRepository.updatePostLikes(postId, newLikes);
      } catch (e) {
        // ❌ 更新失败，回滚到原始状态
        allPosts[postIndex] = originalPost;
        allPosts.refresh();
        _categorizePosts(allPosts);
        _filterPosts();

        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to update like',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Something went wrong',
      );
    }
  }

  /// Navigate to post details
  void navigateToPostDetails(String postId) {
    Get.to(() => PostDetailsScreen(postId: postId));
  }

  /// Navigate to edit post
  void navigateToEditPost(PostModel post) {
    Get.to(() => CreatePostScreen(), arguments: post);
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    try {
      FLoaders.showLoading('Deleting post...');
      print('object');
      await _postRepository.deletePost(postId);
      allPosts.removeWhere((post) => post.postId == postId);
      _categorizePosts(allPosts);
      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Post deleted successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      // 重新初始化数据
      _initializePosts();
    } catch (e) {
      isLoading.value = false;
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Update post reports
  Future<void> updatePostReports(String postId, Map<String, List<String>> reports) async {
    try {
      await _postRepository.updatePostReports(postId, reports);

      // Update local state
      final index = allPosts.indexWhere((p) => p.postId == postId);
      if (index != -1) {
        allPosts[index] = allPosts[index].copyWith(reports: reports);
        allPosts.refresh();
        _categorizePosts(allPosts);
      }
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}