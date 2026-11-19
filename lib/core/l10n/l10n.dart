import 'package:capira/core/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:capira/core/l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
