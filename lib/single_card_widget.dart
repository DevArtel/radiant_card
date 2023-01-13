
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';

import 'glossy_card.dart';

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
