// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Capira';

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
      'Capira yatırım tavsiyesi vermez. Gösterilen fiyatlar gecikmeli olabilir ve yalnızca bilgi amaçlıdır.';

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
  String get marketDataDelayed => 'Veriler gecikmelidir';

  @override
  String get marketNeedsKeyTitle => 'Fiyatlar için API anahtarı gerekli';

  @override
  String get marketNeedsKeyMessage => 'Ayarlar\'dan API anahtarını ekle.';

  @override
  String get marketGoToSettings => 'Ayarlara git';

  @override
  String get marketQuotaExhausted =>
      'Bu ayın istek kotası doldu. Fiyatlar gelecek ay güncellenecek.';

  @override
  String get marketKeyRejected =>
      'API anahtarı kabul edilmedi. Ayarlar\'dan kontrol et.';

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
  String get settingsApiKeyNotSet => 'Ayarlanmadı · fiyatlar için gerekli';

  @override
  String get settingsQuota => 'Bu ayki istek kullanımı';

  @override
  String settingsQuotaValue(String used, String limit) {
    return '$used / $limit';
  }

  @override
  String get settingsQuotaExhausted => 'Kota doldu';

  @override
  String settingsQuotaReset(String date) {
    return '$date tarihinde yenilenir';
  }

  @override
  String get settingsDataNote =>
      'API anahtarını burkutportfoy.com/developer adresinden ücretsiz alabilirsin. Capira resmi bir Bürküt uygulaması değildir.';

  @override
  String get apiKeySheetTitle => 'Bürküt API anahtarı';

  @override
  String get apiKeySheetHelp =>
      'Anahtarı burkutportfoy.com/developer adresinden ücretsiz alabilirsin. Yalnızca bu cihazda şifreli saklanır.';

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
  String get apiKeyErrorRejected => 'Anahtar kabul edilmedi';

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
  String get marketUpdateRule => 'Saatte bir güncellenir';

  @override
  String get marketStocksRule =>
      'Hafta içi 10:00-18:00 arasında, saatte bir güncellenir';

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

  @override
  String get portfolioAddAsset => 'Varlık ekle';

  @override
  String get portfolioPnl => 'Kâr/zarar';

  @override
  String get portfolioToday => 'Bugün';

  @override
  String get portfolioAllocation => 'Dağılım';

  @override
  String get portfolioNoPrice => 'Fiyat yok';

  @override
  String get portfolioCostUnknown => 'Maliyet bilinmiyor';

  @override
  String get categoryFx => 'Döviz';

  @override
  String get categoryMetals => 'Altın ve gümüş';

  @override
  String get categoryStocks => 'Borsa';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get txTitleAdd => 'Varlık ekle';

  @override
  String get txTitleEdit => 'İşlemi düzenle';

  @override
  String get txTitleBuy => 'Alım ekle';

  @override
  String get txTitleSell => 'Satış ekle';

  @override
  String get txType => 'Tür';

  @override
  String get txInstrument => 'Varlık';

  @override
  String get txSelectInstrument => 'Varlık seç';

  @override
  String get txKindBuy => 'Alım';

  @override
  String get txKindSell => 'Satış';

  @override
  String get txQuantity => 'Miktar';

  @override
  String get txUnitPrice => 'Birim fiyat (TL)';

  @override
  String get txUnitPriceHelp => 'Bilmiyorsan boş bırakabilirsin';

  @override
  String get txPriceFilled => 'Güncel fiyatla dolduruldu';

  @override
  String get txDate => 'Tarih';

  @override
  String get txNote => 'Not (isteğe bağlı)';

  @override
  String get txDelete => 'İşlemi sil';

  @override
  String get txDeleteConfirmTitle => 'İşlem silinsin mi?';

  @override
  String get txDeleteConfirmMessage => 'Bu işlem kalıcı olarak silinir.';

  @override
  String get txErrorQuantity => 'Geçerli bir miktar gir';

  @override
  String get txErrorPriceFormat => 'Geçerli bir fiyat gir';

  @override
  String get txErrorPrice => 'Fiyat negatif olamaz';

  @override
  String get txErrorOversell =>
      'Bu tarihte elindeki miktardan fazla satamazsın; önceki bir alım silinirse ya da azalırsa da olmaz';

  @override
  String get txErrorInstrument => 'Bir varlık seç';

  @override
  String get txSaved => 'İşlem kaydedildi';

  @override
  String get txDeleted => 'İşlem silindi';

  @override
  String get pickerTitle => 'Varlık seç';

  @override
  String get pickerSearchStocks => 'Hisse ara (ör. THYAO)';

  @override
  String get pickerStockListUnavailable =>
      'Hisse listesi için API anahtarı gerekli. Sembolü elle yazabilirsin.';

  @override
  String get pickerNoResults => 'Sonuç yok';

  @override
  String get assetDetailTransactions => 'İşlemler';

  @override
  String get assetDetailQuantity => 'Miktar';

  @override
  String get assetDetailAvgCost => 'Ortalama maliyet';

  @override
  String get assetDetailValue => 'Güncel değer';

  @override
  String get assetDetailRealized => 'Gerçekleşen kâr/zarar';

  @override
  String get assetDetailBuy => 'Alım ekle';

  @override
  String get assetDetailSell => 'Satış ekle';

  @override
  String get assetDelete => 'Varlığı sil';

  @override
  String get assetDeleteConfirmTitle => 'Varlık silinsin mi?';

  @override
  String get assetDeleted => 'Varlık silindi';

  @override
  String get assetNotFound => 'Varlık bulunamadı';

  @override
  String portfolioMissingPrices(String count) {
    return '$count varlığın güncel fiyatı yok; toplama dahil edilmedi.';
  }

  @override
  String holdingQuantityAvg(String quantity, String cost) {
    return '$quantity · ort. $cost';
  }

  @override
  String pickerUseSymbol(String symbol) {
    return '\"$symbol\" sembolünü kullan';
  }

  @override
  String assetDeleteConfirmMessage(String name) {
    return '$name ve tüm işlemleri kalıcı olarak silinir.';
  }

  @override
  String txLine(String quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get marketSectionMine => 'Portföyümde';

  @override
  String get marketSectionAll => 'Tümü';

  @override
  String get marketNoHoldingsInCategory =>
      'Bu kategoride portföyünde varlık yok.';

  @override
  String marketCount(String count) {
    return '$count';
  }

  @override
  String get marketSearchStocks => 'Hisse ara (sembol veya ad)';

  @override
  String marketShowMore(String count) {
    return '$count hisse daha göster';
  }

  @override
  String get marketStocksNotLoaded =>
      'Hisse fiyatları ilk güncellemeyle gelir.';

  @override
  String get marketTabFunds => 'Fonlar';

  @override
  String get categoryFunds => 'Fonlar';

  @override
  String get unitShare => 'pay';

  @override
  String get marketFundsRule =>
      'Hafta içi 10:00-18:00 arasında, günde bir kez güncellenir';

  @override
  String get marketSearchFunds => 'Fon ara (kod veya ad)';

  @override
  String get marketFundsNotLoaded => 'Fon listesi ilk güncellemeyle gelir.';

  @override
  String get kapAssetSectionTitle => 'Son KAP bildirimleri';

  @override
  String get kapNone => 'Son 30 günde kayıtlı bildirim yok.';

  @override
  String get kapAssetFooter => 'Son 30 gün · Günde bir kez güncellenir.';

  @override
  String get kapOpenOnKap => 'Bildirimi KAP\'ta aç';

  @override
  String get linkOpenFailed => 'Bağlantı açılamadı.';

  @override
  String get kapScreenTitle => 'KAP bildirimleri';

  @override
  String get kapIconTooltip => 'KAP bildirimleri';

  @override
  String get kapFilterAll => 'Tümü';

  @override
  String get kapEmptyTitle => 'Henüz bildirim yok';

  @override
  String get kapEmptyMessage =>
      'Bildirimler günde bir kez güncellenir ve 30 gün saklanır.';

  @override
  String get kapScreenFooter =>
      'Portföydeki hisselerin son 30 günlük bildirimleri. Günde bir kez güncellenir.';

  @override
  String get kapNewBadge => 'KAP';

  @override
  String get kapNewBadgeSemantics => 'Son 24 saatte KAP bildirimi var';

  @override
  String get assetDetailPrice => 'Güncel fiyat';

  @override
  String get assetDetailDailyChange => 'Günlük değişim';

  @override
  String get assetDetailUpdated => 'Son güncelleme';

  @override
  String portfolioPricesAsOf(String time) {
    return 'Son fiyat güncellemesi: $time';
  }

  @override
  String get portfolioKeyTitle => 'Fiyatlar için API anahtarı gerekli';

  @override
  String get portfolioKeyMessage =>
      'Güncel fiyatlar ve KAP bildirimleri için Ayarlar\'dan API anahtarını ekle.';

  @override
  String get portfolioKeyAction => 'Ayarlara git';

  @override
  String get allocationByCategory => 'Tür';

  @override
  String get allocationByAsset => 'Varlık';

  @override
  String get allocationOther => 'Diğer';

  @override
  String get settingsSectionBackup => 'Yedekleme';

  @override
  String get backupExport => 'Portföyü dışa aktar';

  @override
  String get backupExportHint => 'Varlıklar ve işlemler tek dosyaya kaydedilir';

  @override
  String get backupImport => 'Yedekten geri yükle';

  @override
  String get backupImportHint =>
      'Mevcut portföyün yerine yedektekiler yüklenir';

  @override
  String get backupNote => 'Yedekte fiyatlar ve API anahtarı bulunmaz.';

  @override
  String get backupEmpty => 'Portföy boş; yedeklenecek bir şey yok.';

  @override
  String get backupExportFailed => 'Yedek oluşturulamadı.';

  @override
  String get backupShareSubject => 'Capira portföy yedeği';

  @override
  String get backupRestoreConfirmTitle => 'Yedek geri yüklensin mi?';

  @override
  String backupRestoreConfirmMessage(
    String date,
    String assets,
    String transactions,
  ) {
    return '$date tarihli yedekte $assets varlık ve $transactions işlem var. Mevcut portföyün silinip yerine bunlar yüklenecek.';
  }

  @override
  String get backupRestoreAction => 'Geri yükle';

  @override
  String get backupRestored => 'Yedek geri yüklendi';

  @override
  String get backupRestoreFailed =>
      'Yedek geri yüklenemedi; portföyün değişmedi.';

  @override
  String get backupErrorNotABackup => 'Bu dosya bir Capira yedeği değil.';

  @override
  String get backupErrorNewer =>
      'Bu yedek daha yeni bir Capira sürümüyle oluşturulmuş. Önce uygulamayı güncelle.';

  @override
  String get backupErrorInvalid =>
      'Yedek dosyası bozuk ya da tutarsız; portföyün değişmedi.';

  @override
  String get errorLoadTitle => 'Veriler okunamadı';

  @override
  String get errorLoadMessage =>
      'Telefondaki kayıtlara erişilemedi. Uygulamayı kapatıp yeniden aç.';

  @override
  String get displayCurrencyLabel => 'Para birimi';

  @override
  String portfolioConvertedAt(String symbol, String rate) {
    return 'Güncel kurla çevrildi · 1 $symbol = $rate';
  }

  @override
  String get privacyHide => 'Tutarları gizle';

  @override
  String get privacyShow => 'Tutarları göster';

  @override
  String get historyTitle => 'Değer geçmişi';

  @override
  String get historyRangeWeek => '1 hafta';

  @override
  String get historyRangeMonth => '1 ay';

  @override
  String get historyRangeQuarter => '3 ay';

  @override
  String get historyRangeYear => '1 yıl';

  @override
  String get historyRangeAll => 'Tümü';

  @override
  String get historyEmpty =>
      'Grafik, uygulamayı açtığın her gün kaydedilen değerlerle oluşur. Birkaç gün sonra burada görünecek.';

  @override
  String get historyNote =>
      'Uygulamanın açıldığı günlerin değeri kaydedilir. Alım ve satımlar da değeri değiştirir.';

  @override
  String historyChartLabel(String from, String to) {
    return 'Portföy değeri grafiği, $from ile $to arası';
  }

  @override
  String get summaryTitle => 'Özet';

  @override
  String get summaryWeek => 'Son 7 gün';

  @override
  String get summaryMonth => 'Son 30 gün';

  @override
  String get summaryMarketEffect => 'Piyasa etkisi';

  @override
  String get summaryChange => 'Toplam değişim';

  @override
  String get summaryNetInvested => 'Alım/satım';

  @override
  String get summaryBest => 'En çok yükselen';

  @override
  String get summaryWorst => 'En çok düşen';

  @override
  String summarySince(String date) {
    return 'Kayıtlar $date tarihinden beri tutuluyor.';
  }

  @override
  String get summaryEmpty =>
      'Özet için önceki günlerin değeri gerekiyor; uygulamayı yarın açtığında burada olacak.';
}
