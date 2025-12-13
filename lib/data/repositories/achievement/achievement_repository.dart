import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../../features/leaderboard_achievement/models/achievement_level_model.dart';
import '../../../features/leaderboard_achievement/models/achievement_model.dart';

class AchievementRepository extends GetxController {
  static AchievementRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _achievementsCollection = 'achievements';
  final String _badgeImagesFolder = 'achievement_badges';

  // Badge image cache
  final Map<String, String> badgeImageCache = {};

  /// Get all achievements (for management screen)
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final snapshot = await _db
          .collection(_achievementsCollection)
          .orderBy('category')
          .orderBy('createdAt', descending: true)
          .get();

      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    } catch (e) {
      throw 'Failed to fetch achievements: $e';
    }
  }

  /// Get achievements by status
  Future<List<Achievement>> getAchievementsByStatus(String status) async {
    try {
      final snapshot = await _db
          .collection(_achievementsCollection)
          .where('status', isEqualTo: status)
          .orderBy('category')
          .orderBy('createdAt', descending: true)
          .get();

      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    } catch (e) {
      throw 'Failed to fetch achievements by status: $e';
    }
  }

  /// Get all achievements stream
  Stream<List<Achievement>> getAllAchievementsStream() {
    return _db
        .collection(_achievementsCollection)
        .orderBy('category')
        .orderBy('createdAt')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    });
  }

  /// Get achievement by ID stream (返回 nullable)
  Stream<Achievement?> getAchievementStream(String achievementId) {
    return _db
        .collection(_achievementsCollection)
        .doc(achievementId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) {
        return null; // 🆕 返回 null 而不是 Achievement.empty()
      }
      return await getAchievementWithLevels(doc);
    });
  }

  /// Get achievements by category stream
  Stream<List<Achievement>> getAchievementsByCategoryStream(String category) {
    return _db
        .collection(_achievementsCollection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    });
  }

  /// Get achievement with its levels from subcollection
  Future<Achievement> getAchievementWithLevels(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (!doc.exists) return Achievement.empty();

    final data = doc.data()!;

    // Get levels from subcollection
    final levelsSnapshot = await _db
        .collection(_achievementsCollection)
        .doc(doc.id)
        .collection('achievementLevels')
        .orderBy('level')
        .get();

    final levels = levelsSnapshot.docs
        .map((levelDoc) => AchievementLevel.fromSnapshot(levelDoc))
        .toList();

    return Achievement(
      achievementId: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      maxLevel: data['maxLevel'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
      achievementLevels: levels,
    );
  }

  /// Get achievement by ID
  Future<Achievement> getAchievementById(String achievementId) async {
    try {
      final doc = await _db
          .collection(_achievementsCollection)
          .doc(achievementId)
          .get();

      if (!doc.exists) {
        throw 'Achievement not found';
      }

      // 检查 status 是否为 'active'
      final data = doc.data();
      if (data != null && data['status'] != 'active') {
        throw 'Achievement is not active';
      }

      return await getAchievementWithLevels(doc);
    } catch (e) {
      throw 'Failed to fetch achievement: $e';
    }
  }

  /// Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection(_achievementsCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt')
          .get();

      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    } catch (e) {
      throw 'Failed to fetch achievements by category: $e';
    }
  }

  /// Update achievement status
  Future<void> updateAchievementStatus(String achievementId, String status) async {
    try {
      await _db
          .collection(_achievementsCollection)
          .doc(achievementId)
          .update({
        'status': status,
      });
    } catch (e) {
      print('$e');
      throw 'Failed to update achievement status: $e';
    }
  }

  /// Get badge image URL from storage
  Future<String?> getBadgeImageUrl(String fileName) async {
    try {
      if (fileName.isEmpty) return null;

      // Check cache first
      if (badgeImageCache.containsKey(fileName)) {
        return badgeImageCache[fileName];
      }

      // Load from storage
      final path = '$_badgeImagesFolder/$fileName';
      final ref = _storage.ref().child(path);
      final downloadUrl = await ref.getDownloadURL();

      // Store in cache
      badgeImageCache[fileName] = downloadUrl;

      return downloadUrl;
    } catch (e) {
      print('Failed to get badge image URL: $e');
      return null;
    }
  }

  /// Get cached badge image URL (synchronous)
  String? getCachedBadgeImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;
    return badgeImageCache[fileName];
  }

  /// Preload badge images for achievement levels
  Future<void> preloadBadgeImages(List<AchievementLevel> levels) async {
    for (final level in levels) {
      if (level.badgeImage.isNotEmpty) {
        await getBadgeImageUrl(level.badgeImage);
      }
    }
  }

  /// Update achievement with new levels
  Future<void> updateAchievementWithLevels({
    required String achievementId,
    required List<AchievementLevel> levels,
  }) async {
    try {
      final batch = _db.batch();

      // Update maxLevel in achievement document
      final achievementRef = _db.collection(_achievementsCollection).doc(achievementId);
      batch.update(achievementRef, {
        'maxLevel': levels.length,
      });

      // Get existing levels subcollection
      final existingLevelsSnapshot = await achievementRef
          .collection('achievementLevels')
          .get();

      // Delete all existing levels
      for (var doc in existingLevelsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add updated levels to subcollection
      for (var level in levels) {
        final levelRef = achievementRef.collection('achievementLevels').doc();
        batch.set(levelRef, {
          'level': level.level,
          'unlockCriteria': level.unlockCriteria,
          'title': level.title,
          'description': level.description,
          'badgeImage': level.badgeImage,
          'rewardPoints': level.rewardPoints, // 🆕
        });
      }

      // Commit batch
      await batch.commit();
    } catch (e) {
      print('$e');
      throw 'Failed to update achievement with levels: $e';
    }
  }

  /// Update a single achievement level
  Future<void> updateAchievementLevel({
    required String achievementId,
    required String levelId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _db
          .collection(_achievementsCollection)
          .doc(achievementId)
          .collection('achievementLevels')
          .doc(levelId)
          .update(updates);
    } catch (e) {
      print('$e');
      throw 'Failed to update achievement level: $e';
    }
  }
}