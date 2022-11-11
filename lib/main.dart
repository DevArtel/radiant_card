import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4;

late final ui.FragmentProgram phongProgram;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  phongProgram = await ui.FragmentProgram.compile(
    spirv: (await rootBundle.load('assets/shaders/phong.sprv')).buffer,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // primarySwatch: Colors.blue,
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
        crossAxisCount: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
        children: List.generate(
          1,
          (index) => const SingleCardWidget(),
          // (index) => GloriousCard(
          //     maxAngle: pi / 6,
          //     child: CustomPaint(
          //       painter: ShaderPainter(),
          //     )
          //     // Container(
          //     //   decoration: BoxDecoration(
          //     //     boxShadow: const [
          //     //       BoxShadow(
          //     //         color: Colors.black12,
          //     //         blurRadius: 5,
          //     //         spreadRadius: 5,
          //     //       ),
          //     //     ],
          //     //     color: Color(Random(index).nextInt(pow(2, 32) as int)).withOpacity(1),
          //     //     borderRadius: BorderRadius.circular(16),
          //     //   ),
          //     // ),
          //     ),
        ),
      ),
    );
  }
}

class SingleCardWidget extends StatefulWidget {
  const SingleCardWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<SingleCardWidget> createState() => _SingleCardWidgetState();
}

class _SingleCardWidgetState extends State<SingleCardWidget> {
  Offset _pointerPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = constraints.biggest.center(Offset.zero);

        final lightPos = Vector3(0, 0, -0.5);
        final surfaceNormal = Vector3(
          -_pointerPosition.dx,
          -_pointerPosition.dy,
          -max(center.dx, center.dy),
        ).normalized();
        final viewerPos = Vector3(0, 0, -1);

        final angleX = Vector3(0, surfaceNormal.y, surfaceNormal.z).angleTo(viewerPos) * surfaceNormal.y.sign;
        final angleY = Vector3(surfaceNormal.x, 0, surfaceNormal.z).angleTo(viewerPos) * -surfaceNormal.x.sign;

        return GestureDetector(
          child: Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(angleX)
              ..rotateY(angleY),
            child: CustomPaint(
              painter: ShaderPainter(
                lightPos: lightPos,
                surfaceNormal: surfaceNormal,
                viewerPos: viewerPos,
              ),
            ),
          ),
          onPanUpdate: (details) {
            setState(() {
              _pointerPosition = details.localPosition - center;
            });
          },
        );
      },
    );
  }
}

class ShaderPainter extends CustomPainter {
  final Vector3 lightPos;
  final Vector3 surfaceNormal;
  final Vector3 viewerPos;

  ShaderPainter({
    required this.lightPos,
    required this.surfaceNormal,
    required this.viewerPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final phongShader = phongProgram.shader(
      floatUniforms: Float32List.fromList(<double>[
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
      ]),
    );
    final paint = Paint()..shader = phongShader;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
