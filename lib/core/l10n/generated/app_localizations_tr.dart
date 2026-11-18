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
      'Aşağı çekerek fiyatları güncelleyebilirsin.';

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

  @override
  String get marketSectionFx => 'Döviz';

  @override
  String get marketSectionMetals => 'Altın ve gümüş';

  @override
  String get marketSectionStocks => 'Hisseler';

  @override
  String marketLastUpdated(String time) {
    return 'Son güncelleme $time';
  }

  @override
  String get marketRefreshing => 'Güncelleniyor…';

  @override
  String get marketSourceBurkut => 'Bürküt · hisseler en az 15 dk gecikmeli';

  @override
  String get marketSourceFallback =>
      'Döviz: ECB günlük referans kuru (yedek kaynak)';

  @override
  String get marketNeedsKeyTitle =>
      'Altın, gümüş ve hisse için API anahtarı gerekli';

  @override
  String get marketNeedsKeyMessage =>
      'Döviz kurları ücretsiz yedek kaynaktan geliyor. Bürküt\'ten ücretsiz anahtar alıp Ayarlar\'a ekle.';

  @override
  String get marketGoToSettings => 'Ayarlara git';

  @override
  String get marketQuotaExhausted =>
      'Bu ayın Bürküt istek kotası doldu. Altın ve hisse fiyatları gelecek ay güncellenecek; döviz yedek kaynaktan geliyor.';

  @override
  String get marketKeyRejected =>
      'Bürküt API anahtarı reddedildi. Ayarlar\'dan kontrol et.';

  @override
  String get errorNetwork =>
      'İnternet bağlantısı yok. Son bilinen fiyatlar gösteriliyor.';

  @override
  String get errorRateLimit =>
      'Çok sık istek gönderildi, birazdan tekrar denenecek.';

  @override
  String get errorServer => 'Veri sağlayıcı şu an yanıt vermiyor.';

  @override
  String get errorStorage => 'Veriler okunamadı.';

  @override
  String get errorUnexpected => 'Beklenmeyen bir hata oluştu.';

  @override
  String get instrumentUSD => 'Amerikan Doları';

  @override
  String get instrumentEUR => 'Euro';

  @override
  String get instrumentGBP => 'İngiliz Sterlini';

  @override
  String get instrumentCHF => 'İsviçre Frangı';

  @override
  String get instrumentJPY => 'Japon Yeni';

  @override
  String get instrumentCAD => 'Kanada Doları';

  @override
  String get instrumentAUD => 'Avustralya Doları';

  @override
  String get instrumentDKK => 'Danimarka Kronu';

  @override
  String get instrumentSEK => 'İsveç Kronu';

  @override
  String get instrumentNOK => 'Norveç Kronu';

  @override
  String get instrumentSAR => 'Suudi Arabistan Riyali';

  @override
  String get instrumentGoldGram => 'Gram Altın';

  @override
  String get instrumentGoldQuarter => 'Çeyrek Altın';

  @override
  String get instrumentGoldHalf => 'Yarım Altın';

  @override
  String get instrumentGoldFull => 'Tam Altın';

  @override
  String get instrumentGoldRepublic => 'Cumhuriyet Altını';

  @override
  String get instrumentSilverGram => 'Gram Gümüş';

  @override
  String get settingsSectionData => 'Veri kaynağı';

  @override
  String get settingsApiKey => 'Bürküt API anahtarı';

  @override
  String settingsApiKeySet(String suffix) {
    return 'Kayıtlı · ••••$suffix';
  }

  @override
  String get settingsApiKeyNotSet =>
      'Ayarlanmadı · altın, gümüş ve hisse için gerekli';

  @override
  String get settingsQuota => 'Bu ayki istek kullanımı';

  @override
  String settingsQuotaValue(String used, String limit) {
    return '$used / $limit';
  }

  @override
  String get settingsQuotaExhausted => 'Kota doldu';

  @override
  String get settingsDataNote =>
      'Hisse verileri Borsa İstanbul kuralları gereği en az 15 dakika gecikmelidir. Bürküt lisanslı bir veri dağıtıcısı değildir. Fiyatlar hafta içi 10:00-18:00 arasında, uygulama açıkken 30 dakikada bir güncellenir.';

  @override
  String get apiKeySheetTitle => 'Bürküt API anahtarı';

  @override
  String get apiKeySheetHelp =>
      'burkutportfoy.com/developer adresinden ücretsiz hesap açıp anahtar oluşturabilirsin (ayda 1.000 istek). Anahtar yalnızca bu cihazda şifreli saklanır.';

  @override
  String get apiKeyFieldLabel => 'API anahtarı';

  @override
  String get apiKeySave => 'Doğrula ve kaydet';

  @override
  String get apiKeyDelete => 'Anahtarı sil';

  @override
  String get apiKeySaved => 'Anahtar doğrulandı ve kaydedildi';

  @override
  String get apiKeyDeleted => 'Anahtar silindi';

  @override
  String get apiKeyErrorEmpty => 'Anahtarı gir';

  @override
  String get apiKeyErrorMalformed => 'Anahtar biçimi geçersiz';

  @override
  String get apiKeyErrorRejected => 'Bürküt bu anahtarı kabul etmedi';

  @override
  String get apiKeyErrorQuota =>
      'Bu ayın kotası dolu olduğu için anahtar doğrulanamadı';

  @override
  String get apiKeyShow => 'Göster';

  @override
  String get apiKeyHide => 'Gizle';

  @override
  String get unitGram => 'gram';

  @override
  String get unitPiece => 'adet';

  @override
  String get exchangeBist => 'Borsa İstanbul';

  @override
  String get instrumentGoldAta => 'Ata Altın';
}
