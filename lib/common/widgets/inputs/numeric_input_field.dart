import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NumericInputField extends StatelessWidget {
  const NumericInputField({
    super.key,
    required this.value,
    this.minWidth = 50,
    this.maxWidth = 100,
    this.borderColor = Colors.blue,
    this.borderRadius = 8.0,
    this.textColor = Colors.white,
  });

  final RxInt value;
  final double minWidth;
  final double maxWidth;
  final Color borderColor;
  final double borderRadius;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
    TextEditingController(text: value.value.toString());
    final FocusNode focusNode = FocusNode();

    return Obx(() {
      if (controller.text != value.value.toString()) {
        controller.text = value.value.toString();
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }

      return Container(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: IntrinsicWidth(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),],
            style: TextStyle(color: textColor, fontSize: 18),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
            ),
            onChanged: (newValue) {
              if (newValue.isNotEmpty) {
                int? parsedValue = int.tryParse(newValue);
                if (parsedValue != null) {
                  value.value = parsedValue;
                }
              }
            },
          ),
        ),
      );
    });
  }
}
