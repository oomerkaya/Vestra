// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Vestra';

  @override
  String get navPortfolio => 'Portföy';

  @override
  String get navMarket => 'Piyasa';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get portfolioEmptyTitle => 'Portföyün boş';

  @override
  String get portfolioEmptyMessage =>
      'Döviz, altın, gümüş veya hisse ekleyerek portföyünü oluşturmaya başla.';

  @override
  String get marketEmptyTitle => 'Henüz fiyat yok';

  @override
  String get marketEmptyMessage =>
      'Portföyüne varlık eklediğinde güncel kurlar ve fiyatlar burada görünür.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Aydınlık';

  @override
  String get themeDark => 'Karanlık';

  @override
  String get settingsDisclaimerTitle => 'Yasal uyarı';

  @override
  String get settingsDisclaimer =>
      'Vestra yatırım tavsiyesi vermez. Gösterilen fiyatlar gecikmeli olabilir ve yalnızca bilgi amaçlıdır.';

  @override
  String get portfolioTotalValue => 'Toplam değer';

  @override
  String get portfolioHoldings => 'Varlıklar';

  @override
  String get settingsSectionAppearance => 'Görünüm';

  @override
  String get settingsSectionAbout => 'Hakkında';

  @override
  String get settingsLicenses => 'Açık kaynak lisansları';
}
