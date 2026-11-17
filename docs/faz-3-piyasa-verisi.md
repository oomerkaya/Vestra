# Faz 3: Piyasa verisi

**Durum:** Kod bitti; **gerçek API anahtarıyla doğrulama bekliyor** (aşağıda "Doğrulanacaklar") · **Tarih:** 2026-11-17

## Özet

Uygulama artık döviz, altın, gümüş ve hisse fiyatlarını çekiyor, cihazdaki veritabanına yazıyor ve internet yokken son bilinen değerleri gösteriyor.

- **Birincil kaynak: Bürküt.** Hisse, döviz, altın ve gümüş verisi gelir. Her kullanıcı kendi ücretsiz anahtarını girer.
- **Yedek kaynak: Frankfurter.** Döviz için kullanılır; anahtar gerektirmez.
- **API anahtarı** cihazda şifreli saklanır.
- **Aylık kota** uygulama içinde sayılır.
- **Otomatik yenileme** hafta içi seans saatlerinde, uygulama açıkken 30 dakikada bir yapılır.

| Piyasa (aydınlık) | Piyasa (karanlık) | Ayarlar (karanlık) |
|---|---|---|
| ![](images/light_market.png) | ![](images/dark_market.png) | ![](images/dark_settings.png) |

Ekran görüntülerindeki fiyatlar **örnek veridir**; ekranı göstermek için önbelleğe elle yazıldı.

## Araştırma bulguları

| Konu | Bulgu | Kaynak |
|---|---|---|
| Frankfurter | 30 para birimi, **altın (XAU) ve gümüş (XAG) yok**. ECB günlük referans kuru; anahtarsız ve limitsiz. | `GET api.frankfurter.dev/v1/currencies` (canlı denendi) |
| Bürküt API adresi | `https://api.burkutportfoy.com/api/public/v1` | Resmi SDK `nodejs/src/client.ts` → `DEFAULT_BASE_URL` |
| Bürküt kimlik doğrulama | `X-API-Key: <anahtar>` başlığı. Anahtarsız istek `401 {"error":"UNAUTHORIZED"}` döner | SDK + canlı deneme |
| Bürküt uç noktaları | `GET /forex`, `/forex/{sym}`, `/gold`, `/gold/{sym}`, `/stocks?symbols=A,B`, `/stocks/{sym}` | SDK `resources/*.ts` |
| Yanıt biçimi | `{data: [...]}` ya da düz liste. Alanlar: döviz/altın `symbol, name, buying, selling, change_rate, time`; hisse `symbol, name, last_price, change_rate, time` | SDK `types.ts` |
| Hata kodları | 401 geçersiz anahtar, 403 yetki yok, 429 + `MONTHLY_QUOTA_EXCEEDED` aylık kota, 429 + `Retry-After` dakikalık limit | SDK `errors.ts`, `client.ts` |
| Ücretsiz plan | **Ayda 1.000 istek**, kredi kartı gerekmez. Dakikalık limit açıklanmamış | burkutportfoy.com/developers (SSS) |
| Gecikme / yasal durum | BIST verisi en az 15 dk gecikmeli. Bürküt lisanslı veri dağıtıcısı değildir; eğitim/kişisel kullanım amaçlıdır | PyPI `burkut` sayfası |
| Altın sembolleri | SDK örneklerinde yalnızca `ALTIN` (gram) ve `CEYREK_YENI` görünüyor. Diğerleri ve gümüş **doğrulanmadı** | SDK README, PyPI |

## Alınan kararlar

