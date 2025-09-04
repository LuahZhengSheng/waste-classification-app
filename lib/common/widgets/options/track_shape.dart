import 'package:flutter/material.dart';

/// 自定义 Slider 轨道形状，轨道上带有可配置的圆点
class FTrackShape extends SliderTrackShape {
  FTrackShape({
    required this.divisions, // 默认为 7 个点
    this.trackColor = const Color(0xFF4CAF50), // 绿色
    this.dotColor = Colors.green,
    this.trackHeight = 4.0,
    this.dotRadius = 5.0,
  });

  final int divisions; // 圆点数量
  final Color trackColor;
  final Color dotColor;
  final double trackHeight;
  final double dotRadius;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    bool isDiscrete = false,
    bool isEnabled = true,
    Offset offset = Offset.zero,
  }) {
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required Animation<double> enableAnimation,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = true,
        Offset? secondaryOffset,
      }) {
    final Canvas canvas = context.canvas;
    final Paint trackPaint = Paint()..color = trackColor.withOpacity(0.4);
    final Paint dotPaint = Paint()..color = dotColor;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      offset: offset,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // 绘制轨道
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(4)),
      trackPaint,
    );

    // 计算每个刻度的间距，使得圆点和刻度对齐
    final double trackLeft = trackRect.left;
    final double trackWidth = trackRect.width;
    final double trackCenterY = trackRect.center.dy;
    final double interval = trackWidth / divisions;

    // 绘制圆点
    for (int i = 0; i <= divisions; i++) {
      final Offset dotCenter = Offset(trackLeft + i * interval, trackCenterY);
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }
}
