import 'package:vector_math/vector_math.dart';

class DefaultShaderConfig extends ShaderConfig {
  DefaultShaderConfig()
      : super(
          ambientCoefficient: 1,
          diffuseCoefficient: 1,
          specularCoefficient: 1,
          shininess: 80,
          ambientColor: Vector3(0, 0, 0),
          specularColor: Vector3(1, 1, 1),
        );
}

class ShaderConfig {
  ShaderConfig({
    required this.ambientCoefficient,
    required this.diffuseCoefficient,
    required this.specularCoefficient,
    required this.shininess,
    required this.ambientColor,
    required this.specularColor,
  });

  final double ambientCoefficient;
  final double diffuseCoefficient;
  final double specularCoefficient;
  final double shininess;
  final Vector3 ambientColor;
  final Vector3 specularColor;
}
