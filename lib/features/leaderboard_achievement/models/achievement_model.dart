import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/leaderboard_achievement/models/achievement_level_model.dart';

class AchievementModel {
  final String achievementId;
  final String title;
  final String category;
  final int maxLevel;
  final DateTime createdAt;
  final List<AchievementLevelModel> achievementLevels;

  AchievementModel({
    required this.achievementId,
    required this.title,
    required this.category,
    required this.maxLevel,
    required this.createdAt,
    this.achievementLevels = const [],
  });

  /// Create from Firestore / JSON Map
  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      achievementId: map['achievementId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      maxLevel: map['maxLevel'] ?? 0,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      achievementLevels: (map['achievementLevels'] as List<dynamic>?)
          ?.map((lvl) => AchievementLevelModel.fromMap(
          Map<String, dynamic>.from(lvl as Map)))
          .toList() ??
          [],
    );
  }

  /// Convert to Map for Firestore / JSON
  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'title': title,
      'category': category,
      'maxLevel': maxLevel,
      'createdAt': Timestamp.fromDate(createdAt),
      'achievementLevels': achievementLevels.map((lvl) => lvl.toMap()).toList(),
    };
  }

  AchievementModel copyWith({
    String? title,
    String? category,
    int? maxLevel,
    DateTime? createdAt,
    List<AchievementLevelModel>? achievementLevels,
  }) {
    return AchievementModel(
      achievementId: achievementId,
      title: title ?? this.title,
      category: category ?? this.category,
      maxLevel: maxLevel ?? this.maxLevel,
      createdAt: createdAt ?? this.createdAt,
      achievementLevels: achievementLevels ?? this.achievementLevels,
    );
  }
}
