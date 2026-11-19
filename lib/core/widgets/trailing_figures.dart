import 'package:flutter/material.dart';

/// Right-hand figures of a list row (amount above a change chip).
///
/// Takes at most [maxScreenShare] of the screen width and scales down
/// instead of overflowing when a large system font size makes the figures
/// wider than that; the name on the left keeps its room.
class TrailingFigures extends StatelessWidget {
  const TrailingFigures({
    required this.children,
    this.maxScreenShare = 0.36,
    super.key,
  });

  final List<Widget> children;
  final double maxScreenShare;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width * maxScreenShare,
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      ),
    ),
  );
}
