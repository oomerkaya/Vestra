import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_colors.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/settings/presentation/widgets/api_key_sheet.dart';

/// API key status, monthly quota usage and data-source notes.
class DataSourceSection extends ConsumerWidget {
  const DataSourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final key = ref.watch(burkutKeyProvider).value;
    final quota = ref.watch(quotaUsageProvider).value;
    final hasKey = key != null && key.isNotEmpty;
    final suffix = hasKey && key.length > 4
        ? key.substring(key.length - 4)
        : '';

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              hasKey ? Icons.key_rounded : Icons.key_off_outlined,
              color: hasKey ? theme.colorScheme.primary : null,
            ),
            title: Text(l10n.settingsApiKey),
            subtitle: Text(
              hasKey
                  ? l10n.settingsApiKeySet(suffix)
                  : l10n.settingsApiKeyNotSet,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => unawaited(ApiKeySheet.show(context, hasKey: hasKey)),
          ),
          if (quota != null) ...[
            const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.settingsQuota,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        quota.isExhausted
                            ? l10n.settingsQuotaExhausted
                            : l10n.settingsQuotaValue(
                                Formatters.number(Decimal.fromInt(quota.used)),
                                Formatters.number(Decimal.fromInt(quota.limit)),
                              ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: quota.isExhausted
                              ? context.vestraColors.loss
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.pillAll,
                    child: LinearProgressIndicator(
                      value: quota.isExhausted
                          ? 1
                          : (quota.used / quota.limit).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: context.vestraColors.surfaceMuted,
                      color: quota.isExhausted
                          ? context.vestraColors.loss
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              l10n.settingsDataNote,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
