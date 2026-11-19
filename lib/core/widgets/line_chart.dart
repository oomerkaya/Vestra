import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Simple line chart with a soft area fill (no chart package).
///
/// [values] are drawn left to right, evenly spaced. `double` is used for
/// drawing only; amounts are computed with `Decimal` before.
class LineChart extends StatelessWidget {
  const LineChart({
    required this.values,
    required this.semanticsLabel,
    this.height = 140,
    super.key,
  });

  final List<double> values;
  final String semanticsLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: semanticsLabel,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _LinePainter(values: values, color: color),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  static const double _stroke = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = maxV - minV;
    const top = _stroke;
    final usable = size.height - 2 * _stroke;
    double y(double v) =>
        span == 0 ? size.height / 2 : top + (maxV - v) / span * usable;
    final dx = size.width / (values.length - 1);

    final line = Path()..moveTo(0, y(values.first));
    for (var i = 1; i < values.length; i++) {
      line.lineTo(i * dx, y(values[i]));
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas
      ..drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0),
            ],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.color != color || !_sameValues(old.values, values);

  static bool _sameValues(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
