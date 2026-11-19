import 'package:capira/core/l10n/l10n.dart';
import 'package:capira/core/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
