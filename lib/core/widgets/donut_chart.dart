import 'dart:math' as math;

import 'package:flutter/material.dart';

class DonutSegment {
  const DonutSegment({required this.fraction, required this.color});

  /// Share of the whole, 0..1. Segments should add up to 1.
  final double fraction;
  final Color color;
}

/// Ring chart drawn with a [CustomPainter] (no chart package).
///
/// Uses `double` only for drawing geometry; amounts are computed with
/// `Decimal` before being turned into fractions.
class DonutChart extends StatelessWidget {
  const DonutChart({
    required this.segments,
    this.size = 140,
    this.thickness = 18,
    this.center,
    this.semanticsLabel,
    super.key,
  });

  final List<DonutSegment> segments;
  final double size;
  final double thickness;
  final Widget? center;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      label: semanticsLabel,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _DonutPainter(
            segments: segments,
            thickness: thickness,
            trackColor: track,
          ),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.thickness,
    required this.trackColor,
  });

  final List<DonutSegment> segments;
  final double thickness;
  final Color trackColor;

  /// Gap between segments, in radians.
  static const double _gap = 0.04;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(thickness / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(arcRect, 0, 2 * math.pi, false, paint..color = trackColor);

    final visible = segments.where((s) => s.fraction > 0).toList();
    if (visible.isEmpty) return;
    final gap = visible.length > 1 ? _gap : 0.0;
    var start = -math.pi / 2;
    for (final s in visible) {
      final sweep = s.fraction * 2 * math.pi;
      final drawn = math.max<double>(0, sweep - gap);
      canvas.drawArc(
        arcRect,
        start + gap / 2,
        drawn,
        false,
        paint..color = s.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.segments != segments ||
      old.thickness != thickness ||
      old.trackColor != trackColor;
}
