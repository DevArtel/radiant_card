import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;

class OrientedCard extends StatelessWidget {
  const OrientedCard({
    required this.normal,
    required this.shader,
    required this.configurator,
    required this.viewerPos,
    Key? key,
  }) : super(key: key);

  final Vector3 normal;
  final Function(ui.FragmentShader, Size) configurator;
  final ui.FragmentProgram shader;
  final Vector3 viewerPos;

  @override
  Widget build(BuildContext context) {
    final angleX = Vector3(0, normal.y, normal.z).angleTo(viewerPos) * normal.y.sign;
    final angleY = Vector3(normal.x, 0, normal.z).angleTo(viewerPos) * -normal.x.sign;

    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(angleX)
        ..rotateY(angleY),
      child: CustomPaint(
        painter: _ShaderPainter(
          shader: shader,
          configurator: configurator,
        ),
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.shader,
    required this.configurator,
  });

  final ui.FragmentProgram shader;
  final Function(ui.FragmentShader, Size) configurator;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final fragmentShader = shader.fragmentShader();
    configurator(fragmentShader, size);
    paint.shader = fragmentShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
