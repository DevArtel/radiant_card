import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohso3d/glossy_card.dart';
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
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
    return FutureBuilder(
      future: getImage(),
      builder: (context, snapshot) => !snapshot.hasData
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, constraints) {
                final image = snapshot.data!;

                final center = constraints.biggest.center(Offset.zero);
                final surfaceNormal = Vector3(
                  -_pointerPosition.dx,
                  -_pointerPosition.dy,
                  -max(center.dx, center.dy),
                );

                return GestureDetector(
                  child: GlossyCard(
                    offset: center,
                    surfaceNormal: surfaceNormal,
                    image: image,
                  ),
                  onPanUpdate: (details) {
                    setState(() {
                      _pointerPosition = details.localPosition - center;
                    });
                  },
                );
              },
            ),
    );
  }

  Future<ui.Image> getImage() async {
    final asset = await rootBundle.load("assets/images/pikachu.png");
    final image = await decodeImageFromList(asset.buffer.asUint8List());
    return image;
  }
}
