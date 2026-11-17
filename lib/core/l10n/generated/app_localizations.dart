import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vestra'**
  String get appTitle;

  /// No description provided for @navPortfolio.
  ///
  /// In tr, this message translates to:
  /// **'Portföy'**
  String get navPortfolio;

  /// No description provided for @navMarket.
  ///
  /// In tr, this message translates to:
  /// **'Piyasa'**
  String get navMarket;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @portfolioEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Portföyün boş'**
  String get portfolioEmptyTitle;

  /// No description provided for @portfolioEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Döviz, altın, gümüş veya hisse ekleyerek portföyünü oluşturmaya başla.'**
  String get portfolioEmptyMessage;

  /// No description provided for @marketEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz fiyat yok'**
  String get marketEmptyTitle;

  /// No description provided for @marketEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Portföyüne varlık eklediğinde güncel kurlar ve fiyatlar burada görünür.'**
  String get marketEmptyMessage;

  /// No description provided for @settingsTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Aydınlık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık'**
  String get themeDark;

  /// No description provided for @settingsDisclaimerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yasal uyarı'**
  String get settingsDisclaimerTitle;

  /// No description provided for @settingsDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'Vestra yatırım tavsiyesi vermez. Gösterilen fiyatlar gecikmeli olabilir ve yalnızca bilgi amaçlıdır.'**
  String get settingsDisclaimer;

  /// No description provided for @portfolioTotalValue.
  ///
  /// In tr, this message translates to:
  /// **'Toplam değer'**
  String get portfolioTotalValue;

  /// No description provided for @portfolioHoldings.
  ///
  /// In tr, this message translates to:
  /// **'Varlıklar'**
  String get portfolioHoldings;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsSectionAbout;

  /// No description provided for @settingsLicenses.
  ///
  /// In tr, this message translates to:
  /// **'Açık kaynak lisansları'**
  String get settingsLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
