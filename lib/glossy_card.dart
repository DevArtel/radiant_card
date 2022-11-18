import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ohso3d/main.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;


//todo card aspect ratio
//todo cool shit
class GlossyCard extends StatelessWidget {
  const GlossyCard({
    required this.offset,
    required this.surfaceNormal,
    required this.image,
    Key? key,
  }) : super(key: key);

  /// Offset relative to parent center
  final Offset offset;
  final Vector3 surfaceNormal;
  final ui.Image image;

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
          image: image,
          lightPos: lightPos,
          surfaceNormal: surfaceNormal,
          viewerPos: viewerPos,
        ),
      ),
    );
  }
}

class ShaderPainter extends CustomPainter {
  ShaderPainter({
    required this.lightPos,
    required this.surfaceNormal,
    required this.viewerPos,
    required this.image,
  }) : imageShader = ImageShader(
          image,
          // Specify how image repetition is handled for x and y dimension
          TileMode.decal,
          TileMode.decal,
          // Transformation matrix (identity matrix = no transformation)
          Matrix4.identity().storage,
        );

  final Vector3 lightPos;
  final Vector3 surfaceNormal;
  final Vector3 viewerPos;
  final ui.Image image;
  final ImageShader imageShader;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final phongShader = phongProgram.shader(
      floatUniforms: Float32List.fromList(
        <double>[
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
          image.width.toDouble(), image.height.toDouble(),
        ],
      ),
      samplerUniforms: [imageShader],
    );

    paint.shader = phongShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
