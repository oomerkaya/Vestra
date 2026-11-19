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
  /// **'Fiyatlar ilk güncellemeden sonra burada görünür.'**
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

  /// No description provided for @marketSectionFx.
  ///
  /// In tr, this message translates to:
  /// **'Döviz'**
  String get marketSectionFx;

  /// No description provided for @marketSectionMetals.
  ///
  /// In tr, this message translates to:
  /// **'Altın ve gümüş'**
  String get marketSectionMetals;

  /// No description provided for @marketSectionStocks.
  ///
  /// In tr, this message translates to:
  /// **'Hisseler'**
  String get marketSectionStocks;

  /// No description provided for @marketLastUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme {time}'**
  String marketLastUpdated(String time);

  /// No description provided for @marketRefreshing.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleniyor…'**
  String get marketRefreshing;

  /// No description provided for @marketSourceBurkut.
  ///
  /// In tr, this message translates to:
  /// **'Bürküt · hisseler en az 15 dk gecikmeli'**
  String get marketSourceBurkut;

  /// No description provided for @marketNeedsKeyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiyatlar için Bürküt API anahtarı gerekli'**
  String get marketNeedsKeyTitle;

  /// No description provided for @marketNeedsKeyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Döviz, altın, hisse ve fon fiyatları Bürküt\'ten gelir. burkutportfoy.com/developer adresinden ücretsiz anahtar alıp Ayarlar\'a ekle.'**
  String get marketNeedsKeyMessage;

  /// No description provided for @marketGoToSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlara git'**
  String get marketGoToSettings;

  /// No description provided for @marketQuotaExhausted.
  ///
  /// In tr, this message translates to:
  /// **'Bu ayın Bürküt istek kotası doldu. Altın ve hisse fiyatları gelecek ay güncellenecek; döviz yedek kaynaktan geliyor.'**
  String get marketQuotaExhausted;

  /// No description provided for @marketKeyRejected.
  ///
  /// In tr, this message translates to:
  /// **'Bürküt API anahtarı reddedildi. Ayarlar\'dan kontrol et.'**
  String get marketKeyRejected;

  /// No description provided for @errorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok. Son bilinen fiyatlar gösteriliyor.'**
  String get errorNetwork;

  /// No description provided for @errorRateLimit.
  ///
  /// In tr, this message translates to:
  /// **'Çok sık istek gönderildi, birazdan tekrar denenecek.'**
  String get errorRateLimit;

  /// No description provided for @errorServer.
  ///
  /// In tr, this message translates to:
  /// **'Veri sağlayıcı şu an yanıt vermiyor.'**
  String get errorServer;

  /// No description provided for @errorStorage.
  ///
  /// In tr, this message translates to:
  /// **'Veriler okunamadı.'**
  String get errorStorage;

  /// No description provided for @errorUnexpected.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen bir hata oluştu.'**
  String get errorUnexpected;

  /// No description provided for @instrumentUSD.
  ///
  /// In tr, this message translates to:
  /// **'Amerikan Doları'**
  String get instrumentUSD;

  /// No description provided for @instrumentEUR.
  ///
  /// In tr, this message translates to:
  /// **'Euro'**
  String get instrumentEUR;

  /// No description provided for @instrumentGBP.
  ///
  /// In tr, this message translates to:
  /// **'İngiliz Sterlini'**
  String get instrumentGBP;

  /// No description provided for @instrumentCHF.
  ///
  /// In tr, this message translates to:
  /// **'İsviçre Frangı'**
  String get instrumentCHF;

  /// No description provided for @instrumentJPY.
  ///
  /// In tr, this message translates to:
  /// **'Japon Yeni'**
  String get instrumentJPY;

  /// No description provided for @instrumentCAD.
  ///
  /// In tr, this message translates to:
  /// **'Kanada Doları'**
  String get instrumentCAD;

  /// No description provided for @instrumentAUD.
  ///
  /// In tr, this message translates to:
  /// **'Avustralya Doları'**
  String get instrumentAUD;

  /// No description provided for @instrumentDKK.
  ///
  /// In tr, this message translates to:
  /// **'Danimarka Kronu'**
  String get instrumentDKK;

  /// No description provided for @instrumentSEK.
  ///
  /// In tr, this message translates to:
  /// **'İsveç Kronu'**
  String get instrumentSEK;

  /// No description provided for @instrumentNOK.
  ///
  /// In tr, this message translates to:
  /// **'Norveç Kronu'**
  String get instrumentNOK;

  /// No description provided for @instrumentSAR.
  ///
  /// In tr, this message translates to:
  /// **'Suudi Arabistan Riyali'**
  String get instrumentSAR;

  /// No description provided for @instrumentGoldGram.
  ///
  /// In tr, this message translates to:
  /// **'Gram Altın'**
  String get instrumentGoldGram;

  /// No description provided for @instrumentGoldQuarter.
  ///
  /// In tr, this message translates to:
  /// **'Çeyrek Altın'**
  String get instrumentGoldQuarter;

  /// No description provided for @instrumentGoldHalf.
  ///
  /// In tr, this message translates to:
  /// **'Yarım Altın'**
  String get instrumentGoldHalf;

  /// No description provided for @instrumentGoldFull.
  ///
  /// In tr, this message translates to:
  /// **'Tam Altın'**
  String get instrumentGoldFull;

  /// No description provided for @instrumentGoldRepublic.
  ///
  /// In tr, this message translates to:
  /// **'Cumhuriyet Altını'**
  String get instrumentGoldRepublic;

  /// No description provided for @instrumentSilverGram.
  ///
  /// In tr, this message translates to:
  /// **'Gram Gümüş'**
  String get instrumentSilverGram;

  /// No description provided for @settingsSectionData.
  ///
  /// In tr, this message translates to:
  /// **'Veri kaynağı'**
  String get settingsSectionData;

  /// No description provided for @settingsApiKey.
  ///
  /// In tr, this message translates to:
  /// **'Bürküt API anahtarı'**
  String get settingsApiKey;

  /// No description provided for @settingsApiKeySet.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı · ••••{suffix}'**
  String settingsApiKeySet(String suffix);

  /// No description provided for @settingsApiKeyNotSet.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlanmadı · fiyatlar için gerekli'**
  String get settingsApiKeyNotSet;

  /// No description provided for @settingsQuota.
  ///
  /// In tr, this message translates to:
  /// **'Bu ayki istek kullanımı'**
  String get settingsQuota;

  /// No description provided for @settingsQuotaValue.
  ///
  /// In tr, this message translates to:
  /// **'{used} / {limit}'**
  String settingsQuotaValue(String used, String limit);

  /// No description provided for @settingsQuotaExhausted.
  ///
  /// In tr, this message translates to:
  /// **'Kota doldu'**
  String get settingsQuotaExhausted;

  /// No description provided for @settingsDataNote.
  ///
  /// In tr, this message translates to:
  /// **'Fiyatlar Bürküt\'ten gelir. Döviz ve altın/gümüş uygulama açıkken saatte bir, hisseler yalnızca hafta içi 10:00-18:00 arasında saatte bir, fonlar yalnızca hafta içi 10:00-18:00 arasında günde bir kez güncellenir. Hisse verileri Borsa İstanbul kuralları gereği en az 15 dakika gecikmelidir. Ekranı aşağı çekmek bu süreleri kısaltmaz. Vestra resmi bir Bürküt uygulaması değildir; Bürküt lisanslı bir veri dağıtıcısı değildir.'**
  String get settingsDataNote;

  /// No description provided for @apiKeySheetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bürküt API anahtarı'**
  String get apiKeySheetTitle;

  /// No description provided for @apiKeySheetHelp.
  ///
  /// In tr, this message translates to:
  /// **'burkutportfoy.com/developer adresinden ücretsiz hesap açıp anahtar oluşturabilirsin (ayda 1.000 istek). Anahtar yalnızca bu cihazda şifreli saklanır.'**
  String get apiKeySheetHelp;

  /// No description provided for @apiKeyFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'API anahtarı'**
  String get apiKeyFieldLabel;

  /// No description provided for @apiKeySave.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula ve kaydet'**
  String get apiKeySave;

  /// No description provided for @apiKeyDelete.
  ///
  /// In tr, this message translates to:
  /// **'Anahtarı sil'**
  String get apiKeyDelete;

  /// No description provided for @apiKeySaved.
  ///
  /// In tr, this message translates to:
  /// **'Anahtar doğrulandı ve kaydedildi'**
  String get apiKeySaved;

  /// No description provided for @apiKeyDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Anahtar silindi'**
  String get apiKeyDeleted;

  /// No description provided for @apiKeyErrorEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Anahtarı gir'**
  String get apiKeyErrorEmpty;

  /// No description provided for @apiKeyErrorMalformed.
  ///
  /// In tr, this message translates to:
  /// **'Anahtar biçimi geçersiz'**
  String get apiKeyErrorMalformed;

  /// No description provided for @apiKeyErrorRejected.
  ///
  /// In tr, this message translates to:
  /// **'Bürküt bu anahtarı kabul etmedi'**
  String get apiKeyErrorRejected;

  /// No description provided for @apiKeyErrorQuota.
  ///
  /// In tr, this message translates to:
  /// **'Bu ayın kotası dolu olduğu için anahtar doğrulanamadı'**
  String get apiKeyErrorQuota;

  /// No description provided for @apiKeyShow.
  ///
  /// In tr, this message translates to:
  /// **'Göster'**
  String get apiKeyShow;

  /// No description provided for @apiKeyHide.
  ///
  /// In tr, this message translates to:
  /// **'Gizle'**
  String get apiKeyHide;

  /// No description provided for @unitGram.
  ///
  /// In tr, this message translates to:
  /// **'gram'**
  String get unitGram;

  /// No description provided for @unitPiece.
  ///
  /// In tr, this message translates to:
  /// **'adet'**
  String get unitPiece;

  /// No description provided for @exchangeBist.
  ///
  /// In tr, this message translates to:
  /// **'Borsa İstanbul'**
  String get exchangeBist;

  /// No description provided for @instrumentGoldAta.
  ///
  /// In tr, this message translates to:
  /// **'Ata Altın'**
  String get instrumentGoldAta;

  /// No description provided for @instrumentAED.
  ///
  /// In tr, this message translates to:
  /// **'BAE Dirhemi'**
  String get instrumentAED;

  /// No description provided for @instrumentAZN.
  ///
  /// In tr, this message translates to:
  /// **'Azerbaycan Manatı'**
  String get instrumentAZN;

  /// No description provided for @instrumentCNY.
  ///
  /// In tr, this message translates to:
  /// **'Çin Yuanı'**
  String get instrumentCNY;

  /// No description provided for @instrumentKRW.
  ///
  /// In tr, this message translates to:
  /// **'Güney Kore Wonu'**
  String get instrumentKRW;

  /// No description provided for @instrumentKWD.
  ///
  /// In tr, this message translates to:
  /// **'Kuveyt Dinarı'**
  String get instrumentKWD;

  /// No description provided for @instrumentKZT.
  ///
  /// In tr, this message translates to:
  /// **'Kazakistan Tengesi'**
  String get instrumentKZT;

  /// No description provided for @instrumentPKR.
  ///
  /// In tr, this message translates to:
  /// **'Pakistan Rupisi'**
  String get instrumentPKR;

  /// No description provided for @instrumentQAR.
  ///
  /// In tr, this message translates to:
  /// **'Katar Riyali'**
  String get instrumentQAR;

  /// No description provided for @instrumentRON.
  ///
  /// In tr, this message translates to:
  /// **'Rumen Leyi'**
  String get instrumentRON;

  /// No description provided for @instrumentRUB.
  ///
  /// In tr, this message translates to:
  /// **'Rus Rublesi'**
  String get instrumentRUB;

  /// No description provided for @marketTabFx.
  ///
  /// In tr, this message translates to:
  /// **'Döviz'**
  String get marketTabFx;

  /// No description provided for @marketTabMetals.
  ///
  /// In tr, this message translates to:
  /// **'Madenler'**
  String get marketTabMetals;

  /// No description provided for @marketTabStocks.
  ///
  /// In tr, this message translates to:
  /// **'Borsa'**
  String get marketTabStocks;

  /// No description provided for @marketNextUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki güncelleme {time}'**
  String marketNextUpdate(String time);

  /// No description provided for @marketNotUpdatedYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz güncellenmedi'**
  String get marketNotUpdatedYet;

  /// No description provided for @marketUpdateRule.
  ///
  /// In tr, this message translates to:
  /// **'Saatte bir güncellenir'**
  String get marketUpdateRule;

  /// No description provided for @marketStocksRule.
  ///
  /// In tr, this message translates to:
  /// **'Hafta içi 10:00-18:00 arasında, saatte bir güncellenir'**
  String get marketStocksRule;

  /// No description provided for @marketSessionClosed.
  ///
  /// In tr, this message translates to:
  /// **'Borsa şu an kapalı'**
  String get marketSessionClosed;

  /// No description provided for @marketUpToDate.
  ///
  /// In tr, this message translates to:
  /// **'Veriler güncel · sonraki güncelleme {time}'**
  String marketUpToDate(String time);

  /// No description provided for @marketStocksEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Portföyünde hisse yok'**
  String get marketStocksEmptyTitle;

  /// No description provided for @marketStocksEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Portföye hisse eklediğinde fiyatları burada görünür.'**
  String get marketStocksEmptyMessage;

  /// No description provided for @marketExchangeBist.
  ///
  /// In tr, this message translates to:
  /// **'BIST'**
  String get marketExchangeBist;

  /// No description provided for @portfolioAddAsset.
  ///
  /// In tr, this message translates to:
  /// **'Varlık ekle'**
  String get portfolioAddAsset;

  /// No description provided for @portfolioPnl.
  ///
  /// In tr, this message translates to:
  /// **'Kâr/zarar'**
  String get portfolioPnl;

  /// No description provided for @portfolioToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get portfolioToday;

  /// No description provided for @portfolioAllocation.
  ///
  /// In tr, this message translates to:
  /// **'Dağılım'**
  String get portfolioAllocation;

  /// No description provided for @portfolioNoPrice.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat yok'**
  String get portfolioNoPrice;

  /// No description provided for @portfolioCostUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Maliyet bilinmiyor'**
  String get portfolioCostUnknown;

  /// No description provided for @categoryFx.
  ///
  /// In tr, this message translates to:
  /// **'Döviz'**
  String get categoryFx;

  /// No description provided for @categoryMetals.
  ///
  /// In tr, this message translates to:
  /// **'Altın ve gümüş'**
  String get categoryMetals;

  /// No description provided for @categoryStocks.
  ///
  /// In tr, this message translates to:
  /// **'Borsa'**
  String get categoryStocks;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @txTitleAdd.
  ///
  /// In tr, this message translates to:
  /// **'Varlık ekle'**
  String get txTitleAdd;

  /// No description provided for @txTitleEdit.
  ///
  /// In tr, this message translates to:
  /// **'İşlemi düzenle'**
  String get txTitleEdit;

  /// No description provided for @txTitleBuy.
  ///
  /// In tr, this message translates to:
  /// **'Alım ekle'**
  String get txTitleBuy;

  /// No description provided for @txTitleSell.
  ///
  /// In tr, this message translates to:
  /// **'Satış ekle'**
  String get txTitleSell;

  /// No description provided for @txType.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get txType;

  /// No description provided for @txInstrument.
  ///
  /// In tr, this message translates to:
  /// **'Varlık'**
  String get txInstrument;

  /// No description provided for @txSelectInstrument.
  ///
  /// In tr, this message translates to:
  /// **'Varlık seç'**
  String get txSelectInstrument;

  /// No description provided for @txKindBuy.
  ///
  /// In tr, this message translates to:
  /// **'Alım'**
  String get txKindBuy;

  /// No description provided for @txKindSell.
  ///
  /// In tr, this message translates to:
  /// **'Satış'**
  String get txKindSell;

  /// No description provided for @txQuantity.
  ///
  /// In tr, this message translates to:
  /// **'Miktar'**
  String get txQuantity;

  /// No description provided for @txUnitPrice.
  ///
  /// In tr, this message translates to:
  /// **'Birim fiyat (TL)'**
  String get txUnitPrice;

  /// No description provided for @txUnitPriceHelp.
  ///
  /// In tr, this message translates to:
  /// **'Bilmiyorsan boş bırakabilirsin'**
  String get txUnitPriceHelp;

  /// No description provided for @txPriceFilled.
  ///
  /// In tr, this message translates to:
  /// **'Güncel fiyatla dolduruldu'**
  String get txPriceFilled;

  /// No description provided for @txDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get txDate;

  /// No description provided for @txNote.
  ///
  /// In tr, this message translates to:
  /// **'Not (isteğe bağlı)'**
  String get txNote;

  /// No description provided for @txDelete.
  ///
  /// In tr, this message translates to:
  /// **'İşlemi sil'**
  String get txDelete;

  /// No description provided for @txDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'İşlem silinsin mi?'**
  String get txDeleteConfirmTitle;

  /// No description provided for @txDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem kalıcı olarak silinir.'**
  String get txDeleteConfirmMessage;

  /// No description provided for @txErrorQuantity.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir miktar gir'**
  String get txErrorQuantity;

  /// No description provided for @txErrorPriceFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir fiyat gir'**
  String get txErrorPriceFormat;

  /// No description provided for @txErrorPrice.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat negatif olamaz'**
  String get txErrorPrice;

  /// No description provided for @txErrorOversell.
  ///
  /// In tr, this message translates to:
  /// **'Bu tarihte elindeki miktardan fazla satamazsın; önceki bir alım silinirse ya da azalırsa da olmaz'**
  String get txErrorOversell;

  /// No description provided for @txErrorInstrument.
  ///
  /// In tr, this message translates to:
  /// **'Bir varlık seç'**
  String get txErrorInstrument;

  /// No description provided for @txSaved.
  ///
  /// In tr, this message translates to:
  /// **'İşlem kaydedildi'**
  String get txSaved;

  /// No description provided for @txDeleted.
  ///
  /// In tr, this message translates to:
  /// **'İşlem silindi'**
  String get txDeleted;

  /// No description provided for @pickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Varlık seç'**
  String get pickerTitle;

  /// No description provided for @pickerSearchStocks.
  ///
  /// In tr, this message translates to:
  /// **'Hisse ara (ör. THYAO)'**
  String get pickerSearchStocks;

  /// No description provided for @pickerStockListUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Hisse listesi için Bürküt API anahtarı gerekli. Sembolü elle yazabilirsin.'**
  String get pickerStockListUnavailable;

  /// No description provided for @pickerNoResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç yok'**
  String get pickerNoResults;

  /// No description provided for @assetDetailTransactions.
  ///
  /// In tr, this message translates to:
  /// **'İşlemler'**
  String get assetDetailTransactions;

  /// No description provided for @assetDetailQuantity.
  ///
  /// In tr, this message translates to:
  /// **'Miktar'**
  String get assetDetailQuantity;

  /// No description provided for @assetDetailAvgCost.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama maliyet'**
  String get assetDetailAvgCost;

  /// No description provided for @assetDetailValue.
  ///
  /// In tr, this message translates to:
  /// **'Güncel değer'**
  String get assetDetailValue;

  /// No description provided for @assetDetailRealized.
  ///
  /// In tr, this message translates to:
  /// **'Gerçekleşen kâr/zarar'**
  String get assetDetailRealized;

  /// No description provided for @assetDetailBuy.
  ///
  /// In tr, this message translates to:
  /// **'Alım ekle'**
  String get assetDetailBuy;

  /// No description provided for @assetDetailSell.
  ///
  /// In tr, this message translates to:
  /// **'Satış ekle'**
  String get assetDetailSell;

  /// No description provided for @assetDelete.
  ///
  /// In tr, this message translates to:
  /// **'Varlığı sil'**
  String get assetDelete;

  /// No description provided for @assetDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Varlık silinsin mi?'**
  String get assetDeleteConfirmTitle;

  /// No description provided for @assetDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Varlık silindi'**
  String get assetDeleted;

  /// No description provided for @assetNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Varlık bulunamadı'**
  String get assetNotFound;

  /// No description provided for @portfolioMissingPrices.
  ///
  /// In tr, this message translates to:
  /// **'{count} varlığın güncel fiyatı yok; toplama dahil edilmedi.'**
  String portfolioMissingPrices(String count);

  /// No description provided for @holdingQuantityAvg.
  ///
  /// In tr, this message translates to:
  /// **'{quantity} · ort. {cost}'**
  String holdingQuantityAvg(String quantity, String cost);

  /// No description provided for @pickerUseSymbol.
  ///
  /// In tr, this message translates to:
  /// **'\"{symbol}\" sembolünü kullan'**
  String pickerUseSymbol(String symbol);

  /// No description provided for @assetDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'{name} ve tüm işlemleri kalıcı olarak silinir.'**
  String assetDeleteConfirmMessage(String name);

  /// No description provided for @txLine.
  ///
  /// In tr, this message translates to:
  /// **'{quantity} × {price}'**
  String txLine(String quantity, String price);

  /// No description provided for @marketSectionMine.
  ///
  /// In tr, this message translates to:
  /// **'Portföyümde'**
  String get marketSectionMine;

  /// No description provided for @marketSectionAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get marketSectionAll;

  /// No description provided for @marketNoHoldingsInCategory.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride portföyünde varlık yok.'**
  String get marketNoHoldingsInCategory;

  /// No description provided for @marketCount.
  ///
  /// In tr, this message translates to:
  /// **'{count}'**
  String marketCount(String count);

  /// No description provided for @marketSearchStocks.
  ///
  /// In tr, this message translates to:
  /// **'Hisse ara (sembol veya ad)'**
  String get marketSearchStocks;

  /// No description provided for @marketShowMore.
  ///
  /// In tr, this message translates to:
  /// **'{count} hisse daha göster'**
  String marketShowMore(String count);

  /// No description provided for @marketStocksNotLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Hisse fiyatları ilk güncellemeyle gelir.'**
  String get marketStocksNotLoaded;

  /// No description provided for @marketTabFunds.
  ///
  /// In tr, this message translates to:
  /// **'Fonlar'**
  String get marketTabFunds;

  /// No description provided for @categoryFunds.
  ///
  /// In tr, this message translates to:
  /// **'Fonlar'**
  String get categoryFunds;

  /// No description provided for @unitShare.
  ///
  /// In tr, this message translates to:
  /// **'pay'**
  String get unitShare;

  /// No description provided for @marketFundsRule.
  ///
  /// In tr, this message translates to:
  /// **'Hafta içi 10:00-18:00 arasında, günde bir kez güncellenir (TEFAS fiyatları günlük açıklanır)'**
  String get marketFundsRule;

  /// No description provided for @marketSearchFunds.
  ///
  /// In tr, this message translates to:
  /// **'Fon ara (kod veya ad)'**
  String get marketSearchFunds;

  /// No description provided for @marketFundsNotLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Fon listesi ilk güncellemeyle gelir.'**
  String get marketFundsNotLoaded;

  /// No description provided for @kapSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son KAP bildirimleri'**
  String get kapSectionTitle;

  /// No description provided for @kapAssetSectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'KAP bildirimleri'**
  String get kapAssetSectionTitle;

  /// No description provided for @kapNoneRecent.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 günde bildirim yok.'**
  String get kapNoneRecent;

  /// No description provided for @kapNone.
  ///
  /// In tr, this message translates to:
  /// **'Bu hisse için yakın tarihli bildirim yok.'**
  String get kapNone;

  /// No description provided for @kapNotLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler henüz yüklenmedi. Günde bir kez otomatik güncellenir.'**
  String get kapNotLoaded;

  /// No description provided for @kapLoading.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler yükleniyor…'**
  String get kapLoading;

  /// No description provided for @kapPortfolioFooter.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak: KAP, Bürküt üzerinden. Portföydeki değeri en yüksek 5 hisse için günde bir kez güncellenir; diğer hisselerin bildirimleri detay ekranında.'**
  String get kapPortfolioFooter;

  /// No description provided for @kapAssetFooter.
  ///
  /// In tr, this message translates to:
  /// **'Kaynak: KAP, Bürküt üzerinden. Günde bir kez güncellenir.'**
  String get kapAssetFooter;

  /// No description provided for @kapOpenOnKap.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimi KAP\'ta aç'**
  String get kapOpenOnKap;

  /// No description provided for @linkOpenFailed.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı açılamadı.'**
  String get linkOpenFailed;

  /// No description provided for @kapShowAll.
  ///
  /// In tr, this message translates to:
  /// **'{count} bildirimin tümünü göster'**
  String kapShowAll(String count);

  /// No description provided for @kapShowLess.
  ///
  /// In tr, this message translates to:
  /// **'Daha az göster'**
  String get kapShowLess;
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
