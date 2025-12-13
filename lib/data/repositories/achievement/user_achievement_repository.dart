import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/leaderboard_achievement/models/achievement_model.dart';
import '../../../features/leaderboard_achievement/models/user_achievement_model.dart';
import 'achievement_repository.dart';

class UserAchievementRepository extends GetxController {
  static UserAchievementRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userAchievementsCollection = 'userAchievements';
  final String _achievementsCollection = 'achievements';

  /// Get all user achievements for a specific achievement
  Future<List<UserAchievement>> getUserAchievementsByAchievementId(String achievementId) async {
    try {
      final snapshot = await _db
          .collection(_userAchievementsCollection)
          .where('achievementId', isEqualTo: achievementId)
          .get();

      List<UserAchievement> userAchievements = [];

      for (var doc in snapshot.docs) {
        final userAchievement = await _getUserAchievementWithFullData(doc);
        if (userAchievement != null) {
          userAchievements.add(userAchievement);
        }
      }

      return userAchievements;
    } catch (e) {
      throw 'Failed to fetch user achievements: $e';
    }
  }

  /// Batch create user achievements for a new user
  /// More efficient than calling createUserAchievement multiple times
  Future<void> batchCreateUserAchievements({
    required String userId,
    required List<Achievement> achievements,
  }) async {
    try {
      if (achievements.isEmpty) {
        print('⚠️ No achievements provided for initialization');
        return;
      }

      print('📊 Batch creating ${achievements.length} user achievements for user: $userId');

      // Create batch
      final batch = _db.batch();

      for (final achievement in achievements) {
        final userAchievementRef = _db
            .collection(_userAchievementsCollection)
            .doc(); // Auto-generate ID

        batch.set(userAchievementRef, {
          'userId': userId,
          'achievementId': achievement.achievementId,
          'progress': 0,
          'currentLevel': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Queued user achievement for: ${achievement.title}');
      }

      // Commit batch
      await batch.commit();

      print('🎉 Successfully initialized ${achievements.length} user achievements');
    } catch (e) {
      throw 'Failed to batch create user achievements: $e';
    }
  }


  /// Get all user achievements stream
  Stream<List<UserAchievement>> getUserAchievementsStream(String userId) {
    return _db
        .collection(_userAchievementsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<UserAchievement> userAchievements = [];

      for (var doc in snapshot.docs) {
        final userAchievement = await _getUserAchievementWithFullData(doc);
        if (userAchievement != null) {
          userAchievements.add(userAchievement);
        }
      }

      return userAchievements;
    });
  }

  /// Get user achievement by ID stream
  Stream<UserAchievement> getUserAchievementStream(String userAchievementId) {
    return _db
        .collection(_userAchievementsCollection)
        .doc(userAchievementId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return UserAchievement.empty();

      final userAchievement = await _getUserAchievementWithFullData(doc);
      return userAchievement ?? UserAchievement.empty();
    });
  }

  /// Get user achievements by category stream
  Stream<List<UserAchievement>> getUserAchievementsByCategoryStream(
      String userId, String category) {
    return getUserAchievementsStream(userId).map((userAchievements) {
      return userAchievements
          .where((ua) => ua.achievement.category == category)
          .toList();
    });
  }

  /// 🆕 返回 null 来表示"应该被过滤掉"的情况
  /// Get user achievement with full achievement data (返回 null 如果获取失败)
  Future<UserAchievement?> _getUserAchievementWithFullData(
      DocumentSnapshot<Map<String, dynamic>> doc, {
        bool includeInactive = false, // 🆕 添加参数，默认不包括 inactive
      }) async {
    if (!doc.exists) return null;

    final data = doc.data()!;
    final achievementId = data['achievementId'] as String?;

    if (achievementId == null || achievementId.isEmpty) {
      return null;
    }

    try {
      // 🆕 使用 Firestore 实例直接获取，不通过 repository
      final achievementDoc = await _db
          .collection(_achievementsCollection)
          .doc(achievementId)
          .get();

      if (!achievementDoc.exists) {
        print('Achievement not found: $achievementId');
        return null;
      }

      // 🆕 使用 repository 的公共方法获取 achievement with levels
      final achievement = await AchievementRepository.instance
          .getAchievementWithLevels(achievementDoc);

      // 🆕 根据参数决定是否过滤 inactive
      if (!includeInactive && achievement.status != 'active') {
        print('Filtering out inactive achievement: $achievementId - ${achievement.title}');
        return null;
      }

      final userAchievement = UserAchievement(
        userAchievementId: doc.id,
        userId: data['userId'] ?? '',
        progress: data['progress'] ?? 0,
        currentLevel: data['currentLevel'] ?? 0,
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        achievement: achievement,
      );

      return userAchievement;
    } catch (e) {
      print('Error fetching user achievement data: $e');
      return null;
    }
  }

  /// Get user achievement by achievement ID
  Future<UserAchievement?> getUserAchievementByAchievementId(
      String userId, String achievementId) async {
    try {
      final snapshot = await _db
          .collection(_userAchievementsCollection)
          .where('userId', isEqualTo: userId)
          .where('achievementId', isEqualTo: achievementId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return await _getUserAchievementWithFullData(snapshot.docs.first);
    } catch (e) {
      throw 'Failed to fetch user achievement: $e';
    }
  }

  /// Update user achievement progress
  Future<void> updateProgress(String userAchievementId, int newProgress) async {
    try {
      await _db
          .collection(_userAchievementsCollection)
          .doc(userAchievementId)
          .update({
        'progress': newProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update progress: $e';
    }
  }

  /// Increment user achievement progress
  Future<void> incrementProgress(String userAchievementId, int increment) async {
    try {
      await _db
          .collection(_userAchievementsCollection)
          .doc(userAchievementId)
          .update({
        'progress': FieldValue.increment(increment),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to increment progress: $e';
    }
  }

  /// Create user achievement
  Future<String> createUserAchievement({
    required String userId,
    required String achievementId,
    int initialProgress = 0,
    int initialLevel = 0,
  }) async {
    try {
      final docRef = await _db.collection(_userAchievementsCollection).add({
        'userId': userId,
        'achievementId': achievementId,
        'progress': initialProgress,
        'currentLevel': initialLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw 'Failed to create user achievement: $e';
    }
  }

  /// Get or create user achievement
  Future<UserAchievement?> getOrCreateUserAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      // Try to get existing
      final existing = await getUserAchievementByAchievementId(userId, achievementId);
      if (existing != null) {
        return existing;
      }

      // Create new
      final newId = await createUserAchievement(
        userId: userId,
        achievementId: achievementId,
      );

      // Get the newly created achievement
      final doc = await _db
          .collection(_userAchievementsCollection)
          .doc(newId)
          .get();

      return await _getUserAchievementWithFullData(doc);
    } catch (e) {
      throw 'Failed to get or create user achievement: $e';
    }
  }

  /// Initialize user achievements for a new user
  Future<void> initializeUserAchievements({
    required String userId,
    required List<String> achievementIds,
  }) async {
    try {
      for (final achievementId in achievementIds) {
        await getOrCreateUserAchievement(
          userId: userId,
          achievementId: achievementId,
        );
      }
    } catch (e) {
      throw 'Failed to initialize user achievements: $e';
    }
  }
}
