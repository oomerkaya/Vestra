import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/utils/formatters.dart';
import 'package:vestra/core/widgets/app_card.dart';
import 'package:vestra/core/widgets/confirm_dialog.dart';
import 'package:vestra/core/widgets/messages.dart';
import 'package:vestra/features/portfolio/domain/entities/portfolio_backup.dart';
import 'package:vestra/features/portfolio/portfolio_providers.dart';
import 'package:vestra/features/portfolio/presentation/backup_files.dart';

/// Settings: export the portfolio to a file and restore it from one.
class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(l10n.backupExport),
            subtitle: Text(l10n.backupExportHint),
            onTap: () => unawaited(_export(context, ref)),
          ),
          const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: Text(l10n.backupImport),
            subtitle: Text(l10n.backupImportHint),
            onTap: () => unawaited(_import(context, ref)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(l10n.backupNote, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final holdings = ref.read(holdingsProvider).value ?? const [];
    if (holdings.isEmpty) {
      messenger.showMessage(l10n.backupEmpty);
      return;
    }
    final result = await ref.read(exportPortfolioProvider)();
    switch (result) {
      case Err():
        messenger.showMessage(l10n.backupExportFailed);
      case Success(value: final content):
        final today = DateTime.now();
        final stamp = '${today.year}-${_two(today.month)}-${_two(today.day)}';
        try {
          await ref
              .read(backupFilesProvider)
              .share(
                fileName: 'vestra-yedek-$stamp.json',
                content: content,
                subject: l10n.backupShareSubject,
              );
        } on Object {
          messenger.showMessage(l10n.backupExportFailed);
        }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final String? content;
    try {
      content = await ref.read(backupFilesProvider).pick();
    } on Object {
      messenger.showMessage(l10n.backupErrorNotABackup);
      return;
    }
    if (content == null || !context.mounted) return;

    final backup = switch (ref.read(readBackupProvider)(content)) {
      Success(:final value) => value,
      Err(:final failure) => () {
        messenger.showMessage(_problemMessage(l10n, failure));
        return null;
      }(),
    };
    if (backup == null) return;

    final confirmed = await confirmDestructive(
      context,
      title: l10n.backupRestoreConfirmTitle,
      message: l10n.backupRestoreConfirmMessage(
        DateFormatters.date(backup.exportedAt),
        '${backup.assets.length}',
        '${backup.transactionCount}',
      ),
      confirmLabel: l10n.backupRestoreAction,
    );
    if (!confirmed) return;

    final restored = await ref.read(restoreBackupProvider)(backup);
    messenger.showMessage(
      restored is Success ? l10n.backupRestored : l10n.backupRestoreFailed,
    );
  }

  static String _problemMessage(AppLocalizations l10n, Object failure) =>
      switch (failure) {
        BackupFailure(problem: BackupProblem.notABackup) =>
          l10n.backupErrorNotABackup,
        BackupFailure(problem: BackupProblem.newerFormat) =>
          l10n.backupErrorNewer,
        _ => l10n.backupErrorInvalid,
      };

  static String _two(int v) => v.toString().padLeft(2, '0');
}
