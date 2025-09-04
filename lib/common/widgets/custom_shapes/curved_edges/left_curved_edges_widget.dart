import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/custom_shapes/curved_edges/left_curved_edges.dart';

class FLeftCurvedEdgeWidget extends StatelessWidget {
  const FLeftCurvedEdgeWidget({
    super.key, this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FCustomLeftCurvedEdges(),
      child: child,
    );
  }
}