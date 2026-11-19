import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vestra/core/l10n/l10n.dart';
import 'package:vestra/core/widgets/messages.dart';

/// Opens an https [url] in the browser; shows a message if that fails.
/// Other schemes are refused.
Future<void> openExternalLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.l10n.linkOpenFailed;
  final uri = Uri.tryParse(url);
  var opened = false;
  if (uri != null && uri.scheme == 'https') {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
  }
  if (!opened) messenger.showMessage(failed);
}
