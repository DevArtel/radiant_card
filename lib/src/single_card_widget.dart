import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';

import 'glossy_card.dart';

late final ui.FragmentProgram phongProgram;

enum _ShaderState {
  notInitialized,
  initializing,
  initialized,
}

_ShaderState _shaderState = _ShaderState.notInitialized;
Completer<void> _completer = Completer();

Future<void> _initPhongShader() {
  switch (_shaderState) {
    case _ShaderState.initializing:
      return _completer.future;
    case _ShaderState.notInitialized:
      _shaderState = _ShaderState.initializing;
      return Future<void>(() async {
        phongProgram = await ui.FragmentProgram.fromAsset('packages/ohso3d/shaders/phong.glsl');
      }).then((value) {
        _shaderState = _ShaderState.initialized;
        _completer.complete();
      });
    case _ShaderState.initialized:
      return Future(() {});
  }
}

//todo  1. General case, with normal
//todo  2. Animation depends on angle with gesture detector
//todo  3. Light depends on card location on the screen
//todo  4. LightAnimator
//todo card aspect ratio
//todo Enable library to work with plain Widget instead of ui.Image
//todo Consistent naming
//todo remove GlossyCard, only one functional widget is necessary
//todo publish
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
  Widget build(BuildContext context) => _shaderState == _ShaderState.initialized
      ? buildInnerSingleCardWidget()
      : FutureBuilder<void>(
          future: _initPhongShader(),
          builder: (context, snapshot) => snapshot.connectionState != ConnectionState.done
              ? Image.asset(widget.mainTextureFile)
              : buildInnerSingleCardWidget(),
        );

  _InnerSingleCardWidget buildInnerSingleCardWidget() => _InnerSingleCardWidget(
        mainTextureFile: widget.mainTextureFile,
        maskFile: widget.maskFile,
      );
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
      future: Future.wait([_getImage(widget.mainTextureFile), _getImage(widget.maskFile)]),
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
}

Future<ui.Image> _getImage(String file) async {
  final asset = await rootBundle.load(file);
  final image = await decodeImageFromList(asset.buffer.asUint8List());
  return image;
}
