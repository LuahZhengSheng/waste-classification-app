import 'package:flutter/cupertino.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';

class PostDetailsController extends GetxController {
  final _post = PostModel.empty().obs;
  final _comments = <Comment>[].obs;
  final _commentSortType = 'Top comments'.obs;
  final _isLoading = false.obs;
  final _userCache = <String, Map<String, String>>{}.obs;

  final commentController = TextEditingController();

  // Getters
  Rx<PostModel> get post => _post;
  List<Comment> get comments => _comments;
  RxString get commentSortType => _commentSortType;
  RxBool get isLoading => _isLoading;

  List<Comment> get sortedComments {
    final commentsList = List<Comment>.from(_comments);

    if (_commentSortType.value == 'Top comments') {
      commentsList.sort((a, b) => b.likes.length.compareTo(a.likes.length));
    } else {
      commentsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return commentsList;
  }

  // Load post details and comments
  Future<void> loadPostDetails(String postId) async {
    _isLoading.value = true;

    try {
      // Load post
      _post.value = _getMockPost(postId);

      // Load comments
      _comments.assignAll(_getMockComments(postId));

    } catch (e) {
      Get.snackbar('Error', 'Failed to load post details: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Set comment sort type
  void setSortType(String sortType) {
    _commentSortType.value = sortType;
  }

  // Toggle post like
  Future<void> togglePostLike() async {
    try {
      final currentUserId = getCurrentUserId();

      if (_post.value.likes.contains(currentUserId)) {
        _post.value.likes.remove(currentUserId);
      } else {
        _post.value.likes.add(currentUserId);
      }

      _post.refresh();

    } catch (e) {
      Get.snackbar('Error', 'Failed to update like: $e');
    }
  }

  // Toggle comment like
  Future<void> toggleCommentLike(String commentId) async {
    try {
      final currentUserId = getCurrentUserId();
      final commentIndex = _comments.indexWhere((c) => c.commentId == commentId);

      if (commentIndex != -1) {
        if (_comments[commentIndex].likes.contains(currentUserId)) {
          _comments[commentIndex].likes.remove(currentUserId);
        } else {
          _comments[commentIndex].likes.add(currentUserId);
        }
        _comments.refresh();
      }

    } catch (e) {
      Get.snackbar('Error', 'Failed to update comment like: $e');
    }
  }

  // Add comment
  Future<void> addComment() async {
    final content = commentController.text.trim();
    if (content.isEmpty) return;

    try {
      final newComment = Comment(
        commentId: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        userId: getCurrentUserId(),
        content: content,
        createdAt: DateTime.now(),
      );

      _comments.insert(0, newComment);
      commentController.clear();

      Get.snackbar('Success', 'Comment added successfully');

    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment: $e');
    }
  }

  // Get current user ID
  String getCurrentUserId() {
    return 'current_user_id';
  }

  // Get user name by ID
  String getUserName(String userId) {
    return _userCache[userId]?['name'] ?? 'User ${userId.substring(0, 4)}';
  }

  // Get user avatar by ID
  String getUserAvatar(String userId) {
    return _userCache[userId]?['avatar'] ?? 'https://picsum.photos/100?random=$userId';
  }

  // Mock data
  PostModel _getMockPost(String postId) {
    return PostModel(
      postId: postId,
      userId: 'anna_mary',
      postType: 'Tips',
      content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin velit felis, venenatis tempus metus a, tristique tempus metus. Integer accumsan ipsum a metus lacinia, sed auctor felis dapibus.',
      media: [
        "https://picsum.photos/300/200?random=1",
        "https://picsum.photos/300/200?random=2",
        "https://picsum.photos/300/200?random=3",
      ],
      likes: ['user1', 'user2'],
      commentCount: 35,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  List<Comment> _getMockComments(String postId) {
    return [
      Comment(
        commentId: 'comment1',
        userId: 'mark_ramos',
        content: 'Great work! Well done girl. 👍',
        likes: ['user1', 'user2', 'user3'],
        replyCount: 8,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Comment(
        commentId: 'comment2',
        userId: 'sarah_johnson',
        content: 'This is so helpful, thanks for sharing!',
        likes: ['user1'],
        replyCount: 2,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      Comment(
        commentId: 'comment3',
        userId: 'mike_chen',
        content: 'Amazing tips! I\'ve been looking for something like this.',
        likes: ['user2', 'user4', 'user5', 'user6'],
        replyCount: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}