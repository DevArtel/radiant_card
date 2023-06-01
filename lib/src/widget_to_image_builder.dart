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

class _WidgetToImageBuilderState extends State<WidgetToImageBuilder> with SingleTickerProviderStateMixin<WidgetToImageBuilder> {
  final _offstageKey = GlobalKey();

  final StreamController<ui.Image> _streamController = StreamController();

  Stream<ui.Image>? _imageStream;

  late final double _pixelRatio;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _imageStream = _streamController.stream;
    _animationController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          _repaint();
        });
      });
    _animationController.repeat(period: const Duration(seconds: 1));
  }

  Future<void> _repaint() async {
    final image = await _getUiImage(
      key: _offstageKey,
      pixelRatio: _pixelRatio,
    );
    if (image != null) {
      _streamController.add(image);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
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
      if (_imageStream != null) StreamBuilder(
        stream: _imageStream,
        builder: (context, snapshot) => widget.builder(context, snapshot.data),
      ),
    ],
  );
}

Future<ui.Image?> _getUiImage({
  required GlobalKey<State> key,
  required double pixelRatio,
}) async {
  if (key.currentContext == null) {
    return null;
  }
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return boundary.toImage(pixelRatio: pixelRatio);
}
