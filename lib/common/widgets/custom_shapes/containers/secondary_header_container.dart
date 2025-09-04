import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/custom_shapes/curved_edges/left_curved_edges_widget.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class FSecondaryHeaderContainer extends StatelessWidget {
  const FSecondaryHeaderContainer({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    bool dark = FHelperFunctions.isDarkMode(context);

    return FLeftCurvedEdgeWidget(
      child: Container(
        color: FColors.primary,

        child: Stack(
          children: [
            /// -- Background Custom Shapes
            child,
          ],
        ),
      ),
    );
  }
}