import 'package:capira/core/error/failure.dart';
import 'package:capira/core/l10n/generated/app_localizations.dart';

/// User-facing Turkish text for a [Failure]. Feature-specific failures
/// (validation reasons) are mapped where they are handled.
String failureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      NetworkFailure() => l10n.errorNetwork,
      RateLimitFailure() => l10n.errorRateLimit,
      QuotaExceededFailure() => l10n.marketQuotaExhausted,
      AuthFailure(missingKey: true) => l10n.marketNeedsKeyTitle,
      AuthFailure() => l10n.marketKeyRejected,
      ServerFailure() => l10n.errorServer,
      StorageFailure() => l10n.errorStorage,
      ValidationFailure() || UnexpectedFailure() => l10n.errorUnexpected,
    };
