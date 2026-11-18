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
      'Fiyatlar ilk güncellemeden sonra burada görünür.';

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
      'Döviz ve altın/gümüş fiyatları uygulama açıkken 30 dakikada bir güncellenir. Hisseler yalnızca hafta içi 10:00-18:00 arasında güncellenir ve Borsa İstanbul kuralları gereği en az 15 dakika gecikmelidir. Ekranı aşağı çekmek bu süreleri kısaltmaz. Bürküt lisanslı bir veri dağıtıcısı değildir.';

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

  @override
  String get instrumentAED => 'BAE Dirhemi';

  @override
  String get instrumentAZN => 'Azerbaycan Manatı';

  @override
  String get instrumentCNY => 'Çin Yuanı';

  @override
  String get instrumentKRW => 'Güney Kore Wonu';

  @override
  String get instrumentKWD => 'Kuveyt Dinarı';

  @override
  String get instrumentKZT => 'Kazakistan Tengesi';

  @override
  String get instrumentPKR => 'Pakistan Rupisi';

  @override
  String get instrumentQAR => 'Katar Riyali';

  @override
  String get instrumentRON => 'Rumen Leyi';

  @override
  String get instrumentRUB => 'Rus Rublesi';

  @override
  String get marketTabFx => 'Döviz';

  @override
  String get marketTabMetals => 'Madenler';

  @override
  String get marketTabStocks => 'Borsa';

  @override
  String marketNextUpdate(String time) {
    return 'Sonraki güncelleme $time';
  }

  @override
  String get marketNotUpdatedYet => 'Henüz güncellenmedi';

  @override
  String get marketUpdateRule => '30 dakikada bir güncellenir';

  @override
  String get marketStocksRule =>
      'Hafta içi 10:00-18:00 arasında, 30 dakikada bir güncellenir';

  @override
  String get marketSessionClosed => 'Borsa şu an kapalı';

  @override
  String marketUpToDate(String time) {
    return 'Veriler güncel · sonraki güncelleme $time';
  }

  @override
  String get marketStocksEmptyTitle => 'Portföyünde hisse yok';

  @override
  String get marketStocksEmptyMessage =>
      'Portföye hisse eklediğinde fiyatları burada görünür.';

  @override
  String get marketExchangeBist => 'BIST';
}
