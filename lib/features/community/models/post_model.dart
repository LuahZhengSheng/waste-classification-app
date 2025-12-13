import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/community/models/comment_model.dart';

class PostModel {
  final String postId;
  final String userId;
  final String postType;
  final String content;
  List<String> media;
  List<String> likes;
  int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  bool isDisabled;
  List<Comment> comments;

  // 🎯 举报相关字段
  Map<String, List<String>> reports; // 详细记录：{reportType: [userId1, userId2]}
  List<String> reporters; // 🆕 去重的举报用户列表（像 likes 一样）

  PostModel({
    String? postId,
    required this.userId,
    required this.postType,
    required this.content,
    List<String>? media,
    List<String>? likes,
    this.commentCount = 0,
    DateTime? createdAt,
    this.updatedAt,
    this.isDisabled = false,
    List<Comment>? comments,
    Map<String, List<String>>? reports,
    List<String>? reporters,  // ✅ 构造函数参数
  })  : postId = postId ?? '',
        media = media ?? [],
        likes = likes ?? [],
        comments = comments ?? [],
        reports = reports ?? {},
        reporters = reporters ?? [],  // ✅ 默认空列表
        createdAt = createdAt ?? DateTime.now();

  /// Create an empty Post object
  static PostModel empty() => PostModel(
    userId: '',
    postType: '',
    content: '',
  );

  /// Convert Post to Firestore JSON
  Map<String, dynamic> toJson() {
    final json = {
      'userId': userId,
      'postType': postType,
      'content': content,
      'media': media,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDisabled': isDisabled,
      'reports': reports,
      'reporters': reporters, // 🆕
    };

    if (updatedAt != null) {
      json['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return json;
  }

  /// Create Post from Firestore snapshot
  factory PostModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null for community ID: ${doc.id}");
    }

    // Parse reports map
    Map<String, List<String>> reportsMap = {};
    if (data['reports'] != null && data['reports'] is Map) {
      final rawReports = data['reports'] as Map;
      rawReports.forEach((key, value) {
        if (value is List) {
          reportsMap[key.toString()] = List<String>.from(value);
        }
      });
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
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isDisabled: data['isDisabled'] ?? false,
      reports: reportsMap,
      reporters: List<String>.from(data['reporters'] ?? []), // 🆕
    );
  }

  /// CopyWith method for easy updates
  PostModel copyWith({
    String? postId,
    String? userId,
    String? postType,
    String? content,
    List<String>? media,
    List<String>? likes,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDisabled,
    List<Comment>? comments,
    Map<String, List<String>>? reports,
    List<String>? reporters, // 🆕
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      postType: postType ?? this.postType,
      content: content ?? this.content,
      media: media ?? this.media,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDisabled: isDisabled ?? this.isDisabled,
      comments: comments ?? this.comments,
      reports: reports ?? this.reports,
      reporters: reporters ?? this.reporters, // 🆕
    );
  }

  /// Check if the post was edited
  bool get wasEdited => updatedAt != null &&
      updatedAt!.difference(createdAt).inSeconds > 60;

  /// 🆕 Get report count - 像 likes.length 一样
  int get reportCount => reporters.length;

  /// 🆕 Get total report instances (一个用户可能多次举报不同类型)
  int get totalReportInstances {
    int total = 0;
    reports.forEach((key, value) {
      total += value.length;
    });
    return total;
  }

  /// Check if user has reported this post (检查 reporters list)
  bool hasUserReported(String userId) => reporters.contains(userId);

  /// Get user's reported options
  List<String> getUserReportedOptions(String userId) {
    List<String> reportedOptions = [];
    reports.forEach((option, userList) {
      if (userList.contains(option)) {
        reportedOptions.add(option);
      }
    });
    return reportedOptions;
  }

  /// 🆕 从 reports map 重新计算 reporters list（数据同步）
  PostModel syncReporters() {
    Set<String> uniqueReporters = {};
    reports.forEach((key, value) {
      uniqueReporters.addAll(value);
    });
    return copyWith(reporters: uniqueReporters.toList());
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
      reports: reports,
      reporters: reporters, // 🆕
    );
  }

  @override
  String toString() {
    return 'PostModel(postId: $postId, userId: $userId, postType: $postType, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content}, likes: ${likes.length}, commentCount: $commentCount, reporters: ${reporters.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostModel &&
        other.postId == postId &&
        other.userId == userId &&
        other.postType == postType &&
        other.content == content &&
        other.media == media &&
        other.likes == likes &&
        other.commentCount == commentCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isDisabled == isDisabled &&
        other.comments == comments &&
        other.reports == reports &&
        other.reporters == reporters; // 🆕
  }

  @override
  int get hashCode {
    return postId.hashCode ^
    userId.hashCode ^
    postType.hashCode ^
    content.hashCode ^
    media.hashCode ^
    likes.hashCode ^
    commentCount.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    isDisabled.hashCode ^
    comments.hashCode ^
    reports.hashCode ^
    reporters.hashCode; // 🆕
  }
}
