import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/external_link.dart';
import 'package:vestra/features/market/domain/entities/kap_disclosure.dart';

/// One KAP disclosure: symbol · date, subject and type. Tapping opens the
/// original on kap.org.tr in the browser.
class KapDisclosureTile extends StatelessWidget {
  const KapDisclosureTile({
    required this.disclosure,
    this.showSymbol = true,
    super.key,
  });

  final KapDisclosure disclosure;

  /// Off on a stock's own detail screen.
  final bool showSymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final d = disclosure;
    final url = d.url;
    final date = DateFormatters.date(d.publishedAt);

    return Semantics(
      button: url != null,
      hint: url == null ? null : l10n.kapOpenOnKap,
      child: InkWell(
        onTap: url == null
            ? null
            : () => unawaited(openExternalLink(context, url)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showSymbol ? '${d.symbol} · $date' : date,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      d.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (d.summary != null)
                      Text(
                        d.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (url != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.open_in_new_rounded,
                  size: AppSpacing.lg + AppSpacing.xxs,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small source note under a list of disclosures.
class KapFooter extends StatelessWidget {
  const KapFooter(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.md,
    ),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

/// Placeholder line inside a disclosure section.
class KapMessage extends StatelessWidget {
  const KapMessage(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      0,
    ),
    child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
  );
}
