import 'package:flutter/material.dart';

// Draw a card
// 3D transform
// Display shadow
// Display phong shading
// Interference / Di
// Textures

class GloriousCard extends StatefulWidget {
  const GloriousCard({
    required this.child,
    required this.aspectRatio,
    required this.cornerRadius,
    required this.maxAngleX,
    required this.maxAngleY,
    required this.elevation,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final double aspectRatio;
  final double cornerRadius;
  final double maxAngleX;
  final double maxAngleY;
  final double elevation;

  @override
  State<GloriousCard> createState() => _GloriousCardState();
}

class _GloriousCardState extends State<GloriousCard> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(0.01 * _offset.dy)
        ..rotateY(-0.01 * _offset.dx),
      alignment: FractionalOffset.center,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _offset += details.delta),
        onDoubleTap: () => setState(() => _offset = Offset.zero),
        child: widget.child,
      ),
    );
  }
}
