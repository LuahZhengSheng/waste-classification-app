import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:fyp/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:fyp/utils/constants/colors.dart';

class FPrimaryHeaderContainer extends StatelessWidget {
  const FPrimaryHeaderContainer({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCurvedEdgeWidget(
        child: Container(
          color: FColors.primary,

          child: Stack(
            children: [
              /// -- Background Custom Shapes
              Positioned(top: -150, right: -250, child: FCircularContainer(backgroundColor: FColors.textWhite.withOpacity(0.1))),
              Positioned(top: 100, right: -300, child: FCircularContainer(backgroundColor: FColors.textWhite.withOpacity(0.1))),
              child,
            ],
          ),
        ),
    );
  }
}