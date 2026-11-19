import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Shown instead of a screen's content when its local data could not be
/// read (database error). Never shown for network problems: prices then
/// simply stay at their last known values.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: EmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.errorLoadTitle,
        message: l10n.errorLoadMessage,
      ),
    );
  }
}
