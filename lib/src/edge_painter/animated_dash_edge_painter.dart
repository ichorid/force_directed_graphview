import 'dart:math';

import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// A painter for drawing a moving dash line between nodes.
@immutable
final class AnimatedDashEdgePainter<N extends NodeBase, E extends EdgeBase<N>>
    implements AnimatedEdgePainter<N, E> {
  /// {@nodoc}
  const AnimatedDashEdgePainter({
    required this.animation,
    this.thickness = 1.0,
    this.color = Colors.black,
    this.dashLength = 10.0,
    this.dashSpacing = 10.0,
  });

  /// {@nodoc}
  final double thickness;

  /// {@nodoc}
  final double dashLength;

  /// {@nodoc}
  final double dashSpacing;

  /// {@nodoc}
  final Color color;

  @override
  final Animation<double> animation;

  @override
  void paint(
    Canvas canvas,
    E edge,
    Offset sourcePosition,
    Offset destinationPosition,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final delta = destinationPosition - sourcePosition;
    final distance = delta.distance;
    final direction = delta.direction;

    final numberOfDashes = (distance / (dashLength + dashSpacing)).floor();

    final dashDelta = Offset.fromDirection(direction, dashLength);
    final spacingDelta = Offset.fromDirection(direction, dashSpacing);
    final stepDelta = dashDelta + spacingDelta;

    final path = Path()
      ..moveTo(sourcePosition.dx, sourcePosition.dy)
      ..relativeMoveTo(
        stepDelta.dx * animation.value,
        stepDelta.dy * animation.value,
      );

    for (var i = 0; i < numberOfDashes; i++) {
      path
        ..relativeLineTo(dashDelta.dx, dashDelta.dy)
        ..relativeMoveTo(spacingDelta.dx, spacingDelta.dy);
    }

    canvas.drawPath(path, paint);
  }
}

@immutable
class AnimatedHighlightedEdgePainter<N extends NodeBase, E extends EdgeBase<N>>
    implements AnimatedEdgePainter<N, E> {
  const AnimatedHighlightedEdgePainter({
    required this.animation,
    this.thickness = 4.0,
    this.color = Colors.grey,
    this.highlightColor = Colors.black,
    this.highlightWidthFactor = 0.1,
  });

  final double thickness;
  final Color color;
  final Color highlightColor;
  final double highlightWidthFactor;
  final Animation<double> animation;

  @override
  void paint(
    Canvas canvas,
    E edge,
    Offset sourcePosition,
    Offset destinationPosition,
  ) {
    final paint = Paint()
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..shader = _createGradientShader(sourcePosition, destinationPosition);

    canvas.drawLine(sourcePosition, destinationPosition, paint);
  }

  Shader _createGradientShader(
      Offset sourcePosition, Offset destinationPosition) {
    final hr = highlightWidthFactor / 2; // Highlight radius
    final highlightCenter = animation.value * (1.0 + hr * 2) - hr;
    final highlightStart = highlightCenter - hr;
    final highlightEnd = highlightCenter + hr;

    final direction = destinationPosition - sourcePosition;
    final biggerDimLength = max(direction.dx.abs(), direction.dy.abs());
    final normalizedDirection =
        Offset(direction.dx / biggerDimLength, direction.dy / biggerDimLength);

    // Convert to Alignment, considering that Alignment(0,0) is the center of the canvas
    final start = Alignment(-normalizedDirection.dx, -normalizedDirection.dy);
    final end = Alignment(normalizedDirection.dx, normalizedDirection.dy);

    return LinearGradient(
      begin: start,
      end: end,
      colors: [color, highlightColor, color],
      stops: [
        highlightStart.clamp(0.0, 1.0),
        highlightCenter.clamp(0.0, 1.0),
        highlightEnd.clamp(0.0, 1.0)
      ],
    ).createShader(Rect.fromPoints(sourcePosition, destinationPosition));
  }
}
