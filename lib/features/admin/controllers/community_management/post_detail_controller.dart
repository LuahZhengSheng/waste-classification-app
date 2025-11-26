import 'dart:async';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/models/reply_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/data/repositories/community/comment_repository.dart';
import 'package:fyp/data/repositories/community/reply_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

class PostDetailController extends GetxController {
  final PostModel initialPost;

  PostDetailController(this.initialPost);

  final PostRepository _postRepository = Get.put(PostRepository());
  final CommentRepository _commentRepository = Get.put(CommentRepository());
  final ReplyRepository _replyRepository = Get.put(ReplyRepository());
  final UserRepository _userRepository = Get.put(UserRepository());

  // Observables
  final Rx<PostModel> currentPost = PostModel.empty().obs;
  final RxList<Comment> comments = <Comment>[].obs;
  final RxMap<String, UserModel> usersCache = <String, UserModel>{}.obs;
  final RxBool isLoadingComments = false.obs;
  final RxBool hasMoreComments = true.obs;
  final RxBool hasContentChanged = false.obs;
  final RxBool hasCommentsChanged = false.obs;
  final RxString commentsChangeMessage = ''.obs;
  final RxInt currentCommentCount = 0.obs;
  final RxInt commentsPage = 1.obs;
  final int commentsPerPage = 20;

  // For reply expansion
  final RxMap<String, bool> expandedComments = <String, bool>{}.obs;
  final RxMap<String, List<Reply>> commentReplies = <String, List<Reply>>{}.obs;
  final RxMap<String, bool> loadingReplies = <String, bool>{}.obs;
  final RxMap<String, bool> hasMoreRepliesMap = <String, bool>{}.obs;
  final RxMap<String, int> repliesPageMap = <String, int>{}.obs;
  final int repliesPerPage = 20;

  // Stream subscriptions
  StreamSubscription? _postStreamSubscription;
  StreamSubscription? _commentCountStreamSubscription;

  // Last known comment count for detecting changes
  int _lastKnownCommentCount = 0;

  @override
  void onInit() {
    super.onInit();
    currentPost.value = initialPost;
    _lastKnownCommentCount = initialPost.commentCount;
    currentCommentCount.value = initialPost.commentCount;

    _listenToPostChanges();
    _listenToCommentCountChanges();
    loadInitialData();
  }

  void _listenToPostChanges() {
    _postStreamSubscription = _postRepository.getPostByIdStream(initialPost.postId).listen((post) {
      if (post != null) {
        // Check if important fields changed
        if (_hasImportantChanges(currentPost.value, post)) {
          hasContentChanged.value = true;
        }
        currentPost.value = post;
      }
    });
  }

  void _listenToCommentCountChanges() {
    // Listen to post updates to detect comment count changes
    _commentCountStreamSubscription = _postRepository
        .getPostByIdStream(initialPost.postId)
        .listen((post) {
      if (post != null && post.commentCount != _lastKnownCommentCount) {
        final difference = post.commentCount - _lastKnownCommentCount;

        if (difference > 0) {
          commentsChangeMessage.value = 'New comment${difference > 1 ? 's' : ''} available ($difference)';
        } else if (difference < 0) {
          commentsChangeMessage.value = 'Comment${difference.abs() > 1 ? 's' : ''} deleted (${difference.abs()})';
        }

        hasCommentsChanged.value = true;
        _lastKnownCommentCount = post.commentCount;
        currentCommentCount.value = post.commentCount;
      }
    });
  }

  bool _hasImportantChanges(PostModel oldPost, PostModel newPost) {
    if (oldPost.postId.isEmpty) return false;

    return oldPost.content != newPost.content ||
        oldPost.postType != newPost.postType ||
        oldPost.isDisabled != newPost.isDisabled ||
        oldPost.media.length != newPost.media.length;
  }

