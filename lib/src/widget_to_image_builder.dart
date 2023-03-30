import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class WidgetToImageBuilder extends StatefulWidget {
  final Widget child;
  final Function(BuildContext, ui.Image?) builder;

  const WidgetToImageBuilder({
    super.key,
    required this.child,
    required this.builder,
  });

  @override
  State<WidgetToImageBuilder> createState() => _WidgetToImageBuilderState();
}

class _WidgetToImageBuilderState extends State<WidgetToImageBuilder> {
  final _offstageKey = GlobalKey();
  final _completer = Completer<ui.Image>();

  late final double _pixelRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    doAsync();
  }

  Future<void> doAsync() async {
    await Future.delayed(const Duration(seconds: 1));
    final image = await _getUiImage(
      key: _offstageKey,
      pixelRatio: _pixelRatio,
    );
    _completer.complete(image);
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      Transform.translate(
        offset: const Offset(1000000, 0), // TODO must be far enough to ensure the widget is off the screen
        child: IgnorePointer(
          child: RepaintBoundary(
            key: _offstageKey,
            child: widget.child,
          ),
        ),
      ),
      FutureBuilder(
        future: _completer.future,
        builder: (context, snapshot) => widget.builder(context, snapshot.data),
      ),
    ],
  );
}

Future<ui.Image> _getUiImage({
  required GlobalKey<State> key,
  required double pixelRatio,
}) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return boundary.toImage(pixelRatio: pixelRatio);
}
