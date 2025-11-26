import 'dart:io';
import 'package:get/get.dart';
import 'package:fyp/utils/popups/loaders.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/services/onnx/onnx_inference_service.dart';
import '../../../features/recycling_center/models/waste_category_model.dart';
import '../models/detection_result_model.dart';
import '../screens/detection_result/detection_result.dart';
import '../utils/waste_detection_mapper.dart';

class DetectionController extends GetxController {
  static DetectionController get instance => Get.find();

  final OnnxInferenceService _inferenceService = OnnxInferenceService();
  final WasteCategoryRepository _categoryRepo = Get.put(WasteCategoryRepository());

  final RxBool isInitializing = false.obs;
  final RxBool isDetecting = false.obs;
  final RxList<WasteCategory> allCategories = <WasteCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeModel();
  }

  @override
  void onClose() {
    _inferenceService.dispose();
    super.onClose();
  }

  /// Initialize ONNX model and load categories
  Future<void> initializeModel() async {
    try {
      isInitializing.value = true;

      // Initialize ONNX Runtime
      await _inferenceService.initialize();

      // Load all waste categories from Firestore
      allCategories.value = await _categoryRepo.getAllWasteCategories();

      print('✅ Model and categories loaded successfully');
      print('📦 Loaded ${allCategories.length} waste categories');
    } catch (e) {
      print('❌ Failed to initialize: $e');
      FLoaders.errorSnackBar(
        title: 'Initialization Failed',
        message: 'Failed to load detection model',
      );
    } finally {
      isInitializing.value = false;
    }
  }

  /// Detect objects in image and navigate to results
  Future<void> detectAndShowResults(File imageFile) async {
    if (!_inferenceService.isInitialized) {
      FLoaders.warningSnackBar(
        title: 'Not Ready',
        message: 'Model is still initializing',
      );
      return;
    }

    try {
      isDetecting.value = true;

      FLoaders.customToast(message: 'Analyzing image...');

      // Run detection
      final result = await _inferenceService.detectObjects(imageFile.path);

      // Map detections to waste categories
      final mappedResult = await _mapDetectionsToCategories(result);

      // Navigate to results screen
      Get.to(() => DetectionResultScreen(result: mappedResult));

      if (mappedResult.hasDetections) {
        FLoaders.successSnackBar(
          title: 'Detection Complete',
          message: 'Found ${mappedResult.detectionCount} objects',
        );
      } else {
        FLoaders.warningSnackBar(
          title: 'No Objects Detected',
          message: 'Try taking another photo',
        );
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

  /// Map detection results to waste categories
  Future<ImageDetectionResult> _mapDetectionsToCategories(
      ImageDetectionResult result,
      ) async {
    final mappedDetections = <DetectionResult>[];

    for (final detection in result.detections) {
      // Find matching category
      final category = WasteDetectionMapper.findMatchingCategory(
        detection.label,
        allCategories,
      );

      if (category != null) {
        print('✅ Mapped "${detection.label}" to category "${category.name}"');
      } else {
        print('⚠️ No category found for "${detection.label}"');
      }

      // Create new detection with category
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

  /// Get category by name and recyclability
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