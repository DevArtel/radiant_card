// Draw a card
// 3D transform
// Display shadow
// Display phong shading
// Interference / Di
// Textures

import 'package:flutter/material.dart';

class GloriousCard extends StatelessWidget {
  const GloriousCard({
    Key? key,
    required this.child,
    required this.aspectRatio,
    required this.cornerRadius,
    required this.maxAngleX,
    required this.maxAngleY,
    required this.elevation,
  }) : super(key: key);

  final Widget child;
  final double aspectRatio;
  final double cornerRadius;
  final double maxAngleX;
  final double maxAngleY;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(0.5)
        ..rotateX(0.5),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            // shape:
            borderRadius: BorderRadius.circular(cornerRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(1, 1),
                spreadRadius: 3,
              )
            ]),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
            const BugiWugi(),
          ],
        ),
      ),
    );
  }
}

class BugiWugi extends StatelessWidget {
  const BugiWugi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
