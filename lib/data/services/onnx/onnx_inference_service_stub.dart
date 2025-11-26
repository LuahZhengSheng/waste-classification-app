import 'package:flutter/foundation.dart';

import '../../../features/waste_classification/models/detection_result_model.dart';

class OnnxInferenceService {
  OnnxInferenceService() {
    if (kDebugMode) {
      print('🧩 OnnxInferenceService STUB loaded (no FFI, e.g. Web)');
    }
  }

  bool get isInitialized => false;

  Future<void> initialize() async {
    if (kDebugMode) {
      print('OnnxInferenceService.stub.initialize() called – Web / no-op');
    }
  }

  Future<ImageDetectionResult> detectObjects(String imagePath) async {
    if (kDebugMode) {
      print('OnnxInferenceService.stub.detectObjects() called – unsupported on this platform');
    }
    throw UnsupportedError('OnnxInferenceService is not available on this platform.');
  }

  void dispose() {
    if (kDebugMode) {
      print('OnnxInferenceService.stub.dispose() – no-op');
    }
  }
}