  Future<void> loadInitialData() async {
    try {
      // Load poster info
      await _loadUserData(currentPost.value.userId);

      // Load initial comments
      await loadMoreComments();
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load post details: $e',
      );
    }
  }

  Future<void> loadMoreComments() async {
    if (isLoadingComments.value || !hasMoreComments.value) return;

    try {
      isLoadingComments.value = true;

      final newComments = await _commentRepository.getCommentsPaginated(
        postId: currentPost.value.postId,
        limit: commentsPerPage,
        lastDoc: comments.isNotEmpty ? null : null, // Simplified for demo
      );

      if (newComments.isEmpty) {
        hasMoreComments.value = false;
      } else {
        // Load user data for comment authors
        final userIds = newComments.map((c) => c.userId).toSet();
        await _loadUsersData(userIds);

        comments.addAll(newComments);
        commentsPage.value++;

        // Check if we have all comments
        if (comments.length >= currentCommentCount.value) {
          hasMoreComments.value = false;
        }
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load comments: $e',
      );
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> toggleCommentExpansion(String commentId) async {
    final isCurrentlyExpanded = expandedComments[commentId] ?? false;

    if (isCurrentlyExpanded) {
      // Collapse - just hide replies
      expandedComments[commentId] = false;
    } else {
      // Expand - load replies if not loaded yet
      expandedComments[commentId] = true;
      expandedComments.refresh(); // Force UI update

      if (commentReplies[commentId] == null || commentReplies[commentId]!.isEmpty) {
        await loadReplies(commentId);
      }
    }
  }

  Future<void> loadReplies(String commentId) async {
    try {
      loadingReplies[commentId] = true;
      loadingReplies.refresh(); // Force UI update
      repliesPageMap[commentId] = 1;

      final replies = await _replyRepository.getRepliesPaginated(
        commentId: commentId,
        limit: repliesPerPage,
      );

      print('Loaded ${replies.length} replies for comment $commentId');

      // Load user data for reply authors
      final userIds = replies.map((r) => r.userId).toSet();
      await _loadUsersData(userIds);

      commentReplies[commentId] = replies;
      commentReplies.refresh(); // Force UI update

      // Check if there are more replies
      final comment = comments.firstWhere((c) => c.commentId == commentId);
      hasMoreRepliesMap[commentId] = replies.length < comment.replyCount;
      hasMoreRepliesMap.refresh(); // Force UI update

      print('Has more replies: ${hasMoreRepliesMap[commentId]}');
      print('Reply count: ${comment.replyCount}, Loaded: ${replies.length}');

    } catch (e) {
      print('Failed to load replies for comment $commentId: $e');
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load replies: $e',
      );
    } finally {
      loadingReplies[commentId] = false;
      loadingReplies.refresh(); // Force UI update
    }
  }

  Future<void> loadMoreReplies(String commentId) async {
    if (loadingReplies[commentId] == true) return;

    try {
      loadingReplies[commentId] = true;

      final currentPage = repliesPageMap[commentId] ?? 1;
      repliesPageMap[commentId] = currentPage + 1;

      final newReplies = await _replyRepository.getRepliesPaginated(
        commentId: commentId,
        limit: repliesPerPage,
      );

      if (newReplies.isEmpty) {
        hasMoreRepliesMap[commentId] = false;
      } else {
        // Load user data for reply authors
        final userIds = newReplies.map((r) => r.userId).toSet();
        await _loadUsersData(userIds);

        final existingReplies = commentReplies[commentId] ?? [];
        commentReplies[commentId] = [...existingReplies, ...newReplies];

        // Check if we have all replies
        final comment = comments.firstWhere((c) => c.commentId == commentId);
        if (commentReplies[commentId]!.length >= comment.replyCount) {
          hasMoreRepliesMap[commentId] = false;
        }
      }
    } catch (e) {
      print('Failed to load more replies: $e');
    } finally {
      loadingReplies[commentId] = false;
    }
  }

  Future<void> _loadUserData(String userId) async {
    if (usersCache.containsKey(userId)) return;

    try {
      final user = await _userRepository.fetchOtherUserDetails(userId);
      usersCache[userId] = user;
    } catch (e) {
      print('Failed to load user data for $userId: $e');
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

  void dismissContentChangedNotification() {
    hasContentChanged.value = false;
  }

  Future<void> refreshComments() async {
    try {
      // Clear current comments and reset pagination
      comments.clear();
      commentsPage.value = 1;
      hasMoreComments.value = true;
      expandedComments.clear();
      commentReplies.clear();
      loadingReplies.clear();
      hasMoreRepliesMap.clear();
      repliesPageMap.clear();

      // Hide the notification
      hasCommentsChanged.value = false;

      // Reload comments
      await loadMoreComments();

      FLoaders.successSnackBar(
        title: 'Refreshed',
        message: 'Comments have been refreshed',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to refresh comments: $e',
      );
    }
  }

  Future<void> togglePostStatus() async {
    try {
      final updatedPost = currentPost.value.copyWith(
        isDisabled: !currentPost.value.isDisabled,
        updatedAt: DateTime.now(),
      );

      await _postRepository.savePost(updatedPost);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Post ${currentPost.value.isDisabled ? 'recovered' : 'disabled'} successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update post: $e',
      );
    }
  }

  @override
  void onClose() {
    _postStreamSubscription?.cancel();
    _commentCountStreamSubscription?.cancel();
    super.onClose();
  }
}