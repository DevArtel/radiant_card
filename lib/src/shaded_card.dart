import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ohso3d/ohso3d.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;

// todo move configuration outside library internals
final _defaultConfig = DefaultShaderConfig();

class ShadedCard extends StatelessWidget {
  const ShadedCard({
    required this.surfaceNormal,
    required this.image,
    required this.mask,
    required this.shader,
    this.config,
    Key? key,
  }) : super(key: key);

  final Vector3 surfaceNormal;
  final ui.Image image;
  final ui.Image mask;
  final ShaderConfig? config;
  final ui.FragmentProgram shader;

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
          config: config ?? _defaultConfig,
          shader: shader,
        ),
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
    required this.shader,
  });

  final Vector3 lightPos;
  final Vector3 surfaceNormal;
  final Vector3 viewerPos;
  final ui.Image image;
  final ui.Image mask;
  final ShaderConfig config;
  final ui.FragmentProgram shader;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final fragmentShader = shader.fragmentShader();

    config.populate(fragmentShader);

    // TODO move to the top where shader is specified
    fragmentShader.setFloat(10, lightPos.x);
    fragmentShader.setFloat(11, lightPos.y);
    fragmentShader.setFloat(12, lightPos.z);
    fragmentShader.setFloat(13, size.width);
    fragmentShader.setFloat(14, size.height);
    fragmentShader.setFloat(15, surfaceNormal.x);
    fragmentShader.setFloat(16, surfaceNormal.y);
    fragmentShader.setFloat(17, surfaceNormal.z);
    fragmentShader.setFloat(18, viewerPos.x);
    fragmentShader.setFloat(19, viewerPos.y);
    fragmentShader.setFloat(20, viewerPos.z);
    fragmentShader.setImageSampler(0, image);
    fragmentShader.setImageSampler(1, mask);

    paint.shader = fragmentShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// TODO move to the top where shader is specified
extension PopulateShaderExt on ShaderConfig {
  void populate(ui.FragmentShader shader) {
    shader.setFloat(0, ambientCoefficient);
    shader.setFloat(1, diffuseCoefficient);
    shader.setFloat(2, specularCoefficient);
    shader.setFloat(3, shininess);

    shader.setFloat(4, ambientColor.x);
    shader.setFloat(5, ambientColor.y);
    shader.setFloat(6, ambientColor.z);

    shader.setFloat(7, specularColor.x);
    shader.setFloat(8, specularColor.y);
    shader.setFloat(9, specularColor.z);
  }
}
