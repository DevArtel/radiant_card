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

class _GloriousCardState extends State<GloriousCard> with SingleTickerProviderStateMixin {
  /// Pointer position of Offset(0, 0) is the center of the card
  final _pointerPositionNotifier = ValueNotifier(Offset.zero);
  var _desiredPointerPosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    createTicker((elapsed) {
      final difference = _pointerPositionNotifier.value - _desiredPointerPosition;

      if (difference.distance < 1.0) {
        return;
      }

      _pointerPositionNotifier.value = Offset.lerp(_pointerPositionNotifier.value, _desiredPointerPosition, 0.05)!;
    }).start();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) => _desiredPointerPosition =
              event.localPosition.translate(-constraints.maxWidth / 2, -constraints.maxHeight / 2),
          onExit: (_) => _desiredPointerPosition = Offset.zero,
          child: AnimatedBuilder(
            animation: _pointerPositionNotifier,
            child: widget.child,
            builder: (context, child) => Transform(
              transform: _getTransform(constraints, _pointerPositionNotifier.value),
              alignment: FractionalOffset.center,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Matrix4 _getTransform(BoxConstraints constraints, Offset pointerPosition) {
    final angleX = pointerPosition.dy / (constraints.maxHeight / 2) * widget.maxAngle;
    final angleY = pointerPosition.dx / (constraints.maxWidth / 2) * widget.maxAngle;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(-angleX)
      ..rotateY(angleY);
  }
}
