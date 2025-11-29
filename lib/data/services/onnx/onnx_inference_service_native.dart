import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:onnxruntime/onnxruntime.dart';

import '../../../features/waste_classification/models/detection_result_model.dart';

class OnnxInferenceService {
  OrtSession? _session;
  bool _isInitialized = false;

  static const int inputSize = 640;
  static const double confidenceThreshold = 0.3;
  static const double iouThreshold = 0.45;

  static const List<String> classLabels = [
    'HDPE Plastic', 'Multi-layer Plastic', 'PET Bottle',
    'Single-use Plastic', 'Single-layer Plastic', 'Squeeze-tube',
    'UHT-Box', 'Polystyrene', 'Paper', 'Paper Cup', 'Glass Bottle',
    'Light Bulb', 'Fluorescent Lamp', 'Aluminium Can', 'Cardboard',
    'Battery', 'Smartphone', 'Laptop', 'Monitor', 'Printer',
    'Computer Mouse', 'Computer Keyboard'
  ];

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ ONNX Runtime already initialized');
      return;
    }
    try {
      print('🚀 Starting ONNX Runtime initialization...');
      OrtEnv.instance.init();
      print('✅ ONNX Environment initialized');

      final modelPath = await _copyModelToTemp();
      print('✅ Model path: $modelPath');

      final modelFile = File(modelPath);
      if (!await modelFile.exists()) throw Exception('Model file not found at: $modelPath');
      print('✅ Model file size: ${await modelFile.length()} bytes');

      final sessionOptions = OrtSessionOptions()
        ..setInterOpNumThreads(4)
        ..setIntraOpNumThreads(4)
        ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);

      _session = OrtSession.fromFile(modelFile, sessionOptions);
      print('✅ ONNX session created');

      // 获取输入输出信息
      final inputInfo = _session!.inputNames;
      final outputInfo = _session!.outputNames;
      print('📥 Input info:');
      // for (final input in inputInfo) {
      //   print('  - Name: ${input.name}, Shape: ${input.shape}');
      // }

      // print('📤 Output info:');
      // for (final output in outputInfo) {
      //   print('  - Name: ${output.name}, Shape: ${output.shape}');
      // }

      _isInitialized = true;
      print('✅ ONNX Runtime initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Failed to initialize ONNX Runtime: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to initialize model: $e');
    }
  }

  Future<String> _copyModelToTemp() async {
    try {
      ByteData? byteData;
      try {
        byteData = await rootBundle.load('assets/models/rtdetr.onnx');
        print('✅ Found model at: assets/models/rtdetr.onnx');
      } catch (e) {
        print('⚠️ Not found at assets/models/rtdetr.onnx, trying assets/rtdetr.onnx');
        byteData = await rootBundle.load('assets/rtdetr.onnx');
        print('✅ Found model at: assets/rtdetr.onnx');
      }
      final buffer = byteData.buffer;
      final tempDir = await getTemporaryDirectory();
      final modelPath = '${tempDir.path}/rtdetr.onnx';
      final file = File(modelPath);
      await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      print('✅ Model copied to: $modelPath');
      return modelPath;
    } catch (e) {
      print('❌ Failed to copy model: $e');
      throw Exception('Failed to copy model: $e');
    }
  }

  Future<ImageDetectionResult> detectObjects(String imagePath) async {
    if (!_isInitialized || _session == null) {
      throw Exception('Model not initialized. Call initialize() first.');
    }
    try {
      print('🔍 Loading image: $imagePath');
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) throw Exception('Image file not found: $imagePath');
      final imageBytes = await imageFile.readAsBytes();
      print('✅ Image loaded, size: ${imageBytes.length} bytes');
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');
      print('✅ Image decoded: ${image.width}x${image.height}');
      final originalSize = Size(image.width.toDouble(), image.height.toDouble());

      print('🔄 Preprocessing image...');
      final inputTensor = _preprocessImage(image);
      print('✅ Image preprocessed');

      final runOptions = OrtRunOptions();
      final inputName = _session!.inputNames.first;
      final inputs = {inputName: inputTensor};

      print('🤖 Running inference...');
      final stopwatch = Stopwatch()..start();
      final outputs = _session!.run(runOptions, inputs);
      stopwatch.stop();
      print('✅ Inference complete in ${stopwatch.elapsedMilliseconds}ms');
      print('📤 Outputs count: ${outputs.length}');

      print('🔄 Parsing outputs...');
      final detections = _parseOutputs(outputs, originalSize);
      print('✅ Found ${detections.length} detections');

      print('Dart Output shape snapshot:');
      if (outputs.isNotEmpty && outputs[0] != null) {
        print('Dart Output type=${outputs[0]!.value.runtimeType}');
        print('Dart Output length (top): ${(outputs[0]!.value as List).length}');
      }

      return ImageDetectionResult(
        imagePath: imagePath,
        detections: detections,
        imageSize: originalSize,
      );
    } catch (e, stackTrace) {
      print('❌ Detection failed: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Detection failed: $e');
    }
  }

  /// 图片预处理：resize, RGB, 归一化, CHW
  OrtValueTensor _preprocessImage(img.Image image) {
    final resized = img.copyResize(image, width: inputSize, height: inputSize, interpolation: img.Interpolation.linear);
    final float32List = Float32List(1 * 3 * inputSize * inputSize);
    int idx = 0;
    for (int c = 0; c < 3; c++) {
      for (int h = 0; h < inputSize; h++) {
        for (int w = 0; w < inputSize; w++) {
          final pixel = resized.getPixel(w, h);
          double value = (c == 0)
              ? pixel.r / 255.0
              : (c == 1)
              ? pixel.g / 255.0
              : pixel.b / 255.0;
          float32List[idx++] = value;
        }
      }
    }
    return OrtValueTensor.createTensorWithDataList(float32List, [1, 3, inputSize, inputSize]);
  }

  /// 解析RT-DETR输出，后处理完全仿Python
  List<DetectionResult> _parseOutputs(
      List<OrtValue?> outputs,
      Size originalSize,
      ) {
    final detections = <DetectionResult>[];
    if (outputs.isEmpty || outputs[0] == null) {
      print('⚠️ No outputs from model');
      return detections;
    }
    final predictions = outputs[0]!.value;
    print('📊 Output type: ${predictions.runtimeType}');
    if (predictions is List<List<List<double>>>) {
      return _parse3DOutput(predictions, originalSize);
    } else if (predictions is List<List<double>>) {
      return _parse2DOutput(predictions, originalSize);
    } else {
      print('⚠️ Unknown output format: ${predictions.runtimeType}');
      return detections;
    }
  }

  List<DetectionResult> _parse3DOutput(List<List<List<double>>> predictions, Size originalSize) {
    final detections = <DetectionResult>[];
    final numDetections = predictions[0].length;
    final numClasses = classLabels.length;
    print('🔍 Parsing 3D output: $numDetections, numClasses=$numClasses');
    for (int i = 0; i < numDetections; i++) {
      final detection = predictions[0][i];
      final bboxRaw = detection.sublist(0, 4);
      final clsScores = detection.sublist(4, 4 + numClasses);

      // 打印每个detection的前10个值
      if (i < 5) {
        print('Dart detection[$i] bboxRaw: $bboxRaw');
        print('Dart detection[$i] clsScores (top5): ${clsScores.take(5).toList()}');
      }

      double maxScore = 0;
      int maxClass = 0;
      for (int j = 0; j < clsScores.length; j++) {
        if (clsScores[j] > maxScore) {
          maxScore = clsScores[j];
          maxClass = j;
        }
      }
      if (i < 5) {
        print("Dart detection[$i] maxScore=$maxScore, maxClass=$maxClass/${classLabels[maxClass]}");
      }

      if (maxScore < confidenceThreshold) continue;
      final bbox = _xywh2xyxy(bboxRaw);
      if (bbox[2] <= bbox[0] || bbox[3] <= bbox[1]) continue;
      double x1, y1, x2, y2;
      if (bbox.every((val) => val >= 0 && val <= 1)) {
        x1 = bbox[0] * originalSize.width;
        y1 = bbox[1] * originalSize.height;
        x2 = bbox[2] * originalSize.width;
        y2 = bbox[3] * originalSize.height;
      } else {
        x1 = bbox[0];
        y1 = bbox[1];
        x2 = bbox[2];
        y2 = bbox[3];
      }
      x1 = x1.clamp(0, originalSize.width).toDouble();
      y1 = y1.clamp(0, originalSize.height).toDouble();
      x2 = x2.clamp(0, originalSize.width).toDouble();
      y2 = y2.clamp(0, originalSize.height).toDouble();

      if (x2 > x1 && y2 > y1) {
        final rect = Rect.fromLTRB(x1, y1, x2, y2);
        final label = classLabels[maxClass];
        detections.add(DetectionResult(
          label: label, confidence: maxScore, boundingBox: rect,
        ));
        print('✅ Dart Detection: $label (${maxScore.toStringAsFixed(3)}), box: [${x1.toInt()}, ${y1.toInt()}, ${x2.toInt()}, ${y2.toInt()}]');
      }
    }
    print('🎯 Dart NMS before: ${detections.length}');
    final kept = _applyNMS(detections);
    print('🎯 Dart NMS after: ${kept.length}');
    return kept;
  }

  List<DetectionResult> _parse2DOutput(List<List<double>> predictions, Size originalSize) {
    final detections = <DetectionResult>[];
    final numClasses = classLabels.length;
    print('🔍 Parsing 2D output: ${predictions.length}');
    for (int i = 0; i < predictions.length; i++) {
      final detection = predictions[i];
      if (detection.length < 4 + numClasses) continue;
      final bboxRaw = detection.sublist(0, 4);
      final clsScores = detection.sublist(4, 4 + numClasses);
      double maxScore = 0;
      int maxClass = 0;
      for (int j = 0; j < clsScores.length; j++) {
        if (clsScores[j] > maxScore) {
          maxScore = clsScores[j];
          maxClass = j;
        }
      }
      if (maxScore < confidenceThreshold) continue;
      final bbox = _xywh2xyxy(bboxRaw);
      if (bbox[2] <= bbox[0] || bbox[3] <= bbox[1]) continue;
      double x1, y1, x2, y2;
      if (bbox.every((val) => val >= 0 && val <= 1)) {
        x1 = bbox[0] * originalSize.width;
        y1 = bbox[1] * originalSize.height;
        x2 = bbox[2] * originalSize.width;
        y2 = bbox[3] * originalSize.height;
      } else {
        x1 = bbox[0]; y1 = bbox[1]; x2 = bbox[2]; y2 = bbox[3];
      }
      x1 = x1.clamp(0, originalSize.width).toDouble();
      y1 = y1.clamp(0, originalSize.height).toDouble();
      x2 = x2.clamp(0, originalSize.width).toDouble();
      y2 = y2.clamp(0, originalSize.height).toDouble();
      if (x2 > x1 && y2 > y1) {
        final rect = Rect.fromLTRB(x1, y1, x2, y2);
        final label = classLabels[maxClass];
        detections.add(DetectionResult(
          label: label, confidence: maxScore, boundingBox: rect,
        ));
        print('✅ Detection: $label (${maxScore.toStringAsFixed(3)}), box: [${x1.toInt()}, ${y1.toInt()}, ${x2.toInt()}, ${y2.toInt()}]');
      }
    }
    return _applyNMS(detections);
  }

  // bbox格式转换，跟Python代码一致
  List<double> _xywh2xyxy(List<double> bbox) {
    final xCenter = bbox[0];
    final yCenter = bbox[1];
    final width = bbox[2];
    final height = bbox[3];
    final x1 = xCenter - width / 2;
    final y1 = yCenter - height / 2;
    final x2 = xCenter + width / 2;
    final y2 = yCenter + height / 2;
    return [x1, y1, x2, y2];
  }

  // NMS算法，与Python一致
  List<DetectionResult> _applyNMS(List<DetectionResult> detections) {
    if (detections.length <= 1) return detections;
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <DetectionResult>[];
    for (final detection in detections) {
      bool keep = true;
      for (final keptDetection in kept) {
        final iou = _calculateIoU(detection.boundingBox, keptDetection.boundingBox);
        if (iou > iouThreshold) {
          keep = false;
          break;
        }
      }
      if (keep) kept.add(detection);
    }
    print('🎯 NMS: ${detections.length} -> ${kept.length} detections');
    return kept;
  }

  double _calculateIoU(Rect box1, Rect box2) {
    final intersection = box1.intersect(box2);
    if (intersection.isEmpty) return 0.0;
    final intersectionArea = intersection.width * intersection.height;
    final box1Area = box1.width * box1.height;
    final box2Area = box2.width * box2.height;
    final unionArea = box1Area + box2Area - intersectionArea;
    return intersectionArea / unionArea;
  }

  void dispose() {
    _session?.release();
    _session = null;
    _isInitialized = false;
    OrtEnv.instance.release();
    print('🗑️ ONNX Runtime disposed');
  }
}
