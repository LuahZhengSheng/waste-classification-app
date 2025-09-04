import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/options/track_shape.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:get/get.dart';

class SliderController extends GetxController {
  RxInt value = 0.obs; // ✅ 使用整数存储

  void updateValue(double newValue, int step) {
    value.value = ((newValue / step).round() * step).clamp(0, 100).toInt(); // ✅ 确保整数并限制范围
  }
}

class FOptionsSlider extends StatelessWidget {
  const FOptionsSlider({
    super.key,
    required this.min,
    required this.max,
    this.step = 1,
    this.activeColor = Colors.green,
    this.inactiveColor,
    this.thumbColor,
    this.overlayColor,
    this.thumbRadius = 10,
    this.sliderWidthFactor = 0.8,
  });

  final int min;
  final int max;
  final int step; // ✅ 步长为整数
  final Color activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final Color? overlayColor;
  final double thumbRadius;
  final double sliderWidthFactor;

  @override
  Widget build(BuildContext context) {
    final SliderController controller = Get.put(SliderController());
    double sliderWidth = MediaQuery.of(context).size.width * sliderWidthFactor;

    // 计算 divisions（确保整数）
    final int divisions = ((max - min) ~/ step); // ✅ 使用 ~/ 确保整数除法

    // 生成底部刻度的数值
    List<int> labelValues = List.generate(divisions + 1, (index) => min + index * step);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Obx(() => SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveColor ?? activeColor.withOpacity(0.5),
              thumbColor: thumbColor ?? activeColor,
              overlayColor: overlayColor ?? activeColor.withOpacity(0.3),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
              trackShape: FTrackShape(divisions: divisions), // ✅ 确保轨道点数一致
            ),
            child: SizedBox(
              width: sliderWidth,
              child: Slider(
                value: controller.value.value.toDouble(), // ✅ 确保 `Slider` 仍然接受 `double`
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: divisions,
                onChanged: (newValue) => controller.updateValue(newValue, step),
              ),
            ),
          )),
          SizedBox(
            width: sliderWidth * 1.03,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                labelValues.length,
                    (index) => Obx(() => Text(
                  labelValues[index].toString(), // ✅ 只显示整数
                  style: TextStyle(
                    color: controller.value.value == labelValues[index] ? FColors.white : Colors.grey,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
