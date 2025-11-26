import 'package:flutter/material.dart';
import '../../../features/recycling_center/models/waste_category_model.dart';

class DetectionResult {
  final String label;
  final double confidence;
  final Rect boundingBox;
  final WasteCategory? category;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.category,
  });

  // Get formatted confidence percentage
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'DetectionResult(label: $label, confidence: $confidencePercent, box: $boundingBox)';
  }
}

class ImageDetectionResult {
  final String imagePath;
  final List<DetectionResult> detections;
  final Size imageSize;

  ImageDetectionResult({
    required this.imagePath,
    required this.detections,
    required this.imageSize,
  });

  bool get hasDetections => detections.isNotEmpty;
  int get detectionCount => detections.length;
}