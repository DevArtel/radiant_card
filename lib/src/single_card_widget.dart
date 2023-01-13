
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';

import 'glossy_card.dart';

late final ui.FragmentProgram phongProgram;

bool _isInitialized = false;

// TODO allow client to initialize the shader lazily via a future builder widget
Future<void> _initPhongShader() async {
  // WidgetsFlutterBinding.ensureInitialized();
  if (_isInitialized) {
    return;
  }
  phongProgram = await ui.FragmentProgram.compile(
    spirv: (await rootBundle.load('packages/ohso3d/assets/shaders/phong.sprv')).buffer,
  );
  _isInitialized = true;
}

class SingleCardWidget extends StatefulWidget {
  const SingleCardWidget({
    Key? key,
    required this.mainTextureFile,
    required this.maskFile,
  }) : super(key: key);

  final String mainTextureFile;
  final String maskFile;

  @override
  State<SingleCardWidget> createState() => _SingleCardWidgetState();
}

class _SingleCardWidgetState extends State<SingleCardWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void> (
      future: _initPhongShader(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink(); // TODO allow client to customize the behavior
        }
        return _InnerSingleCardWidget(
          mainTextureFile: widget.mainTextureFile,
          maskFile: widget.maskFile,
        );
      }
    );
  }
}

class _InnerSingleCardWidget extends StatefulWidget {
  const _InnerSingleCardWidget({
    Key? key,
    required this.mainTextureFile,
    required this.maskFile,
  }) : super(key: key);

  final String mainTextureFile;
  final String maskFile;

  @override
  State<_InnerSingleCardWidget> createState() => _InnerSingleCardWidgetState();
}

class _InnerSingleCardWidgetState extends State<_InnerSingleCardWidget> {
  Offset _pointerPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([getImage(widget.mainTextureFile), getImage(widget.maskFile)]),
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
