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
    required this.maxAngle,
    Key? key,
  }) : super(key: key);

  final Widget child;

  final double maxAngle;

  @override
  State<GloriousCard> createState() => _GloriousCardState();
}

class _GloriousCardState extends State<GloriousCard> {
  Offset _localPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: _onHover,
          onExit: _onExit,
          child: Transform(
            transform: _getTransform(constraints),
            alignment: FractionalOffset.center,
            child: widget.child,
          ),
        );
      },
    );
  }

  Matrix4 _getTransform(BoxConstraints constraints) {
    if (_localPosition == Offset.zero) {
      return Matrix4.identity();
    }

    final center = Offset(
      constraints.maxWidth / 2,
      constraints.maxHeight / 2,
    );

    final angleX = (center.dy - _localPosition.dy) / center.dy * widget.maxAngle;
    final angleY = (center.dx - _localPosition.dx) / center.dx * widget.maxAngle;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(angleX)
      ..rotateY(-angleY);
  }

  void _onHover(PointerEvent event) {
    setState(() {
      _localPosition = event.localPosition;
    });
  }

  void _onExit(PointerEvent event) {
    setState(() => _localPosition = Offset.zero);
  }
}
