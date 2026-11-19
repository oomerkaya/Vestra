import 'package:capira/core/theme/app_tokens.dart';
import 'package:capira/core/utils/formatters.dart';
import 'package:capira/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Card with a tappable header that expands/collapses its [child].
///
/// The open/closed state survives tab switches via [PageStorage] when a
/// [storageKey] is given.
class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({
    required this.title,
    required this.child,
    this.trailing,
    this.initiallyExpanded = true,
    this.storageKey,
    super.key,
  });

  final String title;

  /// Shown next to the chevron, e.g. an item count.
  final String? trailing;
  final Widget child;
  final bool initiallyExpanded;
  final String? storageKey;

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    final key = widget.storageKey;
    final stored = key == null
        ? null
        : PageStorage.maybeOf(context)?.readState(context, identifier: key);
    _expanded = stored is bool ? stored : widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    final key = widget.storageKey;
    if (key != null) {
      PageStorage.maybeOf(
        context,
      )?.writeState(context, _expanded, identifier: key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md + AppSpacing.xxs,
                  AppSpacing.md,
                  AppSpacing.md + AppSpacing.xxs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        turkishUpperCase(widget.title),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    if (widget.trailing != null)
                      Text(
                        widget.trailing!,
                        style: theme.textTheme.labelMedium,
                      ),
                    const SizedBox(width: AppSpacing.xs),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: AppDurations.normal,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(),
                      widget.child,
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
