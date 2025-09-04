import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/reply_model.dart';

class ReplyController extends GetxController {
  static ReplyController get instance => Get.find();

  // Dependencies
  // final _commentRepository = Get.put(CommentRepository());

  // Observable variables
  final RxList<Reply> replies = <Reply>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isRefreshing = false.obs;

  // Comment ID for which we're managing replies
  String commentId = '';

  // Text controller for reply input
  final TextEditingController replyController = TextEditingController();
  final FocusNode replyFocusNode = FocusNode();

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreReplies = true;

  // Get CommentController instance
  CommentController get _commentController => CommentController.instance;

  @override
  void onInit() {
    super.onInit();
    // Listen to text controller changes
    replyController.addListener(_validateReplyInput);
  }

  @override
  void onClose() {
    replyController.removeListener(_validateReplyInput);
    replyController.dispose();
    replyFocusNode.dispose();
    super.onClose();
  }

  /// Initialize controller with comment ID
  Future<void> initialize(String commentId, {bool autoFocus = false}) async {
    try {
      this.commentId = commentId;

      // Auto focus reply input if needed
      if (autoFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          replyFocusNode.requestFocus();
        });
      }

      // Load initial replies
      await loadReplies(refresh: true);
    } catch (e) {
      _showError('Failed to initialize', e.toString());
    }
  }

  /// Load replies for the comment
  Future<void> loadReplies({bool refresh = false}) async {
    try {
      if (refresh) {
        _resetPagination();
        replies.clear();
      }

      if (!_hasMoreReplies && !refresh) return;

      // Set loading states
      if (refresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = _currentPage == 1;
        isLoadingMore.value = _currentPage > 1;
      }

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Use mock data for now
      final newReplies = _getMockReplies(commentId, _currentPage);

      if (newReplies.length < _pageSize) {
        _hasMoreReplies = false;
      }

      if (refresh) {
        replies.assignAll(newReplies);
      } else {
        replies.addAll(newReplies);
      }

      _currentPage++;
    } catch (e) {
      _showError('Failed to load replies', e.toString());
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isRefreshing.value = false;
    }
  }

  /// Submit a new reply
  Future<void> submitReply() async {
    if (!_canSubmitReply()) return;

    try {
      isSubmitting.value = true;

      final replyContent = replyController.text.trim();
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Create new reply with temporary ID
      final newReply = Reply(
        replyId: tempId,
        userId: _commentController.getCurrentUserId(),
        content: replyContent,
        likes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to local list at the beginning (optimistic update)
      replies.insert(0, newReply);

      // Update comment reply count
      _commentController.updateReplyCount(1);

      // Clear input
      replyController.clear();
      replyFocusNode.unfocus();

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));

      // Update with real ID from server
      final realReplyId = 'reply_${DateTime.now().millisecondsSinceEpoch}';
      final replyIndex = replies.indexWhere((r) => r.replyId == tempId);
      if (replyIndex != -1) {
        replies[replyIndex] = Reply(
          replyId: realReplyId,
          userId: newReply.userId,
          content: newReply.content,
          likes: newReply.likes,
          createdAt: newReply.createdAt,
          updatedAt: newReply.updatedAt,
        );
      }

      _showSuccess('Reply posted successfully');

    } catch (e) {
      // Revert optimistic update on error
      replies.removeWhere((r) => r.replyId.startsWith('temp_'));
      _commentController.updateReplyCount(-1);
      _showError('Failed to post reply', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Edit a reply
  Future<void> editReply(String replyId, String newContent) async {
    try {
      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex == -1) return;

      final originalReply = replies[replyIndex];

      // Optimistically update UI
      replies[replyIndex] = Reply(
        replyId: originalReply.replyId,
        userId: originalReply.userId,
        content: newContent,
        likes: originalReply.likes,
        createdAt: originalReply.createdAt,
        updatedAt: DateTime.now(),
      );

      // TODO: Send request to backend
      // await _commentRepository.updateReply(replyId, newContent);

      _showSuccess('Reply updated successfully');

    } catch (e) {
      // Revert on error
      await _revertReplyChanges(replyId);
      _showError('Failed to update reply', e.toString());
    }
  }

  /// Toggle like on a reply
  Future<void> toggleReplyLike(String replyId) async {
    try {
      final currentUserId = _commentController.getCurrentUserId();
      if (currentUserId.isEmpty) return;

      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex == -1) return;

      final reply = replies[replyIndex];
      final isCurrentlyLiked = reply.likes.contains(currentUserId);

      // Optimistically update UI
      List<String> updatedLikes = List.from(reply.likes);
      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      replies[replyIndex] = Reply(
        replyId: reply.replyId,
        userId: reply.userId,
        content: reply.content,
        likes: updatedLikes,
        createdAt: reply.createdAt,
        updatedAt: reply.updatedAt,
      );

      // TODO: Send request to backend
      // await _commentRepository.toggleReplyLike(replyId);

    } catch (e) {
      // Revert optimistic update on error
      await _revertReplyLike(replyId);
      _showError('Failed to update like', e.toString());
    }
  }

  /// Delete a reply with confirmation
  Future<void> deleteReply(String replyId) async {
    try {
      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex == -1) return;

      final reply = replies[replyIndex];

      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmationDialog(
        'Delete Reply',
        'Are you sure you want to delete this reply?',
      );

      if (!confirmed) return;

      // Remove from local list first (optimistic update)
      replies.removeAt(replyIndex);
      _commentController.updateReplyCount(-1);

      // TODO: Delete from backend
      // await _commentRepository.deleteReply(replyId);

      _showSuccess('Reply deleted');

    } catch (e) {
      // Rollback on error
      await loadReplies(refresh: true);
      _showError('Failed to delete reply', e.toString());
    }
  }

  /// Copy reply text to clipboard
  Future<void> copyReplyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _showSuccess('Text copied to clipboard');
    } catch (e) {
      _showError('Failed to copy text', e.toString());
    }
  }

  /// Report reply
  Future<void> reportReply(String replyId, String reason) async {
    try {
      // TODO: Implement reporting
      // await _commentRepository.reportReply(replyId, reason);
      _showSuccess('Reply reported. Thank you for your feedback.');
    } catch (e) {
      _showError('Failed to report reply', e.toString());
    }
  }

  /// Check if current user can delete/edit reply
  bool canModifyReply(Reply reply) {
    return reply.userId == _commentController.getCurrentUserId();
  }

  /// Refresh replies
  Future<void> refreshReplies() async {
    await loadReplies(refresh: true);
  }

  /// Load more replies (for pagination)
  Future<void> loadMoreReplies() async {
    if (!_hasMoreReplies || isLoadingMore.value) return;
    await loadReplies();
  }

  /// Check if there are more replies to load
  bool get hasMoreReplies => _hasMoreReplies;

  /// Check if reply input is valid
  bool get isReplyValid => replyController.text.trim().isNotEmpty;

  /// Get replies count
  int get repliesCount => replies.length;

  /// Add external reply (from other parts of the app)
  void addReply(Reply reply) {
    replies.insert(0, reply);
    _commentController.updateReplyCount(1);
  }

  /// Clear all data
  void clearData() {
    replies.clear();
    replyController.clear();
    replyFocusNode.unfocus();
    _resetPagination();
    commentId = '';
  }

  /// Private helper methods
  void _resetPagination() {
    _currentPage = 1;
    _hasMoreReplies = true;
  }

  bool _canSubmitReply() {
    return replyController.text.trim().isNotEmpty && !isSubmitting.value;
  }

  void _validateReplyInput() {
    // This could be used to show/hide send button or show character count
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

  Future<void> _revertReplyLike(String replyId) async {
    try {
      // TODO: Fetch fresh reply data
      // final freshReply = await _commentRepository.getReply(replyId);
      // final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      // if (replyIndex != -1) {
      //   replies[replyIndex] = freshReply;
      // }
    } catch (e) {
      debugPrint('Failed to revert reply like: $e');
    }
  }

  Future<void> _revertReplyChanges(String replyId) async {
    try {
      // TODO: Fetch fresh reply data
      // final freshReply = await _commentRepository.getReply(replyId);
      // final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      // if (replyIndex != -1) {
      //   replies[replyIndex] = freshReply;
      // }
    } catch (e) {
      debugPrint('Failed to revert reply changes: $e');
    }
  }

  /// Mock data for testing
  List<Reply> _getMockReplies(String commentId, int page) {
    if (page > 1) return []; // No more data for pagination demo

    final mockReplies = <Reply>[];

    // Different replies based on comment ID
    if (commentId == 'comment1') {
      mockReplies.addAll([
        Reply(
          replyId: 'reply1_1',
          userId: 'sarah_johnson',
          content: 'I totally agree! This is amazing work.',
          likes: ['mark_ramos', 'current_user_id'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        Reply(
          replyId: 'reply1_2',
          userId: 'mike_chen',
          content: 'Thanks for sharing this with us! Really helpful.',
          likes: ['anna_mary'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        Reply(
          replyId: 'reply1_3',
          userId: 'lisa_wong',
          content: 'Could you share more details about this approach?',
          likes: ['david_kim', 'mark_ramos', 'sarah_johnson'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        Reply(
          replyId: 'reply1_4',
          userId: 'current_user_id',
          content: 'Great question! I\'ll post more details soon.',
          likes: ['lisa_wong'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ]);
    } else if (commentId == 'comment2') {
      mockReplies.addAll([
        Reply(
          replyId: 'reply2_1',
          userId: 'mark_ramos',
          content: 'You\'re welcome! Glad it helped.',
          likes: ['current_user_id', 'mike_chen'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        Reply(
          replyId: 'reply2_2',
          userId: 'david_kim',
          content: 'I had the same question too!',
          likes: ['sarah_johnson'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        ),
      ]);
    }

    return mockReplies;
  }
}