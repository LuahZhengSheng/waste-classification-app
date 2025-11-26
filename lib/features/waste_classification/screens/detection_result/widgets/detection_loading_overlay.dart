import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

class DetectionLoadingOverlay extends StatelessWidget {
  final bool isVisible;

  const DetectionLoadingOverlay({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(FSizes.xl),
          decoration: BoxDecoration(
            color: FColors.white,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: FColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: FSizes.md),
              const Text(
                'Analyzing Image...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: FColors.textPrimary,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'This may take a few seconds',
                style: TextStyle(
                  fontSize: 14,
                  color: FColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}