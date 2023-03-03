import 'dart:ui';

import 'package:vector_math/vector_math.dart';

class DefaultPhongShaderConfig extends PhongShaderConfig {
  DefaultPhongShaderConfig()
      : super(
          ambientCoefficient: 0,
          diffuseCoefficient: 1,
          specularCoefficient: 1,
          shininess: 80,
          ambientColor: Vector3(0, 0, 0),
          specularColor: Vector3(1, 1, 1),
        );
}

class PhongShaderConfig extends ShaderConfig {
  PhongShaderConfig({
    required this.ambientCoefficient,
    required this.diffuseCoefficient,
    required this.specularCoefficient,
    required this.shininess,
    required this.ambientColor,
    required this.specularColor,
  }) : super('packages/ohso3d/shaders/phong.glsl');

  final double ambientCoefficient;
  final double diffuseCoefficient;
  final double specularCoefficient;
  final double shininess;
  final Vector3 ambientColor;
  final Vector3 specularColor;

  @override
  void apply(
    FragmentShader shader,
    Vector3 lightPos,
    Size canvasSize,
    Vector3 normal,
    Vector3 viewerPos,
    List<Image> images,
    Vector3 offset,
    Size worldSize,
  ) {
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

    shader.setFloat(10, lightPos.x);
    shader.setFloat(11, lightPos.y);
    shader.setFloat(12, lightPos.z);

    shader.setFloat(13, canvasSize.width);
    shader.setFloat(14, canvasSize.height);

    shader.setFloat(15, normal.x);
    shader.setFloat(16, normal.y);
    shader.setFloat(17, normal.z);

    shader.setFloat(18, viewerPos.x);
    shader.setFloat(19, viewerPos.y);
    shader.setFloat(20, viewerPos.z);

    shader.setFloat(21, offset.x);
    shader.setFloat(22, offset.y);
    shader.setFloat(23, offset.z);

    shader.setFloat(24, worldSize.width);
    shader.setFloat(25, worldSize.height);

    shader.setImageSampler(0, images[0]);
    shader.setImageSampler(1, images[1]);
  }
}

abstract class ShaderConfig {
  final String fragmentProgramAsset;

  ShaderConfig(this.fragmentProgramAsset);

  void apply(
      FragmentShader shader,
      Vector3 lightPos,
      Size canvasSize,
      Vector3 normal,
      Vector3 viewerPos,
      List<Image> images,
      Vector3 offset,
      Size worldSize,
  );
}
