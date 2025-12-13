// detection_history_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DetectionHistoryModel {
  final String historyId;
  final String userId;
  final String imageUrl; // Storage URL of image with bounding boxes
  final int detectionCount;
  final List<String> detectedItems; // Labels of detected items
  final List<String> categoryIds;   // 对应 waste category 的 id 列表
  final DateTime createdAt;

  DetectionHistoryModel({
    required this.historyId,
    required this.userId,
    required this.imageUrl,
    required this.detectionCount,
    required this.detectedItems,
    required this.categoryIds,
    required this.createdAt,
  });

  /// Empty factory
  static DetectionHistoryModel empty() => DetectionHistoryModel(
    historyId: '',
    userId: '',
    imageUrl: '',
    detectionCount: 0,
    detectedItems: const [],
    categoryIds: const [],
    createdAt: DateTime.now(),
  );

  /// To JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'userId': userId,
      'imageUrl': imageUrl,
      'detectionCount': detectionCount,
      'detectedItems': detectedItems,
      'categoryIds': categoryIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// From Firestore snapshot
  factory DetectionHistoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return DetectionHistoryModel.empty();

    return DetectionHistoryModel(
      historyId: document.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      detectionCount: data['detectionCount'] ?? 0,
      detectedItems: List<String>.from(data['detectedItems'] ?? const []),
      categoryIds: List<String>.from(data['categoryIds'] ?? const []),
      createdAt:
      (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// CopyWith method
  DetectionHistoryModel copyWith({
    String? historyId,
    String? userId,
    String? imageUrl,
    int? detectionCount,
    List<String>? detectedItems,
    List<String>? categoryIds,
    DateTime? createdAt,
  }) {
    return DetectionHistoryModel(
      historyId: historyId ?? this.historyId,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      detectionCount: detectionCount ?? this.detectionCount,
      detectedItems: detectedItems ?? this.detectedItems,
      categoryIds: categoryIds ?? this.categoryIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DetectionHistoryModel(historyId: $historyId, detectionCount: $detectionCount, items: $detectedItems, categoryIds: $categoryIds)';
  }
}
