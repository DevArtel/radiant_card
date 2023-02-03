import 'package:flutter/material.dart';
import 'package:ohso3d/ohso3d.dart';
import 'package:vector_math/vector_math.dart';

import 'image_context_widget.dart';
import 'rotation_controller.dart';
import 'shaded_card.dart';
import 'shader_context_widget.dart';

// TODO Animation depends on phone orientation
// TODO Global illumination
// TODO LightPosAnimator
// TODO Customizable card aspect ratio
// TODO Enable library to work with plain Widget instead of texture filenames
// TODO Publish
class RotatablePhongShadedCard extends StatelessWidget {
  final String mainTextureFile, maskFile;
  final ShaderConfig? config;

  const RotatablePhongShadedCard({
    super.key,
    required this.mainTextureFile,
    required this.maskFile,
    this.config,
  });

  @override
  Widget build(BuildContext context) => RotationController(
        builder: (context, normal) => PhongShadedCard(
          mainTextureFile: mainTextureFile,
          maskFile: maskFile,
          normal: normal,
          config: config,
        ),
      );
}

class PhongShadedCard extends StatelessWidget {
  final Vector3 normal;
  final String mainTextureFile, maskFile;
  final ShaderConfig? config;

  const PhongShadedCard({
    super.key,
    required this.normal,
    required this.mainTextureFile,
    required this.maskFile,
    this.config,
  });

  @override
  Widget build(BuildContext context) => ShaderContextWidget(
        shaderAsset: 'packages/ohso3d/shaders/phong.glsl',
        builder: (context, shader) => ImageContextWidget(
          imageFiles: [mainTextureFile, maskFile],
          builder: (context, images) => ShadedCard(
            surfaceNormal: normal,
            image: images[0],
            mask: images[1],
            phongProgram: shader,
            config: config,
          ),
          emptyBuilder: (context) => Image.asset(mainTextureFile),
        ),
        emptyBuilder: (context) => Image.asset(mainTextureFile),
      );
}
