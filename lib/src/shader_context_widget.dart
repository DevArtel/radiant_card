import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

late final ui.FragmentProgram _shader;

enum _ShaderState {
  notInitialized,
  initializing,
  initialized,
}

_ShaderState _shaderState = _ShaderState.notInitialized;
Completer<void> _completer = Completer();

// TODO multiple shader support
Future<void> _initShader(String shaderAsset) {
  switch (_shaderState) {
    case _ShaderState.initializing:
      return _completer.future;
    case _ShaderState.notInitialized:
      _shaderState = _ShaderState.initializing;
      return Future<void>(() async {
        _shader = await ui.FragmentProgram.fromAsset(shaderAsset);
      }).then((value) {
        _shaderState = _ShaderState.initialized;
        _completer.complete();
      });
    case _ShaderState.initialized:
      return Future(() {});
  }
}

// TODO shader list in parameters
class ShaderContextWidget extends StatelessWidget {
  final Function(BuildContext, ui.FragmentProgram) builder;
  final WidgetBuilder emptyBuilder;
  final String shaderAsset;

  const ShaderContextWidget({
    Key? key,
    required this.builder,
    required this.emptyBuilder,
    required this.shaderAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _shaderState == _ShaderState.initialized
      ? builder(context, _shader)
      : FutureBuilder<void>(
          future: _initShader(shaderAsset),
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.done ? builder(context, _shader) : emptyBuilder(context),
        );
}
