import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class WidgetToImageBuilder extends StatelessWidget {
  final _offstageKey = GlobalKey();

  final Widget widget;
  final Function(BuildContext, ui.Image) builder;
  final Function(BuildContext) emptyBuilder;

  WidgetToImageBuilder({
    super.key,
    required this.widget,
    required this.builder,
    required this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          key: _offstageKey,
          child: Container(color: Colors.blue),
        ),
        // Container(color: Colors.green),
        Builder(
          builder: (context) {
            return FutureBuilder(
              future: _getUiImage(
                key: _offstageKey,
                pixelRatio: MediaQuery.of(context).devicePixelRatio,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return RawImage(image: snapshot.data);
                } else {
                  return emptyBuilder(context);
                }
              },
            );
          }
        ),
      ],
    );
  }
}

Future<ui.Image> _getUiImage({
  required GlobalKey<State> key,
  required double pixelRatio,
}) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return boundary.toImage(pixelRatio: pixelRatio);
}

class _StatefulProxy extends StatefulWidget {
  final Widget child;

  const _StatefulProxy({super.key, required this.child,});

  @override
  State<_StatefulProxy> createState() => _StatefulProxyState();
}

class _StatefulProxyState extends State<_StatefulProxy> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}