| Karar | Alternatif | Gerekçe |
|---|---|---|
| **Bürküt birincil, Frankfurter yalnızca döviz yedeği** | Döviz her zaman Frankfurter'dan | Kullanıcı tercihi. Tek tutarlı, gün içi güncellenen kaynak. Anahtar yoksa ya da kota dolmuşsa döviz yine güncellenir |
| **Otomatik yenileme 30 dk'da bir** (CLAUDE.md'deki 15 dk yerine) | 15 dk + %90'da durdurma | Kullanıcı tercihi. Yenileme başına en fazla 3 istek gidiyor; 15 dk'da bir ve gün boyu açık kullanımda ayda yaklaşık 2.100 istek eder ve kota aşılır |
| Döviz ve altında **alış (`buying`) fiyatı** kullanılır | Satış fiyatı, ortalama | Elindeki varlığı bugün satsan alacağın değer; portföy için temkinli değer |
| Yenileme sırası döviz → maden → hisse. Anahtar eksik/reddedilmiş ya da kota dolmuşsa kalan Bürküt çağrıları **atlanır** | Her kategoriyi ayrı denemek | Boşa istek (ve kota) harcanmaz |
| Anahtar yoksa ya da kota doluysa **istek hiç gönderilmez**, kontrol yerelde yapılır | İsteği gönderip 401/429 beklemek | Kota korunur |
| Kota sayacı uygulamanın kendi tahmini (`app_settings`, aylık). Sunucu "kota doldu" derse o geçerlidir | Sunucudan kota sorgulamak | Böyle bir uç nokta bulunamadı |
| Önbellek boşsa seans dışında da **bir kez** yenilenir | Seans dışında hiç yenilememek | İlk açılış hafta sonuna denk gelirse ekran boş kalmasın |
| Kota dolsa da otomatik yenileme durmaz | Tamamen durdurmak | Bürküt'e istek gitmez; döviz ücretsiz yedekten güncellenmeye devam eder |
| Saat dilimi sabit **UTC+3** | `timezone` paketi | Türkiye 2016'dan beri yaz saati uygulamıyor; paket eklemeye gerek yok |
| Tatil takvimi `assets/data/market_holidays.json` | Kodda sabit liste | CLAUDE.md kuralı; kod değişmeden güncellenebilir |
| `AssetType` `core/domain/instrument.dart`'a taşındı, `Instrument` bir Dart record | Portföy domain'inde bırakmak | Piyasa ve portföy ikisi de kullanıyor. Record yapısal eşitlik sağlıyor |
| `Failure` artık `Exception` uyguluyor | — | Riverpod stream'lerinde hata olarak fırlatılabilsin |

## Veritabanı: şema v2 (ilk migration)

`price_cache` tablosuna üç kolon eklendi: `name` (sağlayıcının verdiği ad), `change_percent` (günlük değişim, Decimal TEXT), `as_of` (sağlayıcının fiyat zamanı).

- [`app_database.dart`](../lib/core/database/app_database.dart): `schemaVersion = 2`, `onUpgrade: stepByStep(from1To2: ...)` ile üç `addColumn`.
- `drift_schemas/vestra/drift_schema_v2.json` ve `lib/core/database/app_database.steps.dart` üretildi.
- [`test/drift/vestra/migration_test.dart`](../test/drift/vestra/migration_test.dart):
  - v1 → v2 şemasının kodla birebir aynı olduğunu doğrular.
  - v1'de doldurulmuş varlık, işlem, fiyat ve ayar satırlarının v2'ye **kayıpsız** geçtiğini doğrular.

## Yapılanlar

### `core`

| Dosya | İçerik |
|---|---|
| `domain/instrument.dart` | `AssetType`, `Instrument` (record) |
| `error/failure.dart` | Yeni `QuotaExceededFailure`; `AuthFailure(missingKey)` ile "anahtar yok" ve "anahtar reddedildi" ayrımı; `Failure implements Exception` |
| `network/dio_factory.dart` | Zaman aşımları (bağlantı 10 sn, okuma 15 sn). **Loglama interceptor'ı yok**; başlıklarda anahtar var |
| `network/dio_failure_mapper.dart` | `DioException` → `Failure`. 429'u kota/limit diye ayırır, `Retry-After`'ı okur. Yanıt gövdesi mesaja kopyalanmaz |
| `l10n/failure_messages.dart` | Her `Failure` için Türkçe kullanıcı mesajı |
| `utils/formatters.dart` | `DateFormatters.shortDateTime` (`14:32` / `17.11 14:32`), `turkishUpperCase` |
| `widgets/instrument_avatar.dart` | Türe göre renkli kare avatar |
| `widgets/section_header.dart` | Artık Türkçe büyük harf kullanıyor ("HİSSELER") |

### Piyasa: domain (`lib/features/market/domain/`)

