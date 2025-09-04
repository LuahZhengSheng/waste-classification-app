import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/sizes.dart';

class FActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final bool hasHoverEffect;

  const FActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    this.onPressed,
    this.hasHoverEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm * 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm * 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: FSizes.iconSm,
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                text,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}