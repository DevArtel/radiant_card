import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ohso3d/ohso3d.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;

final _defaultConfig = DefaultShaderConfig();

class GlossyCard extends StatelessWidget {
  const GlossyCard({
    required this.offset,
    required this.surfaceNormal,
    required this.image,
    required this.mask,
    this.config,
    Key? key,
  }) : super(key: key);

  /// Offset relative to parent center
  final Offset offset;
  final Vector3 surfaceNormal;
  final ui.Image image;
  final ui.Image mask;
  final ShaderConfig? config;

  @override
  Widget build(BuildContext context) {
    final lightPos = Vector3(0, 0, -1);

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
        painter: _ShaderPainter(
            image: image,
            lightPos: lightPos,
            surfaceNormal: surfaceNormal,
            viewerPos: viewerPos,
            mask: mask,
            config: config ?? _defaultConfig),
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.lightPos,
    required this.surfaceNormal,
    required this.viewerPos,
    required this.image,
    required this.mask,
    required this.config,
  });

  final Vector3 lightPos;
  final Vector3 surfaceNormal;
  final Vector3 viewerPos;
  final ui.Image image;
  final ui.Image mask;
  final ShaderConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final phongShader = phongProgram.fragmentShader();

    config.populate(phongShader);

    phongShader.setFloat(10, lightPos.x);
    phongShader.setFloat(11, lightPos.y);
    phongShader.setFloat(12, lightPos.z);

    phongShader.setFloat(13, size.width);
    phongShader.setFloat(14, size.height);

    phongShader.setFloat(15, surfaceNormal.x);
    phongShader.setFloat(16, surfaceNormal.y);
    phongShader.setFloat(17, surfaceNormal.z);

    phongShader.setFloat(18, viewerPos.x);
    phongShader.setFloat(19, viewerPos.y);
    phongShader.setFloat(20, viewerPos.z);

    phongShader.setImageSampler(0, image);
    phongShader.setImageSampler(1, mask);

    paint.shader = phongShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension PopulateShaderExt on ShaderConfig {
  void populate(ui.FragmentShader phongShader) {
    phongShader.setFloat(0, ambientCoefficient);
    phongShader.setFloat(1, diffuseCoefficient);
    phongShader.setFloat(2, specularCoefficient);
    phongShader.setFloat(3, shininess);

    phongShader.setFloat(4, ambientColor.x);
    phongShader.setFloat(5, ambientColor.y);
    phongShader.setFloat(6, ambientColor.z);

    phongShader.setFloat(7, specularColor.x);
    phongShader.setFloat(8, specularColor.y);
    phongShader.setFloat(9, specularColor.z);
  }
}
