import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vestra/core/error/failure.dart';
import 'package:vestra/core/error/result.dart';
import 'package:vestra/core/l10n/failure_messages.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/features/market/market_providers.dart';
import 'package:vestra/features/market/presentation/price_refresh_controller.dart';
import 'package:vestra/features/settings/domain/usecases/save_burkut_key.dart';
import 'package:vestra/features/settings/settings_providers.dart';

/// Bottom sheet to enter, verify, save or delete the Bürküt API key.
class ApiKeySheet extends ConsumerStatefulWidget {
  const ApiKeySheet({required this.hasKey, super.key});

  final bool hasKey;

  static Future<void> show(BuildContext context, {required bool hasKey}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ApiKeySheet(hasKey: hasKey),
      );

  @override
  ConsumerState<ApiKeySheet> createState() => _ApiKeySheetState();
}

class _ApiKeySheetState extends ConsumerState<ApiKeySheet> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(saveBurkutKeyProvider)(_controller.text);
    if (!mounted) return;
    switch (result) {
      case Success():
        ref
          ..invalidate(burkutKeyProvider)
          ..invalidate(quotaUsageProvider);
        unawaited(
          ref
              .read(priceRefreshControllerProvider.notifier)
              .refresh(manual: true),
        );
        navigator.pop();
        messenger.showSnackBar(SnackBar(content: Text(l10n.apiKeySaved)));
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = _message(l10n, failure);
        });
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(apiKeyRepositoryProvider).deleteBurkutKey();
    ref.invalidate(burkutKeyProvider);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.apiKeyDeleted)));
  }

  static String _message(AppLocalizations l10n, Failure failure) =>
      switch (failure) {
        ApiKeyFormatFailure(reason: ApiKeyValidationReason.empty) =>
          l10n.apiKeyErrorEmpty,
        ApiKeyFormatFailure() => l10n.apiKeyErrorMalformed,
        AuthFailure() => l10n.apiKeyErrorRejected,
        QuotaExceededFailure() => l10n.apiKeyErrorQuota,
        _ => failureMessage(l10n, failure),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.apiKeySheetTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.apiKeySheetHelp,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            enabled: !_busy,
            onSubmitted: (_) => unawaited(_save()),
            decoration: InputDecoration(
              labelText: l10n.apiKeyFieldLabel,
              hintText: 'bk_live_…',
              errorText: _error,
              errorMaxLines: 3,
              suffixIcon: IconButton(
                tooltip: _obscure ? l10n.apiKeyShow : l10n.apiKeyHide,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _busy ? null : () => unawaited(_save()),
            child: _busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.apiKeySave),
          ),
          if (widget.hasKey) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: _busy ? null : () => unawaited(_delete()),
              child: Text(l10n.apiKeyDelete),
            ),
          ],
        ],
      ),
    );
  }
}
