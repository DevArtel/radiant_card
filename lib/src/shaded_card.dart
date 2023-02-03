import 'package:flutter/material.dart';
import 'package:ohso3d/ohso3d.dart';
import 'package:vector_math/vector_math.dart';

import 'image_context_widget.dart';
import 'orientation_controller.dart';
import 'oriented_card.dart';
import 'shader_context_widget.dart';

// TODO Fix flickering on rotation start
// TODO Animation depends on phone orientation
// TODO Global illumination
// TODO LightPosAnimator
// TODO Customizable card aspect ratio
// TODO Enable library to work with plain Widget instead of texture filenames
// TODO Publish
class RotatableShadedCard extends StatelessWidget {
  final String mainTextureFile, maskFile;
  final ShaderConfig? config;

  const RotatableShadedCard({
    super.key,
    required this.mainTextureFile,
    required this.maskFile,
    this.config,
  });

  @override
  Widget build(BuildContext context) => OrientationController(
        builder: (context, normal) => ShadedCard(
          mainTextureFile: mainTextureFile,
          maskFile: maskFile,
          normal: normal,
          config: config,
        ),
      );
}

class ShadedCard extends StatelessWidget {
  final Vector3 normal;
  final String mainTextureFile, maskFile;
  final ShaderConfig config;
  final Vector3 lightPos;
  final Vector3 viewerPos;

  ShadedCard({
    super.key,
    required this.mainTextureFile,
    required this.maskFile,
    ShaderConfig? config,
    Vector3? normal,
    Vector3? lightPos,
    Vector3? viewerPos,
  })  : config = config ?? DefaultPhongShaderConfig(),
        normal = normal ?? Vector3(0, 0, -1),
        lightPos = lightPos ?? Vector3(0, 0, -1),
        viewerPos = viewerPos ?? Vector3(0, 0, -1);

  @override
  Widget build(BuildContext context) => ShaderContextWidget(
        shaderAsset: config.shaderAsset,
        builder: (context, shader) => ImageContextWidget(
          imageFiles: [mainTextureFile, maskFile],
          builder: (context, images) => OrientedCard(
            normal: normal,
            shader: shader,
            viewerPos: viewerPos,
            configurator: (shader, size) => config.apply(shader, lightPos, size, normal, viewerPos, images),
          ),
          emptyBuilder: (context) => Image.asset(mainTextureFile),
        ),
        emptyBuilder: (context) => Image.asset(mainTextureFile),
      );
}
