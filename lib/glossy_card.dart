import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ohso3d/main.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;

class GlossyCard extends StatelessWidget {
  const GlossyCard({
    required this.offset,
    required this.surfaceNormal,
    Key? key,
  }) : super(key: key);

  /// Offset relative to parent center
  final Offset offset;
  final Vector3 surfaceNormal;

  @override
  Widget build(BuildContext context) {
    final lightPos = Vector3(0, 0, -0.5);

    final viewerPos = Vector3(0, 0, -1);

    final angleX = Vector3(0, surfaceNormal.y, surfaceNormal.z).angleTo(viewerPos) * surfaceNormal.y.sign;
    final angleY = Vector3(surfaceNormal.x, 0, surfaceNormal.z).angleTo(viewerPos) * -surfaceNormal.x.sign;

    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(angleX)
        ..rotateY(angleY),
      child: CustomPaint(
        painter: ShaderPainter(
          lightPos: lightPos,
          surfaceNormal: surfaceNormal,
          viewerPos: viewerPos,
        ),
      ),
    );
  }
}

class ShaderPainter extends CustomPainter {
  final Vector3 lightPos;
  final Vector3 surfaceNormal;
  final Vector3 viewerPos;

  ShaderPainter({
    required this.lightPos,
    required this.surfaceNormal,
    required this.viewerPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final phongShader = phongProgram.shader(
      floatUniforms: Float32List.fromList(<double>[
        1, // Ka
        1, // Kd
        1, // Ks
        80, // shininessVal
        0, 0, 0, // ambientColor
        112 / 256.0, 0 / 256.0, 204 / 256.0, // diffuseColor
        1, 1, 1, // specularColor
        lightPos.x, lightPos.y, lightPos.z, // lightPos
        size.width, size.height, // viewportSize
        surfaceNormal.x, surfaceNormal.y, surfaceNormal.z, // surfaceNormal
        viewerPos.x, viewerPos.y, viewerPos.z,
      ]),
    );
    final paint = Paint()..shader = phongShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