| Dosya | İçerik |
|---|---|
| `entities/quote.dart` | `Quote` (instrument, priceTry, source, fetchedAt, name?, changePercent?, asOf?), `QuoteSource`, `QuoteCategory` |
| `entities/quota_usage.dart` | Ay (`YYYY-MM`), kullanılan, limit (1.000), sunucunun "doldu" bayrağı |
| `entities/market_calendar.dart` | Kapalı günler ve yarım günler, JSON'dan okunur |
| `providers/price_providers.dart` | `FxRateProvider`, `MetalPriceProvider`, `StockPriceProvider` arayüzleri |
| `repositories/market_repository.dart` | `watchQuotes`, `refresh(stockSymbols)`, `quotaUsage`, `RefreshReport` |
| `services/refresh_policy.dart` | Saf kurallar: seans açık mı, otomatik yenileme zamanı geldi mi, backoff süresi |
| `usecases/refresh_prices.dart` | Portföyde **miktarı > 0 olan** hisseleri toplar, yenilemeyi tetikler |

**Yenileme kuralları (`RefreshPolicy`):**
- Seans hafta içi 10:00-18:00 (İstanbul); yarım günlerde 12:30'a kadar, tatillerde kapalı.
- Otomatik yenileme seans içinde, son yenilemeden en az 30 dk sonra yapılır. Önbellek boşsa her zaman yapılır.
- Backoff 1, 2, 4, 8, 16, 30, 30… dakika. Sunucunun `Retry-After` değeri daha uzunsa o kullanılır.
- Elle yenileme (aşağı çekme) seans saatine bakmaz.

### Piyasa: data (`lib/features/market/data/`)

| Dosya | İçerik |
|---|---|
| `datasources/burkut_remote_data_source.dart` | `/forex`, `/gold`, `/stocks?symbols=` (dio, `X-API-Key`) |
| `datasources/frankfurter_remote_data_source.dart` | `/latest?base=TRY&symbols=...` |
| `datasources/quota_local_data_source.dart` | Aylık sayaç (`app_settings` → `burkut_quota`, JSON) |
| `datasources/price_cache_local_data_source.dart` | Önbelleği izleme ve toplu upsert |
| `dto/json_parsing.dart`, `dto/burkut_dtos.dart` | Esnek JSON okuma: sayı ya da metin, virgüllü ondalık, `{data:[]}` ya da düz liste. Bozuk öğe atlanır |
| `mappers/burkut_symbols.dart` | Bürküt sembolü → Vestra enstrümanı. XAU/XAG/TRY döviz sayılmaz |
| `mappers/quote_mappers.dart` | `Quote` ↔ `price_cache` satırı. Bilinmeyen tür/kaynak satırları atlanır |
| `providers/burkut_price_provider.dart` | Üç fiyat arayüzü + `ApiKeyValidator`. Anahtar ve kota kontrolü, sayaç, hata eşleme |
| `providers/frankfurter_fx_provider.dart` | TRY bazlı kurları ters çevirir (`1 / oran`, 6 basamak) |
| `repositories/market_repository_impl.dart` | Döviz yedeği, atlama mantığı, önbelleğe yazma |

### Ayarlar

| Dosya | İçerik |
|---|---|
| `domain/repositories/api_key_repository.dart` | `ApiKeyRepository`, `ApiKeyValidator` |
| `domain/usecases/save_burkut_key.dart` | Boşlukları kırpar, biçimi kontrol eder (10-200 karakter, harf/rakam/`_`/`-`). Bürküt'e 1 istekle doğrulatır, sonra kaydeder |
| `data/repositories/api_key_repository_impl.dart` | `flutter_secure_storage` (Android Keystore). Hata nesnesi loglanmaz |
| `presentation/widgets/data_source_section.dart` | Anahtar durumu (son 4 karakter), kota çubuğu (ör. `312 / 1.000`), veri kaynağı notu |
| `presentation/widgets/api_key_sheet.dart` | Anahtar girişi (gizle/göster), "Doğrula ve kaydet", "Anahtarı sil", Türkçe hata mesajları |

### Sunum

- `market/presentation/price_refresh_controller.dart`:
  - Dakikada bir yenileme kurallarını kontrol eder.
  - Uygulama öne gelince (`AppLifecycleListener.onResume`) de kontrol eder; arka plandayken hiçbir şey yapmaz.
  - Hız limiti veya tam ağ kesintisinde backoff uygular.
  - `app.dart` uygulama boyunca canlı tutar.
- `market/presentation/market_screen.dart`:
  - Aşağı çekerek yenileme.
  - "Son güncelleme" ve kaynak satırı; yedek kaynak kullanılıyorsa belirtilir.
  - Anahtar yoksa "Ayarlara git" kartı; kota/ağ/anahtar sorunlarında bilgi kartı.
  - Döviz, Altın ve gümüş, Hisseler bölümleri.
