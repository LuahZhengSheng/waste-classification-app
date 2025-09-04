import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';

class PostsController extends GetxController {
  // Observable variables
  final _posts = <PostModel>[].obs;
  final _filteredPosts = <PostModel>[].obs;
  final _selectedFilter = 'All'.obs;
  final _userCache = <String, Map<String, String>>{}.obs; // userId -> {name, avatar}

  // Getters
  List<PostModel> get posts => _posts;
  List<PostModel> get filteredPosts => _filteredPosts;
  RxString get selectedFilter => _selectedFilter;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    ever(_posts, (_) => _applyFilter());
    ever(_selectedFilter, (_) => _applyFilter());
  }

  // Load posts from Firestore
  Future<void> loadPosts() async {
    try {
      // TODO: Implement Firestore query
      // For now, using mock data
      _posts.assignAll(_getMockPosts());
      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load posts: $e');
    }
  }

  // Apply filter to posts
  void _applyFilter() {
    if (_selectedFilter.value == 'All') {
      _filteredPosts.assignAll(_posts);
    } else {
      _filteredPosts.assignAll(_posts.where((post) =>
      post.postType.toLowerCase() == _selectedFilter.value.toLowerCase()
      ));
    }
  }

  // Set filter
  void setFilter(String filter) {
    _selectedFilter.value = filter;
  }

  // Toggle like on post
  Future<void> toggleLike(String postId) async {
    try {
      final postIndex = _posts.indexWhere((p) => p.postId == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final currentUserId = getCurrentUserId();

        if (post.likes.contains(currentUserId)) {
          post.likes.remove(currentUserId);
        } else {
          post.likes.add(currentUserId);
        }

        _posts[postIndex] = post;
        _posts.refresh();

        // TODO: Update Firestore
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update like: $e');
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      _posts.removeWhere((post) => post.postId == postId);
      // TODO: Delete from Firestore
      Get.snackbar('Success', 'Post deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete post: $e');
    }
  }

  // Get current user ID
  String getCurrentUserId() {
    // TODO: Get from authentication service
    return 'current_user_id';
  }

  // Get user name by ID
  String getUserName(String userId) {
    // TODO: Implement user lookup
    return _userCache[userId]?['name'] ?? 'Unknown User';
  }

  // Get user avatar by ID
  String getUserAvatar(String userId) {
    // TODO: Implement user lookup
    return _userCache[userId]?['avatar'] ?? 'https://via.placeholder.com/150';
  }

  // Mock data for testing
  List<PostModel> _getMockPosts() {
    return [
      PostModel(
        postId: '1',
        userId: 'user1',
        postType: 'Tips',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin velit felis, venenatis tempus metus a, tristique tempus metus.',
        media: [
          "https://picsum.photos/200",
          "https://picsum.photos/200",
          "https://picsum.photos/200",
        ],
        likes: ['user2', 'user3'],
        commentCount: 35,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PostModel(
        postId: '2',
        userId: 'current_user_id',
        postType: 'Question',
        content: 'How do you handle state management in Flutter? Looking for best practices.',
        likes: ['user1'],
        commentCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}