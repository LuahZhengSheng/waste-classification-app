import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../../../features/waste_classification/models/detection_result_model.dart';

class DetectionApiService {
  static const String apiUrl = 'http://10.31.163.142:5000/predict';

  static Future<ImageDetectionResult> detectObjects(File imageFile) async {
    print('📤 Sending image to detect: ${imageFile.path}');
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    print('⏳ Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Detection API error: ${response.statusCode}');
    }
    final responseBody = await response.stream.bytesToString();
    print('🔙 API raw response: $responseBody');
    final result = json.decode(responseBody);

    // 读取图片尺寸
    final bytes = await imageFile.readAsBytes();
    final decodedImg = img.decodeImage(bytes);
    final imageSize = decodedImg != null
        ? Size(decodedImg.width.toDouble(), decodedImg.height.toDouble())
        : Size(0, 0);

    final List detections = result['detections'] ?? [];
    print('🔬 Detection count: ${detections.length}');

    final List<DetectionResult> detectionResults = [];
    int idx = 0;

    for (var det in detections) {
      print('➡️ Parsing detection[$idx]: $det');
      final rawBbox = det['bbox'];
      print('   Raw bbox: $rawBbox');
      if (rawBbox is! List || rawBbox.length != 4) {
        print('   ⚠️ Unexpected bbox shape, skip');
        continue;
      }
      double getDouble(dynamic v) {
        if (v is num) return v.toDouble();
        if (v is String) return double.tryParse(v) ?? 0.0;
        if (v is List && v.isNotEmpty) return getDouble(v.first);
        return 0.0;
      }
      final bbox = [
        getDouble(rawBbox[0]),
        getDouble(rawBbox[1]),
        getDouble(rawBbox[2]),
        getDouble(rawBbox[3]),
      ];
      print('   Parsed bbox: $bbox');

      final labelIndex = det['class'] is int ? det['class'] : int.tryParse(det['class'].toString()) ?? 0;
      final score = getDouble(det['score']);
      final label = DetectionApiService.classLabels[
      labelIndex >= 0 && labelIndex < DetectionApiService.classLabels.length ? labelIndex : 0
      ];

      print('   label: $label, labelIndex: $labelIndex, score: $score');

      detectionResults.add(DetectionResult(
        label: label,
        confidence: score,
        boundingBox: Rect.fromLTRB(
          bbox[0], bbox[1], bbox[2], bbox[3],
        ),
      ));
      idx += 1;
    }

    print('✅ Parsed ${detectionResults.length} detection results');
    return ImageDetectionResult(
      imagePath: imageFile.path,
      detections: detectionResults,
      imageSize: imageSize,
    );
  }

  static const List<String> classLabels = [
    'HDPE Plastic', 'Multi-layer Plastic', 'PET Bottle',
    'Single-use Plastic', 'Single-layer Plastic', 'Squeeze-tube',
    'UHT-Box', 'Polystyrene', 'Paper', 'Paper Cup', 'Glass Bottle',
    'Light Bulb', 'Fluorescent Lamp', 'Aluminium Can', 'Cardboard',
    'Battery', 'Smartphone', 'Laptop', 'Monitor', 'Printer',
    'Computer Mouse', 'Computer Keyboard'
  ];
}
