import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/sizes.dart';

// Post media grid widgets
class FPostMedia extends StatelessWidget {
  final List<String> mediaUrls;
  final int maxDisplay;
  final Function(int)? onTap; // Optional tap callback

  const FPostMedia({
    super.key,
    required this.mediaUrls,
    this.maxDisplay = 5,
    this.onTap, // Non-required parameter
  });

  @override
  Widget build(BuildContext context) {
    final displayUrls = mediaUrls.take(maxDisplay).toList();
    final remainingCount = mediaUrls.length - maxDisplay;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(displayUrls.length, (index) {
            final isLast = index == displayUrls.length - 1;
            final showOverlay = remainingCount > 0 && isLast;

            return GestureDetector(
              onTap: onTap != null ? () => onTap!(index) : null,
              child: SizedBox(
                width: _getImageWidth(constraints.maxWidth, displayUrls.length, index),
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        displayUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                      if (showOverlay)
                        Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Text(
                              '+$remainingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Calculate media width based on total media and position
  double _getImageWidth(double containerWidth, int totalMedia, int index) {
    const spacing = 4.0;

    if (totalMedia == 1) {
      return containerWidth; // Single media takes full width
    }

    if (totalMedia == 2) {
      return (containerWidth - spacing) / 2; // Two media split width equally
    }

    if (totalMedia >= 3) {
      // First row: Single media (index 0) takes full width
      if (index == 0) {
        return containerWidth;
      }
      // Second row: Two media (index 1 and 2) split width equally
      else {
        return (containerWidth - spacing) / 2;
      }
    }

    return (containerWidth - spacing) / 2; // Default case
  }
}