import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class FOptionsSelector extends StatelessWidget {
  const FOptionsSelector({
    super.key,
    required this.options,
    this.selectedColor = Colors.green,
    this.unselectedColor = Colors.transparent,
    this.borderColor = Colors.green,
    this.borderWidth = 2,
    this.borderRadius = 20,
    this.selectedTextStyle = const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    this.unselectedTextStyle = const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
    required this.selectedIndex, // 让外部传入选中索引
    required this.onSelect, // 让外部控制选中逻辑
  });

  final List<String> options;
  final Color selectedColor;
  final Color unselectedColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final TextStyle selectedTextStyle;
  final TextStyle unselectedTextStyle;
  final RxInt selectedIndex; // 由外部控制的 RxInt
  final void Function(int) onSelect; // 选中时的回调

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(vertical: FSizes.spaceBtwItems),
      child: Wrap( // 用 Wrap 代替 Row
        spacing: 10, // 每个选项之间的水平间距
        runSpacing: 10, // 每行之间的间距
        alignment: WrapAlignment.start, // 左对齐
        children: List.generate(
          options.length,
              (index) => GestureDetector(
            onTap: () => onSelect(index), // 点击时调用外部的 onSelect
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: selectedIndex.value == index ? selectedColor : unselectedColor,
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Text(
                options[index],
                style: selectedIndex.value == index ? selectedTextStyle : unselectedTextStyle,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
