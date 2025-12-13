import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fyp/utils/popups/loaders.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/services/detection/detection_api_service.dart';
import '../../../utils/helpers/image_compressor.dart';
import '../controllers/detection_history_controller.dart';
import '../models/detection_result_model.dart';
import '../models/waste_category_model.dart';
import '../screens/detection_result/detection_result.dart';
import '../screens/detection_result/widgets/bounding_box_painter.dart';
import '../utils/waste_detection_mapper.dart';

class DetectionController extends GetxController {
  static DetectionController get instance => Get.find();

  final WasteCategoryRepository _categoryRepo =
  Get.put(WasteCategoryRepository());

  final RxBool isDetecting = false.obs;
  final RxBool isInitializing = false.obs;
  final RxList<WasteCategory> allCategories = <WasteCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeCategories();
  }

  /// 加载所有类别
  Future<void> initializeCategories() async {
    try {
      isInitializing.value = true;
      allCategories.value = await _categoryRepo.getAllWasteCategories();
      print('✅ Loaded ${allCategories.length} waste categories');
    } catch (e) {
      print('❌ Failed to load categories: $e');
      FLoaders.errorSnackBar(
        title: 'Initialization Failed',
        message: 'Failed to load waste categories',
      );
    } finally {
      isInitializing.value = false;
    }
  }

  /// 对接API进行推理
  Future<void> detectAndShowResults(File imageFile) async {
    try {
      isDetecting.value = true;
      FLoaders.customToast(message: 'Uploading image for analysis...');

      // 用API识别
      final result = await DetectionApiService.detectObjects(imageFile);

      // 映射到waste categories
      final mappedResult = await _mapDetectionsToCategories(result);

      File finalImageFile = imageFile;

      // 只在有目标时绘制bounding boxes
      if (mappedResult.hasDetections) {
        // 使用 BoundingBoxPainter 绘制bounding boxes到图片上
        final imageWithBoxes = await _createImageWithBoundingBoxes(
          imageFile.path,
          mappedResult,
        );

        // 使用带有bounding boxes的图片作为最终图片
        finalImageFile = imageWithBoxes;

        // 创建新的结果对象，使用绘制后的图片路径
        final resultWithBoxes = ImageDetectionResult(
          imagePath: imageWithBoxes.path,
          detections: mappedResult.detections,
          imageSize: mappedResult.imageSize,
        );

        // 立即跳转到结果页面，使用带有bounding boxes的结果
        Get.to(() => DetectionResultScreen(result: resultWithBoxes));

        // 在后台压缩并保存历史记录
        _saveDetectionHistoryInBackground(resultWithBoxes, finalImageFile);

        FLoaders.successSnackBar(
          title: 'Detection Complete',
          message: 'Found ${mappedResult.detectionCount} objects',
        );
      } else {
        FLoaders.warningSnackBar(
          title: 'No Objects Detected',
          message: 'Try taking another photo',
        );

        // 没有检测到目标也跳转
        Get.to(() => DetectionResultScreen(result: mappedResult));
      }

    } catch (e) {
      print('❌ Detection error: $e');
      FLoaders.errorSnackBar(
        title: 'Detection Failed',
        message: e.toString(),
      );
    } finally {
      isDetecting.value = false;
    }
  }

  /// 在后台压缩图片并保存历史记录
  Future<void> _saveDetectionHistoryInBackground(
      ImageDetectionResult result,
      File imageFile
      ) async {
    try {
      // 压缩图片为WebP格式
      final compressedImage = await ImageCompressor.compressAndConvertToWebP(imageFile);
      print('✅ Image compressed to WebP: ${compressedImage.path}');

      // 🆕 提取 categoryIds
      final categoryIds = result.detections
          .map((d) => d.category?.categoryId ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      // 保存历史记录
      final historyController = Get.put(DetectionHistoryController());
      await historyController.saveDetectionHistory(
        imageFile: compressedImage,
        detectionCount: result.detectionCount,
        detectedItems: result.detections.map((d) => d.label).toList(),
        categoryIds: categoryIds, // 🆕 传递 categoryIds
      );

      print('✅ Detection history saved with compressed WebP image');
    } catch (e) {
      print('⚠️ Failed to save detection history: $e');

      // 如果压缩失败，尝试保存原始图片
      try {
        // 🆕 提取 categoryIds
        final categoryIds = result.detections
            .map((d) => d.category?.categoryId ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        final historyController = Get.put(DetectionHistoryController());
        await historyController.saveDetectionHistory(
          imageFile: imageFile,
          detectionCount: result.detectionCount,
          detectedItems: result.detections.map((d) => d.label).toList(),
          categoryIds: categoryIds, // 🆕 传递 categoryIds
        );

        print('✅ Detection history saved with original image as fallback');
      } catch (e2) {
        print('❌ Completely failed to save history: $e2');
      }
    }
  }

  /// 使用 BoundingBoxPainter 创建带有bounding boxes的图片
  Future<File> _createImageWithBoundingBoxes(
      String imagePath,
      ImageDetectionResult result,
      ) async {
    try {
      print('🎨 Starting to draw bounding boxes using BoundingBoxPainter...');
      print('📐 Image size: ${result.imageSize}');

      final originalImage = await _loadImage(File(imagePath));
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 绘制原始图片
      canvas.drawImage(originalImage, Offset.zero, Paint());

      // 使用 BoundingBoxPainter 绘制 bounding boxes
      final painter = BoundingBoxPainter(
        detections: result.detections,
        imageSize: result.imageSize,
        displaySize: result.imageSize, // 使用图片原始尺寸作为显示尺寸
      );

      // 在画布上绘制
      painter.paint(canvas, result.imageSize);

      final picture = recorder.endRecording();
      final img = await picture.toImage(
        result.imageSize.width.toInt(),
        result.imageSize.height.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/detection_$timestamp.png');
      await file.writeAsBytes(bytes);

      print('✅ Bounding boxes drawn to: ${file.path}');
      return file;
    } catch (e) {
      print('❌ Failed to create image with boxes: $e');
      rethrow;
    }
  }

  Future<ui.Image> _loadImage(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ImageDetectionResult> _mapDetectionsToCategories(
      ImageDetectionResult result,
      ) async {
    final mappedDetections = <DetectionResult>[];
    for (final detection in result.detections) {
      final category = WasteDetectionMapper.findMatchingCategory(
        detection.label,
        allCategories,
      );
      if (category != null) {
        print('✅ Mapped "${detection.label}" to category "${category.name}"');
      } else {
        print('⚠️ No category found for "${detection.label}"');
      }
      mappedDetections.add(DetectionResult(
        label: detection.label,
        confidence: detection.confidence,
        boundingBox: detection.boundingBox,
        category: category,
      ));
    }
    return ImageDetectionResult(
      imagePath: result.imagePath,
      detections: mappedDetections,
      imageSize: result.imageSize,
    );
  }

  WasteCategory? findCategory({
    required String categoryName,
    required bool isRecyclable,
  }) {
    try {
      return allCategories.firstWhere(
            (cat) =>
        cat.name.toLowerCase().contains(categoryName.toLowerCase()) &&
            cat.isRecyclable == isRecyclable,
      );
    } catch (e) {
      return null;
    }
  }
}


// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:fyp/utils/popups/loaders.dart';
// import '../../../data/repositories/recycling_center/waste_category_repository.dart';
// import '../../../data/services/onnx/onnx_inference_service.dart';
// import '../controllers/detection_history_controller.dart';
// import '../models/detection_result_model.dart';
// import '../models/waste_category_model.dart';
// import '../screens/detection_result/detection_result.dart';
// import '../utils/waste_detection_mapper.dart';
//
// class DetectionController extends GetxController {
//   static DetectionController get instance => Get.find();
//
//   final OnnxInferenceService _inferenceService = OnnxInferenceService();
//   final WasteCategoryRepository _categoryRepo =
//       Get.put(WasteCategoryRepository());
//
//   final RxBool isInitializing = false.obs;
//   final RxBool isDetecting = false.obs;
//   final RxList<WasteCategory> allCategories = <WasteCategory>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     initializeModel();
//   }
//
//   @override
//   void onClose() {
//     _inferenceService.dispose();
//     super.onClose();
//   }
//
//   /// Initialize ONNX model and load categories
//   Future<void> initializeModel() async {
//     try {
//       isInitializing.value = true;
//
//       // Initialize ONNX Runtime
//       await _inferenceService.initialize();
//
//       // Load all waste categories from Firestore
//       allCategories.value = await _categoryRepo.getAllWasteCategories();
//
//       print('✅ Model and categories loaded successfully');
//       print('📦 Loaded ${allCategories.length} waste categories');
//     } catch (e) {
//       print('❌ Failed to initialize: $e');
//       FLoaders.errorSnackBar(
//         title: 'Initialization Failed',
//         message: 'Failed to load detection model',
//       );
//     } finally {
//       isInitializing.value = false;
//     }
//   }
//
//   /// Detect objects in image and navigate to results
//   Future<void> detectAndShowResults(File imageFile) async {
//     if (!_inferenceService.isInitialized) {
//       FLoaders.warningSnackBar(
//         title: 'Not Ready',
//         message: 'Model is still initializing',
//       );
//       return;
//     }
//
//     try {
//       isDetecting.value = true;
//
//       FLoaders.customToast(message: 'Analyzing image...');
//
//       // Run detection
//       final result = await _inferenceService.detectObjects(imageFile.path);
//
//       // Map detections to waste categories
//       final mappedResult = await _mapDetectionsToCategories(result);
//
//       // Only save to history if there are detections
//       if (mappedResult.hasDetections) {
//         // Create image with bounding boxes
//         final imageWithBoxes = await _createImageWithBoundingBoxes(
//           imageFile.path,
//           mappedResult,
//         );
//
//         // Save to history
//         try {
//           final historyController = Get.put(DetectionHistoryController());
//           await historyController.saveDetectionHistory(
//             imageFile: imageWithBoxes,
//             detectionCount: mappedResult.detectionCount,
//             detectedItems: mappedResult.detections.map((d) => d.label).toList(),
//           );
//         } catch (e) {
//           print('⚠️ Failed to save history: $e');
//           // Don't show error to user, continue with showing results
//         }
//
//         FLoaders.successSnackBar(
//           title: 'Detection Complete',
//           message: 'Found ${mappedResult.detectionCount} objects',
//         );
//       } else {
//         FLoaders.warningSnackBar(
//           title: 'No Objects Detected',
//           message: 'Try taking another photo',
//         );
//       }
//
//       // Navigate to results screen
//       Get.to(() => DetectionResultScreen(result: mappedResult));
//     } catch (e) {
//       print('❌ Detection error: $e');
//       FLoaders.errorSnackBar(
//         title: 'Detection Failed',
//         message: e.toString(),
//       );
//     } finally {
//       isDetecting.value = false;
//     }
//   }
//
//   /// Create image with bounding boxes drawn on it
//   Future<File> _createImageWithBoundingBoxes(
//     String imagePath,
//     ImageDetectionResult result,
//   ) async {
//     try {
//       // Load the original image
//       final originalImage = await _loadImage(File(imagePath));
//
//       // Create a canvas to draw on
//       final recorder = ui.PictureRecorder();
//       final canvas = Canvas(recorder);
//
//       // Draw the original image
//       canvas.drawImage(originalImage, Offset.zero, Paint());
//
//       // Draw bounding boxes and labels
//       _drawBoundingBoxes(canvas, result.detections, result.imageSize);
//
//       // Convert canvas to image
//       final picture = recorder.endRecording();
//       final img = await picture.toImage(
//         result.imageSize.width.toInt(),
//         result.imageSize.height.toInt(),
//       );
//
//       // Convert to bytes
//       final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//       final bytes = byteData!.buffer.asUint8List();
//
//       // Save to temporary file
//       final tempDir = await getTemporaryDirectory();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final file = File('${tempDir.path}/detection_$timestamp.png');
//       await file.writeAsBytes(bytes);
//
//       return file;
//     } catch (e) {
//       print('❌ Failed to create image with boxes: $e');
//       rethrow;
//     }
//   }
//
//   /// Load image file as ui.Image
//   Future<ui.Image> _loadImage(File file) async {
//     final bytes = await file.readAsBytes();
//     final codec = await ui.instantiateImageCodec(bytes);
//     final frame = await codec.getNextFrame();
//     return frame.image;
//   }
//
//   /// Draw bounding boxes on canvas
//   void _drawBoundingBoxes(
//     Canvas canvas,
//     List<DetectionResult> detections,
//     Size imageSize,
//   ) {
//     final colors = [
//       Colors.red,
//       Colors.green,
//       Colors.blue,
//       Colors.orange,
//       Colors.purple,
//       Colors.cyan,
//       Colors.pink,
//       Colors.teal,
//     ];
//
//     for (int i = 0; i < detections.length; i++) {
//       final detection = detections[i];
//       final color = colors[i % colors.length];
//
//       // Draw bounding box
//       final boxPaint = Paint()
//         ..color = color
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 3.0;
//
//       canvas.drawRect(detection.boundingBox, boxPaint);
//
//       // Draw label background
//       final textSpan = TextSpan(
//         text: '${detection.label} ${detection.confidencePercent}',
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//
//       final textPainter = TextPainter(
//         text: textSpan,
//         textDirection: TextDirection.ltr,
//       );
//
//       textPainter.layout();
//
//       final textBackgroundRect = Rect.fromLTWH(
//         detection.boundingBox.left,
//         detection.boundingBox.top - textPainter.height - 4,
//         textPainter.width + 8,
//         textPainter.height + 4,
//       );
//
//       // Ensure text background doesn't go above the image
//       final adjustedTextBackgroundRect = Rect.fromLTWH(
//         textBackgroundRect.left,
//         textBackgroundRect.top < 0
//             ? detection.boundingBox.top
//             : textBackgroundRect.top,
//         textBackgroundRect.width,
//         textBackgroundRect.height,
//       );
//
//       final backgroundPaint = Paint()
//         ..color = color
//         ..style = PaintingStyle.fill;
//
//       canvas.drawRect(adjustedTextBackgroundRect, backgroundPaint);
//
//       // Draw label text
//       textPainter.paint(
//         canvas,
//         Offset(
//           detection.boundingBox.left + 4,
//           (adjustedTextBackgroundRect.top < 0
//                   ? detection.boundingBox.top
//                   : adjustedTextBackgroundRect.top) +
//               2,
//         ),
//       );
//
//       // Draw corner indicators
//       _drawCorners(canvas, detection.boundingBox, color);
//     }
//   }
//
//   /// Draw corner indicators for better visualization
//   void _drawCorners(Canvas canvas, Rect box, Color color) {
//     final cornerPaint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0
//       ..strokeCap = StrokeCap.round;
//
//     final cornerLength = 12.0;
//
//     // Top-left corner
//     canvas.drawLine(
//       Offset(box.left, box.top),
//       Offset(box.left + cornerLength, box.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       Offset(box.left, box.top),
//       Offset(box.left, box.top + cornerLength),
//       cornerPaint,
//     );
//
//     // Top-right corner
//     canvas.drawLine(
//       Offset(box.right, box.top),
//       Offset(box.right - cornerLength, box.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       Offset(box.right, box.top),
//       Offset(box.right, box.top + cornerLength),
//       cornerPaint,
//     );
//
//     // Bottom-left corner
//     canvas.drawLine(
//       Offset(box.left, box.bottom),
//       Offset(box.left + cornerLength, box.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       Offset(box.left, box.bottom),
//       Offset(box.left, box.bottom - cornerLength),
//       cornerPaint,
//     );
//
//     // Bottom-right corner
//     canvas.drawLine(
//       Offset(box.right, box.bottom),
//       Offset(box.right - cornerLength, box.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       Offset(box.right, box.bottom),
//       Offset(box.right, box.bottom - cornerLength),
//       cornerPaint,
//     );
//   }
//
//   /// Map detection results to waste categories
//   Future<ImageDetectionResult> _mapDetectionsToCategories(
//     ImageDetectionResult result,
//   ) async {
//     final mappedDetections = <DetectionResult>[];
//
//     for (final detection in result.detections) {
//       // Find matching category
//       final category = WasteDetectionMapper.findMatchingCategory(
//         detection.label,
//         allCategories,
//       );
//
//       if (category != null) {
//         print('✅ Mapped "${detection.label}" to category "${category.name}"');
//       } else {
//         print('⚠️ No category found for "${detection.label}"');
//       }
//
//       // Create new detection with category
//       mappedDetections.add(DetectionResult(
//         label: detection.label,
//         confidence: detection.confidence,
//         boundingBox: detection.boundingBox,
//         category: category,
//       ));
//     }
//
//     return ImageDetectionResult(
//       imagePath: result.imagePath,
//       detections: mappedDetections,
//       imageSize: result.imageSize,
//     );
//   }
//
//   /// Get category by name and recyclability
//   WasteCategory? findCategory({
//     required String categoryName,
//     required bool isRecyclable,
//   }) {
//     try {
//       return allCategories.firstWhere(
//         (cat) =>
//             cat.name.toLowerCase().contains(categoryName.toLowerCase()) &&
//             cat.isRecyclable == isRecyclable,
//       );
//     } catch (e) {
//       return null;
//     }
//   }
// }


