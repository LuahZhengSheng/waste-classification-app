import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/custom_shapes/curved_edges/curved_edges.dart';

class FCurvedEdgeWidget extends StatelessWidget {
  const FCurvedEdgeWidget({
    super.key, this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FCustomCurvedEdges(),
      child: child,
    );
  }
}