import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'orientation_controller.dart';
import 'oriented_card.dart';
import 'shader_config.dart';
import 'shader_context_widget.dart';

// TODO support Flutter animations in rendered-to-texture widgets
// TODO Animation depends on phone orientation
// TODO LightPosAnimator
// TODO Publish
class RotatableShadedCard extends StatelessWidget {
  final ui.Image mainTexture, mask;
  final ShaderConfig? shaderConfig;
  final Vector3 centerPos;
  final Size worldSize;

  const RotatableShadedCard({
    super.key,
    required this.mainTexture,
    required this.mask,
    this.shaderConfig,
    required this.centerPos,
    required this.worldSize,
  });

  @override
  Widget build(BuildContext context) => OrientationController(
        builder: (context, normal) => ShadedCard(
          mainTexture: mainTexture,
          mask: mask,
          normal: normal,
          shaderConfig: shaderConfig,
          centerPos: centerPos,
          worldSize: worldSize,
        ),
      );
}

class ShadedCard extends StatelessWidget {
  final Vector3 normal;
  final ui.Image mainTexture, mask;
  final ShaderConfig shaderConfig;
  final Vector3 lightPos;
  final Vector3 viewerPos;
  final Vector3 centerPos;
  final Size worldSize;

  ShadedCard({
    super.key,
    required this.mainTexture,
    required this.mask,
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
        builder: (context, fragmentProgram) => OrientedCard(
          normal: normal,
          fragmentProgram: fragmentProgram,
          viewerPos: viewerPos,
          configurator: (shader, size) => shaderConfig.apply(
            shader,
            lightPos,
            size,
            normal,
            viewerPos,
            mainTexture,
            mask,
            centerPos,
            worldSize,
          ),
        ),
        emptyBuilder: (context) => const SizedBox.shrink(),
      );
}
