import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class RotationController extends StatefulWidget {
  final Function(BuildContext, Vector3) builder;

  const RotationController({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<RotationController> createState() => _RotationControllerState();
}

class _RotationControllerState extends State<RotationController> {
  Offset _pointerPosition = Offset.zero;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final center = constraints.biggest.center(Offset.zero);
          final surfaceNormal = Vector3(
            -_pointerPosition.dx,
            -_pointerPosition.dy,
            -max(center.dx, center.dy),
          );

          return GestureDetector(
            child: widget.builder(context, surfaceNormal),
            onPanUpdate: (details) {
              setState(() {
                _pointerPosition = details.localPosition - center;
              });
            },
          );
        },
      );
}
