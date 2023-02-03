import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

late final ui.FragmentProgram _fragmentProgram;

enum _FragmentProgramState {
  notInitialized,
  initializing,
  initialized,
}

_FragmentProgramState _fragmentProgramState = _FragmentProgramState.notInitialized;
Completer<void> _completer = Completer();

// TODO multiple fragment programs support
Future<void> _initFragmentProgram(String fragmentProgramAsset) {
  switch (_fragmentProgramState) {
    case _FragmentProgramState.initializing:
      return _completer.future;
    case _FragmentProgramState.notInitialized:
      _fragmentProgramState = _FragmentProgramState.initializing;
      return Future<void>(() async {
        _fragmentProgram = await ui.FragmentProgram.fromAsset(fragmentProgramAsset);
      }).then((value) {
        _fragmentProgramState = _FragmentProgramState.initialized;
        _completer.complete();
      });
    case _FragmentProgramState.initialized:
      return Future(() {});
  }
}

// TODO program asset list in parameters
class FragmentProgramContextWidget extends StatelessWidget {
  final Function(BuildContext, ui.FragmentProgram) builder;
  final WidgetBuilder emptyBuilder;
  final String fragmentProgramAsset;

  const FragmentProgramContextWidget({
    Key? key,
    required this.builder,
    required this.emptyBuilder,
    required this.fragmentProgramAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _fragmentProgramState == _FragmentProgramState.initialized
      ? builder(context, _fragmentProgram)
      : FutureBuilder<void>(
          future: _initFragmentProgram(fragmentProgramAsset),
          builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
              ? builder(context, _fragmentProgram)
              : emptyBuilder(context),
        );
}
