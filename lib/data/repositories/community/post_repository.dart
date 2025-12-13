import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

import '../../../utils/helpers/media_helpers.dart';
import 'comment_repository.dart';
import 'reply_repository.dart';

class PostRepository extends GetxController {
  static PostRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;


  CommentRepository get _commentRepository {
    try {
      return Get.find<CommentRepository>();
    } catch (e) {
      // 如果找不到，就创建一个
      return Get.put(CommentRepository());
    }
  }

  ReplyRepository get _replyRepository {
    try {
      return Get.find<ReplyRepository>();
    } catch (e) {
      // 如果找不到，就创建一个
      return Get.put(ReplyRepository());
    }
  }

  /// Get original post data without converting media paths to URLs
  /// This is used for edit mode to get the original storage paths
  Future<PostModel?> getOriginalPost(String postId) async {
    try {
      final doc = await _db.collection("posts").doc(postId).get();
      if (doc.exists) {
        // Use fromSnapshot without URL conversion to get original storage paths
        return PostModel.fromSnapshot(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to get original post: $e';
    }
  }

  /// Get full media URL from storage path
  Future<String> getMediaUrl(String storagePath, String userId) async {
    try {
      final isVideo = storagePath.contains('.mp4') ||
          storagePath.contains('.mov') ||
          storagePath.contains('.avi');

      final fullPath = isVideo
          ? 'posts/$userId/videos/$storagePath'
          : 'posts/$userId/images/$storagePath';

      return await storage.ref(fullPath).getDownloadURL();
    } catch (e) {
      throw 'Failed to get media URL: $e';
    }
  }

  /// Get media URLs for a list of storage paths
  Future<List<String>> getMediaUrls(List<String> storagePaths, String userId) async {
    try {
      final urls = <String>[];
      for (var path in storagePaths) {
        final url = await getMediaUrl(path, userId);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw 'Failed to get media URLs: $e';
    }
  }

  /// Get all posts using Future (instead of Stream)
  Future<List<PostModel>> getAllPosts() async {
    try {
      final snapshot = await _db
          .collection("posts")
          .orderBy('createdAt', descending: true)
          .get();

      final posts = <PostModel>[];

      print('=== DEBUG: Firestore Posts Query (Future) ===');
      print('Total documents in snapshot: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        try {
          print('--- Processing post ${doc.id} ---');
          print('Document data: ${doc.data()}');

          var post = PostModel.fromSnapshot(doc);

          // 打印帖子的关键信息，特别是 isDisabled 字段
          print('Post ID: ${post.postId}');
          print('User ID: ${post.userId}');
          print('Content: ${post.content.substring(0, min(50, post.content.length))}...');
          print('Post Type: ${post.postType}');
          print('isDisabled: ${post.isDisabled}');
          print('Created At: ${post.createdAt}');
          print('Media count: ${post.media.length}');

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            print('Converting media paths to URLs...');
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
            print('Media URLs converted: ${urls.length}');
          }

          posts.add(post);
          print('✓ Successfully processed post ${post.postId}\n');
        } catch (e) {
          print('✗ Error processing post ${doc.id}: $e');
          print('Document data that caused error: ${doc.data()}');
          // Skip this post and continue with others
        }
      }

      // 在返回前打印总结信息
      print('=== DEBUG: Posts Processing Summary ===');
      print('Total posts successfully processed: ${posts.length}');
      print('Disabled posts count: ${posts.where((p) => p.isDisabled).length}');
      print('Active posts count: ${posts.where((p) => !p.isDisabled).length}');

      // 打印所有帖子的 isDisabled 状态
      print('All posts isDisabled status:');
      for (var post in posts) {
        print('  - ${post.postId}: isDisabled = ${post.isDisabled}');
      }
      print('=== DEBUG: End of Posts Query ===\n');

      return posts;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to load posts: $e';
    }
  }

  /// Stream to listen to posts count changes only
  Stream<int> getPostsCountStream() {
    return _db
        .collection("posts")
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Stream to get all posts in real-time (with media URLs)
  Stream<List<PostModel>> getAllPostsStream() {
    return _db
        .collection("posts")
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      print('=== DEBUG: Firestore Posts Query ===');
      print('Total documents in snapshot: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        try {
          print('--- Processing post ${doc.id} ---');
          print('Document data: ${doc.data()}');

          var post = PostModel.fromSnapshot(doc);

          // 打印帖子的关键信息，特别是 isDisabled 字段
          print('Post ID: ${post.postId}');
          print('User ID: ${post.userId}');
          print('Content: ${post.content.substring(0, min(50, post.content.length))}...');
          print('Post Type: ${post.postType}');
          print('isDisabled: ${post.isDisabled}');
          print('Created At: ${post.createdAt}');
          print('Media count: ${post.media.length}');

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            print('Converting media paths to URLs...');
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
            print('Media URLs converted: ${urls.length}');
          }

          posts.add(post);
          print('✓ Successfully processed post ${post.postId}\n');
        } catch (e) {
          print('✗ Error processing post ${doc.id}: $e');
          print('Document data that caused error: ${doc.data()}');
          // Skip this post and continue with others
        }
      }

      // 在返回前打印总结信息
      print('=== DEBUG: Posts Processing Summary ===');
      print('Total posts successfully processed: ${posts.length}');
      print('Disabled posts count: ${posts.where((p) => p.isDisabled).length}');
      print('Active posts count: ${posts.where((p) => !p.isDisabled).length}');

      // 打印所有帖子的 isDisabled 状态
      print('All posts isDisabled status:');
      for (var post in posts) {
        print('  - ${post.postId}: isDisabled = ${post.isDisabled}');
      }
      print('=== DEBUG: End of Posts Query ===\n');

      return posts;
    });
  }

  /// Stream to get single post by ID (with media URLs) - 用于实时更新单个帖子
  Stream<PostModel?> getPostByIdStream(String postId) {
    return _db
        .collection("posts")
        .doc(postId)
        .snapshots()
        .asyncMap((doc) async {
      if (doc.exists) {
        var post = PostModel.fromSnapshot(doc);

        // Convert storage paths to URLs
        if (post.media.isNotEmpty) {
          final urls = await getMediaUrls(post.media, post.userId);
          post = post.copyWith(media: urls);
        }

        return post;
      }
      return null;
    });
  }


  /// Stream to get posts by type (with media URLs)
  Stream<List<PostModel>> getPostsByTypeStream(String postType) {
    return _db
        .collection("posts")
        .where('postType', isEqualTo: postType)
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    });
  }

  /// Stream to get posts by user (with media URLs)
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _db
        .collection("posts")
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    });
  }

  /// Function to save post data to Firestore
  Future<String> savePost(PostModel post) async {
    try {
      final postJson = post.toJson();

      // Convert URLs to file names
      if (postJson['media'] != null && postJson['media'] is List) {
        postJson['media'] = MediaHelpers.convertUrlsToFileNames(
            List<String>.from(postJson['media'])
        );
      }

      // 【修改】如果是新 post（没有 postId），让 Firestore 生成 ID
      if (post.postId.isEmpty) {
        final docRef = await _db.collection("posts").add(postJson);
        print('✅ Created new post with ID: ${docRef.id}');
        return docRef.id; // 返回生成的 ID
      } else {
        // 如果有 postId，说明是更新现有 post
        await _db.collection("posts").doc(post.postId).set(postJson);
        print('✅ Updated existing post: ${post.postId}');
        return post.postId;
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update post likes
  Future<void> updatePostLikes(String postId, List<String> likes) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'likes': likes,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update post reports
  Future<void> updatePostReports(String postId, Map<String, List<String>> reports) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'reports': reports,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update post comment count
  Future<void> increaseCommentCount(String postId) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Decrease post comment count
  Future<void> decreaseCommentCount(String postId) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Delete post (hard delete)
  /// Deletes the post, all associated media, comments, and replies
  Future<void> deletePost(String postId) async {
    try {
      print('Go1');
      // Get post data first
      final doc = await _db.collection("posts").doc(postId).get();
      if (!doc.exists) return;

      final post = PostModel.fromSnapshot(doc);
      print('Go2');
      // 1. Delete all comments and get their IDs
      final commentIds = await _commentRepository.deleteCommentsByPost(postId);
      print('Go3');
      // 2. Delete all replies of those comments
      if (commentIds.isNotEmpty) {
        await _replyRepository.deleteRepliesByComments(commentIds);
      }
      print('Go4');
      // 3. Delete media from storage
      if (post.media.isNotEmpty) {
        for (var storagePath in post.media) {
          try {
            final isVideo = storagePath.contains('.mp4') ||
                storagePath.contains('.mov') ||
                storagePath.contains('.avi');

            final fullPath = isVideo
                ? 'posts/${post.userId}/videos/$storagePath'
                : 'posts/${post.userId}/images/$storagePath';

            await storage.ref(fullPath).delete();
            print('✅ Deleted media: $fullPath');
          } catch (e) {
            print('❌ Failed to delete media $storagePath: $e');
          }
        }
      }
      print('Go5');
      // 4. Delete the post document
      await _db.collection("posts").doc(postId).delete();
      print('✅ Deleted post: $postId');
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      print('error: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get single post by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _db.collection("posts").doc(postId).get();
      if (doc.exists) {
        var post = PostModel.fromSnapshot(doc);

        // Convert storage paths to URLs
        if (post.media.isNotEmpty) {
          final urls = await getMediaUrls(post.media, post.userId);
          post = post.copyWith(media: urls);
        }

        return post;
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Search posts by content (with media URLs)
  Stream<List<PostModel>> searchPosts(String query) {
    return _db
        .collection("posts")
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          if (post.content.toLowerCase().contains(query.toLowerCase())) {
            // Convert storage paths to URLs
            if (post.media.isNotEmpty) {
              final urls = await getMediaUrls(post.media, post.userId);
              post = post.copyWith(media: urls);
            }

            posts.add(post);
          }
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    });
  }

  /// Get posts with pagination (with media URLs)
  Future<List<PostModel>> getPostsPaginated({
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _db
          .collection("posts")
          .where('isDisabled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get total posts count
  Future<int> getPostsCount({bool isDisabled = false}) async {
    try {
      final snapshot = await _db
          .collection("posts")
          .where('isDisabled', isEqualTo: isDisabled)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw 'Failed to get posts count: $e';
    }
  }

  /// Stream posts with pagination
  Stream<List<PostModel>> getPostsStreamPaginated({
    required int limit,
    required int offset,
    bool isDisabled = false,
  }) {
    return _db
        .collection("posts")
        .where('isDisabled', isEqualTo: isDisabled)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      // Skip documents based on offset
      final docs = snapshot.docs.skip(offset).take(limit).toList();
      final posts = <PostModel>[];

      for (var doc in docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    });
  }

  /// Toggle post disabled status
  Future<void> togglePostDisabledStatus(String postId, bool isDisabled) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'isDisabled': isDisabled,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to update post status: $e';
    }
  }

  /// Get post details with comments (limited)
  Future<PostModel> getPostWithComments(String postId, {int commentLimit = 10}) async {
    try {
      final postDoc = await _db.collection("posts").doc(postId).get();

      if (!postDoc.exists) {
        throw 'Post not found';
      }

      var post = PostModel.fromSnapshot(postDoc);

      // Convert storage paths to URLs
      if (post.media.isNotEmpty) {
        final urls = await getMediaUrls(post.media, post.userId);
        post = post.copyWith(media: urls);
      }

      return post;
    } catch (e) {
      throw 'Failed to get post details: $e';
    }
  }
}