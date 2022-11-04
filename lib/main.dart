import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohso3d/src/glorious_card.dart';

late final Shader shader;
late final Shader phongShader;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final program = await ui.FragmentProgram.compile(
    spirv: (await rootBundle.load('assets/shaders/simple.sprv')).buffer,
  );
  final phongProgram = await ui.FragmentProgram.compile(
    spirv: (await rootBundle.load('assets/shaders/phong.sprv')).buffer,
  );

  shader = program.shader(
    floatUniforms: Float32List.fromList(<double>[1]),
  );

  /**
   * layout(location = 0) in vec3 normalInterp;  // Surface normal
      layout(location = 1) in vec3 vertPos;       // Vertex position
      // layout(location = 0) uniform int mode;   // Rendering mode
      layout(location = 0) uniform float Ka;   // Ambient reflection coefficient
      layout(location = 1) uniform float Kd;   // Diffuse reflection coefficient
      layout(location = 2) uniform float Ks;   // Specular reflection coefficient
      layout(location = 3) uniform float shininessVal; // Shininess
      // Material color
      layout(location = 4) uniform vec3 ambientColor;
      layout(location = 5) uniform vec3 diffuseColor;
      layout(location = 6) uniform vec3 specularColor;
      layout(location = 7) uniform vec3 lightPos; // Light position
   */
  phongShader = phongProgram.shader(
    floatUniforms: Float32List.fromList(<double>[
      1, // Ka
      1, // Kd
      1, // Ks
      80, // shininessVal
      0, 0, 0, // ambientColor
      112 / 256.0, 0 / 256.0, 204 / 256.0, // diffuseColor
      1, 1, 1, // specularColor
      // -1.9, 1, -1, // lightPos
      0, 0, -1, // lightPos
    ]),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards demo'),
      ),
      body: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
        children: List.generate(
          8,
          (index) => GloriousCard(
              maxAngle: pi / 6,
              child: CustomPaint(
                painter: ShaderPainter(),
              )
              // Container(
              //   decoration: BoxDecoration(
              //     boxShadow: const [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 5,
              //         spreadRadius: 5,
              //       ),
              //     ],
              //     color: Color(Random(index).nextInt(pow(2, 32) as int)).withOpacity(1),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              // ),
              ),
        ),
      ),
    );
  }
}

class ShaderPainter extends CustomPainter {
  ShaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = phongShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
