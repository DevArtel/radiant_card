import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'image_context_widget.dart';
import 'orientation_controller.dart';
import 'oriented_card.dart';
import 'shader_config.dart';
import 'shader_context_widget.dart';

// TODO Fix flickering on rotation start
// TODO Animation depends on phone orientation
// TODO LightPosAnimator
// TODO Enable library to work with Flutter widgets instead of textures
// TODO Publish
class RotatableShadedCard extends StatelessWidget {
  final String mainTextureFile, maskFile;
  final ShaderConfig? shaderConfig;
  final Vector3 centerPos;
  final Size worldSize;

  const RotatableShadedCard({
    super.key,
    required this.mainTextureFile,
    required this.maskFile,
    this.shaderConfig,
    required this.centerPos,
    required this.worldSize,
  });

  @override
  Widget build(BuildContext context) => OrientationController(
        builder: (context, normal) => ShadedCard(
          mainTextureFile: mainTextureFile,
          maskFile: maskFile,
          normal: normal,
          shaderConfig: shaderConfig,
          centerPos: centerPos,
          worldSize: worldSize,
        ),
      );
}

class ShadedCard extends StatelessWidget {
  final Vector3 normal;
  final String mainTextureFile, maskFile;
  final ShaderConfig shaderConfig;
  final Vector3 lightPos;
  final Vector3 viewerPos;
  final Vector3 centerPos;
  final Size worldSize;

  ShadedCard({
    super.key,
    required this.mainTextureFile,
    required this.maskFile,
    ShaderConfig? shaderConfig,
    Vector3? normal,
    Vector3? lightPos,
    Vector3? viewerPos,
    required this.centerPos,
    required this.worldSize,
  })  : shaderConfig = shaderConfig ?? DefaultPhongShaderConfig(),
        normal = normal ?? Vector3(0, 0, -1),
        lightPos = lightPos ?? Vector3(0, 0, -0.25),
        viewerPos = viewerPos ?? Vector3(0, 0, -1);

  @override
  Widget build(BuildContext context) => FragmentProgramContextWidget(
        fragmentProgramAsset: shaderConfig.fragmentProgramAsset,
        builder: (context, fragmentProgram) => ImageContextWidget(
          imageFiles: [mainTextureFile, maskFile],
          builder: (context, images) => OrientedCard(
            normal: normal,
            fragmentProgram: fragmentProgram,
            viewerPos: viewerPos,
            configurator: (shader, size) => shaderConfig.apply(shader, lightPos, size, normal, viewerPos, images, centerPos, worldSize),
          ),
          emptyBuilder: (context) => Image.asset(mainTextureFile),
        ),
        emptyBuilder: (context) => Image.asset(mainTextureFile),
      );
}
