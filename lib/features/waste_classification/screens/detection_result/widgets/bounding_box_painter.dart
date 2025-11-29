import 'package:flutter/material.dart';
import '../../../models/detection_result_model.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final Size imageSize;
  final Size displaySize;

  BoundingBoxPainter({
    required this.detections,
    required this.imageSize,
    required this.displaySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
      Colors.teal,
      Colors.yellow,
      Colors.lime,
      Colors.indigo,
      Colors.amber,
    ];

    // 🎯 使用相对比例但设置合理的范围
    final baseSize = (imageSize.width + imageSize.height) / 2;

    // 计算相对值，但限制在合理范围内
    final strokeWidth = _calculateStrokeWidth(baseSize);
    final fontSize = _calculateFontSize(baseSize);
    final cornerLength = _calculateCornerLength(baseSize);

    print('📐 Base size: $baseSize, Stroke: ${strokeWidth}px, Font: ${fontSize}px');

    // 计算缩放比例和偏移量
    final scaleX = displaySize.width / imageSize.width;
    final scaleY = displaySize.height / imageSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (displaySize.width - imageSize.width * scale) / 2;
    final offsetY = (displaySize.height - imageSize.height * scale) / 2;

    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final color = colors[i % colors.length];

      // 缩放 bounding box 到显示尺寸
      final scaledBox = Rect.fromLTWH(
        detection.boundingBox.left * scale + offsetX,
        detection.boundingBox.top * scale + offsetY,
        detection.boundingBox.width * scale,
        detection.boundingBox.height * scale,
      );

      // 绘制 bounding box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawRect(scaledBox, boxPaint);

      // 绘制标签背景和文字
      _drawLabel(canvas, detection, color, scaledBox, fontSize);

      // 绘制角标
      _drawCorners(canvas, scaledBox, color, cornerLength, strokeWidth);
    }
  }

  /// 🎯 计算线宽 - 使用相对比例但限制范围
  double _calculateStrokeWidth(double baseSize) {
    // 基础比例计算
    double calculatedWidth = baseSize * 0.004;
    // 限制在合理范围内：4px - 12px
    return calculatedWidth.clamp(4.0, 12.0);
  }

  /// 🎯 计算字体大小 - 使用相对比例但限制范围
  double _calculateFontSize(double baseSize) {
    // 基础比例计算
    double calculatedSize = baseSize * 0.02;
    // 限制在合理范围内：20px - 40px
    return calculatedSize.clamp(20.0, 40.0);
  }

  /// 🎯 计算角标长度 - 使用相对比例但限制范围
  double _calculateCornerLength(double baseSize) {
    // 基础比例计算
    double calculatedLength = baseSize * 0.015;
    // 限制在合理范围内：15px - 30px
    return calculatedLength.clamp(15.0, 30.0);
  }

  /// 绘制标签（文字和背景）
  void _drawLabel(Canvas canvas, DetectionResult detection, Color color, Rect box, double fontSize) {
    final textSpan = TextSpan(
      text: '${detection.label} ${detection.confidencePercent}',
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5, // 增加字母间距提高可读性
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // 计算文本背景位置 - 根据字体大小动态调整间距
    final verticalPadding = fontSize * 0.2;
    final horizontalPadding = fontSize * 0.3;

    final textBackgroundRect = Rect.fromLTWH(
      box.left,
      box.top - textPainter.height - verticalPadding,
      textPainter.width + horizontalPadding * 2,
      textPainter.height + verticalPadding,
    );

    // 确保文本背景不会超出图片上方
    final adjustedTextBackgroundRect = Rect.fromLTWH(
      textBackgroundRect.left,
      textBackgroundRect.top < 0 ? box.top : textBackgroundRect.top,
      textBackgroundRect.width,
      textBackgroundRect.height,
    );

    // 绘制文本背景
    final backgroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(adjustedTextBackgroundRect, backgroundPaint);

    // 绘制文本
    textPainter.paint(
      canvas,
      Offset(
        box.left + horizontalPadding,
        (adjustedTextBackgroundRect.top < 0 ? box.top : adjustedTextBackgroundRect.top) + verticalPadding / 2,
      ),
    );
  }

  /// 绘制角标
  void _drawCorners(Canvas canvas, Rect box, Color color, double cornerLength, double strokeWidth) {
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.6 // 角标线宽是主框线宽的60%
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(box.left, box.top),
      Offset(box.left + cornerLength, box.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(box.left, box.top),
      Offset(box.left, box.top + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(box.right, box.top),
      Offset(box.right - cornerLength, box.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(box.right, box.top),
      Offset(box.right, box.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(box.left, box.bottom),
      Offset(box.left + cornerLength, box.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(box.left, box.bottom),
      Offset(box.left, box.bottom - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(box.right, box.bottom),
      Offset(box.right - cornerLength, box.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(box.right, box.bottom),
      Offset(box.right, box.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}