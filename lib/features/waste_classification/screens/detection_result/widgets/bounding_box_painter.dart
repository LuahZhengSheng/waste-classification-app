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

    // Calculate scale factors to fit image in display
    final scaleX = displaySize.width / imageSize.width;
    final scaleY = displaySize.height / imageSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate offset to center the image
    final offsetX = (displaySize.width - imageSize.width * scale) / 2;
    final offsetY = (displaySize.height - imageSize.height * scale) / 2;

    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final color = colors[i % colors.length];

      // Scale bounding box to display size
      final scaledBox = Rect.fromLTWH(
        detection.boundingBox.left * scale + offsetX,
        detection.boundingBox.top * scale + offsetY,
        detection.boundingBox.width * scale,
        detection.boundingBox.height * scale,
      );

      // Draw bounding box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRect(scaledBox, boxPaint);

      // Draw label background
      final textSpan = TextSpan(
        text: '${detection.label} ${detection.confidencePercent}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final textBackgroundRect = Rect.fromLTWH(
        scaledBox.left,
        scaledBox.top - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      // Ensure text background doesn't go above the image
      final adjustedTextBackgroundRect = Rect.fromLTWH(
        textBackgroundRect.left,
        textBackgroundRect.top < 0 ? scaledBox.top : textBackgroundRect.top,
        textBackgroundRect.width,
        textBackgroundRect.height,
      );

      final backgroundPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRect(adjustedTextBackgroundRect, backgroundPaint);

      // Draw label text
      textPainter.paint(
        canvas,
        Offset(
          scaledBox.left + 4,
          (adjustedTextBackgroundRect.top < 0 ? scaledBox.top : adjustedTextBackgroundRect.top) + 2,
        ),
      );

      // Draw corner indicators (optional, for better visual)
      _drawCorners(canvas, scaledBox, color);
    }
  }

  void _drawCorners(Canvas canvas, Rect box, Color color) {
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cornerLength = 12.0;

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