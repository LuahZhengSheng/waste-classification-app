import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/community/models/comment_model.dart';

class PostModel {
  final String postId;           // Firestore doc ID
  final String userId;           // Author ID
  final String postType;         // Type of post (tip, discussion, question, etc.)
  final String content;          // Post content
  List<String> media;            // List of media URLs
  List<String> likes;            // User IDs who liked this post
  int commentCount;              // Number of comments (for display)
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isDisabled;               // Whether this post is disabled
  List<Comment> comments;        // Loaded comments (optional)

  PostModel({
    required this.postId,
    required this.userId,
    required this.postType,
    required this.content,
    List<String>? media,
    List<String>? likes,
    this.commentCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDisabled = false,
    List<Comment>? comments,
  })  : media = media ?? [],
        likes = likes ?? [],
        comments = comments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create an empty Post object
  static PostModel empty() => PostModel(
    postId: '',
    userId: '',
    postType: '',
    content: '',
  );

  /// Convert Post to Firestore JSON (without comments, since they are separate docs)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'postType': postType,
      'content': content,
      'media': media,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDisabled': isDisabled,
    };
  }

  /// Create Post from Firestore snapshot
  factory PostModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null for post ID: ${doc.id}");
    }
    return PostModel(
      postId: doc.id,
      userId: data['userId'] ?? '',
      postType: data['postType'] ?? '',
      content: data['content'] ?? '',
      media: List<String>.from(data['media'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDisabled: data['isDisabled'] ?? false,
    );
  }

  /// Attach loaded comments to the Post object
  PostModel withComments(List<Comment> loadedComments) {
    return PostModel(
      postId: postId,
      userId: userId,
      postType: postType,
      content: content,
      media: media,
      likes: likes,
      commentCount: commentCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDisabled: isDisabled,
      comments: loadedComments,
    );
  }
}
