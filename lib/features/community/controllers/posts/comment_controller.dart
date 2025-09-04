import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/comment_model.dart';

class CommentController extends GetxController {
  static CommentController get instance => Get.find();

  // Dependencies
  // final _commentRepository = Get.put(CommentRepository());
  // final _authController = AuthenticationController.instance;
  // final _userController = UserController.instance;

  // Current comment data
  Rx<Comment> currentComment = Comment.empty().obs;

  // User cache for quick lookup
  final RxMap<String, Map<String, String>> _userCache = <String, Map<String, String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserCache();
  }

  /// Initialize controller with comment data
  void initialize(Comment comment) {
    currentComment.value = comment;
  }

  /// Toggle like on the main comment
  Future<void> toggleLike() async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId.isEmpty) return;

      final isCurrentlyLiked = currentComment.value.likes.contains(currentUserId);

      // Optimistically update UI
      List<String> updatedLikes = List.from(currentComment.value.likes);
      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      _updateComment(likes: updatedLikes);

      // TODO: Send request to backend
      // await _commentRepository.toggleCommentLike(currentComment.value.commentId);

    } catch (e) {
      // Revert optimistic update on error
      await _revertLike();
      _showError('Failed to update like', e.toString());
    }
  }

  /// Edit the main comment
  Future<void> edit(String newContent) async {
    try {
      final originalContent = currentComment.value.content;

      // Optimistically update UI
      _updateComment(content: newContent, updatedAt: DateTime.now());

      // TODO: Update in backend
      // await _commentRepository.updateComment(currentComment.value.commentId, newContent);

      _showSuccess('Comment updated successfully');
    } catch (e) {
      // Revert on error
      // _updateComment(content: originalContent);
      _showError('Failed to update comment', e.toString());
    }
  }

  /// Delete the main comment
  Future<void> delete() async {
    try {
      final confirmed = await _showDeleteConfirmationDialog(
        'Delete Comment',
        'Are you sure you want to delete this comment? This action cannot be undone.',
      );

      if (!confirmed) return;

      // TODO: Delete from backend
      // await _commentRepository.deleteComment(currentComment.value.commentId);

      _showSuccess('Comment deleted successfully');

      // Navigate back or notify parent
      Get.back();
    } catch (e) {
      _showError('Failed to delete comment', e.toString());
    }
  }

  /// Copy comment text to clipboard
  Future<void> copyText() async {
    try {
      await Clipboard.setData(ClipboardData(text: currentComment.value.content));
      _showSuccess('Text copied to clipboard');
    } catch (e) {
      _showError('Failed to copy text', e.toString());
    }
  }

  /// Report comment
  Future<void> report(String reason) async {
    try {
      // TODO: Implement reporting
      // await _commentRepository.reportComment(currentComment.value.commentId, reason);
      _showSuccess('Comment reported. Thank you for your feedback.');
    } catch (e) {
      _showError('Failed to report comment', e.toString());
    }
  }

  /// Update reply count (called from RepliesController)
  void updateReplyCount(int delta) {
    final newCount = currentComment.value.replyCount + delta;
    _updateComment(replyCount: newCount.clamp(0, double.infinity).toInt());
  }

  /// Get current user ID
  String getCurrentUserId() {
    // TODO: Get from authentication service
    // return _authController.user.value?.id ?? '';
    return 'current_user_id';
  }

  /// Get user name by ID
  String getUserName(String userId) {
    return _userCache[userId]?['name'] ?? 'User ${userId.substring(0, 4)}';
  }

  /// Get user avatar by ID
  String getUserAvatar(String userId) {
    return _userCache[userId]?['avatar'] ?? 'https://picsum.photos/100?random=${userId.hashCode}';
  }

  /// Check if current user can delete/edit comment
  bool canModify() {
    return currentComment.value.userId == getCurrentUserId();
  }

  /// Format time ago
  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  /// Clear comment data
  void clearData() {
    currentComment.value = Comment.empty();
  }

  /// Private helper methods
  void _updateComment({
    String? content,
    List<String>? likes,
    int? replyCount,
    DateTime? updatedAt,
  }) {
    currentComment.value = Comment(
      commentId: currentComment.value.commentId,
      userId: currentComment.value.userId,
      content: content ?? currentComment.value.content,
      likes: likes ?? currentComment.value.likes,
      replyCount: replyCount ?? currentComment.value.replyCount,
      createdAt: currentComment.value.createdAt,
      updatedAt: updatedAt ?? currentComment.value.updatedAt,
      replies: currentComment.value.replies,
    );
  }

  Future<bool> _showDeleteConfirmationDialog(String title, String content) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red[800],
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _revertLike() async {
    try {
      // TODO: Fetch fresh comment data
      // final freshComment = await _commentRepository.getComment(currentComment.value.commentId);
      // currentComment.value = freshComment;
    } catch (e) {
      debugPrint('Failed to revert comment like: $e');
    }
  }

  void _initializeUserCache() {
    _userCache.addAll({
      'current_user_id': {
        'name': 'You',
        'avatar': 'https://picsum.photos/100?random=0',
      },
      'anna_mary': {
        'name': 'Anna Mary',
        'avatar': 'https://picsum.photos/100?random=1',
      },
      'mark_ramos': {
        'name': 'Mark Ramos',
        'avatar': 'https://picsum.photos/100?random=2',
      },
      'sarah_johnson': {
        'name': 'Sarah Johnson',
        'avatar': 'https://picsum.photos/100?random=3',
      },
      'mike_chen': {
        'name': 'Mike Chen',
        'avatar': 'https://picsum.photos/100?random=4',
      },
      'lisa_wong': {
        'name': 'Lisa Wong',
        'avatar': 'https://picsum.photos/100?random=5',
      },
      'david_kim': {
        'name': 'David Kim',
        'avatar': 'https://picsum.photos/100?random=6',
      },
    });
  }
}