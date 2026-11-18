import 'package:flutter/material.dart';
import 'package:vestra/core/l10n/l10n.dart';

/// "Are you sure?" dialog for destructive actions. Returns `true` only if
/// the user confirmed.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.commonDelete),
        ),
      ],
    ),
  );
  return result ?? false;
}
