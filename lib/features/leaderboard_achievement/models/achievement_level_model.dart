import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementLevelModel {
  final String achievementLevelId;
  final int level;
  final int unlockCriteria;
  final String description;
  final String badgeImage;

  AchievementLevelModel({
    required this.achievementLevelId,
    required this.level,
    required this.unlockCriteria,
    required this.description,
    required this.badgeImage,
  });

  /// Create from Firestore or Map
  factory AchievementLevelModel.fromMap(Map<String, dynamic> map) {
    return AchievementLevelModel(
      achievementLevelId: map['achievementLevelId'] ?? '',
      level: map['level'] ?? 0,
      unlockCriteria: map['unlockCriteria'] ?? 0,
      description: map['description'] ?? '',
      badgeImage: map['badgeImage'] ?? '',
    );
  }

  /// Convert to Map for Firestore or JSON
  Map<String, dynamic> toMap() {
    return {
      'achievementLevelId': achievementLevelId,
      'level': level,
      'unlockCriteria': unlockCriteria,
      'description': description,
      'badgeImage': badgeImage,
    };
  }

  /// Create from Firestore document
  factory AchievementLevelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError("Missing data for AchievementLevelModel: ${doc.id}");
    }
    return AchievementLevelModel.fromMap(data);
  }

  /// Copy with new values
  AchievementLevelModel copyWith({
    String? achievementLevelId,
    int? level,
    int? unlockCriteria,
    String? description,
    String? badgeImage,
  }) {
    return AchievementLevelModel(
      achievementLevelId: achievementLevelId ?? this.achievementLevelId,
      level: level ?? this.level,
      unlockCriteria: unlockCriteria ?? this.unlockCriteria,
      description: description ?? this.description,
      badgeImage: badgeImage ?? this.badgeImage,
    );
  }

  @override
  String toString() {
    return 'AchievementLevelModel(id: $achievementLevelId, level: $level, unlockCriteria: $unlockCriteria, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AchievementLevelModel &&
            other.achievementLevelId == achievementLevelId);
  }

  @override
  int get hashCode => achievementLevelId.hashCode;
}