- `market/presentation/widgets/quote_tile.dart`: avatar, ad, alt satır (kod / gram / adet / Borsa İstanbul), fiyat (10 TL altı 4 basamak), değişim hapı.
- `market/presentation/instrument_labels.dart`: Türkçe adlar ve sıralama (USD, EUR, GBP, gram, çeyrek, …).

## Güvenlik

- Anahtar yalnızca `flutter_secure_storage`'da durur; DB'de, logda, testte ve kodda yok. Testlerde sahte anahtar ve sahte yanıt kullanıldı.
- dio'da loglama yok. Hata mesajlarına yanıt gövdesi kopyalanmaz.
- Ayarlar ekranında anahtarın yalnızca son 4 karakteri görünür.

## Testler

Toplam **97 test**, hepsi geçti (Faz 2 sonunda 52).

| Dosya | Kapsam |
|---|---|
| `test/features/market/domain/refresh_policy_test.dart` | Seans saatleri, İstanbul saati, hafta sonu, tatil, yarım gün, 30 dk aralık, önbellek boşken yenileme, backoff dizisi ve `Retry-After`, takvim JSON'u |
| `test/features/market/data/parsing_and_errors_test.dart` | Decimal/tarih/liste okuma, DTO'lar, `DioException` → `Failure` (ağ, 401/403, kota, limit + `Retry-After`, 5xx) |
| `test/features/market/data/providers_test.dart` | Bürküt eşleme ve alış fiyatı. Anahtarsız ya da kota doluyken istek gitmemesi, sunucu kota yanıtında sayacın kilitlenmesi, toplu hisse isteği, `validate`, Frankfurter ters çevirme, aylık sayaç sıfırlanması |
| `test/features/market/data/market_repository_impl_test.dart` | Normal akış, anahtar yokken yedek kaynak ve atlama, ağ hatasında devam, hisse yoksa çağrı yok, önbellek güncelleme, her şey başarısızken eski önbelleğin korunması |
| `test/features/settings/save_burkut_key_test.dart` | Kırpma ve kaydetme, boş/bozuk biçimde ağa gitmeme, reddedilen anahtarı saklamama |
| `test/drift/vestra/migration_test.dart` | v1 → v2 şema ve veri bütünlüğü |
| `test/core/formatters_test.dart` | `turkishUpperCase` eklendi |

## Doğrulama

| Komut | Sonuç |
|---|---|
| `dart format --set-exit-if-changed lib test` | Temiz |
| `flutter analyze` | No issues found |
| `flutter test` | 97/97 |
| `flutter build apk --debug` | Başarılı |
| Canlı: `GET api.frankfurter.dev/v1/latest?base=TRY&symbols=...` | Beklenen biçim; USD = 1 / 0,019836 ≈ ₺50,41 |
| Canlı: `GET api.burkutportfoy.com/api/public/v1/gold` (anahtarsız) | `401 UNAUTHORIZED`; adres ve hata biçimi doğru |

## Doğrulanacaklar (gerçek anahtarla, Faz 4'ten önce)

1. `/gold` yanıtındaki gerçek semboller: `YARIM_YENI`, `TAM_YENI`, `ATA_YENI` ve **gümüş** (`GUMUS`?) gerçekten var mı? Gerekirse [`burkut_symbols.dart`](../lib/features/market/data/mappers/burkut_symbols.dart) güncellenecek.
2. `change_rate` yüzde mi (1,27) yoksa oran mı (0,0127)?
3. `time` alanının biçimi.
4. `/forex`'te hangi para birimleri var?
5. Yanıt `{data: [...]}` mi, düz liste mi? İkisi de destekleniyor, yine de teyit edilecek.

## Bilinen eksikler / sonraki faza devredilenler

- Portföy değerlemesi (miktar × güncel fiyat) ve kâr/zarar Faz 4'te.
- Fiyatı olmayan varlıklarda (ör. anahtar yokken altın) "fiyat yok" gösterimi Faz 4'te.
- Tatil takvimi 2026-2027'yi kapsıyor; her yıl Borsa İstanbul duyurusuyla güncellenmeli (Faz 5 README notu).
- Bürküt'ün kota yenileme günü bilinmiyor; uygulama takvim ayını esas alıyor.
