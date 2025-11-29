import 'package:flutter/material.dart';

class CommonBadge extends StatelessWidget {
  final IconData? icon;
  final Color? color;
  final String text;
  final double iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;

  const CommonBadge({
    super.key,
    this.icon,
    this.color,
    required this.text,
    this.iconSize = 14,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 6,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = color ?? Theme.of(context).primaryColor;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: (borderColor ?? baseColor.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: baseColor, size: iconSize),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: textStyle ??
                TextStyle(
                  color: baseColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
