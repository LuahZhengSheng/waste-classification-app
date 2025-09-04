import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/leaderboard_achievement/models/achievement_model.dart';

class UserAchievementModel {
  final String userAchievementId;
  final int currentLevel;
  final int progress;
  final DateTime updatedAt;
  final AchievementModel achievement;

  UserAchievementModel({
    required this.userAchievementId,
    required this.currentLevel,
    required this.progress,
    required this.updatedAt,
    required this.achievement,
  });

  /// Create from Firestore / JSON Map
  factory UserAchievementModel.fromMap(Map<String, dynamic> map) {
    return UserAchievementModel(
      userAchievementId: map['userAchievementId'] ?? '',
      currentLevel: map['currentLevel'] ?? 0,
      progress: map['progress'] ?? 0,
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      achievement: AchievementModel.fromMap(
          Map<String, dynamic>.from(map['achievement'] ?? {})),
    );
  }

  /// Convert to Map for Firestore / JSON
  Map<String, dynamic> toMap() {
    return {
      'userAchievementId': userAchievementId,
      'currentLevel': currentLevel,
      'progress': progress,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'achievement': achievement.toMap(),
    };
  }

  UserAchievementModel copyWith({
    int? currentLevel,
    int? progress,
    DateTime? updatedAt,
    AchievementModel? achievement,
  }) {
    return UserAchievementModel(
      userAchievementId: userAchievementId,
      currentLevel: currentLevel ?? this.currentLevel,
      progress: progress ?? this.progress,
      updatedAt: updatedAt ?? this.updatedAt,
      achievement: achievement ?? this.achievement,
    );
  }

  /// Check if the user has completed this achievement
  bool isCompleted() => currentLevel >= achievement.maxLevel;

  /// Calculate current progress percentage
  double progressPercentage() {
    if (achievement.maxLevel == 0) return 0;
    return (progress / achievement.maxLevel).clamp(0, 1).toDouble();
  }
}
