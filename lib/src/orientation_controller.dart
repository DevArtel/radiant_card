import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class OrientationController extends StatefulWidget {
  final Function(BuildContext, Vector3) builder;

  const OrientationController({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<OrientationController> createState() => _OrientationControllerState();
}

class _OrientationControllerState extends State<OrientationController> {
  Offset _pointerPosition = Offset.zero;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final center = constraints.biggest.center(Offset.zero);
          final normal = Vector3(
            -_pointerPosition.dx,
            -_pointerPosition.dy,
            -max(center.dx, center.dy),
          );

          return GestureDetector(
            child: widget.builder(context, normal),
            onPanUpdate: (details) {
              setState(() {
                _pointerPosition = details.localPosition - center;
              });
            },
          );
        },
      );
}
