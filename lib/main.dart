import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohso3d/glossy_card.dart';
import 'package:vector_math/vector_math.dart' hide Matrix4, Colors;

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
        childAspectRatio: 711.0 / 990.0,
        children: List.generate(
          1,
          (index) => const SingleCardWidget(),
        ),
      ),
      backgroundColor: Colors.white,
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
      future: Future.wait([getImage("assets/images/pikachu.png"), getImage("assets/images/mask_1.png")]),
      builder: (context, snapshot) => !snapshot.hasData
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, constraints) {
                final images = snapshot.data!;

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
                    image: images[0],
                    mask: images[1],
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

  Future<ui.Image> getImage(String file) async {
    final asset = await rootBundle.load(file);
    final image = await decodeImageFromList(asset.buffer.asUint8List());
    return image;
  }
}
